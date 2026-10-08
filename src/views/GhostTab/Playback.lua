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
    }
end)

local selected_ghost_id = 0
-- names edited in the UI, by ghost ID; only displayed here, the ghost module keeps its filepath
local display_names = {}
local picker_open = false
local picker_ghost_id = nil
local picker_original = nil

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

        local hack_supported = Ghost.hack_is_supported()
        local hack_enabled = Ghost.hack_is_applied()
        local valid_ghost_selected = selected_ghost_id ~= 0

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
            tooltip = Ghost.auto_apply_hack and Locales.str('GHOST_DISABLE_HACK_TOOLTIP') or Locales.str('GHOST_ENABLE_HACK_TOOLTIP'),
            is_checked = Ghost.auto_apply_hack,
            is_enabled = hack_supported
        })
        if auto_apply_hack ~= Ghost.auto_apply_hack then
            Ghost.auto_apply_hack = auto_apply_hack
        end

        if ugui.button({
                uid = UID.AddGhost,
                rectangle = grid_rect(0.1, 2.7, 2.6, 1),
                text = Locales.str('GHOST_ADD'),
            }) then
            local path = iohelper.filediag("*.ghost", 0)
            if string.len(path) > 0 then
                local new_id = Ghost.load_ghost_file(path)
                if not new_id then
                    print(Locales.str('GHOST_LOAD_FAILED'))
                else
                    selected_ghost_id = new_id
                end
            end
        end

        if ugui.button({
                uid = UID.RemoveGhost,
                rectangle = grid_rect(2.7, 2.7, 2.6, 1),
                text = Locales.str('GHOST_REMOVE'),
                is_enabled = valid_ghost_selected
            }) then
            Ghost.unload_ghost(selected_ghost_id)
            selected_ghost_id = 0 -- go back to Mario
        end

        local was_enabled = Ghost.is_enabled(selected_ghost_id)
        if ugui.button({
            uid = UID.EnableGhost,
            rectangle = grid_rect(5.3, 2.7, 2.6, 1),
            text = was_enabled and Locales.str('GHOST_DISABLE_GHOST') or Locales.str('GHOST_ENABLE_GHOST'),
            tooltip = Locales.str('GHOST_ENABLE_GHOST_TOOLTIP'),
            is_enabled = valid_ghost_selected
        }) then
            if was_enabled then
                Ghost.disable_ghost(selected_ghost_id)
            else
                Ghost.enable_ghost(selected_ghost_id)
            end
        end


        -- ghost list
        local ghosts = Ghost.list_ghosts()
        local ghost_list = {}
        local selected_index = nil
        for i, ghost in ipairs(ghosts) do
            local enabled = Ghost.is_enabled(ghost.id) and '[✓] ' or '[  ] '
            ghost.name = display_names[ghost.id] or ghost.name
            ghost_list[#ghost_list + 1] = enabled .. ghost.name
            if ghost.id == selected_ghost_id then
                selected_index = i
            end
        end
        local new_index = ugui.listbox({
            uid = UID.GhostList,
            rectangle = grid_rect(0.1, 3.7, 7.8, 3.4),
            selected_index = selected_index,
            items = ghost_list,
        })
        if new_index and ghosts[new_index] then
            selected_ghost_id = ghosts[new_index].id
        end

        -- file of the selected ghost
        section_label(UID.FileLabel, grid_rect(0, 7.1, 1, 0.9), Locales.str('GHOST_FILE'))

        local name = ''
        for _, ghost in ipairs(ghosts) do
            if ghost.id == selected_ghost_id then name = ghost.name end
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
        if valid_ghost_selected and new_name ~= name then
            display_names[selected_ghost_id] = new_name
        end

        if ugui.button({
                uid = UID.SaveGhost,
                rectangle = grid_rect(6, 7.15, 1.9, 0.75),
                text = Locales.str('GHOST_SAVE_AS'),
                tooltip = Locales.str('GHOST_SAVE_AS_TOOLTIP'),
                is_enabled = valid_ghost_selected
            }) then
            local path = iohelper.filediag("*.ghost", 1)
            if string.len(path) > 0 and not Ghost.save_ghost_file(selected_ghost_id, path) then
                print(Locales.str('GHOST_SAVE_FAILED'))
            end
        end

        -- editable ghost data
        section_label(UID.TimerStartLabel, grid_rect(0, 7.9, 8, 1), Locales.str('GHOST_TIMER_START'))

        local current_start = Ghost.get_global_timer_offset(selected_ghost_id)
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
            Ghost.set_global_timer_start(selected_ghost_id, typed_start)
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
            Ghost.set_global_timer_start(selected_ghost_id, math.max(0, current_start - 1))
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
            Ghost.set_global_timer_start(selected_ghost_id, current_start + 1)
        end

        -- close the picker (keeping the current color) if its target is no longer editable
        if picker_open and picker_ghost_id ~= selected_ghost_id then
            picker_open = false
        end

        -- display object's graphics instead of hat options
        local graphics = Ghost.get_graphics(selected_ghost_id)
        if graphics ~= 0 then
            section_label(UID.GraphicsLabel, grid_rect(0, 8.8, 2.5, 1), Locales.str('GHOST_GRAPHICS'))
            section_label(UID.Graphics, grid_rect(2, 8.8, 5.4, 1), string.format('0x%X', graphics))
        else
            section_label(UID.TransparentLabel, grid_rect(0, 8.8, 2.5, 1), Locales.str('GHOST_TRANSPARENT'))

            local transparent = Ghost.is_transparent(selected_ghost_id)
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
                Ghost.set_transparent(selected_ghost_id, not transparent)
            end

            section_label(UID.ColorLabel, grid_rect(0, 9.7, 1.3, 1), Locales.str('GHOST_COLOR'))

            -- editable without a ghost selected, since ID 0 is Mario's hat
            local color = Ghost.get_color(selected_ghost_id)
            local typed_color = parse_hex_color(ugui.textbox({
                uid = UID.Color,
                rectangle = grid_rect(1.3, 9.8, 2, 0.8),
                text = rgb_to_str(color),
                tooltip = Locales.str('GHOST_COLOR_TOOLTIP'),
                styler_mixin = {
                    font_size = theme.font_size * 1.25,
                },
            }))
            if typed_color then
                Ghost.set_color(selected_ghost_id, typed_color)
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
                    picker_ghost_id = selected_ghost_id
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
                    Ghost.set_color(selected_ghost_id, picked_rgb)
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
                    Ghost.set_color(picker_ghost_id, picker_original)
                    picker_open = false
                end
            end
        end

        ugui.listbox({
            uid = UID.GhostData,
            rectangle = grid_rect(0, 12, 8, 4),
            selected_index = nil,
            items = ghost_varwatch_data(selected_ghost_id),
        })
    end
}
