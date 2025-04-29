Section, Sheet = dofile(views_path .. "PianoRoll/Sheet.lua")

local function NewSheetMeta(name)
    return {
        name = name
    }
end

---@class Project
---@field public meta table Metadata about the project that is stored into the piano roll project file (*.prp).
---@field public current Sheet|nil The currently selected and active piano roll.
---@field public all table All piano roll sheets as loaded from their respective *.prs files in order.
---@field public projectLocation string The location of the piano roll project file (*.prp).
---@field public copyEntireState boolean If true, the entire TASState of the active edited frame is copied to all selected. If false, only the changes made will be copied instead.
local __clsProject = {}

function __clsProject.new()
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

        Current = __clsProject.Current,
        AssertedCurrent = __clsProject.AssertedCurrent,
        SetCurrentName = __clsProject.SetCurrentName,
        ProjectFolder = __clsProject.ProjectFolder,
        Load = __clsProject.Load,
        AddSheet = __clsProject.AddSheet,
        MoveSheet = __clsProject.MoveSheet,
        RemoveSheet = __clsProject.RemoveSheet,
        Select = __clsProject.Select,
        Rebase = __clsProject.Rebase,
    }
end

---Retrieves the current piano roll, raising error when it is nil
---@return Sheet current The current Sheet, never nil
function __clsProject:AssertedCurrent()
    local result = self:Current()
    if result == nil then
        error("Expected PianoRollProject:Current() to not be nil.", 2)
    end
    return result
end

---Retrieves the current piano roll, or nil if no sheet is selected
---@return Sheet | nil current The current Sheet, may be nil
function __clsProject:Current()
    local sheetMeta = self.meta.sheets[self.meta.selectionIndex]
    return sheetMeta ~= nil and self.all[sheetMeta.name] or nil
end

---Adds a new sheet to the end of the sheet list.
function __clsProject:AddSheet()
    self.meta.createdSheetCount = self.meta.createdSheetCount + 1
    local newSheet = Sheet.new("Sheet " .. self.meta.createdSheetCount, true)
    self.all[newSheet.name] = newSheet
    self.meta.sheets[#self.meta.sheets+1] = NewSheetMeta(newSheet.name)
end

---Removes the sheet at the provided index
---@param index number The 1-based index of the sheet to remove - must be within the range of [1; #meta.sheets]
function __clsProject:RemoveSheet(index)
    self.all[table.remove(self.meta.sheets, index).name] = nil
    self:Select(#self.meta.sheets > 0 and (index % #self.meta.sheets) or 0)
end

---Moves the sheet at the provided index up or down in the list of sheets
---@param sign number +1 to move the sheet down, or -1 to move the sheet up
function __clsProject:MoveSheet(index, sign)
    local tmp = self.meta.sheets[index]
    self.meta.sheets[index] = self.meta.sheets[index + sign]
    self.meta.sheets[index + sign] = tmp
end

---Sets the name of the currently selected sheet, such that it is still properly referenced by the project instance
---@param name string The new name of the sheet
function __clsProject:SetCurrentName(name)
    local currentSheetMeta = self.meta.sheets[self.meta.selectionIndex]

    -- short circuit if there is nothing to do
    if name == currentSheetMeta.name then return end

    local sheet = self.all[currentSheetMeta.name]
    self.all[currentSheetMeta.name] = nil
    self.all[name] = sheet
    currentSheetMeta.name = name
end

---Selects the piano roll sheet at the provided index and runs it from its savestate to its current preview.
---@param index number The 1-based index of the sheet to select.
function __clsProject:Select(index, loadState)
    self.disabled = false
    local previous = self:Current()
    if previous ~= nil then previous._busy = false end
    self.meta.selectionIndex = index
    local current = self:Current()
    if current ~= nil then
        current:runToPreview(loadState)
    end
end

---Selects and rebases the piano roll sheet at the provided index onto the current state of the game.
---@param index number The 1-based index of the sheet to select.
function __clsProject:Rebase(index)
    self.meta.selectionIndex = index
    self.all[self.meta.sheets[index].name]:rebase()
end

---Retrieves the directory in which this project's project file resides
function __clsProject:ProjectFolder()
    return self.projectLocation:match("(.*[/\\])")
end

---Loads the piano roll sheets from the given meta data
---@param meta table The Project.meta field as stored in a piano roll project (*.prp) file
function __clsProject:Load(meta)
    self.meta = meta
    self.all = {}
    local projectFolder = self:ProjectFolder()
    for _, sheetMeta in ipairs(meta.sheets) do
        local newSheet = Sheet.new(sheetMeta.name)
        newSheet:load(projectFolder .. sheetMeta.name .. ".prs", true)
        self.all[sheetMeta.name] = newSheet
    end
end

return {
    new = __clsProject.new,
}