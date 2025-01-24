---@class Selection
---@field public startGT integer The global timer value of the frame that was clicked to begin creating this selection, which may be greater than endGT
---@field public endGT integer The global timer value of the frame on which this selection's range was ended, which may be less than startGT
local __clsSelection = {}

function __clsSelection.new(state, globalTimer)
    return {
        state = state,
        startGT = globalTimer,
        endGT = globalTimer,
        min = __clsSelection.min,
        max = __clsSelection.max,
    }
end

---The smaller value of startGT and endGT
function __clsSelection:min() return math.min(self.startGT, self.endGT) end

---The greater value of startGT and endGT
function __clsSelection:max() return math.max(self.startGT, self.endGT) end


---@class PianoRoll
---@field public previewGT integer The global timer value to which to advance to when changes to the piano roll have been made.
---@field public startGT integer The global timer value indicating the inclusive start of this piano roll.
---@field public editingGT integer The global timer value indicating the frame of this piano roll that is currently being edited.
---@field public endGT integer The global timer value indicating the exclusive end of this piano roll.
---@field public selection Selection | nil A single selection range for which to apply changes in the joystick gui to.
---@field public frames table A table mapping from global timer values to the respective intended inputs and TASState.
---@field public name string A name for the piano roll for convenience.
local __clsPianoRoll = {}

---@return PianoRoll result Creates a new PianoRoll starting at the current global timer value
function __clsPianoRoll.new(name)
    local globalTimer = Memory.current.mario_global_timer

    ---@type PianoRoll
    local newInstance = {
        startGT = globalTimer,
        endGT = globalTimer,
        previewGT = globalTimer,
        editingGT = globalTimer,
        selection = nil,
        frames = {},
        name = name,
        _savestateFile = name .. ".tmp.savestate",
        _oldTASState = {},
        _oldClock = 0,
        _busy = false,
        _updatePending = false,
        numFrames = __clsPianoRoll.numFrames,
        edit = __clsPianoRoll.edit,
        update = __clsPianoRoll.update,
        jumpTo = __clsPianoRoll.jumpTo,
        trimEnd = __clsPianoRoll.trimEnd,
        save = __clsPianoRoll.save,
        load = __clsPianoRoll.load,
    }
    savestate.savefile(newInstance._savestateFile)
    return newInstance
end

function __clsPianoRoll:numFrames() return self.endGT - self.startGT end

function __clsPianoRoll:edit(globalTimerTarget)
    self.editingGT = globalTimerTarget
    TASState = self.frames[globalTimerTarget] or TASState
    self._oldClock = os.clock()
end

function __clsPianoRoll:jumpTo(globalTimerTarget)
    if self._busy then
        self._updatePending = true
        return
    end
    if self.endGT == self.startGT then return end
    self.previewGT = globalTimerTarget
    self._busy = true
    self._updatePending = false

    savestate.loadfile(self._savestateFile)
    emu.pause(true)
    local previousTASState = TASState
    local was_ff = emu.get_ff()
    emu.set_ff(true)
    local runUntilSelected
    runUntilSelected = function()
        TASState = previousTASState
        local globalTimer = memory.readdword(Addresses[Settings.address_source_index].global_timer)
        local frame = self.frames[globalTimer]
        frame.preview_joystick_x = Joypad.input.X
        frame.preview_joystick_y = Joypad.input.Y
        if globalTimer >= self.previewGT then
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
    if self._savestateFile ~= savestateFile then
        local infile = io.open(self._savestateFile, "rb")
        local outfile = io.open(savestateFile, "wb")
        if (infile == nil or outfile == nil) then
            print("Failed to copy savestate for " .. self.name)
            return
        end
        outfile:write(infile:read("a"))
        infile:close()
        outfile:close()
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

function __clsPianoRoll:load(file)
    local contents = persistence.load(file);
    if contents ~= nil then
        self._savestateFile = file .. ".savestate"
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
        self:jumpTo(self.previewGT)
    end
end

function __clsPianoRoll:trimEnd()
    for k, _ in pairs(self.frames) do
        if k > self.previewGT then
            self.frames[k] = nil
        end
    end
    self.endGT = self.previewGT + 1
end

return {
    new = __clsPianoRoll.new
},
{
    new = __clsSelection.new
}