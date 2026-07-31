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
        Action = enum_next(),
        JoystickX = enum_next(),
        JoystickY = enum_next(),
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
        is_checked = Joypad.input.A == true,
    })
    ugui.toggle_button({
        uid = UID.B,
        rectangle = grid_rect_abs(4, 16, 1, 1),
        text = 'B',
        is_checked = Joypad.input.B == true,
    })
    ugui.toggle_button({
        uid = UID.Z,
        rectangle = grid_rect_abs(5, 16, 1, 1),
        text = 'Z',
        is_checked = Joypad.input.Z == true,
    })
    ugui.toggle_button({
        uid = UID.S,
        rectangle = grid_rect_abs(6, 16, 1, 1),
        text = 'S',
        is_checked = Joypad.input.start == true,
    })
    ugui.toggle_button({
        uid = UID.R,
        rectangle = grid_rect_abs(7, 16, 1, 1),
        text = 'R',
        is_checked = Joypad.input.R == true,
    })
    local foreground_color = ugui.standard_styler.params.button.text[ugui.visual_states.normal]
    local theme = Styles.theme()
    ugui.label({
        uid = UID.Action,
        rectangle = grid_rect_abs(3, 15, 5, 1),
        text = VarWatch_compute_value('action'),
        color = foreground_color,
        font_size = theme.font_size * Drawing.scale,
        font_name = 'Consolas',
        align_x = BreitbandGraphics.alignment.center,
        align_y = BreitbandGraphics.alignment.center,
    })
    ugui.label({
        uid = UID.JoystickX,
        rectangle = grid_rect_abs(3, 14, 2.5, 1),
        text = 'X: ' .. Joypad.input.X,
        color = foreground_color,
        font_size = theme.font_size * Drawing.scale * 1.25,
        font_name = 'Consolas',
        align_x = BreitbandGraphics.alignment.center,
        align_y = BreitbandGraphics.alignment.center,
    })
    ugui.label({
        uid = UID.JoystickY,
        rectangle = grid_rect_abs(5.5, 14, 2.5, 1),
        text = 'Y: ' .. Joypad.input.Y,
        color = foreground_color,
        font_size = theme.font_size * Drawing.scale * 1.25,
        font_name = 'Consolas',
        align_x = BreitbandGraphics.alignment.center,
        align_y = BreitbandGraphics.alignment.center,
    })
end
