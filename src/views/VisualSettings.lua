--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local items = {
    {
        text = Locales.str('SETTINGS_VISUALS_STYLE'),
        func = function(rect)
            local new_active_style_index = ugui.combobox({
                uid = 1,
                rectangle = rect,
                items = Styles.theme_names(),
                selected_index = Settings.active_style_index,
            })

            if new_active_style_index ~= Settings.active_style_index then
                Settings.active_style_index = new_active_style_index
                Styles.update_style()
            end
        end,
    },
    {
        text = Locales.str('SETTINGS_VISUALS_LOCALE'),
        func = function(rect)
            local new_locale_index = ugui.combobox({
                uid = 3,
                rectangle = rect,
                items = Locales.names(),
                selected_index = Settings.locale_index,
            })
            Settings.locale_index = new_locale_index
        end,
    },
    {
        text = Locales.str('SETTINGS_VISUALS_NOTIFICATIONS'),
        func = function(rect)
            local notification_styles = {
                Locales.str('SETTINGS_VISUALS_NOTIFICATIONS_BUBBLE'),
                Locales.str('SETTINGS_VISUALS_NOTIFICATIONS_CONSOLE'),
            }

            local index = ugui.carrousel_button({
                uid = 5,
                rectangle = rect,
                items = notification_styles,
                selected_index = Settings.notification_style,
                tooltip =
                'The style used for notifications.\n    Bubble: Show notifications over the game.\n    Console: Show notifications in the Lua console.',
            })

            Settings.notification_style = index
        end,
    },
    {
        text = Locales.str('SETTINGS_VISUALS_FRAMESKIP'),
        func = function(rect)
            Settings.repaint_throttle = math.max(1, math.abs(ugui.numberbox({
                uid = 20,
                rectangle = rect,
                tooltip = Locales.str('SETTINGS_VISUALS_FRAMESKIP_TOOLTIP'),
                value = Settings.repaint_throttle,
                places = 1,
            })))
        end,
    },
}

return {
    name = Locales.str('SETTINGS_VISUALS_TAB_NAME'),
    draw = function()
        Drawing.setting_list(items, { x = 0, y = 0.1 })
    end,
}
