--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('Timer', function(enum_next)
    return {
        Start = enum_next(ugui.registry.button.uids()),
        Stop = enum_next(ugui.registry.button.uids()),
        Reset = enum_next(ugui.registry.button.uids()),
        ToggleAuto = enum_next(ugui.registry.toggle_button.uids()),
        Joypad = enum_next(ugui.registry.joystick.uids()),
        A = enum_next(ugui.registry.toggle_button.uids()),
        B = enum_next(ugui.registry.toggle_button.uids()),
        Z = enum_next(ugui.registry.toggle_button.uids()),
        S = enum_next(ugui.registry.toggle_button.uids()),
        L = enum_next(ugui.registry.toggle_button.uids()),
        R = enum_next(ugui.registry.toggle_button.uids()),
        DL = enum_next(ugui.registry.toggle_button.uids()),
        DR = enum_next(ugui.registry.toggle_button.uids()),
        DU = enum_next(ugui.registry.toggle_button.uids()),
        DD = enum_next(ugui.registry.toggle_button.uids()),
        CL = enum_next(ugui.registry.toggle_button.uids()),
        CR = enum_next(ugui.registry.toggle_button.uids()),
        CU = enum_next(ugui.registry.toggle_button.uids()),
        CD = enum_next(ugui.registry.toggle_button.uids()),
        ProcessedValues = enum_next(ugui.registry.listbox.uids()),
        TimerText = enum_next(ugui.registry.label.uids()),
    }
end)

return {
    name = function() return Locales.str('TIMER_TAB_NAME') end,
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

        ugui.label({
            uid = UID.TimerText,
            rectangle = grid_rect(0, 5, 8, 1),
            text = Timer.get_frame_text(),
            color = BreitbandGraphics.invert_color(theme.background_color),
            font_size = theme.font_size * Drawing.scale * 2,
            font_name = 'Consolas',
            align_x = BreitbandGraphics.alignment.center,
            align_y = BreitbandGraphics.alignment.center,
        })

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
