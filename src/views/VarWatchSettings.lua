--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('VarWatchSettings', function(enum_next)
    return {
        AngleFormat = enum_next(),
        DecimalPlaces = enum_next(2),
        SelectedVar = enum_next(4),
        MoveVarUp = enum_next(),
        MoveVarDown = enum_next(),
        HideVar = enum_next(),
    }
end)

local items = {
    {
        text = function() return Locales.str('SETTINGS_VARWATCH_ANGLE_FORMAT') end,
        func = function(rect)
            if ugui.button({
                    uid = UID.AngleFormat,
                    rectangle = rect,
                    text = Settings.format_angles_degrees and Locales.str('SETTINGS_VARWATCH_ANGLE_FORMAT_DEGREE') or Locales.str('SETTINGS_VARWATCH_ANGLE_FORMAT_SHORT'),
                    tooltip = Locales.str('SETTINGS_VARWATCH_ANGLE_FORMAT_TOOLTIP'),
                }) then
                Settings.format_angles_degrees = not Settings.format_angles_degrees
            end
        end,
    },
    {
        text = function() return Locales.str('SETTINGS_VARWATCH_DECIMAL_POINTS') end,
        func = function(rect)
            Settings.format_decimal_points = math.abs(ugui.numberbox({
                uid = UID.DecimalPlaces,
                rectangle = rect,
                value = Settings.format_decimal_points,
                places = 1,
                tooltip = Locales.str('SETTINGS_VARWATCH_DECIMAL_POINTS_TOOLTIP'),
            }))
        end,
    },
    {
        text = function() return Locales.str('SETTINGS_VARWATCH_SPD_EFFICIENCY') end,
        func = function(rect)
            if ugui.button({
                    uid = UID.SpeedEfficiency,
                    rectangle = rect,
                    text = Settings.spd_efficiency_fraction and Locales.str('SETTINGS_VARWATCH_SPD_EFFICIENCY_FRACTION') or Locales.str('SETTINGS_VARWATCH_SPD_EFFICIENCY_PERCENTAGE'),
                    tooltip = Locales.str('SETTINGS_VARWATCH_SPD_EFFICIENCY_TOOLTIP'),
                }) then
                Settings.spd_efficiency_fraction = not Settings.spd_efficiency_fraction
            end
        end,
    },
}

local selected_var_index = 1

return {
    name = function() return Locales.str('SETTINGS_VARWATCH_TAB_NAME') end,
    draw = function()
        selected_var_index = ugui.listbox({
            uid = UID.SelectedVar,
            rectangle = grid_rect(0, 0, 8, 8),
            selected_index = selected_var_index,
            items = lualinq.select(Settings.variables, function(x)
                if not x.visible then
                    return x.identifier .. ' ' .. Locales.str('SETTINGS_VARWATCH_DISABLED')
                end
                return x.identifier
            end),
        })

        if ugui.button({
                uid = UID.MoveVarUp,
                is_enabled = selected_var_index > 1,
                rectangle = grid_rect(0, 8, 1, 1),
                text = '[icon:arrow_up]',
            }) then
            swap(Settings.variables, selected_var_index, selected_var_index - 1)
            selected_var_index = selected_var_index - 1
        end

        if ugui.button({
                uid = UID.MoveVarDown,
                is_enabled = selected_var_index < #Settings.variables,
                rectangle = grid_rect(1, 8, 1, 1),
                text = '[icon:arrow_down]',
            }) then
            swap(Settings.variables, selected_var_index, selected_var_index + 1)
            selected_var_index = selected_var_index + 1
        end

        Settings.variables[selected_var_index].visible = not ugui.toggle_button({
            uid = UID.HideVar,
            rectangle = grid_rect(2, 8, 2, 1),
            text = Locales.str('SETTINGS_VARWATCH_HIDE'),
            is_checked = not Settings.variables[selected_var_index].visible,
        })

        Drawing.setting_list(items, { x = 0, y = 9 })
    end,
}
