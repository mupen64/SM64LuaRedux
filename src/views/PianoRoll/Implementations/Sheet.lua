---@diagnostic disable:invisible

---@type Sheet
---@diagnostic disable-next-line:assign-type-mismatch
local __impl = __impl

---@type Section
local Section = dofile(views_path .. "PianoRoll/Definitions/Section.lua")

function __impl.new(name, createSavestate)
    local globalTimer = Memory.current.mario_global_timer

    local newInstance = {
        startGT = globalTimer,
        previewFrame = { sectionIndex = 1, frameIndex = 1 },
        activeFrame = { sectionIndex = 1, frameIndex = 1 },
        sections = { Section.new("idle", 150) },
        name = name,
        _savestate = nil,
        _oldTASState = {},
        _oldClock = 0,
        _busy = false,
        _updatePending = false,
        _rebasing = false,
        _sectionIndex = 1,
        _frameCounter = 1,
        num_sections = __impl.num_sections,
        evaluate_frame = __impl.evaluate_frame,
        update = __impl.update,
        run_to_preview = __impl.run_to_preview,
        rebase = __impl.rebase,
        save = __impl.save,
        load = __impl.load,
    }
    if createSavestate then
        savestate.do_memory({}, "save", function(result, data) newInstance._savestate = data end)
    end

    return newInstance
end

function __impl:num_sections() return #self.sections end

function __impl:evaluate_frame()
    local section = self.sections[self._sectionIndex]
    if section == nil then return nil end

    local tasState = section.inputs[math.min(self._frameCounter, #section.inputs)].tasState
    local currentAction = Locales.raw().ACTIONS[memory.readdword(Addresses[Settings.address_source_index].mario_action)]
    tasState.preview_action = currentAction
    if self._frameCounter >= section.timeout or currentAction == section.endAction then
        self._sectionIndex = self._sectionIndex + 1
        self._frameCounter = 0
    end
    if self._sectionIndex > self.previewFrame.sectionIndex
        or (self._sectionIndex == self.previewFrame.sectionIndex
            and self.previewFrame.frameIndex
            and self._frameCounter >= self.previewFrame.frameIndex - 1
            ) then
        emu.pause(false)
        emu.set_ff(false)
        self._busy = false
    end

    self._frameCounter = self._frameCounter + 1
    section = self.sections[self._sectionIndex]
    return section and section.inputs[math.min(self._frameCounter, #section.inputs)] or nil
end

function __impl:run_to_preview(loadState)
    if self._busy then
        self._updatePending = true
        return
    end
    if self:num_sections() == 0 then return end
    self._busy = true
    self._updatePending = false

    if loadState == nil and true or loadState then
        savestate.do_memory(self._savestate, "load", function()
            emu.pause(true)
            emu.set_ff(Settings.piano_roll.fast_foward)
        end)
    else
        emu.pause(true)
        emu.set_ff(Settings.piano_roll.fast_foward)
    end

    self._sectionIndex = 1
    self._frameCounter = 1
end

function __impl:save(file)
    writeAll(file .. ".savestate", self._savestate)
    persistence.store(
        file,
        {
            sections     = self.sections,
            name         = self.name,
            activeFrame  = self.activeFrame,
            previewFrame = self.previewFrame,
        }
    )
end

function __impl:load(file)
    local contents = persistence.load(file);
    if contents ~= nil then
        self._savestate = readAll(file .. ".savestate")
        CloneInto(self, contents)
    end
end

function __impl:update()
    local anyChange = CloneInto(self._oldTASState, TASState)
    local now = os.clock()
    if anyChange then
        self._oldClock = now
        self._updatePending = true
    elseif self._updatePending then
        self._oldClock = now
        self:run_to_preview()
    end
end

function __impl:rebase()
    savestate.do_memory({}, "save", function(result, data)
        self._savestate = data
        self:run_to_preview()
    end)
end