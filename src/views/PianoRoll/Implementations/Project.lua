---@type Project
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

---@type Sheet
local Sheet = dofile(views_path .. "PianoRoll/Definitions/Sheet.lua")

local function NewSheetMeta(name)
    return {
        name = name
    }
end

function __impl.new()
    return {
        meta = {
            createdSheetCount = 0,
            selectionIndex = 0,
            sheets = {}
        },
        all = {},
        copyEntireState = true,
        projectLocation = nil,
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
    local sheetMeta = self.meta.sheets[self.meta.selectionIndex]
    return sheetMeta ~= nil and self.all[sheetMeta.name] or nil
end

function __impl:add_sheet()
    self.meta.createdSheetCount = self.meta.createdSheetCount + 1
    local newSheet = Sheet.new("Sheet " .. self.meta.createdSheetCount, true)
    self.all[newSheet.name] = newSheet
    self.meta.sheets[#self.meta.sheets+1] = NewSheetMeta(newSheet.name)
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
    local currentSheetMeta = self.meta.sheets[self.meta.selectionIndex]

    -- short circuit if there is nothing to do
    if name == currentSheetMeta.name then return end

    local sheet = self.all[currentSheetMeta.name]
    self.all[currentSheetMeta.name] = nil
    self.all[name] = sheet
    currentSheetMeta.name = name
end

function __impl:select(index, loadState)
    self.disabled = false
    local previous = self:current()
    if previous ~= nil then previous._busy = false end
    self.meta.selectionIndex = index
    local current = self:current()
    if current ~= nil then
        current:run_to_preview(loadState)
    end
end

function __impl:rebase(index)
    self.meta.selectionIndex = index
    self.all[self.meta.sheets[index].name]:rebase()
end

function __impl:project_folder()
    return self.projectLocation:match("(.*[/\\])")
end

function __impl:load(meta)
    self.meta = meta
    self.all = {}
    local projectFolder = self:project_folder()
    for _, sheetMeta in ipairs(meta.sheets) do
        local newSheet = Sheet.new(sheetMeta.name, false)
        newSheet:load(projectFolder .. sheetMeta.name .. ".prs")
        self.all[sheetMeta.name] = newSheet
    end
end