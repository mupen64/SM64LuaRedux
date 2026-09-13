--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('SettingsV5', function(enum_next)
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
        LoadMapFile = enum_next(ugui.registry.button.uids()),
        Region = enum_next(ugui.registry.combobox.uids()),
        AutoDetect = enum_next(ugui.registry.button.uids()),
        DetectOnStart = enum_next(ugui.registry.toggle_button.uids()),
        MemoryGroup = enum_next(ugui.registry.toggle_button.uids()),
        MemoryGroupLabel = enum_next(ugui.registry.label.uids()),
        MemoryItemLabelBase = enum_next(4 * ugui.registry.label.uids()),
        Scrollbar = enum_next(ugui.registry.scrollbar.uids()),
        AngleFormat = enum_next(ugui.registry.button.uids()),
        DecimalPlaces = enum_next(ugui.registry.numberbox.uids()),
        SelectedVar = enum_next(ugui.registry.listbox.uids()),
        MoveVarUp = enum_next(ugui.registry.button.uids()),
        MoveVarDown = enum_next(ugui.registry.button.uids()),
        HideVar = enum_next(ugui.registry.toggle_button.uids()),
        VarWatchGroup = enum_next(ugui.registry.toggle_button.uids()),
        VarWatchGroupLabel = enum_next(ugui.registry.label.uids()),
        NavbarCoverLabel = enum_next(ugui.registry.label.uids()),
        VarWatchItemLabelBase = enum_next(UIDProvider.unknown),
    }
end)

local VIEWPORT_HEIGHT = 15
local content_height = VIEWPORT_HEIGHT

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
        show_label = false,
        control_width = 7.5,
        text = function() return Locales.str('SETTINGS_INTERACTION_MANUAL_ON_JOYSTICK_INTERACT') end,
        func = function(rect)
            Settings.enable_manual_on_joystick_interact = ugui.toggle_button({
                uid = UID.EnableManualOnJoystickInteract,
                rectangle = rect,
                is_checked = Settings.enable_manual_on_joystick_interact,
                text = Locales.str('SETTINGS_INTERACTION_MANUAL_ON_JOYSTICK_INTERACT'),
                tooltip = Locales.str('SETTINGS_INTERACTION_MANUAL_ON_JOYSTICK_INTERACT_TOOLTIP'),
            })
        end,
    },
    {
        show_label = false,
        control_width = 7.5,
        text = function() return Locales.str('SETTINGS_INTERACTION_LOCK_HOTKEYS_WHEN_CONTROL_ACTIVE') end,
        func = function(rect)
            Settings.lock_hotkeys_when_control_active = ugui.toggle_button({
                uid = UID.LockHotkeysWhenControlActive,
                rectangle = rect,
                is_checked = Settings.lock_hotkeys_when_control_active,
                text = Locales.str('SETTINGS_INTERACTION_LOCK_HOTKEYS_WHEN_CONTROL_ACTIVE'),
                tooltip = Locales.str('SETTINGS_INTERACTION_LOCK_HOTKEYS_WHEN_CONTROL_ACTIVE_TOOLTIP'),
            })
        end,
    },
}

local function draw_setting_item(item, y, label_uid)
    local theme = Styles.theme()
    local foreground_color = Drawing.foreground_color()

    local control_width = item.control_width or 4
    local control_height = item.control_height or 1

    if item.show_label ~= false then
        local control_x = 7.5 - control_width

        ugui.label({
            uid = label_uid,
            rectangle = grid_rect(0, y, control_x, control_height),
            text = item.text(),
            color = foreground_color,
            font_size = theme.font_size * Drawing.scale * 1.1,
            font_name = theme.font_name,
            align_x = BreitbandGraphics.alignment.start,
            align_y = BreitbandGraphics.alignment.center,
            fit = true
        })

        item.func(grid_rect(control_x, y, control_width, control_height))
        return y + (item.row_height or 1.25)
    end

    item.func(grid_rect(0, y, control_width, control_height))
    return y + (item.row_height or 1.25)
end

