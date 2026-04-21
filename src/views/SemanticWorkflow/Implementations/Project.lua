--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@type Project
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

---@type Sheet
local Sheet = dofile(views_path .. 'SemanticWorkflow/Definitions/Sheet.lua')

function __impl.new()
    return {
        current = nil,
        all = {},
        project_location = nil,
        version = SEMANTIC_WORKFLOW_FILE_VERSION,

        asserted_current = __impl.asserted_current,
        project_folder = __impl.project_folder,
        load = __impl.load,
        save = __impl.save,
        add_sheet = __impl.add_sheet,
        remove_sheet = __impl.remove_sheet,
        move_sheet = __impl.move_sheet,
        select = __impl.select,
        rebase = __impl.rebase,
        duplicate_sheet = __impl.duplicate_sheet,
    }
end

function __impl:asserted_current()
    local result = self.current
    if result == nil then
        error('Expected the current sheet to not be nil.', 2)
    end
    return result
end

function __impl:add_sheet()
    local new_sheet = Sheet.new(UniqueName('Sheet', lualinq.select(self.all, function(x) return x.name end)), true)
    self.all[#self.all+1] = new_sheet
end

function __impl:remove_sheet(sheet)
    local index = IndexOf(self.all, sheet)
    table.remove(self.all, index)
    if #self.all > 0 then
        self:select(self.all[#self.all > 0 and (index % #self.all) or 0])
    end
end

function __impl:duplicate_sheet(sheet)
    if not sheet then return end
    local base_name = sheet.name:gsub(' %d+$', '')
    local new_name = UniqueName(base_name, lualinq.select(self.all, function(x) return x.name end))
    local new_sheet = Sheet.new(new_name, false)
    new_sheet.sections = ugui.internal.deep_clone(sheet.sections)
    new_sheet.preview_input = ugui.internal.deep_clone(sheet.preview_input)
    new_sheet.active_input = ugui.internal.deep_clone(sheet.active_input)
    if sheet._base_sheet ~= nil then
        new_sheet:set_base_sheet(sheet._base_sheet)
    else
        new_sheet._savestate = sheet._savestate
    end
    self.all[#self.all+1] = new_sheet
end

function __impl:move_sheet(sheet, sign)
    local index = IndexOf(self.all, sheet)
    if index + sign > 0 and index + sign <= #self.all then
        self.all[index + sign], self.all[index] = self.all[index], self.all[index + sign]
    end
end

function __impl:select(sheet, from_base)
    local previous = self.current
    if previous ~= nil then previous.busy = false end
    self.current = sheet
    if sheet ~= nil then
        sheet:run_to_preview(from_base)
    end
end

function __impl:rebase(sheet)
    self.current = sheet
    sheet:rebase()
end

function __impl:project_folder()
    return self.project_location:match('(.*[/\\])')
end

function __impl:load(file)
    self.project_location = file
    local meta = {}
    CloneInto(meta, json.decode(ReadAll(file)))
    self.version = meta.version
    self.all = {}
    local project_folder = self:project_folder()
    local base_sheet_names = {}
    local sheets_by_name = {}
    for _, sheet_meta in ipairs(meta.sheets) do
        local new_sheet = Sheet.new(sheet_meta.name, false)
        base_sheet_names[new_sheet] = sheet_meta.base_sheet
        sheets_by_name[new_sheet.name] = new_sheet
        self.all[#self.all + 1] = new_sheet
    end

    for _, sheet in ipairs(self.all) do
        local base = sheets_by_name[base_sheet_names[sheet]]
        sheet:load(project_folder .. sheet.name .. '.sws', not base)
        if base then
            sheet:set_base_sheet(base)
        end
    end
    self:select(self.all[meta.selection_index], true)
end

function __impl:save()
    ---@type ProjectMeta
    local project_meta = {
        version = SEMANTIC_WORKFLOW_FILE_VERSION,
        selection_index = IndexOf(self.all, self.current),
        sheets = lualinq.select(self.all, function(x) return {
            name = x.name,
            base_sheet = x._base_sheet and x._base_sheet.name or nil,
        } end)
    }
    local json = json.encode(project_meta)
    WriteAll(SemanticWorkflowProject.project_location, json)

    local project_folder = SemanticWorkflowProject:project_folder()
    for _, sheet in ipairs(SemanticWorkflowProject.all) do
        sheet:save(project_folder .. sheet.name .. '.sws')
    end
end
