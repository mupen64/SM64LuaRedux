--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

return {
    name = Locales.str('TAS_TAB_NAME'),
    draw = function()
        local theme = Styles.theme()

        ugui.listbox({
            uid = 0,
            rectangle = grid_rect(0, 8, 8, 8),
            selected_index = nil,
            items = VarWatch.processed_values,
        })

        Settings.tas.goal_angle = math.abs(ugui.numberbox({
            uid = 5,
            is_enabled = Settings.tas.movement_mode == MovementModes.match_angle,
            rectangle = grid_rect(4, 3, 4, 1),
            places = 5,
            value = Settings.tas.goal_angle,
        }))

        Settings.tas.goal_mag = math.abs(ugui.numberbox({
            uid = 10,
            rectangle = grid_rect(4, 4, 2, 1),
            places = 3,
            value = Settings.tas.goal_mag,
        }))

        local old_high_magnitude = Settings.tas.high_magnitude
        local high_magnitude = ugui.toggle_button({
            uid = 15,
            rectangle = grid_rect(7, 4, 1, 1),
            text = Locales.str('MAG_HI'),
            is_checked = Settings.tas.high_magnitude,
        })
        if high_magnitude ~= old_high_magnitude then
            action.invoke(ACTION_TOGGLE_HIGH_MAGNITUDE)
        end

        if ugui.button({
                uid = 20,
                rectangle = grid_rect(6, 4, 1, 1),
                text = Locales.str('MAG_RESET'),
            }) then
            action.invoke(ACTION_RESET_MAGNITUDE)
        end

        local foreground_color = BreitbandGraphics.invert_color(theme.background_color)

        BreitbandGraphics.draw_text(
            grid_rect(4, 6, 2, 1),
            'center',
            'center',
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            'Consolas',
            'X: ' .. Engine.stick_for_input_x(Settings.tas))

        BreitbandGraphics.draw_text(
            grid_rect(6, 6, 2, 1),
            'center',
            'center',
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            'Consolas',
            'Y: ' .. Engine.stick_for_input_y(Settings.tas))

        if ugui.button({
                uid = 25,
                rectangle = grid_rect(4, 5, 2, 1),
                text = Locales.str('SPDKICK'),
            }) then
            action.invoke(ACTION_SET_SPDKICK)
        end

        local old_framewalk = Settings.tas.framewalk
        local framewalk = ugui.toggle_button({
            uid = 30,
            rectangle = grid_rect(6, 5, 2, 1),
            text = Locales.str('FRAMEWALK'),
            is_checked = Settings.tas.framewalk,
        })
        if framewalk ~= old_framewalk then
            action.invoke(ACTION_TOGGLE_FRAMEWALK)
        end

        local strain_always = Settings.tas.strain_always
        local new_strain_always = ugui.toggle_button({
            uid = 35,
            is_enabled = Settings.tas.strain_speed_target,
            rectangle = grid_rect(4, 0, 3, 1),
            text = Locales.str('D99_ALWAYS'),
            is_checked = Settings.tas.strain_always,
        })
        if new_strain_always ~= strain_always then
            action.invoke(ACTION_TOGGLE_D99_ALWAYS)
        end

        local strain_speed_target = Settings.tas.strain_speed_target
        local new_strain_speed_target = ugui.toggle_button({
            uid = 40,
            rectangle = grid_rect(7, 0, 1, 1),
            text = Locales.str('D99'),
            is_checked = Settings.tas.strain_speed_target,
        })
        if new_strain_speed_target ~= strain_speed_target then
            action.invoke(ACTION_TOGGLE_D99_ENABLED)
        end

        local old_swim = Settings.tas.swim
        local swim = ugui.toggle_button({
            uid = 45,
            rectangle = grid_rect(6.5, 7, 1.5, 1),
            text = Locales.str('SWIM'),
            is_checked = Settings.tas.swim,
        })
        if swim ~= old_swim then
            action.invoke(ACTION_TOGGLE_SWIM)
        end

        local old_dyaw = Settings.tas.dyaw
        local dyaw = ugui.toggle_button({
            uid = 50,
            is_enabled = Settings.tas.movement_mode == MovementModes.match_angle,
            rectangle = grid_rect(4, 1, 2, 1),
            text = Locales.str('DYAW'),
            is_checked = Settings.tas.dyaw,
        })
        if dyaw ~= old_dyaw then
            action.invoke(ACTION_TOGGLE_DYAW)
        end

        local old_strain_left = Settings.tas.strain_left
        local strain_left = ugui.toggle_button({
            uid = 55,
            rectangle = grid_rect(6, 1, 1, 1),
            text = '[icon:arrow_left]',
            is_checked = Settings.tas.strain_left,
        })
        if strain_left ~= old_strain_left then
            action.invoke(ACTION_TOGGLE_STRAIN_LEFT)
        end

        local old_strain_right = Settings.tas.strain_right
        local strain_right = ugui.toggle_button({
            uid = 60,
            rectangle = grid_rect(7, 1, 1, 1),
            text = '[icon:arrow_right]',
            is_checked = Settings.tas.strain_right,
        })
        if strain_right ~= old_strain_right then
            action.invoke(ACTION_TOGGLE_STRAIN_RIGHT)
        end

        local joystick_rect = grid(0, 4, 4, 4)
        local displayPosition = { x = Engine.stick_for_input_x(Settings.tas), y = -Engine.stick_for_input_y(Settings.tas) }
        local newPosition = ugui.joystick({
            uid = 70,
            rectangle = {
                x = joystick_rect[1],
                y = joystick_rect[2],
                width = joystick_rect[3],
                height = joystick_rect[4],
            },
            position = displayPosition,
            mag = Settings.tas.goal_mag >= 127 and 0 or Settings.tas.goal_mag,
            x_snap = 8,
            y_snap = 8,
        })
        if Settings.enable_manual_on_joystick_interact and (newPosition.x ~= displayPosition.x or newPosition.y ~= displayPosition.y) then
            action.invoke(ACTION_SET_MOVEMENT_MODE_MANUAL)
            Settings.tas.manual_joystick_x = math.min(127, math.floor(newPosition.x + 0.5))
            Settings.tas.manual_joystick_y = math.min(127, -math.floor(newPosition.y + 0.5))
        end

        local atan_strain = ugui.toggle_button({
            uid = 75,
            rectangle = grid_rect(4, 2, 3, 1),
            text = Locales.str('ATAN_STRAIN'),
            is_checked = Settings.tas.atan_strain,
        })

        if atan_strain and not Settings.tas.atan_strain then
            -- FIXME: do we really need to update memory
            Memory.update()
            Settings.tas.atan_start = Memory.current.mario_global_timer
        end
        Settings.tas.atan_strain = atan_strain

        Settings.tas.reverse_arc = ugui.toggle_button({
            uid = 80,
            rectangle = grid_rect(7, 2, 1, 1),
            text = Locales.str('ATAN_STRAIN_REV'),
            is_checked = Settings.tas.reverse_arc,
        })

        if ugui.button({
                uid = 85,
                rectangle = grid_rect(4, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.atan_exp = math.max(-4, math.min(Settings.atan_exp + 1, 4))
        end
        if ugui.button({
                uid = 90,
                rectangle = grid_rect(4, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.atan_exp = math.max(-4, math.min(Settings.atan_exp - 1, 4))
        end

        if ugui.button({
                uid = 95,
                rectangle = grid_rect(4.5, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.tas.atan_r = Settings.tas.atan_r + math.pow(10, Settings.atan_exp)
        end
        if ugui.button({
                uid = 100,
                rectangle = grid_rect(4.5, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.tas.atan_r = Settings.tas.atan_r - math.pow(10, Settings.atan_exp)
        end

        if ugui.button({
                uid = 105,
                rectangle = grid_rect(5, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.tas.atan_d = Settings.tas.atan_d + math.pow(10, Settings.atan_exp)
        end
        if ugui.button({
                uid = 110,
                rectangle = grid_rect(5, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.tas.atan_d = Settings.tas.atan_d - math.pow(10, Settings.atan_exp)
        end

        if ugui.button({
                uid = 115,
                rectangle = grid_rect(5.5, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.tas.atan_n = math.max(0,
                Settings.tas.atan_n + math.pow(10, math.max(-0.6020599913279624, Settings.atan_exp)), 2)
        end
        if ugui.button({
                uid = 120,
                rectangle = grid_rect(5.5, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.tas.atan_n = math.max(0,
                Settings.tas.atan_n - math.pow(10, math.max(-0.6020599913279624, Settings.atan_exp)), 2)
        end

        if ugui.button({
                uid = 135,
                rectangle = grid_rect(6, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.tas.atan_start = math.max(0, Settings.tas.atan_start + math.pow(10, math.max(0, Settings.atan_exp)))
        end
        if ugui.button({
                uid = 140,
                rectangle = grid_rect(6, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.tas.atan_start = math.max(0, Settings.tas.atan_start - math.pow(10, math.max(0, Settings.atan_exp)))
        end

        if ugui.toggle_button({
                uid = 145,
                rectangle = grid_rect(0, 0, 4, 1),
                text = Locales.str('DISABLED'),
                is_checked = Settings.tas.movement_mode == MovementModes.disabled,
            }) ~= (Settings.tas.movement_mode == MovementModes.disabled) then
            action.invoke(ACTION_SET_MOVEMENT_MODE_DISABLED)
        end
        if ugui.toggle_button({
                uid = 150,
                rectangle = grid_rect(0, 1, 4, 1),
                text = Locales.str('MATCH_YAW'),
                is_checked = Settings.tas.movement_mode == MovementModes.match_yaw,
            }) ~= (Settings.tas.movement_mode == MovementModes.match_yaw) then
            action.invoke(ACTION_SET_MOVEMENT_MODE_MATCH_YAW)
        end
        if ugui.toggle_button({
                uid = 155,
                rectangle = grid_rect(0, 2, 4, 1),
                text = Locales.str('REVERSE_ANGLE'),
                is_checked = Settings.tas.movement_mode == MovementModes.reverse_angle,
            }) ~= (Settings.tas.movement_mode == MovementModes.reverse_angle) then
            action.invoke(ACTION_SET_MOVEMENT_MODE_REVERSE_ANGLE)
        end
        if ugui.toggle_button({
                uid = 160,
                rectangle = grid_rect(0, 3, 4, 1),
                text = Locales.str('MATCH_ANGLE'),
                is_checked = Settings.tas.movement_mode == MovementModes.match_angle,
            }) ~= (Settings.tas.movement_mode == MovementModes.match_angle) then
            action.invoke(ACTION_SET_MOVEMENT_MODE_MATCH_ANGLE)
        end
    end,
}
