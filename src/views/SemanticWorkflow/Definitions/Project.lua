---@diagnostic disable:missing-return

---@class Project
---@field public meta table Metadata about the project that is stored into the semantic workflow project file (*.swp).
---@field public all table All semantic workflow sheets as loaded from their respective *.prs files in order.
---@field public project_location string The location of the semantic workflow project file (*.swp).
---@field public copy_entire_state boolean If true, the entire TASState of the active edited frame is copied to all selected. If false, only the changes made will be copied instead.
local __clsProject = {}

---Constructs a new Project with no sheets.
---@return Project project The new project.
function __clsProject.new() end

---Retrieves the current sheet, raising error when it is nil.
---@return Sheet current The current Sheet, never nil.
function __clsProject:asserted_current() end

---Retrieves the current sheet, or nil if no sheet is selected.
---@return Sheet | nil current The current Sheet, may be nil.
function __clsProject:current() end

---Adds a new sheet to the end of the sheet list.
function __clsProject:add_sheet() end

---Removes the sheet at the provided index.
---@param index number The 1-based index of the sheet to remove - must be within the range of [1; #meta.sheets].
function __clsProject:remove_sheet(index) end

---Moves the sheet at the provided index up or down in the list of sheets
---@param sign number +1 to move the sheet down, or -1 to move the sheet up
function __clsProject:move_sheet(index, sign) end

---Sets the name of the currently selected sheet, such that it is still properly referenced by the project instance.
---@param name string The new name of the sheet.
function __clsProject:set_current_name(name) end

---Selects the semantic workflow sheet at the provided index and runs it from its savestate to its current preview.
---@param index number The 1-based index of the sheet to select.
function __clsProject:select(index, load_state) end

---Selects and rebases the semantic workflow sheet at the provided index onto the current state of the game.
---@param index number The 1-based index of the sheet to select.
function __clsProject:rebase(index) end

---Retrieves the directory in which this project's project file resides.
---@return string | nil directory The directory in which the project file resides, or nil if the project has never been saved or loaded.
function __clsProject:project_folder() end

---Loads the semantic workflow sheets from the given meta data.
---@param meta table The Project.meta field as stored in a semantic workflow project (*.swp) file.
function __clsProject:load(meta) end

__impl = __clsProject
dofile(views_path .. "SemanticWorkflow/Implementations/Project.lua")
__impl = nil

return __clsProject