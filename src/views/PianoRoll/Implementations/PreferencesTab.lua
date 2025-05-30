---@type PreferencesTab
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

__impl.name = "Preferences"
__impl.help_key = "PREFERENCES_TAB"

local UID <const> = dofile(views_path .. "PianoRoll/UID.lua")[__impl.name]

function __impl.allocate_uids(EnumNext)
    return {
        ToggleEditEntireState = EnumNext(),
        ToggleFastForward = EnumNext(),
    }
end

local controlHeight = 0.75

function __impl.render(draw)
    local top = 1
    Settings.piano_roll.edit_entire_state = ugui.toggle_button(
        {
            uid = UID.ToggleEditEntireState,
            rectangle = grid_rect(0, top, 8, controlHeight),
            text = "Edit entire state",
            is_checked = Settings.piano_roll.edit_entire_state,
        }
    )
    Settings.piano_roll.fast_foward = ugui.toggle_button(
        {
            uid = UID.ToggleFastForward,
            rectangle = grid_rect(0, top + controlHeight, 8, controlHeight),
            text = "Fast Forward",
            is_checked = Settings.piano_roll.fast_foward,
        }
    )
end