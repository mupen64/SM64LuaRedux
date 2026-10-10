--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('GhostPlayback', function(enum_next)
    return {
        PlaybackStatus = enum_next(ugui.label_uids()),
        EnableHack = enum_next(ugui.toggle_button_uids()),
        GhostsLabel = enum_next(ugui.label_uids()),
        AddGhost = enum_next(ugui.button_uids()),
        RemoveGhost = enum_next(ugui.button_uids()),
        EnableGhost = enum_next(ugui.button_uids()),
        GhostList = enum_next(ugui.listbox_uids()),
        FileLabel = enum_next(ugui.label_uids()),
        FileName = enum_next(ugui.textbox_uids()),
        SaveGhost = enum_next(ugui.button_uids()),
        TimerStartLabel = enum_next(ugui.label_uids()),
        TimerStart = enum_next(ugui.textbox_uids()),
        TimerStartDecrement = enum_next(ugui.button_uids()),
        TimerStartIncrement = enum_next(ugui.button_uids()),
        GraphicsLabel = enum_next(ugui.label_uids()),
        Graphics = enum_next(ugui.label_uids()),
        TransparentLabel = enum_next(ugui.label_uids()),
        Transparent = enum_next(ugui.button_uids()),
        ColorLabel = enum_next(ugui.label_uids()),
        Color = enum_next(ugui.textbox_uids()),
        ColorPickerButton = enum_next(ugui.button_uids()),
        ColorSwatch = enum_next(ugui.panel_uids()),
        ColorPicker = enum_next(ugui.colorpicker_uids()),
        ColorPickerOk = enum_next(ugui.button_uids()),
        ColorPickerCancel = enum_next(ugui.button_uids()),
        GhostData = enum_next(ugui.listbox_uids()),
        Warning = enum_next(ugui.label_uids()),
        AcceptWarning = enum_next(ugui.button_uids()),
    }
end)

local selected_ghost = nil

-- names edited in the UI, by ghost; only displayed here, the ghost module keeps its filepath
local display_names = {}

-- set the display name from the filepath
local function ghost_name(ghost)
    if not ghost then
        return 'Mario'
    end
    if not display_names[ghost] then
        display_names[ghost] = ghost.filepath:match('[^\\/]+$'):match("^(.*)%.[^%.]*$") or ghost.filepath
    end
    return display_names[ghost]
end

local picker_open = false
local picker_ghost = nil
local picker_original = nil
local color_text = nil
local color_text_ghost = nil

local function rgb_to_str(rgb)
    return string.format('#%02X%02X%02X', rgb[1], rgb[2], rgb[3])
end

local function parse_hex_color(text)
    if not text then
        return nil
    end
    local hex = text:gsub('#', ''):gsub('%s', '')
    if #hex ~= 6 or hex:match('%X') then
        return nil
    end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then
        return nil
    end
    return {r, g, b}
end

local function rgb_to_ugui_color(rgb)
    return {r = rgb[1] / 255, g = rgb[2] / 255, b = rgb[3] / 255, a = 1}
end

local function ugui_color_to_rgb(color)
    return {
        math.floor(color.r * 255 + 0.5),
        math.floor(color.g * 255 + 0.5),
        math.floor(color.b * 255 + 0.5),
    }
end

