--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('GhostSettings', function(enum_next)
    return {
        AutoLoad = enum_next(ugui.toggle_button_uids()),
        TransparentDefault = enum_next(ugui.toggle_button_uids()),
        BaseOffsetLabel = enum_next(ugui.label_uids()),
        BaseOffset = enum_next(ugui.textbox_uids()),
        ShowPlaybackWarning = enum_next(ugui.toggle_button_uids()),
        OverlayData = enum_next(ugui.toggle_button_uids()),
        RecordVariablesLabel = enum_next(ugui.label_uids()),
        -- one toggle per entry in GHOST_RECORDABLE_VARIABLES (loaded first by GhostTab/Main.lua)
        RecordVariables = enum_next(ugui.toggle_button_uids() * #GHOST_RECORDABLE_VARIABLES),
    }
end)

-- text being typed into the base offset box, kept while it's focused so partial input isn't reverted
local base_offset_text = nil

return {
    name = function() return Locales.str('SETTINGS_TAB_NAME') end,
    draw = function()
        local theme = Styles.theme()

        Settings.ghost_recording_auto_load = ugui.toggle_button({
            uid = UID.AutoLoad,
            rectangle = grid_rect(0.1, 1, 7.8, 1),
            text = Locales.str('GHOST_SETTINGS_AUTO_LOAD'),
            tooltip = Locales.str('GHOST_SETTINGS_AUTO_LOAD_TOOLTIP'),
            is_checked = Settings.ghost_recording_auto_load,
        })

        Settings.ghost_transparent_default = ugui.toggle_button({
            uid = UID.TransparentDefault,
            rectangle = grid_rect(0.1, 2, 7.8, 1),
            text = Locales.str('GHOST_SETTINGS_TRANSPARENT_DEFAULT'),
            tooltip = Locales.str('GHOST_SETTINGS_TRANSPARENT_DEFAULT_TOOLTIP'),
            is_checked = Settings.ghost_transparent_default,
        })

        ugui.label({
            uid = UID.BaseOffsetLabel,
            rectangle = grid_rect(0.1, 3, 4, 1),
            text = Locales.str('GHOST_SETTINGS_BASE_OFFSET'),
            color = Drawing.foreground_color(),
            font_size = theme.font_size * 1.25,
            font_name = theme.font_name,
            align_x = ugui.alignment['start'],
            align_y = ugui.alignment.center,
        })

        -- a move requested while the hack is running finishes once its ghosts are freed
        local target_base = Ghosts.get_pending_base_offset() or Ghosts.base_offset
        local is_focused = ugui.internal.keyboard_captured_control == UID.BaseOffset
        if not is_focused then
            base_offset_text = string.format('0x%X', target_base)
        end
        base_offset_text = ugui.textbox({
            uid = UID.BaseOffset,
            rectangle = grid_rect(4.1, 3.1, 3.8, 0.8),
            text = base_offset_text,
            tooltip = Locales.str('GHOST_SETTINGS_BASE_OFFSET_TOOLTIP'),
            styler_mixin = {
                font_size = theme.font_size * 1.25,
            },
        })
        -- accepts 8060, 0x8060 or 0x80600000; Ghosts.set_base_offset ignores invalid values
        local base = tonumber((base_offset_text:gsub('^%s*0[xX]', '')), 16)
        if base and base > 0xFFFF and base & 0xFFFF == 0 then
            base = base >> 16
        end
        if base and base ~= target_base then
            Ghosts.set_base_offset(base)
        end

        Settings.ghost_playback_warning_accepted = not ugui.toggle_button({
            uid = UID.ShowPlaybackWarning,
            rectangle = grid_rect(0.1, 4, 7.8, 1),
            text = Locales.str('GHOST_SETTINGS_SHOW_PLAYBACK_WARNING'),
            tooltip = Locales.str('GHOST_SETTINGS_SHOW_PLAYBACK_WARNING_TOOLTIP'),
            is_checked = not Settings.ghost_playback_warning_accepted,
        })

        Settings.ghost_overlay_data = ugui.toggle_button({
            uid = UID.OverlayData,
            rectangle = grid_rect(0.1, 5, 7.8, 1),
            text = Locales.str('GHOST_SETTINGS_OVERLAY_DATA'),
            tooltip = Locales.str('GHOST_SETTINGS_OVERLAY_DATA_TOOLTIP'),
            is_checked = Settings.ghost_overlay_data or false,
        })

        -- extra data recorded with each frame, laid out in two columns
        ugui.label({
            uid = UID.RecordVariablesLabel,
            rectangle = grid_rect(0.1, 6, 7.8, 1),
            text = Locales.str('GHOST_SETTINGS_RECORD_VARIABLES'),
            color = Drawing.foreground_color(),
            font_size = theme.font_size * 1.25,
            font_name = theme.font_name,
            align_x = ugui.alignment['start'],
            align_y = ugui.alignment.center,
        })
        -- presets saved before this setting existed don't have the table
        Settings.ghost_recorded_variables = Settings.ghost_recorded_variables or {}
        for i, variable in ipairs(GHOST_RECORDABLE_VARIABLES) do
            local column, row = (i - 1) % 2, (i - 1) // 2
            Settings.ghost_recorded_variables[variable.id] = ugui.toggle_button({
                uid = UID.RecordVariables + (i - 1) * ugui.toggle_button_uids(),
                rectangle = grid_rect(0.1 + column * 3.9, 6.9 + row, 3.8, 1),
                text = Locales.str(variable.locale),
                tooltip = Locales.str('GHOST_SETTINGS_RECORD_VARIABLE_TOOLTIP'),
                is_checked = Settings.ghost_recorded_variables[variable.id] or false,
                is_enabled = not Ghosts.is_recording(),
            })
        end
    end
}
