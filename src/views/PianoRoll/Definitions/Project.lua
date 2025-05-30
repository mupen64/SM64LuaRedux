---@diagnostic disable:missing-return

---@class Project
---@field public meta table Metadata about the project that is stored into the piano roll project file (*.prp).
---@field public current Sheet|nil The currently selected and active piano roll.
---@field public all table All piano roll sheets as loaded from their respective *.prs files in order.
---@field public projectLocation string The location of the piano roll project file (*.prp).
---@field public copyEntireState boolean If true, the entire TASState of the active edited frame is copied to all selected. If false, only the changes made will be copied instead.
local __clsProject = {}

---Constructs a new Project with no sheets.
---@return Project project The new project.
function __clsProject.new() end

---Retrieves the current sheet, raising error when it is nil.
---@return Sheet current The current Sheet, never nil.
function __clsProject:AssertedCurrent() end

---Retrieves the current sheet, or nil if no sheet is selected.
---@return Sheet | nil current The current Sheet, may be nil.
function __clsProject:Current() end

---Adds a new sheet to the end of the sheet list.
function __clsProject:AddSheet() end

---Removes the sheet at the provided index.
---@param index number The 1-based index of the sheet to remove - must be within the range of [1; #meta.sheets].
function __clsProject:RemoveSheet(index) end

---Moves the sheet at the provided index up or down in the list of sheets
---@param sign number +1 to move the sheet down, or -1 to move the sheet up
function __clsProject:MoveSheet(index, sign) end

---Sets the name of the currently selected sheet, such that it is still properly referenced by the project instance.
---@param name string The new name of the sheet.
function __clsProject:SetCurrentName(name) end

---Selects the piano roll sheet at the provided index and runs it from its savestate to its current preview.
---@param index number The 1-based index of the sheet to select.
function __clsProject:Select(index, loadState) end

---Selects and rebases the piano roll sheet at the provided index onto the current state of the game.
---@param index number The 1-based index of the sheet to select.
function __clsProject:Rebase(index) end

---Retrieves the directory in which this project's project file resides.
---@return string | nil directory The directory in which the project file resides, or nil if the project has never been saved or loaded.
function __clsProject:ProjectFolder() end

---Loads the piano roll sheets from the given meta data.
---@param meta table The Project.meta field as stored in a piano roll project (*.prp) file.
function __clsProject:Load(meta) end

__impl = __clsProject
dofile(views_path .. "PianoRoll/Implementations/Project.lua")
__impl = nil

return __clsProject