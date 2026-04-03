--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@diagnostic disable:missing-return

---@class SheetMeta
---@field public name string The file name in the project directory (without extension).
---@field public base_sheet string | nil The name of the base sheet, if applicable.

---@class ProjectMeta
---@field public sheets SheetMeta[] The ordered list of sheet metadata objects that are part of this project.
---@field public selection_index integer|nil The index of the selected sheet, if any.
---@field public version string The version file version of this project file.

---@class Project Describes the data required to work with and store multiple sheets.
---@field public version string The file version this project was created with.
---@field public all Sheet[] All semantic workflow sheets as loaded from their respective *.sws files in order.
---@field public current Sheet|nil The currently selected sheet. If nil, no inputs will be sent to mupen by this project.
---@field public project_location string The location of the semantic workflow project file (*.swp).
local cls_project = {}

---Constructs a new Project with no sheets.
---@return Project project The new project.
function cls_project.new() end

---Retrieves the current sheet, raising an error when it is nil.
---@return Sheet current The current Sheet, never nil.
function cls_project:asserted_current() end

---Adds a new sheet to the end of the sheet list.
function cls_project:add_sheet() end

---Removes the provided sheet from the project.
---@param sheet Sheet The sheet to remove.
function cls_project:remove_sheet(sheet) end

---Moves the provided sheet up or down in the list of sheets
---@param sheet Sheet The sheet to move.
---@param sign number +1 to move the sheet down, or -1 to move the sheet up
function cls_project:move_sheet(sheet, sign) end

---Adds a duplicate of the provided sheet and to the end of the sheet list.
---@param sheet Sheet The sheet to duplicate.
function cls_project:duplicate_sheet(sheet) end

---Selects the semantic workflow sheet at the provided index and runs it to its current preview frame.
---@param sheet Sheet The 1-based index of the sheet to select.
---@param from_base boolean | nil Whether to run the sheet from its defined base, which may be either a savestate or another sheet. Defaults to true.
function cls_project:select(sheet, from_base) end

---Selects and rebases the semantic workflow sheet at the provided index onto the current state of the game.
---@param sheet Sheet The sheet to select.
function cls_project:rebase(sheet) end

---Retrieves the directory in which this project's project file resides.
---@return string | nil directory The directory in which the project file resides, or nil if the project has never been saved or loaded.
function cls_project:project_folder() end

---Loads the semantic workflow sheets from the given file.
---@param file string The path to the semantic workflow project file (*.swp).
function cls_project:load(file) end

function cls_project:save() end

__impl = cls_project
dofile(views_path .. 'SemanticWorkflow/Implementations/Project.lua')
__impl = nil

return cls_project