local function draw_group(group, y)
    local theme = Styles.theme()
    local foreground_color = Drawing.foreground_color()

    ugui.label({
        uid = group.label_uid,
        rectangle = grid_rect(1.1, y, 6.4, 1),
        text = group.text(),
        color = foreground_color,
        font_size = theme.font_size * Drawing.scale * 1.1,
        font_name = theme.font_name,
        align_x = BreitbandGraphics.alignment.start,
        align_y = BreitbandGraphics.alignment.center,
        styler_mixin = { is_bold = true },
    })

    local expanded = Settings[group.expanded_setting]
    local new_expanded = ugui.toggle_button({
        uid = group.uid,
        rectangle = grid_rect(0, y, 1, 1),
        text = expanded and '[icon:arrow_down]' or '[icon:arrow_right]',
        is_checked = expanded,
        styler_mixin = { icon_size = 14 },
    })
    Settings[group.expanded_setting] = new_expanded

    y = y + 1.1
    if new_expanded then
        for item_index = 1, #group.items, 1 do
            y = draw_setting_item(group.items[item_index], y, group.item_label_uid_base + item_index - 1)
        end
        return y + 0.3
    end
    return y
end

local selected_var_index = 1

local varwatch_items = {
    {
        show_label = false,
        control_width = 7.5,
        control_height = 9,
        row_height = 9.25,
        text = function() return '' end,
        func = function(rect)
            local row = Settings.grid_size * Drawing.scale
            local list_rectangle = {
                x = rect.x,
                y = rect.y,
                width = rect.width,
                height = row * 8,
            }

            selected_var_index = ugui.listbox({
                uid = UID.SelectedVar,
                rectangle = list_rectangle,
                selected_index = selected_var_index,
                items = lualinq.select(Settings.variables, function(x)
                    if not x.visible then
                        return x.identifier .. ' ' .. Locales.str('SETTINGS_VARWATCH_DISABLED')
                    end
                    return x.identifier
                end),
            })

            local button_size = row * 0.8
            local button_gap = row * 0.1
            local button_y = rect.y + row * 8 + (row - button_size) / 2
            if ugui.button({
                    uid = UID.MoveVarUp,
                    is_enabled = selected_var_index > 1,
                    rectangle = { x = rect.x, y = button_y, width = button_size, height = button_size },
                    text = '[icon:arrow_up]',
                }) then
                swap(Settings.variables, selected_var_index, selected_var_index - 1)
                selected_var_index = selected_var_index - 1
            end

            if ugui.button({
                    uid = UID.MoveVarDown,
                    is_enabled = selected_var_index < #Settings.variables,
                    rectangle = { x = rect.x + button_size + button_gap, y = button_y, width = button_size, height = button_size },
                    text = '[icon:arrow_down]',
                }) then
                swap(Settings.variables, selected_var_index, selected_var_index + 1)
                selected_var_index = selected_var_index + 1
            end

            Settings.variables[selected_var_index].visible = not ugui.toggle_button({
                uid = UID.HideVar,
                rectangle = { x = rect.x + (button_size + button_gap) * 2, y = button_y, width = button_size * 2, height = button_size },
                text = Locales.str('SETTINGS_VARWATCH_HIDE'),
                is_checked = not Settings.variables[selected_var_index].visible,
            })
        end,
    },
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
}

local memory_items = {
    {
        show_label = false,
        text = function() return Locales.str('SETTINGS_MEMORY_FILE_SELECT') end,
        func = function(rect)
            if ugui.button({
                    uid = UID.LoadMapFile,
                    rectangle = rect,
                    text = Locales.str('SETTINGS_MEMORY_FILE_SELECT'),
                    is_enabled = false,
                }) then
                local path = iohelper.filediag('*.map', 0)
                if string.len(path) > 0 then
                    local file = io.open(path, 'r')
                    if file then
                        local text = file:read('a')
                        io.close(file)
                        -- TODO: Implement
                    end
                end
            end
        end,
    },
    {
        text = function() return Locales.str('SETTINGS_MEMORY_REGION') end,
        func = function(rect)
            Settings.address_source_index = ugui.combobox({
                uid = UID.Region,
                rectangle = rect,
                items = lualinq.select(Addresses, function(addr) return addr.name() end),
                selected_index = Settings.address_source_index,
                tooltip = Locales.str('SETTINGS_MEMORY_REGION_TOOLTIP'),
            })
        end,
    },
    {
        show_label = false,
        text = function() return Locales.str('SETTINGS_MEMORY_DETECT_NOW') end,
        func = function(rect)
            if ugui.button({
                    uid = UID.AutoDetect,
                    rectangle = rect,
                    text = Locales.str('SETTINGS_MEMORY_DETECT_NOW'),
                    tooltip = Locales.str('SETTINGS_MEMORY_DETECT_NOW_TOOLTIP'),
                }) then
                Settings.address_source_index = Memory.find_matching_address_source_index()
            end
        end,
    },
    {
        show_label = false,
        text = function() return Locales.str('SETTINGS_MEMORY_DETECT_ON_START') end,
        func = function(rect)
            Settings.autodetect_address = ugui.toggle_button({
                uid = UID.DetectOnStart,
                rectangle = rect,
                text = Locales.str('SETTINGS_MEMORY_DETECT_ON_START'),
                is_checked = Settings.autodetect_address,
                tooltip = Locales.str('SETTINGS_MEMORY_DETECT_ON_START_TOOLTIP'),
            })
        end,
    },
}

