---@diagnostic disable:missing-return

---@class Project
---@field public meta table Metadata about the project that is stored into the semantic workflow project file (*.swp).
---@field public all table All semantic workflow sheets as loaded from their respective *.sws files in order.
---@field public project_location string The location of the semantic workflow project file (*.swp).
-- TODO: This should be a global setting, probably...
---@field public copy_entire_state boolean If true, the entire TASState of the active edited frame is copied to all selected. If false, only the changes made will be copied instead.
---@field public disabled boolean If true, no inputs will be sent to mupen by this project.
local cls_project = {}

---Constructs a new Project with no sheets.
---@return Project project The new project.
function cls_project.new() end

---Retrieves the current sheet, raising error when it is nil.
---@return Sheet current The current Sheet, never nil.
function cls_project:asserted_current() end

---Retrieves the current sheet, or nil if no sheet is selected.
---@return Sheet | nil current The current Sheet, may be nil.
function cls_project:current() end

---Adds a new sheet to the end of the sheet list.
function cls_project:add_sheet() end

---Removes the sheet at the provided index.
---@param index number The 1-based index of the sheet to remove - must be within the range of [1; #meta.sheets].
function cls_project:remove_sheet(index) end

---Moves the sheet at the provided index up or down in the list of sheets
---@param index number The 1-based index of the sheet to move, such that moving it by "sign" will keep it in the range of [1; #meta.sheets].
---@param sign number +1 to move the sheet down, or -1 to move the sheet up
function cls_project:move_sheet(index, sign) end

---Sets the name of the currently selected sheet, such that it is still properly referenced by the project instance.
---@param name string The new name of the sheet.
function cls_project:set_current_name(name) end

---Selects the semantic workflow sheet at the provided index and runs it from its savestate to its current preview frame.
---@param index number The 1-based index of the sheet to select.
function cls_project:select(index, load_state) end

---Selects and rebases the semantic workflow sheet at the provided index onto the current state of the game.
---@param index number The 1-based index of the sheet to select.
function cls_project:rebase(index) end

---Retrieves the directory in which this project's project file resides.
---@return string | nil directory The directory in which the project file resides, or nil if the project has never been saved or loaded.
function cls_project:project_folder() end

---Loads the semantic workflow sheets from the given file.
---@param file string The path to the semantic workflow project file (*.swp).
function cls_project:load(file) end

function cls_project:save() end

__impl = cls_project
dofile(views_path .. "SemanticWorkflow/Implementations/Project.lua")
__impl = nil

return cls_project