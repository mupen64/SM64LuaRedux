---@diagnostic disable:missing-return

---@class Sheet Describes the data required to manage, store and edit the ordered sections of a sheet.
---@field public version string The file version of this sheet. See Version.lua for more information.
---@field public preview_frame SelectionFrame The frame to which to proceed when re-running the game after a change.
---@field public active_frame SelectionFrame The frame whose controls to display in the "Inputs" page.
---@field public sections Section[] The sections to execute in order.
---@field public name string A name for the sheet for convenience.
---@field public busy boolean Whether the sheet is waiting for the game to run until its preview frame.
---@field private _section_index integer The nth section that is currently being played.
---@field private _frame_counter integer The nth frame of the current section that is currently being played.
---@field private _update_pending boolean Whether a change has been made that demands re-running the sheet until its preview frame.
---@field private _savestate ByteBuffer The savestate this sheet runs from.
local cls_sheet = {}

---Constructs a new sheet with the given name and a single section.
---
---If `createSavestate` is set, the sheet will be "based" on the game's current state.
---Otherwise, a savestate MUST be supplied either
---via [load](lua://cls_sheet.load) or [rebase](lua://cls_sheet.rebase)
---before calling [run_to_preview](lua://cls_sheet.run_to_preview).
---@param name string The name of the sheet.
---@param create_savestate boolean Whether to create a savestate.
---@return Sheet sheet The new sheet.
function cls_sheet.new(name, create_savestate) end

---Retrieves the inputs for the next frame and advances this sheet's internal counters.
---such that sequential invocations will yield the appropriate frames to advance the game with.
---@return SectionInputs inputs The inputs to advance the game's next frame with.
function cls_sheet:evaluate_frame() end

---Runs the game until the preview frame of this sheet.
function cls_sheet:run_to_preview(load_state) end

---Saves this sheet's data and associated savestate into `file` and `file`.savestate respectively.
---@param file string The file path to save to (absolute or relative).
function cls_sheet:save(file) end

---Loads this sheet's data and associated savestate from `file` and `file`.savestate respectively.
---@param file string The file path to load from (absolute or relative).
function cls_sheet:load(file) end

---Replaces the savestate this sheet runs from with the game's current state.
function cls_sheet:rebase() end

__impl = cls_sheet
dofile(views_path .. "SemanticWorkflow/Implementations/Sheet.lua")
__impl = nil

return cls_sheet