local groups = {
    {
        uid = UID.VisualGroup,
        label_uid = UID.VisualGroupLabel,
        item_label_uid_base = UID.VisualItemLabelBase,
        text = function() return Locales.str('SETTINGS_VISUALS_TAB_NAME') end,
        items = visual_items,
        expanded_setting = 'settings_visuals_expanded',
    },
    {
        uid = UID.InteractionGroup,
        label_uid = UID.InteractionGroupLabel,
        item_label_uid_base = UID.InteractionItemLabelBase,
        text = function() return Locales.str('SETTINGS_INTERACTION_TAB_NAME') end,
        items = interaction_items,
        expanded_setting = 'settings_interaction_expanded',
    },
    {
        uid = UID.MemoryGroup,
        label_uid = UID.MemoryGroupLabel,
        item_label_uid_base = UID.MemoryItemLabelBase,
        text = function() return Locales.str('SETTINGS_MEMORY_TAB_NAME') end,
        items = memory_items,
        expanded_setting = 'settings_memory_expanded',
    },
    {
        uid = UID.VarWatchGroup,
        label_uid = UID.VarWatchGroupLabel,
        item_label_uid_base = UID.VarWatchItemLabelBase,
        text = function() return Locales.str('SETTINGS_VARWATCH_TAB_NAME') end,
        items = varwatch_items,
        expanded_setting = 'settings_varwatch_expanded',
    },
}

local function draw_groups()
    local y = 0.2
    for i = 1, #groups, 1 do
        y = draw_group(groups[i], y)
    end
    content_height = y
end

return {
    name = function() return Locales.str('SETTINGS_TAB_NAME') end,
    draw = function()
        local scrollbar_rectangle = grid_rect(7.5, 0, 0.5, VIEWPORT_HEIGHT)
        if Settings.navbar_visible then
            scrollbar_rectangle.height = grid_rect(0, 16, 0, 0).y - scrollbar_rectangle.y
        else
            scrollbar_rectangle.height = Drawing.size.height - scrollbar_rectangle.y
        end
        local content_rectangle = grid_rect(0, 0, 7.5, VIEWPORT_HEIGHT)
        local cell_height = Settings.grid_size * Drawing.scale
        local max_scroll = math.max(0, (content_height - VIEWPORT_HEIGHT) * cell_height)

        if can_scroll() then
            if ugui.internal.is_mouse_wheel_up() then
                Settings.settings_scroll_offset = math.max(0, Settings.settings_scroll_offset - cell_height * 3)
            elseif ugui.internal.is_mouse_wheel_down() then
                Settings.settings_scroll_offset = math.min(max_scroll,
                    Settings.settings_scroll_offset + cell_height * 3)
            end
        end

        BreitbandGraphics.push_clip(content_rectangle)
        Drawing.push_offset(0, -Settings.settings_scroll_offset)
        draw_groups()
        Drawing.pop_offset()
        BreitbandGraphics.pop_clip()

        max_scroll = math.max(0, (content_height - VIEWPORT_HEIGHT) * cell_height)
        if max_scroll > 0 then
            Settings.settings_scroll_offset = math.min(Settings.settings_scroll_offset, max_scroll)
            local relative_scroll = ugui.scrollbar({
                uid = UID.Scrollbar,
                rectangle = scrollbar_rectangle,
                value = Settings.settings_scroll_offset / max_scroll,
                ratio = VIEWPORT_HEIGHT / content_height,
            })
            Settings.settings_scroll_offset = relative_scroll * max_scroll
        else
            Settings.settings_scroll_offset = 0
        end

        if Settings.navbar_visible then
            local cover_rectangle = grid_rect(0, 16, 8, 30)

            -- HACK: Block hittesting with a dummy label below the navbar because the controls scroll under it
            defer_before_navbar(function()
                ugui.label({
                    uid = UID.NavbarCoverLabel,
                    rectangle = cover_rectangle,
                    text = '',
                    color = BreitbandGraphics.colors.black,
                    hittestable = true,
                })
            end)

            -- HACK: Obscure the controls under the navbar too... :P
            defer_draw(function()
                BreitbandGraphics.fill_rectangle(grid_rect(0, 16.85, 8, 30), Styles.theme().background_color)
            end)
        end
    end,
}
