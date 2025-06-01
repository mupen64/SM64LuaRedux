---@diagnostic disable:missing-return

---@class Sheet
---@field public preview_frame SelectionFrame The frame top which to proceed when re-running the game after a change.
---@field public active_frame SelectionFrame The frame whose controls to display in the "Inputs" page.
---@field public sections Section[] An array of TASStates with their associated section definition to execute in order.
---@field public name string A name for the sheet for convenience.
---@field private _section_index integer The nth section that is currently being played.
---@field private _frame_counter integer The nth frame of the current section that is currently being played.
---@field private _busy boolean Whether the sheet is waiting for the game to run until its preview frame.
---@field private _update_pending boolean Whether a change has been made that demands rerunning the sheet until its preview frame.
---@field private _savestate unknown The savestate this sheet runs from.
local __clsSheet = {}

---Constructs a new sheet with the given name and a single section.
---
---If `createSavestate` is set, the sheet will be "based" on the game's current state.
---Otherwise, a savestate MUST be supplied either
---via [load](lua://__clsSheet.load) or [rebase](lua://__clsSheet.rebase)
---before calling [run_to_preview](lua://__clsSheet.run_to_preview).
---@param name string The name of the sheet.
---@param create_savestate boolean Whether to create a savestate.
---@return Sheet sheet The new sheet.
function __clsSheet.new(name, create_savestate) end

-- TODO: remove this in favor of using #sections directly
function __clsSheet:num_sections() end

---Retrieves the inputs for the next frame and advances this sheet's internal counters
---such that the sequential invocations will yield the appropriate frames to advance the game with.
---@return SectionInputs inputs The inputs to advance the game's next frame with.
function __clsSheet:evaluate_frame() end

---Runs the game until the preview frame of this sheet.
function __clsSheet:run_to_preview(load_state) end

---Saves this sheet's data and associated savestate into `file` and `file`.savestate respectively.
---@param file string The file path to save to (absolute or relative).
function __clsSheet:save(file) end

---Loads this sheet's data and associated savestate from `file` and `file`.savestate respectively.
---@param file string The file path to load from (absolute or relative).
function __clsSheet:load(file) end

---Replaces the savestate this sheet runs from with the game's current state.
function __clsSheet:rebase() end

__impl = __clsSheet
dofile(views_path .. "SemanticWorkflow/Implementations/Sheet.lua")
__impl = nil

return __clsSheet