---@type Project
local __impl = __impl

---@type Section
Section,
---@type Sheet
Sheet = dofile(views_path .. "PianoRoll/Sheet.lua")

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

        Current = __impl.Current,
        AssertedCurrent = __impl.AssertedCurrent,
        SetCurrentName = __impl.SetCurrentName,
        ProjectFolder = __impl.ProjectFolder,
        Load = __impl.Load,
        AddSheet = __impl.AddSheet,
        MoveSheet = __impl.RemoveSheet,
        Select = __impl.Select,
        Rebase = __impl.Rebase,
    }
end

function __impl:AssertedCurrent()
    local result = self:Current()
    if result == nil then
        error("Expected the current sheet to not be nil.", 2)
    end
    return result
end

function __impl:Current()
    local sheetMeta = self.meta.sheets[self.meta.selectionIndex]
    return sheetMeta ~= nil and self.all[sheetMeta.name] or nil
end

function __impl:AddSheet()
    self.meta.createdSheetCount = self.meta.createdSheetCount + 1
    local newSheet = Sheet.new("Sheet " .. self.meta.createdSheetCount, true)
    self.all[newSheet.name] = newSheet
    self.meta.sheets[#self.meta.sheets+1] = NewSheetMeta(newSheet.name)
end

function __impl:RemoveSheet(index)
    self.all[table.remove(self.meta.sheets, index).name] = nil
    self:Select(#self.meta.sheets > 0 and (index % #self.meta.sheets) or 0)
end

function __impl:MoveSheet(index, sign)
    local tmp = self.meta.sheets[index]
    self.meta.sheets[index] = self.meta.sheets[index + sign]
    self.meta.sheets[index + sign] = tmp
end

function __impl:SetCurrentName(name)
    local currentSheetMeta = self.meta.sheets[self.meta.selectionIndex]

    -- short circuit if there is nothing to do
    if name == currentSheetMeta.name then return end

    local sheet = self.all[currentSheetMeta.name]
    self.all[currentSheetMeta.name] = nil
    self.all[name] = sheet
    currentSheetMeta.name = name
end

function __impl:Select(index, loadState)
    self.disabled = false
    local previous = self:Current()
    if previous ~= nil then previous._busy = false end
    self.meta.selectionIndex = index
    local current = self:Current()
    if current ~= nil then
        current:runToPreview(loadState)
    end
end

function __impl:Rebase(index)
    self.meta.selectionIndex = index
    self.all[self.meta.sheets[index].name]:rebase()
end

function __impl:ProjectFolder()
    return self.projectLocation:match("(.*[/\\])")
end

function __impl:Load(meta)
    self.meta = meta
    self.all = {}
    local projectFolder = self:ProjectFolder()
    for _, sheetMeta in ipairs(meta.sheets) do
        ---@type Sheet
        local newSheet = Sheet.new(sheetMeta.name)
        newSheet:load(projectFolder .. sheetMeta.name .. ".prs")
        self.all[sheetMeta.name] = newSheet
    end
end