---@type Project
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

---@type Sheet
local Sheet = dofile(views_path .. "SemanticWorkflow/Definitions/Sheet.lua")

local function new_sheet_meta(name)
    return {
        name = name
    }
end

function __impl.new()
    return {
        meta = {
            created_sheet_count = 0,
            selection_index = 0,
            sheets = {}
        },
        all = {},
        copy_entire_state = true,
        project_location = nil,
        disabled = false,

        current = __impl.current,
        asserted_current = __impl.asserted_current,
        set_current_name = __impl.set_current_name,
        project_folder = __impl.project_folder,
        load = __impl.load,
        add_sheet = __impl.add_sheet,
        remove_sheet = __impl.remove_sheet,
        select = __impl.select,
        rebase = __impl.rebase,
    }
end

function __impl:asserted_current()
    local result = self:current()
    if result == nil then
        error("Expected the current sheet to not be nil.", 2)
    end
    return result
end

function __impl:current()
    local sheet_meta = self.meta.sheets[self.meta.selection_index]
    return sheet_meta ~= nil and self.all[sheet_meta.name] or nil
end

function __impl:add_sheet()
    self.meta.created_sheet_count = self.meta.created_sheet_count + 1
    local new_sheet = Sheet.new("Sheet " .. self.meta.created_sheet_count, true)
    self.all[new_sheet.name] = new_sheet
    self.meta.sheets[#self.meta.sheets+1] = new_sheet_meta(new_sheet.name)
end

function __impl:remove_sheet(index)
    self.all[table.remove(self.meta.sheets, index).name] = nil
    self:select(#self.meta.sheets > 0 and (index % #self.meta.sheets) or 0)
end

function __impl:move_sheet(index, sign)
    local tmp = self.meta.sheets[index]
    self.meta.sheets[index] = self.meta.sheets[index + sign]
    self.meta.sheets[index + sign] = tmp
end

function __impl:set_current_name(name)
    local current_sheet_meta = self.meta.sheets[self.meta.selection_index]

    -- short circuit if there is nothing to do
    if name == current_sheet_meta.name then return end

    local sheet = self.all[current_sheet_meta.name]
    self.all[current_sheet_meta.name] = nil
    self.all[name] = sheet
    current_sheet_meta.name = name
end

function __impl:select(index, load_state)
    self.disabled = false
    local previous = self:current()
    if previous ~= nil then previous._busy = false end
    self.meta.selection_index = index
    local current = self:current()
    if current ~= nil then
        current:run_to_preview(load_state)
    end
end

function __impl:rebase(index)
    self.meta.selection_index = index
    self.all[self.meta.sheets[index].name]:rebase()
end

function __impl:project_folder()
    return self.project_location:match("(.*[/\\])")
end

function __impl:load(meta)
    self.meta = meta
    self.all = {}
    local project_folder = self:project_folder()
    for _, sheet_meta in ipairs(meta.sheets) do
        local new_sheet = Sheet.new(sheet_meta.name, false)
        new_sheet:load(project_folder .. sheet_meta.name .. ".sws")
        self.all[sheet_meta.name] = new_sheet
    end
end