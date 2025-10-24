--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

MiniVisualizer = {}

local UID = UIDProvider.allocate_once('MiniVisualizer', function(enum_next)
    return {
        Joystick = enum_next(),
        A = enum_next(),
        B = enum_next(),
        Z = enum_next(),
        S = enum_next(),
        R = enum_next(),
    }
end)

MiniVisualizer.draw = function()
    if not Settings.mini_visualizer then
        return
    end
    ugui.standard_styler.draw_raised_frame({
        rectangle = grid_rect_abs(3, 14, 5, 2),
    }, ugui.visual_states.normal)
    
    ugui.joystick({
        uid = UID.Joystick,
        rectangle = grid_rect_abs(0, 14, 3, 3),
        position = {
            x = Joypad.input.X,
            y = -Joypad.input.Y,
        },
        mag = 0,
    })
    ugui.toggle_button({
        uid = UID.A,
        rectangle = grid_rect_abs(3, 16, 1, 1),
        text = 'A',
        is_checked = Joypad.input.A,
    })
    ugui.toggle_button({
        uid = UID.B,
        rectangle = grid_rect_abs(4, 16, 1, 1),
        text = 'B',
        is_checked = Joypad.input.B,
    })
    ugui.toggle_button({
        uid = UID.Z,
        rectangle = grid_rect_abs(5, 16, 1, 1),
        text = 'Z',
        is_checked = Joypad.input.Z,
    })
    ugui.toggle_button({
        uid = UID.S,
        rectangle = grid_rect_abs(6, 16, 1, 1),
        text = 'S',
        is_checked = Joypad.input.start,
    })
    ugui.toggle_button({
        uid = UID.R,
        rectangle = grid_rect_abs(7, 16, 1, 1),
        text = 'R',
        is_checked = Joypad.input.R,
    })
    local foreground_color = ugui.standard_styler.params.button.text[ugui.visual_states.normal]
    BreitbandGraphics.draw_text(
        grid_rect_abs(3, 15, 5, 1),
        'center',
        'center',
        { aliased = not Styles.theme().cleartype },
        foreground_color,
        Styles.theme().font_size * Drawing.scale,
        'Consolas',
        VarWatch_compute_value('action'))
    BreitbandGraphics.draw_text(
        grid_rect_abs(3, 14, 2.5, 1),
        'center',
        'center',
        { aliased = not Styles.theme().cleartype },
        foreground_color,
        Styles.theme().font_size * Drawing.scale * 1.25,
        'Consolas',
        'X: ' .. Joypad.input.X)
    BreitbandGraphics.draw_text(
        grid_rect_abs(5.5, 14, 2.5, 1),
        'center',
        'center',
        { aliased = not Styles.theme().cleartype },
        foreground_color,
        Styles.theme().font_size * Drawing.scale * 1.25,
        'Consolas',
        'Y: ' .. Joypad.input.Y)
end
