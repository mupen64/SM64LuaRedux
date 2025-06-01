---@type PreferencesTab
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

__impl.name = "Preferences"
__impl.help_key = "PREFERENCES_TAB"

local UID <const> = dofile(views_path .. "SemanticWorkflow/UID.lua")[__impl.name]

function __impl.allocate_uids(enum_next)
    return {
        ToggleEditEntireState = enum_next(),
        ToggleFastForward = enum_next(),
    }
end

local control_height = 0.75

function __impl.render(draw)
    local top = 1
    Settings.semantic_workflow.edit_entire_state = ugui.toggle_button(
        {
            uid = UID.ToggleEditEntireState,
            rectangle = grid_rect(0, top, 8, control_height),
            text = "Edit entire state",
            is_checked = Settings.semantic_workflow.edit_entire_state,
        }
    )
    Settings.semantic_workflow.fast_foward = ugui.toggle_button(
        {
            uid = UID.ToggleFastForward,
            rectangle = grid_rect(0, top + control_height, 8, control_height),
            text = "Fast Forward",
            is_checked = Settings.semantic_workflow.fast_foward,
        }
    )
end