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

---@class SectionInputs
---@field tasState table TAS states to derive the control stick inputs from - note that arctan straining will refer to the section's timeout for its length
---@field joy table The joypad data, that is, pressed buttons and joystick values.
---@field editing boolean Whether the input is selected for editing.
local __clsSectionInputs = {}

---@class Section
---@field endAction string The name of the action that, when reached in playback, ends this section
---@field timeout integer The maximum number of frames this section goes on for
---@field inputs SectionInputs[] The TAS states and button presses for the earliest frames of this section. If the segment as longer than this array, its last element being held out until the end of this section.
---@field collapsed boolean Whether the section's earliest inputs should be hidden in the FrameListGui
local __clsSection = {}

local function NewSection(endAction, timeout)
    local tmp = {}
    local tmp2 = {}
    CloneInto(tmp, Joypad.input)
    ---@type Section
    return {
        endAction = endAction,
        timeout = timeout,
        inputs = { { tasState = NewTASState(), joy = tmp, } },
        collapsed = false,
    }
end

---@class Sheet
---@field public previewIndex integer The 1-based index of the section to which to advance to when changes to the piano roll have been made.
---@field public previewSubIndex integer The 1-based index of the previewed section's frame to which to advance to when changes to the piano roll have been made.
---@field public editingIndex integer The 1-based index of the section of this piano roll that is currently being edited.
---@field public editingSubIndex integer The 1-based index of the edited section's frame that is currently being edited.
---@field public sections Section[] An array of TASStates with their associated section definition to execute in order.
---@field public name string A name for the piano roll for convenience.
---@field private _sectionIndex integer The nth section that is currently being played
local __clsSheet = {}

local function NewSheet(name)
    local globalTimer = Memory.current.mario_global_timer

    ---@type Sheet
    local newInstance = {
        startGT = globalTimer,
        previewIndex = 1,
        previewSubIndex = 0,
        editingIndex = 1,
        editingSubIndex = 1,
        sections = { NewSection("idle", 150) },
        name = name,
        _savestateFile = name .. ".tmp.savestate",
        _oldTASState = {},
        _oldClock = 0,
        _busy = false,
        _updatePending = false,
        _rebasing = false,
        _sectionIndex = 1,
        _frameCounter = 1,
        _previousTASState = nil,
        numSections = __clsSheet.numSections,
        evaluateFrame = __clsSheet.evaluateFrame,
        update = __clsSheet.update,
        runToPreview = __clsSheet.runToPreview,
        rebase = __clsSheet.rebase,
        save = __clsSheet.save,
        load = __clsSheet.load,
    }
    savestate.savefile(newInstance._savestateFile)
    return newInstance
end

function __clsSheet:numSections() return #self.sections end

function __clsSheet:evaluateFrame()
    local section = self.sections[self._sectionIndex]
    if section == nil then return nil end

    local tasState = section.inputs[math.min(self._frameCounter, #section.inputs)].tasState
    local currentAction = Locales.raw().ACTIONS[memory.readdword(Addresses[Settings.address_source_index].mario_action)]
    tasState.preview_action = currentAction
    if self._frameCounter >= section.timeout or currentAction == section.endAction then
        self._sectionIndex = self._sectionIndex + 1
        self._frameCounter = 0
    end
    if self._sectionIndex > self.previewIndex
        or (self._sectionIndex == self.previewIndex
            and self.previewSubIndex
            and self._frameCounter >= self.previewSubIndex
            ) then
        emu.pause(false)
        emu.set_ff(false)
        self._busy = false
    end

    self._frameCounter = self._frameCounter + 1
    section = self.sections[self._sectionIndex]
    return section and section.inputs[math.min(self._frameCounter, #section.inputs)] or nil
end

function __clsSheet:runToPreview(loadState)
    if self._busy then
        self._updatePending = true
        return
    end
    if self:numSections() == 0 then return end
    self._busy = true
    self._updatePending = false

    if loadState == nil and true or loadState then
        savestate.loadfile(self._savestateFile)
        print("loading file \"" .. self._savestateFile .. "\"")
    end
    emu.pause(true)
    emu.set_ff(true)

    self._previousTASState = TASState
    self._sectionIndex = 1
    self._frameCounter = 1
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
            editingIndex = self.editingIndex,
            editingSubIndex = self.editingSubIndex,
            previewIndex = self.previewIndex,
            previewSubIndex = self.previewSubIndex,
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
        self:runToPreview()
    end
end

function __clsSheet:rebase(path)
    if CopyFile(path, self._savestateFile) then
        self._rebasing = true
        self:runToPreview()
        print("rebased \"" .. self.name .. "\" onto \"" .. path .. "\"")
    end
end

return
{ new = NewSection },
{ new = NewSheet },
{ new = NewSelection }