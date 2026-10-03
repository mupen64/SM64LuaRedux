--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('GhostPlayback', function(enum_next)
    return {
        PlaybackStatus = enum_next(ugui.registry.label.uids()),
        EnableHack = enum_next(ugui.registry.button.uids()),
        GhostsLabel = enum_next(ugui.registry.label.uids()),
        AddGhost = enum_next(ugui.registry.button.uids()),
        RemoveGhost = enum_next(ugui.registry.button.uids()),
        GhostList = enum_next(ugui.registry.listbox.uids()),
        TimerStartLabel = enum_next(ugui.registry.label.uids()),
        TimerStart = enum_next(ugui.registry.textbox.uids()),
        TimerStartDecrement = enum_next(ugui.registry.button.uids()),
        TimerStartIncrement = enum_next(ugui.registry.button.uids()),
        GraphicsLabel = enum_next(ugui.registry.label.uids()),
        Graphics = enum_next(ugui.registry.label.uids()),
        TransparentLabel = enum_next(ugui.registry.label.uids()),
        Transparent = enum_next(ugui.registry.button.uids()),
        ColorLabel = enum_next(ugui.registry.label.uids()),
        Color = enum_next(ugui.registry.textbox.uids()),
        ColorPickerButton = enum_next(ugui.registry.button.uids()),
        ColorPickerOk = enum_next(ugui.registry.button.uids()),
        ColorPickerCancel = enum_next(ugui.registry.button.uids()),
        GhostData = enum_next(ugui.registry.listbox.uids()),
    }
end)

local picker = dofile(views_path .. 'GhostTab/ColorPicker.lua')

local selected_ghost_id = 0

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
                font_size = theme.font_size * Drawing.scale * 1.25,
                font_name = theme.font_name,
                align_x = BreitbandGraphics.alignment['start'],
                align_y = BreitbandGraphics.alignment.center,
            })
        end

        local hack_supported = Ghost.hack_is_supported()
        local hack_enabled = Ghost.hack_is_applied()
        local valid_ghost_selected = hack_enabled and selected_ghost_id ~= 0

        local status = Locales.str('GHOST_STATUS_DISABLED')
        if not hack_supported then
            status = Locales.str('GHOST_STATUS_UNSUPPORTED')
        elseif hack_enabled then
            status = Locales.str('GHOST_STATUS_ENABLED')
        end
        section_label(UID.PlaybackStatus, grid_rect(0, 1, 8, 1), status)

        if ugui.button({
                uid = UID.EnableHack,
                rectangle = grid_rect(0.1, 1.8, 7.8, 1),
                text = Locales.str('GHOST_ENABLE_HACK'),
                is_enabled = hack_supported
            }) then
            Ghost.apply_hack()
        end

        section_label(UID.GhostsLabel, grid_rect(0, 2.8, 8, 1), Locales.str('GHOST_LIST'))

        if ugui.button({
                uid = UID.AddGhost,
                rectangle = grid_rect(0.1, 3.6, 2.8, 1),
                text = Locales.str('GHOST_ADD'),
                is_enabled = hack_enabled
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
                rectangle = grid_rect(3, 3.6, 4.8, 1),
                text = Locales.str('GHOST_REMOVE'),
                is_enabled = valid_ghost_selected
            }) then
            Ghost.unload_ghost(selected_ghost_id)
            selected_ghost_id = 0 -- go back to Mario
        end

        -- ghost list
        local ghosts = Ghost.list_ghosts()
        local ghost_list = {}
        local selected_index = nil
        for i, ghost in ipairs(ghosts) do
            ghost_list[#ghost_list + 1] = ghost.name
            if ghost.id == selected_ghost_id then
                selected_index = i
            end
        end
        local new_index = ugui.listbox({
            uid = UID.GhostList,
            rectangle = grid_rect(0.1, 4.6, 7.8, 3.4),
            selected_index = selected_index,
            items = ghost_list,
        })
        if new_index and ghosts[new_index] then
            selected_ghost_id = ghosts[new_index].id
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
                font_size = theme.font_size * Drawing.scale * 1.25,
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
                    font_size = theme.font_size * Drawing.scale * 1.25,
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
                    font_size = theme.font_size * Drawing.scale * 1.25,
                },
            }) then
            Ghost.set_global_timer_start(selected_ghost_id, current_start + 1)
        end

        -- close the picker (keeping the current color) if its target is no longer editable
        if picker.open and (picker.ghost_id ~= selected_ghost_id or not hack_enabled) then
            picker.open = false
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
                        font_size = theme.font_size * Drawing.scale * 1.25,
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
                    font_size = theme.font_size * Drawing.scale * 1.25,
                },
                is_enabled = hack_enabled
            }))
            if typed_color then
                Ghost.set_color(selected_ghost_id, typed_color)
                color = typed_color
            end

            if ugui.control({
                    uid = UID.ColorPickerButton,
                    rectangle = grid_rect(3.4, 9.8, 0.8, 0.8),
                    text = '',
                    color = color,
                    tooltip = Locales.str('GHOST_COLOR_PICKER_TOOLTIP'),
                    is_enabled = hack_enabled,
                }, 'color_button').primary then
                picker.open = not picker.open
                picker.ghost_id = selected_ghost_id
                picker.original = { color[1], color[2], color[3] }
                picker.last_color = nil -- resync the wheel to the current color
            end

            if picker.open then
                local picked_color = picker.draw(grid_rect(4.5, 9.2, 3, 3), color)
                if picked_color then
                    Ghost.set_color(selected_ghost_id, picked_color)
                end

                if ugui.button({
                        uid = UID.ColorPickerOk,
                        rectangle = grid_rect(0.1, 10.9, 2.1, 0.8),
                        text = Locales.str('GHOST_COLOR_PICKER_OK'),
                        tooltip = Locales.str('GHOST_COLOR_PICKER_OK_TOOLTIP'),
                    }) then
                    picker.open = false
                end

                if ugui.button({
                        uid = UID.ColorPickerCancel,
                        rectangle = grid_rect(2.2, 10.9, 2.1, 0.8),
                        text = Locales.str('GHOST_COLOR_PICKER_CANCEL'),
                        tooltip = Locales.str('GHOST_COLOR_PICKER_CANCEL_TOOLTIP'),
                    }) then
                    Ghost.set_color(picker.ghost_id, picker.original)
                    picker.open = false
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
