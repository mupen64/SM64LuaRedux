--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('VisualSettingsV3', function(enum_next)
    return {
        ActiveStyle = enum_next(ugui.registry.combobox.uids()),
        Locale = enum_next(ugui.registry.combobox.uids()),
        NotificationStyle = enum_next(ugui.registry.carrousel_button.uids()),
        RepaintThrottle = enum_next(ugui.registry.numberbox.uids()),
        EnableManualOnJoystickInteract = enum_next(ugui.registry.toggle_button.uids()),
        LockHotkeysWhenControlActive = enum_next(ugui.registry.toggle_button.uids()),
        VisualGroup = enum_next(ugui.registry.toggle_button.uids()),
        InteractionGroup = enum_next(ugui.registry.toggle_button.uids()),
        VisualGroupLabel = enum_next(ugui.registry.label.uids()),
        InteractionGroupLabel = enum_next(ugui.registry.label.uids()),
        VisualItemLabelBase = enum_next(4 * ugui.registry.label.uids()),
        InteractionItemLabelBase = enum_next(2 * ugui.registry.label.uids()),
    }
end)

local visual_items = {
    {
        text = function() return Locales.str('SETTINGS_VISUALS_STYLE') end,
        func = function(rect)
            local new_active_style_index = ugui.combobox({
                uid = UID.ActiveStyle,
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
        text = function() return Locales.str('SETTINGS_VISUALS_LOCALE') end,
        func = function(rect)
            local new_locale_index = ugui.combobox({
                uid = UID.Locale,
                rectangle = rect,
                items = Locales.names(),
                selected_index = Settings.locale_index,
            })
            Settings.locale_index = new_locale_index
        end,
    },
    {
        text = function() return Locales.str('SETTINGS_VISUALS_NOTIFICATIONS') end,
        func = function(rect)
            local notification_styles = {
                Locales.str('SETTINGS_VISUALS_NOTIFICATIONS_BUBBLE'),
                Locales.str('SETTINGS_VISUALS_NOTIFICATIONS_CONSOLE'),
            }

            local index = ugui.carrousel_button({
                uid = UID.NotificationStyle,
                rectangle = rect,
                items = notification_styles,
                selected_index = Settings.notification_style,
                tooltip = Locales.str('SETTINGS_VISUALS_NOTIFICATIONS_TOOLTIP'),
            })

            Settings.notification_style = index
        end,
    },
    {
        text = function() return Locales.str('SETTINGS_VISUALS_FF_FPS') end,
        func = function(rect)
            Settings.ff_fps = math.max(1, math.abs(ugui.numberbox({
                uid = UID.RepaintThrottle,
                rectangle = rect,
                tooltip = Locales.str('SETTINGS_VISUALS_FF_FPS_TOOLTIP'),
                value = Settings.ff_fps,
                places = 2,
            })))
        end,
    },
}

local interaction_items = {
    {
        text = function() return Locales.str('SETTINGS_INTERACTION_MANUAL_ON_JOYSTICK_INTERACT') end,
        func = function(rect)
            Settings.enable_manual_on_joystick_interact = ugui.toggle_button({
                uid = UID.EnableManualOnJoystickInteract,
                rectangle = rect,
                is_checked = Settings.enable_manual_on_joystick_interact,
                text = Locales.str('GENERIC_ON'),
            })
        end,
    },
    {
        text = function() return Locales.str('SETTINGS_INTERACTION_LOCK_HOTKEYS_WHEN_CONTROL_ACTIVE') end,
        func = function(rect)
            Settings.lock_hotkeys_when_control_active = ugui.toggle_button({
                uid = UID.LockHotkeysWhenControlActive,
                rectangle = rect,
                is_checked = Settings.lock_hotkeys_when_control_active,
                text = Locales.str('GENERIC_ON'),
            })
        end,
    },
}

local function draw_setting_item(item, y, label_uid)
    local theme = Styles.theme()
    local foreground_color = Drawing.foreground_color()

    ugui.label({
        uid = label_uid,
        rectangle = grid_rect(0, y, 8, 0.5),
        text = item.text(),
        color = foreground_color,
        font_size = theme.font_size * Drawing.scale * 1.1,
        font_name = theme.font_name,
        align_x = BreitbandGraphics.alignment.start,
        align_y = BreitbandGraphics.alignment.center,
    })

    item.func(grid_rect(0, y + 0.6, 4, 1))
    return y + 1.75
end

local function draw_group(group, y)
    local theme = Styles.theme()
    local foreground_color = Drawing.foreground_color()

    ugui.label({
        uid = group.label_uid,
        rectangle = grid_rect(1.1, y, 6.9, 1),
        text = group.text(),
        color = foreground_color,
        font_size = theme.font_size * Drawing.scale * 1.1,
        font_name = theme.font_name,
        align_x = BreitbandGraphics.alignment.start,
        align_y = BreitbandGraphics.alignment.center,
        styler_mixin = { is_bold = true },
    })

    group.expanded = ugui.toggle_button({
        uid = group.uid,
        rectangle = grid_rect(0, y, 1, 1),
        text = group.expanded and '[icon:arrow_down]' or '[icon:arrow_right]',
        is_checked = group.expanded,
        styler_mixin = { icon_size = 14 },
    })

    y = y + 1.1
    if group.expanded then
        for item_index = 1, #group.items, 1 do
            y = draw_setting_item(group.items[item_index], y, group.item_label_uid_base + item_index - 1)
        end
        return y + 0.3
    end
    return y + 0.2
end

local groups = {
    {
        uid = UID.VisualGroup,
        label_uid = UID.VisualGroupLabel,
        item_label_uid_base = UID.VisualItemLabelBase,
        text = function() return Locales.str('SETTINGS_VISUALS_TAB_NAME') end,
        items = visual_items,
        expanded = true,
    },
    {
        uid = UID.InteractionGroup,
        label_uid = UID.InteractionGroupLabel,
        item_label_uid_base = UID.InteractionItemLabelBase,
        text = function() return Locales.str('SETTINGS_INTERACTION_TAB_NAME') end,
        items = interaction_items,
        expanded = true,
    },
}

local function draw_groups()
    local y = 0.2
    for i = 1, #groups, 1 do
        y = draw_group(groups[i], y)
    end
end

return {
    name = function() return Locales.str('SETTINGS_VISUALS_TAB_NAME') end,
    draw = function()
        draw_groups()
    end,
}