return {
    name = function() return Locales.str('GHOST_PLAYBACK_TAB_NAME') end,

    ---@return string[] # the varwatch lines of the selected ghost (Mario if none), for the overlay
    varwatch_items = function() return ghost_varwatch_data(selected_ghost) end,

    ---@return string, string | nil # the selected ghost's display name, and its hat color as hex (nil for object ghosts)
    selected_name_and_color = function()
        local is_object = selected_ghost and selected_ghost.graphics ~= 0
        return ghost_name(selected_ghost), not is_object and rgb_to_str(Ghosts.get_color(selected_ghost)) or nil
    end,
    
    draw = function()
        local theme = Styles.theme()
        local foreground_color = Drawing.foreground_color()

        local function section_label(uid, rect, text)
            ugui.label({
                uid = uid,
                rectangle = rect,
                text = text,
                color = foreground_color,
                font_size = theme.font_size * 1.25,
                font_name = theme.font_name,
                align_x = ugui.alignment['start'],
                align_y = ugui.alignment.center,
            })
        end

        -- the rest of the tab stays hidden until the memory warning is accepted (reset in the settings tab)
        if not Settings.ghost_playback_warning_accepted then
            ugui.label({
                uid = UID.Warning,
                rectangle = grid_rect(0.1, 1, 7.8, 5),
                text = Locales.str('GHOST_PLAYBACK_WARNING'),
                color = foreground_color,
                font_size = theme.font_size * 1.25,
                font_name = theme.font_name,
                align_x = ugui.alignment['start'],
                align_y = ugui.alignment['start'],
                wrap = true,
            })
            if ugui.button({
                    uid = UID.AcceptWarning,
                    rectangle = grid_rect(2, 6.5, 4, 1),
                    text = Locales.str('GHOST_PLAYBACK_WARNING_ACCEPT'),
                }) then
                Settings.ghost_playback_warning_accepted = true
            end
            return
        end

        local hack_supported = Ghosts.hack_is_supported()
        local hack_enabled = Ghosts.hack_is_applied()
        local valid_ghost_selected = selected_ghost ~= nil

        local status = Locales.str('GHOST_STATUS')
        if not hack_supported then
            status = status .. Locales.str('GHOST_UNSUPPORTED')
        elseif hack_enabled then
            status = status .. Locales.str('GHOST_ENABLED')
        else
            status = status .. Locales.str('GHOST_DISABLED')
        end
        section_label(UID.PlaybackStatus, grid_rect(0, 0.9, 8, 1), status)

        local auto_apply_hack = ugui.toggle_button({
            uid = UID.EnableHack,
            rectangle = grid_rect(0.1, 1.7, 7.8, 1),
            text = Locales.str('GHOST_ENABLE_HACK'),
            tooltip = Ghosts.auto_apply_hack and Locales.str('GHOST_DISABLE_HACK_TOOLTIP') or Locales.str('GHOST_ENABLE_HACK_TOOLTIP'),
            is_checked = Ghosts.auto_apply_hack,
            is_enabled = hack_supported
        })
        if auto_apply_hack ~= Ghosts.auto_apply_hack then
            Ghosts.auto_apply_hack = auto_apply_hack
        end

        if ugui.button({
                uid = UID.AddGhost,
                rectangle = grid_rect(0.1, 2.7, 2.6, 1),
                text = Locales.str('GHOST_ADD'),
            }) then
            local path = iohelper.filediag("*.ghost", 0)
            if string.len(path) > 0 then
                local new_ghost = Ghosts.load_ghost_file(path)
                if not new_ghost then
                    print(Locales.str('GHOST_LOAD_FAILED'))
                else
                    selected_ghost = new_ghost
                end
            end
        end

        if ugui.button({
                uid = UID.RemoveGhost,
                rectangle = grid_rect(2.7, 2.7, 2.6, 1),
                text = Locales.str('GHOST_REMOVE'),
                is_enabled = valid_ghost_selected
            }) then
            Ghosts.unload_ghost(selected_ghost)
            display_names[selected_ghost] = nil
            selected_ghost = nil -- go back to Mario
            valid_ghost_selected = false
        end

        local was_enabled = not selected_ghost or selected_ghost.enabled
        if ugui.button({
            uid = UID.EnableGhost,
            rectangle = grid_rect(5.3, 2.7, 2.6, 1),
            text = was_enabled and Locales.str('GHOST_DISABLE_GHOST') or Locales.str('GHOST_ENABLE_GHOST'),
            tooltip = Locales.str('GHOST_ENABLE_GHOST_TOOLTIP'),
            is_enabled = valid_ghost_selected
        }) then
            selected_ghost.enabled = not was_enabled
        end

        -- file of the selected ghost
        section_label(UID.FileLabel, grid_rect(0, 7.1, 1, 0.9), Locales.str('GHOST_FILE'))

        local name = 'Mario'
        if selected_ghost then
            name = ghost_name(selected_ghost)
        end
        local new_name = ugui.textbox({
            uid = UID.FileName,
            rectangle = grid_rect(1.5, 7.15, 4.5, 0.8),
            text = name,
            tooltip = Locales.str('GHOST_NAME_TOOLTIP'),
            styler_mixin = {
                font_size = theme.font_size * 1.25,
            },
            is_enabled = valid_ghost_selected
        })
        if selected_ghost and new_name ~= name then
            display_names[selected_ghost] = new_name
        end

        if ugui.button({
                uid = UID.SaveGhost,
                rectangle = grid_rect(6, 7.15, 1.9, 0.75),
                text = Locales.str('GHOST_SAVE_AS'),
                tooltip = Locales.str('GHOST_SAVE_AS_TOOLTIP'),
                is_enabled = valid_ghost_selected
            }) then
            local path = iohelper.filediag("*.ghost", 1)
            if string.len(path) > 0 and not Ghosts.save_ghost_file(selected_ghost, path) then
                print(Locales.str('GHOST_SAVE_FAILED'))
            end
        end

        -- editable ghost data
        section_label(UID.TimerStartLabel, grid_rect(0, 7.9, 8, 1), Locales.str('GHOST_TIMER_START'))

        local current_start = not selected_ghost and 0 or selected_ghost.global_timer_start
        local new_start = ugui.textbox({
            uid = UID.TimerStart,
            rectangle = grid_rect(3.7, 8, 2.6, 0.8),
            text = current_start .. '',
            tooltip = Locales.str('GHOST_TIMER_START_TOOLTIP'),
            styler_mixin = {
                font_size = theme.font_size * 1.25,
            },
            is_enabled = valid_ghost_selected
        })
        -- the box shows the start timer, not the raw offset, so convert back when editing
        local typed_start = tonumber(new_start)
        if typed_start and typed_start ~= current_start then
            selected_ghost.global_timer_start = typed_start
        end

        if ugui.button({
                uid = UID.TimerStartDecrement,
                rectangle = grid_rect(6.3, 8, 0.8, 0.8),
                text = '-',
                tooltip = Locales.str('GHOST_TIMER_START_DECREMENT_TOOLTIP'),
                is_enabled = valid_ghost_selected,
                styler_mixin = {
                    font_size = theme.font_size * 1.25,
                },
            }) then
            selected_ghost.global_timer_start = math.max(0, current_start - 1)
        end

        if ugui.button({
                uid = UID.TimerStartIncrement,
                rectangle = grid_rect(7.1, 8, 0.8, 0.8),
                text = '+',
                tooltip = Locales.str('GHOST_TIMER_START_INCREMENT_TOOLTIP'),
                is_enabled = valid_ghost_selected,
                styler_mixin = {
                    font_size = theme.font_size * 1.25,
                },
            }) then
            selected_ghost.global_timer_start = current_start + 1
        end

        -- close the picker (keeping the current color) if its target is no longer editable
        if picker_open and picker_ghost ~= selected_ghost then
            picker_open = false
        end

        -- display object's graphics instead of hat options
        local graphics = not selected_ghost and 0 or selected_ghost.graphics
        if graphics ~= 0 then
            section_label(UID.GraphicsLabel, grid_rect(0, 8.8, 2.5, 1), Locales.str('GHOST_GRAPHICS'))
            section_label(UID.Graphics, grid_rect(2, 8.8, 5.4, 1), string.format('0x%X', graphics))
        else
            section_label(UID.TransparentLabel, grid_rect(0, 8.8, 2.5, 1), Locales.str('GHOST_TRANSPARENT'))

            local transparent = false
            if valid_ghost_selected then
                transparent = selected_ghost.is_transparent
            end
            if ugui.button({
                    uid = UID.Transparent,
                    rectangle = grid_rect(2.5, 8.9, 0.8, 0.8),
                    text = transparent and '✓' or '',
                    tooltip = Locales.str('GHOST_TRANSPARENT_TOOLTIP'),
                    is_enabled = valid_ghost_selected,
                    styler_mixin = {
                        font_size = theme.font_size * 1.25,
                    },
                }) then
                selected_ghost.is_transparent = not transparent
            end

            section_label(UID.ColorLabel, grid_rect(0, 9.7, 1.3, 1), Locales.str('GHOST_COLOR'))

            local color = Ghosts.get_color(selected_ghost)
            local color_text_is_focused = ugui.internal.keyboard_captured_control == UID.Color
            if color_text == nil or not color_text_is_focused or color_text_ghost ~= selected_ghost then
                color_text = rgb_to_str(color)
                color_text_ghost = selected_ghost
            end
            color_text = ugui.textbox({
                uid = UID.Color,
                rectangle = grid_rect(1.3, 9.8, 2, 0.8),
                text = color_text,
                tooltip = Locales.str('GHOST_COLOR_TOOLTIP'),
                styler_mixin = {
                    font_size = theme.font_size * 1.25,
                },
            })
            local typed_color = parse_hex_color(color_text)
            if typed_color then
                Ghosts.set_color(selected_ghost, typed_color)
                color = typed_color
            end

            local swatch_rect = grid_rect(3.4, 9.8, 0.8, 0.8)
            local open_picker = ugui.button({
                uid = UID.ColorPickerButton,
                rectangle = swatch_rect,
                text = '',
                tooltip = Locales.str('GHOST_COLOR_PICKER_TOOLTIP'),
            })
            -- the panel isn't hittestable, so clicks still reach the button underneath
            ugui.panel({
                uid = UID.ColorSwatch,
                rectangle = {
                    x = swatch_rect.x + 4,
                    y = swatch_rect.y + 4,
                    width = swatch_rect.width - 8,
                    height = swatch_rect.height - 8,
                },
                fill = rgb_to_str(color),
            })
            if open_picker then
                if picker_open then
                    picker_open = false
                else
                    picker_open = true
                    picker_ghost = selected_ghost
                    picker_original = { color[1], color[2], color[3] }
                end
            end

            if picker_open then
                local picked_color = ugui.colorpicker({
                    uid = UID.ColorPicker,
                    rectangle = grid_rect(4.5, 9.2, 3, 3),
                    color = rgb_to_ugui_color(color),
                    shape = 'circle',
                    band_position = 'right',
                })
                local picked_rgb = ugui_color_to_rgb(picked_color)
                if picked_rgb[1] ~= color[1] or picked_rgb[2] ~= color[2] or picked_rgb[3] ~= color[3] then
                    Ghosts.set_color(selected_ghost, picked_rgb)
                    color = picked_rgb
                end

                if ugui.button({
                        uid = UID.ColorPickerOk,
                        rectangle = grid_rect(0.1, 10.9, 2.1, 0.8),
                        text = Locales.str('GHOST_COLOR_PICKER_OK'),
                        tooltip = Locales.str('GHOST_COLOR_PICKER_OK_TOOLTIP'),
                    }) then
                    picker_open = false
                end

                if ugui.button({
                        uid = UID.ColorPickerCancel,
                        rectangle = grid_rect(2.2, 10.9, 2.1, 0.8),
                        text = Locales.str('GHOST_COLOR_PICKER_CANCEL'),
                        tooltip = Locales.str('GHOST_COLOR_PICKER_CANCEL_TOOLTIP'),
                    }) then
                    Ghosts.set_color(picker_ghost, picker_original)
                    picker_open = false
                end
            end
        end

        ugui.listbox({
            uid = UID.GhostData,
            rectangle = grid_rect(0, 12, 8, 4),
            selected_index = nil,
            items = ghost_varwatch_data(selected_ghost),
        })

        -- ghost list
        -- drawn last so changes in selected)ghost don't affect other UI elements
        local ghosts = Ghosts.list_ghosts()
        local ghost_name_list = {'[✓] Mario'}
        local selected_index = 1
        for i, ghost in ipairs(ghosts) do
            local enabled = ghost.enabled and '[✓] ' or '[  ] '
            ghost_name_list[#ghost_name_list + 1] = enabled .. ghost_name(ghost)
            if ghost == selected_ghost then
                selected_index = i + 1 -- Mario is the first item
            end
        end
        local new_index = ugui.listbox({
            uid = UID.GhostList,
            rectangle = grid_rect(0.1, 3.7, 7.8, 3.4),
            selected_index = selected_index,
            items = ghost_name_list,
        })
        if new_index then
            if new_index == 1 then
                selected_ghost = nil -- Mario
            else
                selected_ghost = ghosts[new_index - 1]
            end
        end
    end
}
