---@class Selection
---@field public startIndex integer The 0-based index of the frame that was clicked to begin creating this selection, which may be greater than endIndex
---@field public endIndex integer The 0-based index of the frame on which this selection's range was ended, which may be less than startIndex
local __clsSelection = {}

function __clsSelection.new(state, frameNumber)
    return {
        state = state,
        startIndex = frameNumber,
        endIndex = frameNumber,
        min = __clsSelection.min,
        max = __clsSelection.max,
    }
end

---The smaller value of startIndex and endIndex
function __clsSelection:min() return math.min(self.startIndex, self.endIndex) end

---The greater value of startIndex and endIndex
function __clsSelection:max() return math.max(self.startIndex, self.endIndex) end

local function CopyFile(srcPath, destPath)
    local infile = io.open(srcPath, "rb")
    local outfile = io.open(destPath, "wb")
    if (infile == nil or outfile == nil) then
        print("Failed to copy \"" .. srcPath .. "\" to \"" .. destPath .. "\"")
        return false
    end
    outfile:write(infile:read("a"))
    infile:close()
    outfile:close()
    return true
end


---@class PianoRoll
---@field public previewIndex integer The 0-based index of the to which to advance to when changes to the piano roll have been made.
---@field public startGT integer The global timer value indicating the inclusive start of this piano roll.
---@field public editingIndex integer The 0-based index of the frame of this piano roll that is currently being edited.
---@field public selection Selection | nil A single selection range for which to apply changes in the joystick gui to.
---@field public frames table An array of TASStates to execute per global timer increment after startGT.
---@field public name string A name for the piano roll for convenience.
local __clsPianoRoll = {}

---@return PianoRoll result Creates a new PianoRoll starting at the current global timer value
function __clsPianoRoll.new(name)
    local globalTimer = Memory.current.mario_global_timer

    ---@type PianoRoll
    local newInstance = {
        startGT = globalTimer,
        previewIndex = 0,
        editingIndex = 0,
        selection = nil,
        frames = {},
        name = name,
        _savestateFile = name .. ".tmp.savestate",
        _oldTASState = {},
        _oldClock = 0,
        _busy = false,
        _updatePending = false,
        _rebasing = false,
        numFrames = __clsPianoRoll.numFrames,
        edit = __clsPianoRoll.edit,
        update = __clsPianoRoll.update,
        jumpTo = __clsPianoRoll.jumpTo,
        trimEnd = __clsPianoRoll.trimEnd,
        rebase = __clsPianoRoll.rebase,
        save = __clsPianoRoll.save,
        load = __clsPianoRoll.load,
    }
    savestate.savefile(newInstance._savestateFile)
    return newInstance
end

function __clsPianoRoll:numFrames() return self.frames[0] ~= nil and #self.frames + 1 or 0 end

function __clsPianoRoll:edit(frameIndex)
    self.editingIndex = frameIndex
    TASState = self.frames[frameIndex] or TASState
    self._oldClock = os.clock()
end

function __clsPianoRoll:jumpTo(targetIndex)
    if self._busy then
        self._updatePending = true
        return
    end
    if self:numFrames() == 0 then return end
    self.previewIndex = targetIndex
    self._busy = true
    self._updatePending = false

    savestate.loadfile(self._savestateFile)
    print("loading file \"" .. self._savestateFile .. "\"")
    emu.pause(true)
    local previousTASState = TASState
    local was_ff = emu.get_ff()
    emu.set_ff(true)
    local runUntilSelected
    runUntilSelected = function()
        TASState = previousTASState
        local globalTimer = memory.readdword(Addresses[Settings.address_source_index].global_timer)
        local frame = self.frames[globalTimer - self.startGT]
        frame.preview_joystick_x = Joypad.input.X
        frame.preview_joystick_y = Joypad.input.Y
        if globalTimer >= self.startGT + self.previewIndex then
            emu.pause(false)
            emu.set_ff(was_ff)
            emu.atinput(runUntilSelected, true)
            self._busy = false
        end
    end
    emu.atinput(runUntilSelected)
end

function __clsPianoRoll:save(file)
    local savestateFile = file .. ".savestate"
    if self._savestateFile ~= savestateFile and CopyFile(self._savestateFile, savestateFile) then
        self._savestateFile = savestateFile
    end

    persistence.store(
        file,
        {
            frames      = self.frames,
            name        = self.name,
            startGT     = self.startGT,
            editingIndex   = self.editingIndex,
            previewIndex   = self.previewIndex,
        }
    )
end

function __clsPianoRoll:load(file, setStFile)
    local contents = persistence.load(file);
    if contents ~= nil then
        if setStFile then self._savestateFile = file .. ".savestate" end
        CloneInto(self, contents)
    end
end

function __clsPianoRoll:update()
    local anyChange = CloneInto(self._oldTASState, TASState)
    local now = os.clock()
    if anyChange then
        self._oldClock = now
        self._updatePending = true
    elseif self._updatePending then
        self._oldClock = now
        self:jumpTo(self.previewIndex)
    end
end

function __clsPianoRoll:trimEnd()
    self.frames = table.move(self.frames, 0, self.previewIndex, 0, {})
end

function __clsPianoRoll:rebase(path)
    if CopyFile(path, self._savestateFile) then
        self._rebasing = true
        self:jumpTo(self.previewIndex)
        print("rebased \"" .. self.name .. "\" onto \"" .. path .. "\"")
    end
end

return {
    new = __clsPianoRoll.new
},
{
    new = __clsSelection.new
}