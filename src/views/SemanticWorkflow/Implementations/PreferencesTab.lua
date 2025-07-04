---@type PreferencesTab
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

__impl.name = "Preferences"
__impl.help_key = "PREFERENCES_TAB"

local UID <const> = dofile(views_path .. "SemanticWorkflow/UID.lua")[__impl.name]

---@type Gui
local Gui = dofile(views_path .. "SemanticWorkflow/Definitions/Gui.lua")

function __impl.allocate_uids(enum_next)
    return {
        ToggleEditEntireState = enum_next(),
        ToggleFastForward = enum_next(),
        DefaultSectionTimeout = enum_next(),
    }
end

function __impl.render(draw)
    local top = 1
    Settings.semantic_workflow.edit_entire_state = ugui.toggle_button(
        {
            uid = UID.ToggleEditEntireState,
            rectangle = grid_rect(0, top, 8, Gui.MEDIUM_CONTROL_HEIGHT),
            text = Locales.str("SEMANTIC_WORKFLOW_PREFERENCES_EDIT_ENTIRE_STATE"),
            is_checked = Settings.semantic_workflow.edit_entire_state,
        }
    )
    Settings.semantic_workflow.fast_foward = ugui.toggle_button(
        {
            uid = UID.ToggleFastForward,
            rectangle = grid_rect(0, top + Gui.MEDIUM_CONTROL_HEIGHT, 8, Gui.MEDIUM_CONTROL_HEIGHT),
            text = Locales.str("SEMANTIC_WORKFLOW_PREFERENCES_FAST_FORWARD"),
            is_checked = Settings.semantic_workflow.fast_foward,
        }
    )

    draw:text(
        grid_rect(2, top + Gui.MEDIUM_CONTROL_HEIGHT * 2, 4, Gui.MEDIUM_CONTROL_HEIGHT),
        "end",
        Locales.str("SEMANTIC_WORKFLOW_PREFERENCES_DEFAULT_SECTION_TIMEOUT")
    )
    Settings.semantic_workflow.default_section_timeout = math.max(
        ugui.numberbox(
            {
                uid = UID.DefaultSectionTimeout,
                rectangle = grid_rect(6, top + Gui.MEDIUM_CONTROL_HEIGHT * 2, 2, Gui.MEDIUM_CONTROL_HEIGHT),
                places = 3,
                value = Settings.semantic_workflow.default_section_timeout,
            }
        ),
        1
    )
end