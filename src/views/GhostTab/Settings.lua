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
        DisableBodyMovement = enum_next(ugui.toggle_button_uids()),
        RecordVariablesLabel = enum_next(ugui.label_uids()),
        -- one toggle per entry in GHOST_RECORDABLE_VARIABLES (loaded first by GhostTab/Main.lua)
        RecordVariables = enum_next(ugui.toggle_button_uids() * #GHOST_RECORDABLE_VARIABLES),
        HighlightColorLabel = enum_next(ugui.label_uids()),
        HighlightColor = enum_next(ugui.textbox_uids()),
        HighlightColorPickerButton = enum_next(ugui.button_uids()),
        HighlightColorSwatch = enum_next(ugui.panel_uids()),
        HighlightColorPicker = enum_next(ugui.colorpicker_uids()),
        HighlightColorPickerOk = enum_next(ugui.button_uids()),
        HighlightColorPickerCancel = enum_next(ugui.button_uids()),
    }
end)

local Colors = dofile(views_path .. 'GhostTab/Colors.lua')

-- highlight color editing state, like the playback tab's hat color
local highlight_text = nil
local picker_open = false
local picker_original = nil

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

        -- takes effect the next time the hack is applied
        Settings.ghost_disable_body_movement = ugui.toggle_button({
            uid = UID.DisableBodyMovement,
            rectangle = grid_rect(0.1, 6, 7.8, 1),
            text = Locales.str('GHOST_SETTINGS_DISABLE_BODY_MOVEMENT'),
            tooltip = Locales.str('GHOST_SETTINGS_DISABLE_BODY_MOVEMENT_TOOLTIP'),
            is_checked = Settings.ghost_disable_body_movement or false,
        })

        -- extra data recorded with each frame, laid out in two columns
        ugui.label({
            uid = UID.RecordVariablesLabel,
            rectangle = grid_rect(0.1, 7, 7.8, 1),
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
                rectangle = grid_rect(0.1 + column * 3.9, 7.9 + row, 3.8, 1),
                text = Locales.str(variable.locale),
                tooltip = Locales.str('GHOST_SETTINGS_RECORD_VARIABLE_TOOLTIP'),
                is_checked = Settings.ghost_recorded_variables[variable.id] or false,
                is_enabled = not Ghosts.is_recording(),
            })
        end

        -- color of the world visualizer box around the object picked by name in the recording tab
        ugui.label({
            uid = UID.HighlightColorLabel,
            rectangle = grid_rect(0.1, 11, 4.5, 1),
            text = Locales.str('GHOST_SETTINGS_HIGHLIGHT_COLOR'),
            color = Drawing.foreground_color(),
            font_size = theme.font_size * 1.25,
            font_name = theme.font_name,
            align_x = ugui.alignment['start'],
            align_y = ugui.alignment.center,
        })

        local color = Settings.ghost_recording_highlight_color or {255, 0, 0}
        if highlight_text == nil or ugui.internal.keyboard_captured_control ~= UID.HighlightColor then
            highlight_text = Colors.rgb_to_str(color)
        end
        highlight_text = ugui.textbox({
            uid = UID.HighlightColor,
            rectangle = grid_rect(4.6, 11.1, 2.3, 0.8),
            text = highlight_text,
            tooltip = Locales.str('GHOST_SETTINGS_HIGHLIGHT_COLOR_TOOLTIP'),
            styler_mixin = {
                font_size = theme.font_size * 1.25,
            },
        })
        local typed_color = Colors.parse_hex_color(highlight_text)
        if typed_color then
            color = typed_color
        end

        local swatch_rect = grid_rect(7, 11.1, 0.8, 0.8)
        local open_picker = ugui.button({
            uid = UID.HighlightColorPickerButton,
            rectangle = swatch_rect,
            text = '',
            tooltip = Locales.str('GHOST_COLOR_PICKER_TOOLTIP'),
        })
        -- the panel isn't hittestable, so clicks still reach the button underneath
        ugui.panel({
            uid = UID.HighlightColorSwatch,
            rectangle = {
                x = swatch_rect.x + 4,
                y = swatch_rect.y + 4,
                width = swatch_rect.width - 8,
                height = swatch_rect.height - 8,
            },
            fill = Colors.rgb_to_str(color),
        })
        if open_picker then
            picker_open = not picker_open
            picker_original = { color[1], color[2], color[3] }
        end

        if picker_open then
            local picked_rgb = Colors.ugui_color_to_rgb(ugui.colorpicker({
                uid = UID.HighlightColorPicker,
                rectangle = grid_rect(0.1, 12, 3, 3),
                color = Colors.rgb_to_ugui_color(color),
                shape = 'circle',
                band_position = 'right',
            }))
            if picked_rgb[1] ~= color[1] or picked_rgb[2] ~= color[2] or picked_rgb[3] ~= color[3] then
                color = picked_rgb
            end

            if ugui.button({
                    uid = UID.HighlightColorPickerOk,
                    rectangle = grid_rect(3.3, 12.1, 2.1, 0.8),
                    text = Locales.str('GHOST_COLOR_PICKER_OK'),
                    tooltip = Locales.str('GHOST_COLOR_PICKER_OK_TOOLTIP'),
                }) then
                picker_open = false
            end

            if ugui.button({
                    uid = UID.HighlightColorPickerCancel,
                    rectangle = grid_rect(5.5, 12.1, 2.1, 0.8),
                    text = Locales.str('GHOST_COLOR_PICKER_CANCEL'),
                    tooltip = Locales.str('GHOST_COLOR_PICKER_CANCEL_TOOLTIP'),
                }) then
                color = picker_original
                picker_open = false
            end
        end
        Settings.ghost_recording_highlight_color = color
    end
}
