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

---@class Section
---@field endAction string The name of the action that, when reached in playback, ends this section
---@field timeout integer The maximum number of frames this section goes on for
---@field tasState table The TAS state to apply for the entire duration of this section - note that arctan straining will refer to timeout for its length
---@field joy table The joypad data, that is, pressed buttons and joystick values.
local __clsSection = {}

local function NewSection(endAction, timeout)
    local tmp = {}
    CloneInto(tmp, Joypad.input)
    ---@type Section
    return {
        endAction = endAction,
        timeout = timeout,
        tasState = NewTASState(),
        joy = tmp,
    }
end

---@class Selection
---@field public startIndex integer The 1-based index of the section that was clicked to begin creating this selection, which may be greater than endIndex
---@field public endIndex integer The 1-based index of the section on which this selection's range was ended, which may be less than startIndex
local __clsSelection = {}

local function NewSelection(state, sectionIndex)
    return {
        state = state,
        startIndex = sectionIndex,
        endIndex = sectionIndex,
        min = __clsSelection.min,
        max = __clsSelection.max,
    }
end

---The smaller value of startIndex and endIndex
function __clsSelection:min() return math.min(self.startIndex, self.endIndex) end

---The greater value of startIndex and endIndex
function __clsSelection:max() return math.max(self.startIndex, self.endIndex) end

---@class Sheet
---@field public previewIndex integer The 1-based index of the section to which to advance to when changes to the piano roll have been made.
---@field public editingIndex integer The 1-based index of the section of this piano roll that is currently being edited.
---@field public selection Selection | nil A single selection range for which to apply changes in the joystick gui to.
---@field public sections table An array of TASStates with their associated section definition to execute in order.
---@field public name string A name for the piano roll for convenience.
---@field private _sectionIndex integer The nth section that is currently being played
local __clsSheet = {}

local function NewSheet(name)
    local globalTimer = Memory.current.mario_global_timer

    ---@type Sheet
    local newInstance = {
        startGT = globalTimer,
        previewIndex = 1,
        editingIndex = 1,
        selection = nil,
        sections = { NewSection("idle", 150) },
        name = name,
        _savestateFile = name .. ".tmp.savestate",
        _oldTASState = {},
        _oldClock = 0,
        _busy = false,
        _updatePending = false,
        _rebasing = false,
        _sectionIndex = 1,
        numSections = __clsSheet.numSections,
        currentSection = __clsSheet.currentSection,
        edit = __clsSheet.edit,
        update = __clsSheet.update,
        jumpTo = __clsSheet.jumpTo,
        rebase = __clsSheet.rebase,
        save = __clsSheet.save,
        load = __clsSheet.load,
    }
    savestate.savefile(newInstance._savestateFile)
    return newInstance
end

function __clsSheet:numSections() return #self.sections end

function __clsSheet:currentSection() return self.sections[self._sectionIndex] end

function __clsSheet:edit(sectionIndex)
    self.editingIndex = sectionIndex
    self._oldClock = os.clock()
end

function __clsSheet:jumpTo(targetIndex, loadState)
    if self._busy then
        self._updatePending = true
        return
    end
    if self:numSections() == 0 then return end
    self.previewIndex = targetIndex
    self._busy = true
    self._updatePending = false

    if loadState == nil and true or loadState then
        savestate.loadfile(self._savestateFile)
        print("loading file \"" .. self._savestateFile .. "\"")
    end
    emu.pause(true)
    local previousTASState = TASState
    local was_ff = emu.get_ff()
    emu.set_ff(true)

    self._sectionIndex = 1
    local frameCounter = 0
    local runUntilSelected
    runUntilSelected = function()
        TASState = previousTASState
        local section = self.sections[self._sectionIndex]
        local tasState = section.tasState
        tasState.preview_action = Memory.current.mario_action
        frameCounter = frameCounter + 1
        if frameCounter >= section.timeout or Locales.raw().ACTIONS[Memory.current.mario_action] == section.endAction then
            self._sectionIndex = self._sectionIndex + 1
            frameCounter = 0
        end
        if self._sectionIndex > self.previewIndex then
            emu.pause(false)
            emu.set_ff(was_ff)
            emu.atinput(runUntilSelected, true)
            self._busy = false
        end
    end
    emu.atinput(runUntilSelected)
end

function __clsSheet:save(file)
    local savestateFile = file .. ".savestate"
    if self._savestateFile ~= savestateFile and CopyFile(self._savestateFile, savestateFile) then
        self._savestateFile = savestateFile
    end

    persistence.store(
        file,
        {
            sections     = self.sections,
            name         = self.name,
            startGT      = self.startGT,
            editingIndex = self.editingIndex,
            previewIndex = self.previewIndex,
        }
    )
end

function __clsSheet:load(file, setStFile)
    local contents = persistence.load(file);
    if contents ~= nil then
        if setStFile then self._savestateFile = file .. ".savestate" end
        CloneInto(self, contents)
    end
end

function __clsSheet:update()
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

function __clsSheet:rebase(path)
    if CopyFile(path, self._savestateFile) then
        self._rebasing = true
        self:jumpTo(self.previewIndex)
        print("rebased \"" .. self.name .. "\" onto \"" .. path .. "\"")
    end
end

return
{ new = NewSection },
{ new = NewSheet },
{ new = NewSelection }