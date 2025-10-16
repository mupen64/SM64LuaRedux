--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('Timer', function(enum_next)
    return {
        Start = enum_next(),
        Stop = enum_next(),
        Reset = enum_next(),
        ToggleAuto = enum_next(),
        Joypad = enum_next(),
        A = enum_next(),
        B = enum_next(),
        Z = enum_next(),
        S = enum_next(),
        L = enum_next(),
        R = enum_next(),
        DL = enum_next(),
        DR = enum_next(),
        DU = enum_next(),
        DD = enum_next(),
        CL = enum_next(),
        CR = enum_next(),
        CU = enum_next(),
        CD = enum_next(),
        ProcessedValues = enum_next(3),
    }
end)

return {
    name = Locales.str('TIMER_TAB_NAME'),
    draw = function()
        local theme = Styles.theme()

        if ugui.button({
                uid = UID.Start,

                rectangle = grid_rect(0, 0, 2, 1),
                text = Locales.str('TIMER_START'),
            }) then
            Timer.start()
        end
        if ugui.button({
                uid = UID.Stop,

                rectangle = grid_rect(2, 0, 2, 1),
                text = Locales.str('TIMER_STOP'),
            }) then
            Timer.stop()
        end
        if ugui.button({
                uid = UID.Reset,

                rectangle = grid_rect(4, 0, 2, 1),
                text = Locales.str('TIMER_RESET'),
            }) then
            Timer.reset()
        end
        Settings.timer_auto = ugui.toggle_button({
            uid = UID.ToggleAuto,
            rectangle = grid_rect(6, 0, 2, 1),
            text = Settings.timer_auto and Locales.str('TIMER_AUTO') or Locales.str('TIMER_MANUAL'),
            is_checked = Settings.timer_auto,
        })
        ugui.joystick({
            uid = UID.Joypad,
            rectangle = grid_rect(2, 1, 4, 4),
            position = {
                x = Joypad.input.X,
                y = -Joypad.input.Y,
            },
        })

        BreitbandGraphics.draw_text(grid_rect(0, 5, 8, 1), 'center', 'center',
            { aliased = not theme.cleartype },
            BreitbandGraphics.invert_color(theme.background_color),
            theme.font_size * Drawing.scale * 2,
            'Consolas',
            Timer.get_frame_text())

        ugui.toggle_button({
            uid = UID.A,
            rectangle = grid_rect(4, 6, 2),
            text = 'A',
            is_checked = Joypad.input.A,
        })

        ugui.toggle_button({
            uid = UID.B,
            rectangle = grid_rect(2, 6, 2),
            text = 'B',
            is_checked = Joypad.input.B,
        })

        ugui.toggle_button({
            uid = UID.Z,
            rectangle = grid_rect(3, 8, 1),
            text = 'Z',
            is_checked = Joypad.input.Z,
        })

        ugui.toggle_button({
            uid = UID.S,
            rectangle = grid_rect(4, 8, 1),
            text = 'S',
            is_checked = Joypad.input.start,
        })

        ugui.toggle_button({
            uid = UID.L,
            rectangle = grid_rect(1, 7),
            text = 'L',
            is_checked = Joypad.input.L,
        })

        ugui.toggle_button({
            uid = UID.R,
            rectangle = grid_rect(6, 7),
            text = 'R',
            is_checked = Joypad.input.R,
        })

        ugui.toggle_button({
            uid = UID.DL,
            rectangle = grid_rect(0, 7),
            text = 'D<',
            is_checked = Joypad.input.left,
        })

        ugui.toggle_button({
            uid = UID.DR,
            rectangle = grid_rect(2, 7),
            text = 'D>',
            is_checked = Joypad.input.right,
        })

        ugui.toggle_button({
            uid = UID.DU,
            rectangle = grid_rect(1, 6),
            text = 'D^',
            is_checked = Joypad.input.up,
        })

        ugui.toggle_button({
            uid = UID.DD,
            rectangle = grid_rect(1, 8),
            text = 'Dv',
            is_checked = Joypad.input.down,
        })

        ugui.toggle_button({
            uid = UID.CL,
            rectangle = grid_rect(5, 7),
            text = 'C<',
            is_checked = Joypad.input.Cleft,
        })

        ugui.toggle_button({
            uid = UID.CR,
            rectangle = grid_rect(7, 7),
            text = 'C>',
            is_checked = Joypad.input.Cright,
        })

        ugui.toggle_button({
            uid = UID.CU,
            rectangle = grid_rect(6, 6),
            text = 'C^',
            is_checked = Joypad.input.Cup,
        })

        ugui.toggle_button({
            uid = UID.CD,
            rectangle = grid_rect(6, 8),
            text = 'Cv',
            is_checked = Joypad.input.Cdown,
        })

        ugui.listbox({
            uid = UID.ProcessedValues,
            rectangle = grid_rect(0, 9, 8, 7),
            selected_index = nil,
            items = VarWatch.processed_values,
        })
    end,
}
