--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@diagnostic disable:invisible

---@type Sheet
---@diagnostic disable-next-line:assign-type-mismatch
local __impl = __impl

---@type Section
local Section = dofile(views_path .. 'SemanticWorkflow/Definitions/Section.lua')

function __impl.new(name, create_savestate)
    local global_timer = Memory.current.mario_global_timer

    local new_instance = {
        version = SEMANTIC_WORKFLOW_FILE_VERSION,
        preview_input = { section_index = 1, input_index = 1 },
        active_input = { section_index = 1, input_index = 1 },
        sections = { Section.new('Start') }, -- TODO: consider localizing this name
        name = name,
        busy = false,
        _savestate = nil,
        _base_sheet = nil,
        _invalidated = true,
        _rebasing = false,
        _section_index = 1,
        _input_index = 1,
        _frame_counter = 0,
        evaluate_frame = __impl.evaluate_frame,
        run_to_preview = __impl.run_to_preview,
        rebase = __impl.rebase,
        set_base_sheet = __impl.set_base_sheet,
        save = __impl.save,
        load = __impl.load,
        invalidated = __impl.invalidated,
    }
    if create_savestate then
        savestate.do_memory('', 'save', function(result, data) new_instance._savestate = data end)
    end

    return new_instance
end

function __impl:evaluate_frame()
    if self._base_sheet ~= nil and self._base_sheet.busy then
        return self._base_sheet:evaluate_frame()
    end

    local section = self.sections[self._section_index]
    if section == nil then return nil end

    local input = section.inputs[self._input_index]

    local current_action = Memory.current.mario_action
    if (input.timeout and self._frame_counter >= input.timeout)
        or current_action == input.end_action
    then
        self._input_index = self._input_index + 1
        self._frame_counter = 0
        if #section.inputs < self._input_index then
            self._section_index = self._section_index + 1
            self._input_index = 1
        end
    end
    if self._section_index > self.preview_input.section_index
        or (self._section_index == self.preview_input.section_index
            and self.preview_input.input_index
            and self._input_index >= self.preview_input.input_index
        ) then
        if self._on_preview_input_reached == nil then
            -- we've reached the end, pause emulation
            emu.pause(false)
            emu.set_ff(false)
        else
            -- continue with the next sheet
            local invocation = self._on_preview_input_reached
            self._on_preview_input_reached = nil

            ---@diagnostic disable-next-line: need-check-nil -- trivially not nil here
            invocation()
        end
        self.busy = false
    end

    self._frame_counter = self._frame_counter + 1
    section = self.sections[self._section_index]
    return section and section.inputs[math.min(self._input_index, #section.inputs)] or nil
end

---@param sheet Sheet
---@param from_base boolean | nil
local function run_to_preview_internal(sheet, from_base)
    sheet.busy = true

    sheet._section_index = 1
    sheet._input_index = 1
    sheet._frame_counter = 0

    if from_base == nil or from_base then
        if sheet._base_sheet ~= nil then
            if sheet._savestate == nil or sheet._base_sheet:invalidated() then
                -- Run the sheet without loading a savestate because it's a continuation of its base sheet
                sheet._base_sheet._on_preview_input_reached = function()
                    sheet._base_sheet._invalidated = false
                    savestate.do_memory('', 'save', function(result, data) sheet._savestate = data end)
                    sheet._section_index = 1
                    sheet._frame_counter = 0
                end
                run_to_preview_internal(sheet._base_sheet, from_base)
                return
            end
        end

        -- Run the sheet from its savestate, which is either its dedicated savestate or the valid "cache" for where its base sheet ends up
        savestate.do_memory(sheet._savestate, 'load', function()
            emu.pause(true)
            emu.set_ff(Settings.semantic_workflow.fast_foward)
        end)
    else
        -- Run the sheet without loading a savestate because the user decided to ignore the dedicated savestate
        emu.pause(true)
        emu.set_ff(Settings.semantic_workflow.fast_foward)
    end
end

function __impl:invalidated()
    return self._invalidated or (self._base_sheet ~= nil and self._base_sheet:invalidated())
end

function __impl:run_to_preview(from_base)
    self._invalidated = true
    if self.busy or #self.sections == 0 then return end

    run_to_preview_internal(self, from_base)
end

function __impl:save(file)
    self.version = SEMANTIC_WORKFLOW_FILE_VERSION
    if self._base_sheet == nil then
        WriteAll(file .. '.savestate', self._savestate)
    end
    WriteAll(
        file,
        json.encode({
            version = self.version,
            sections = self.sections,
            name = self.name,
            active_input = self.active_input,
            preview_input = self.preview_input,
        })
    )
end

function __impl:load(file, load_state)
    local contents = json.decode(ReadAll(file));
    if contents ~= nil then
        if load_state then
            self._savestate = ReadAll(file .. '.savestate')
        end
        CloneInto(self, contents)

        -- convert sheets pre 2.0.0
        if contents.version:match("^%s*[vV]?(%d+)") == '1' then
            self._frame_counter = self._frame_counter or 0
            self._section_frame_counter = self._section_frame_counter or 0
            self._input_index = self._input_index or 1
            self.active_input = contents.active_frame and {
                input_index = contents.active_frame.frame_index,
                section_index = contents.active_frame.section_index
            } or self.active_input
            self.preview_input = contents.preview_frame and {
                input_index = contents.preview_frame.frame_index,
                section_index = contents.preview_frame.section_index
            } or self.preview_input

            for _, section in pairs(self.sections) do
                ---@diagnostic disable: undefined-field
                if section.end_action or section.timeout then
                    for _, input in pairs(section.inputs) do
                        input.timeout = input.timeout or 1
                        input.end_action = section.end_action
                    end
                    if section.timeout then
                    section.inputs[#section.inputs].timeout = section.timeout - #section.inputs + 1
                    end
                end
            ---@diagnostic enable: undefined-field
            end
        end
    end
end

function __impl:rebase()
    savestate.do_memory('', 'save', function(result, data)
        self._base_sheet = nil
        self._savestate = data
        self:run_to_preview()
    end)
end

function __impl:set_base_sheet(sheet)
    self._base_sheet = sheet
    self._savestate = nil
end
