--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Locales = {}



---@class Locale
---@field public name string
---@field public GENERIC_ON string
---@field public GENERIC_OFF string
---@field public GENERIC_START string
---@field public GENERIC_STOP string
---@field public GENERIC_RESET string
---@field public GENERIC_NIL string
---@field public TAS_TAB_NAME string
---@field public SEMANTIC_WORKFLOW_TAB_NAME string
---@field public SETTINGS_TAB_NAME string
---@field public TOOLS_TAB_NAME string
---@field public TIMER_TAB_NAME string
---@field public PRESET string
---@field public PRESET_CONTEXT_MENU_DELETE_ALL string
---@field public DISABLED string
---@field public MATCH_YAW string
---@field public REVERSE_YAW string
---@field public MATCH_ANGLE string
---@field public D99_ALWAYS string
---@field public D99 string
---@field public DYAW string
---@field public ATAN_STRAIN string
---@field public ATAN_STRAIN_REV string
---@field public MAG_RESET string
---@field public MAG_HI string
---@field public SPDKICK string
---@field public FRAMEWALK string
---@field public SWIM string
---@field public YES string
---@field public NO string
---@field public SEMANTIC_WORKFLOW_HELP_HEADER_TITLE string
---@field public SEMANTIC_WORKFLOW_HELP_SHOW_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_HELP_EXIT_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_HELP_PREV_PAGE string
---@field public SEMANTIC_WORKFLOW_HELP_NEXT_PAGE string
---@field public SEMANTIC_WORKFLOW_SHEET_NO_SELECTED string
---@field public SEMANTIC_WORKFLOW_SHEET_DELETE_CONFIRMATION string
---@field public SEMANTIC_WORKFLOW_FRAMELIST_START string
---@field public SEMANTIC_WORKFLOW_FRAMELIST_NAME string
---@field public SEMANTIC_WORKFLOW_FRAMELIST_SECTION string
---@field public SEMANTIC_WORKFLOW_FRAMELIST_STICK string
---@field public SEMANTIC_WORKFLOW_FRAMELIST_UNTIL string
---@field public SEMANTIC_WORKFLOW_TOOL_COPY_ENTIRE_STATE string
---@field public SEMANTIC_WORKFLOW_CONTROL_MANUAL string
---@field public SEMANTIC_WORKFLOW_CONTROL_MATCH_YAW string
---@field public SEMANTIC_WORKFLOW_CONTROL_MATCH_ANGLE string
---@field public SEMANTIC_WORKFLOW_CONTROL_REVERSE_YAW string
---@field public SEMANTIC_WORKFLOW_CONTROL_DYAW string
---@field public SEMANTIC_WORKFLOW_CONTROL_ATAN_RETIME string
---@field public SEMANTIC_WORKFLOW_CONTROL_ATAN_SELECT_START string
---@field public SEMANTIC_WORKFLOW_CONTROL_ATAN_SELECT_END string
---@field public SEMANTIC_WORKFLOW_CONTROL_ATAN string
---@field public SEMANTIC_WORKFLOW_CONTROL_ATAN_REVERSE string
---@field public SEMANTIC_WORKFLOW_CONTROL_HIGH_MAG string
---@field public SEMANTIC_WORKFLOW_CONTROL_SPDKICK string
---@field public SEMANTIC_WORKFLOW_PROJECT_FILE_VERSION string
---@field public SEMANTIC_WORKFLOW_PROJECT_NO_SHEETS_AVAILABLE string
---@field public SEMANTIC_WORKFLOW_PROJECT_NEW string
---@field public SEMANTIC_WORKFLOW_PROJECT_NEW_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_OPEN string
---@field public SEMANTIC_WORKFLOW_PROJECT_OPEN_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_SAVE string
---@field public SEMANTIC_WORKFLOW_PROJECT_SAVE_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_PURGE string
---@field public SEMANTIC_WORKFLOW_PROJECT_PURGE_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_CONFIRM_PURGE string
---@field public SEMANTIC_WORKFLOW_PROJECT_CONFIRM_SHEET_DELETION_1 string
---@field public SEMANTIC_WORKFLOW_PROJECT_CONFIRM_SHEET_DELETION_2 string
---@field public SEMANTIC_WORKFLOW_PROJECT_DISABLE_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_SELECT_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_ADD_SHEET string
---@field public SEMANTIC_WORKFLOW_PROJECT_REBASE_SHEET_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_REPLACE_INPUTS_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_PLAY_WITHOUT_ST_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_DELETE_SHEET_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_ADD_SHEET_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_MOVE_SHEET_UP_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PROJECT_MOVE_SHEET_DOWN_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_INPUTS_EXPAND_SECTION string
---@field public SEMANTIC_WORKFLOW_INPUTS_COLLAPSE_SECTION string
---@field public SEMANTIC_WORKFLOW_INPUTS_INSERT_SECTION string
---@field public SEMANTIC_WORKFLOW_INPUTS_INSERT_SECTION_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION string
---@field public SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_INPUTS_TIMEOUT string
---@field public SEMANTIC_WORKFLOW_INPUTS_TIMEOUT_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_INPUTS_END_ACTION string
---@field public SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TYPE_TO_SEARCH_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_INPUTS_INSERT_INPUT string
---@field public SEMANTIC_WORKFLOW_INPUTS_INSERT_INPUT_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_INPUTS_DELETE_INPUT string
---@field public SEMANTIC_WORKFLOW_INPUTS_DELETE_INPUT_TOOL_TIP string
---@field public SEMANTIC_WORKFLOW_PREFERENCES_EDIT_ENTIRE_STATE string
---@field public SEMANTIC_WORKFLOW_PREFERENCES_FAST_FORWARD string
---@field public SEMANTIC_WORKFLOW_PREFERENCES_DEFAULT_SECTION_TIMEOUT string
---@field public SETTINGS_VISUALS_TAB_NAME string
---@field public SETTINGS_INTERACTION_TAB_NAME string
---@field public SETTINGS_VARWATCH_TAB_NAME string
---@field public SETTINGS_MEMORY_TAB_NAME string
---@field public SETTINGS_VISUALS_STYLE string
---@field public SETTINGS_VISUALS_LOCALE string
---@field public SETTINGS_VISUALS_NOTIFICATIONS string
---@field public SETTINGS_VISUALS_NOTIFICATIONS_BUBBLE string
---@field public SETTINGS_VISUALS_NOTIFICATIONS_CONSOLE string
---@field public SETTINGS_VISUALS_FF_FPS string
---@field public SETTINGS_VISUALS_FF_FPS_TOOLTIP string
---@field public SETTINGS_VISUALS_UPDATE_EVERY_VI string
---@field public SETTINGS_VISUALS_UPDATE_EVERY_VI_TOOLTIP string
---@field public SETTINGS_VARWATCH_DISABLED string
---@field public SETTINGS_VARWATCH_HIDE string
---@field public SETTINGS_VARWATCH_ANGLE_FORMAT string
---@field public SETTINGS_VARWATCH_ANGLE_FORMAT_SHORT string
---@field public SETTINGS_VARWATCH_ANGLE_FORMAT_DEGREE string
---@field public SETTINGS_VARWATCH_DECIMAL_POINTS string
---@field public SETTINGS_VARWATCH_SPD_EFFICIENCY string
---@field public SETTINGS_VARWATCH_SPD_EFFICIENCY_PERCENTAGE string
---@field public SETTINGS_VARWATCH_SPD_EFFICIENCY_FRACTION string
---@field public SETTINGS_MEMORY_FILE_SELECT string
---@field public SETTINGS_MEMORY_DETECT_NOW string
---@field public SETTINGS_MEMORY_DETECT_ON_START string
---@field public SETTINGS_HOTKEYS_NOTHING string
---@field public SETTINGS_HOTKEYS_CONFIRMATION string
---@field public SETTINGS_HOTKEYS_CLEAR string
---@field public SETTINGS_HOTKEYS_RESET string
---@field public SETTINGS_HOTKEYS_ASSIGN string
---@field public SETTINGS_HOTKEYS_ACTIVATION string
---@field public SETTINGS_HOTKEYS_ACTIVATION_ALWAYS string
---@field public SETTINGS_HOTKEYS_ACTIVATION_WHEN_NO_FOCUS string
---@field public TOOLS_RNG string
---@field public TOOLS_RNG_LOCK string
---@field public TOOLS_RNG_USE_INDEX string
---@field public TOOLS_DUMPING string
---@field public TOOLS_GHOST string
---@field public TOOLS_GHOST_START string
---@field public TOOLS_GHOST_STOP string
---@field public TOOLS_GHOST_START_RECORDING_FAILED string
---@field public TOOLS_GHOST_STOP_RECORDING_FAILED string
---@field public TOOLS_TRACKERS string
---@field public TOOLS_OVERLAYS string
---@field public TOOLS_AUTOMATION string
---@field public TOOLS_MOVED_DIST string
---@field public TOOLS_MINI_OVERLAY string
---@field public TOOLS_AUTO_FIRSTIES string
---@field public TOOLS_WORLD_VISUALIZER string
---@field public TIMER_START string
---@field public TIMER_STOP string
---@field public TIMER_RESET string
---@field public TIMER_MANUAL string
---@field public TIMER_AUTO string
---@field public VARWATCH_FACING_YAW string
---@field public VARWATCH_INTENDED_YAW string
---@field public VARWATCH_H_SPEED string
---@field public VARWATCH_H_SLIDING string
---@field public VARWATCH_Y_SPEED string
---@field public VARWATCH_SPD_EFFICIENCY_PERCENTAGE string
---@field public VARWATCH_SPD_EFFICIENCY_FRACTION string
---@field public VARWATCH_POS_X string
---@field public VARWATCH_POS_Y string
---@field public VARWATCH_POS_Z string
---@field public VARWATCH_PITCH string
---@field public VARWATCH_YAW_VEL string
---@field public VARWATCH_PITCH_VEL string
---@field public VARWATCH_XZ_MOVEMENT string
---@field public VARWATCH_ACTION string
---@field public VARWATCH_UNKNOWN_ACTION string
---@field public VARWATCH_RNG string
---@field public VARWATCH_RNG_INDEX string
---@field public VARWATCH_GLOBAL_TIMER string
---@field public VARWATCH_DIST_MOVED string
---@field public ADDRESS_USA string
---@field public ADDRESS_JAPAN string
---@field public ADDRESS_SHINDOU string
---@field public ADDRESS_PAL string
---@field public SEMANTIC_WORKFLOW_HELP_EXPLANATIONS { PROJECT_TAB: SemanticWorkflowHelpSection, INPUTS_TAB: SemanticWorkflowHelpSection, PREFERENCES_TAB: SemanticWorkflowHelpSection }
---@field public ACTIONS { [integer]: string }

---@alias SemanticWorkflowHelpSection { HEADING: string, PAGES: { HEADING: string, TEXT: string }[] }

---@type Locale[]
local locales = {}

local files = {
    'en_US',
}

for i = 1, #files, 1 do
    local name = files[i]
    locales[i] = dofile(string.format('%s%s.lua', locales_path, name))
end

---@return string[] # The names of all available locales.
---@nodiscard
Locales.names = function()
    return lualinq.select_key(locales, 'name')
end

---Gets a string from the current locale.
---@param id string # The identifier of the string to query.
---@return string # The localized string, or the identifier if not found.
---@nodiscard
Locales.str = function(id)
    local val = locales[Settings.locale_index][id]
    return val or id
end

---Gets the raw locale table for the current locale.
---@return Locale
---@nodiscard
Locales.raw = function()
    return locales[Settings.locale_index]
end

---Gets a localized action string.
---@param raw integer # The raw action identifier.
---@return string # The localized action string, or a hex representation if not found.
---@nodiscard
Locales.action = function(raw)
    return Locales.raw().ACTIONS[raw] or string.format('%x', raw)
end
