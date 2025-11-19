--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('TAS', function(enum_next)
    return {
        ProcessedValues = enum_next(4),
        GoalAngle = enum_next(2),
        GoalMag = enum_next(2),
        HighMagnitude = enum_next(),
        ResetMag = enum_next(),
        SpeedKick = enum_next(),
        FrameWalk = enum_next(),
        D99Always = enum_next(),
        D99 = enum_next(),
        Swim = enum_next(),
        DYaw = enum_next(),
        StrainLeft = enum_next(),
        StrainRight = enum_next(),
        Joystick = enum_next(),
        AtanStrain = enum_next(),
        AtanStrainReverse = enum_next(),
        AtanButtons = enum_next(20),
        MovementModeDisabled = enum_next(),
        MovementModeMatchYaw = enum_next(),
        MovementModeReverseYaw = enum_next(),
        MovementModeMatchAngle = enum_next(),
    }
end)

return {
    name = Locales.str('TAS_TAB_NAME'),
    draw = function()
        local theme = Styles.theme()
        -- TODO: Expose this as a helper in `Drawing` or something
        local foreground_color = BreitbandGraphics.invert_color(theme.background_color)
        local stick_x = Engine.stick_for_input_x(Settings.tas)
        local stick_y = Engine.stick_for_input_y(Settings.tas)
        local movement_mode_changed = false

        local function set_movement_mode(mode, target_action)
            if movement_mode_changed then
                action.invoke(target_action)
                return
            end
            action.invoke(Settings.tas.movement_mode == mode and ACTION_SET_MOVEMENT_MODE_DISABLED or target_action)
            movement_mode_changed = true
        end

        local _, meta = ugui.toggle_button({
            uid = UID.MovementModeMatchYaw,
            rectangle = grid_rect(0, 0, 4, 1),
            text = Locales.str('MATCH_YAW'),
            is_checked = Settings.tas.movement_mode == MovementModes.match_yaw,
        })

        if meta.signal_change == ugui.signal_change_states.started then
            set_movement_mode(MovementModes.match_yaw, ACTION_SET_MOVEMENT_MODE_MATCH_YAW)
        end

        local _, meta = ugui.toggle_button({
            uid = UID.MovementModeReverseYaw,
            rectangle = grid_rect(4, 0, 4, 1),
            text = Locales.str('REVERSE_YAW'),
            is_checked = Settings.tas.movement_mode == MovementModes.reverse_yaw,
        })

        if meta.signal_change == ugui.signal_change_states.started then
            set_movement_mode(MovementModes.reverse_yaw, ACTION_SET_MOVEMENT_MODE_REVERSE_YAW)
        end

        local _, meta = ugui.toggle_button({
            uid = UID.MovementModeMatchAngle,
            rectangle = grid_rect(0, 1, 2.5, 1),
            text = Locales.str('MATCH_ANGLE'),
            is_checked = Settings.tas.movement_mode == MovementModes.match_angle,
        })

        if meta.signal_change == ugui.signal_change_states.started then
            set_movement_mode(MovementModes.match_angle, ACTION_SET_MOVEMENT_MODE_MATCH_ANGLE)
        end

        local _, dyaw_meta = ugui.toggle_button({
            uid = UID.DYaw,
            is_enabled = Settings.tas.movement_mode == MovementModes.match_angle,
            rectangle = grid_rect(2.5, 1, 2, 1),
            text = Locales.str('DYAW'),
            is_checked = Settings.tas.dyaw,
        })
        if dyaw_meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_TOGGLE_DYAW)
        end

        local _, meta = ugui.toggle_button({
            uid = UID.StrainLeft,
            rectangle = grid_rect(4.5, 1, 0.75, 1),
            text = '[icon:arrow_left]',
            is_checked = Settings.tas.strain_left,
        })
        if meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_TOGGLE_STRAIN_LEFT)
        end

        local _, meta = ugui.toggle_button({
            uid = UID.StrainRight,
            rectangle = grid_rect(5.25, 1, 0.75, 1),
            text = '[icon:arrow_right]',
            is_checked = Settings.tas.strain_right,
        })
        if meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_TOGGLE_STRAIN_RIGHT)
        end

        Settings.tas.goal_angle = math.abs(ugui.numberbox({
            uid = UID.GoalAngle,
            is_enabled = Settings.tas.movement_mode == MovementModes.match_angle,
            rectangle = grid_rect(6, 1, 2, 1),
            places = 5,
            value = Settings.tas.goal_angle,
        }))

        local _, meta = ugui.toggle_button({
            uid = UID.D99,
            rectangle = grid_rect(0, 2, 2, 1),
            text = Locales.str('D99'),
            is_checked = Settings.tas.strain_speed_target,
        })
        if meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_TOGGLE_D99_ENABLED)
        end

        local _, meta = ugui.toggle_button({
            uid = UID.D99Always,
            is_enabled = Settings.tas.strain_speed_target,
            rectangle = grid_rect(2, 2, 2, 1),
            text = Locales.str('D99_ALWAYS'),
            is_checked = Settings.tas.strain_always,
        })
        if meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_TOGGLE_D99_ALWAYS)
        end

        local atan_strain, meta = ugui.toggle_button({
            uid = UID.AtanStrain,
            rectangle = grid_rect(4, 2, 3, 1),
            text = Locales.str('ATAN_STRAIN'),
            is_checked = Settings.tas.atan_strain,
        })
        if meta.signal_change == ugui.signal_change_states.started then
            -- FIXME: do we really need to update memory
            Memory.update()
            Settings.tas.atan_strain = atan_strain
            Settings.tas.atan_start = Memory.current.mario_global_timer
        end

        Settings.tas.reverse_arc = ugui.toggle_button({
            uid = UID.AtanStrainReverse,
            rectangle = grid_rect(7, 2, 1, 1),
            text = Locales.str('ATAN_STRAIN_REV'),
            is_checked = Settings.tas.reverse_arc,
        })

        if Settings.tas.atan_strain then
            local function atan_field(index, text, up_callback, down_callback)
                local width = 1.6
                local x = index * width
                BreitbandGraphics.draw_text(
                    grid_rect(x, 3, width, 0.5),
                    'center',
                    'center',
                    { aliased = not theme.cleartype, fit = true },
                    foreground_color,
                    theme.font_size * Drawing.scale,
                    'Consolas',
                    text)

                if ugui.button({
                        uid = UID.AtanButtons + index * 2,
                        rectangle = grid_rect(x, 3.5, width / 2, 0.5),
                        text = '-',
                    }) then
                    down_callback()
                end

                if ugui.button({
                        uid = UID.AtanButtons + index * 2 + 1,
                        rectangle = grid_rect(x + width / 2, 3.5, width / 2, 0.5),
                        text = '+',
                    }) then
                    up_callback()
                end
            end

            atan_field(0,
                'E: ' .. tostring(Settings.atan_exp),
                function()
                    Settings.atan_exp = math.max(-4, math.min(Settings.atan_exp + 1, 4))
                end,
                function()
                    Settings.atan_exp = math.max(-4, math.min(Settings.atan_exp - 1, 4))
                end)

            atan_field(1,
                'R: ' .. tostring(Settings.tas.atan_r),
                function()
                    Settings.tas.atan_r = Settings.tas.atan_r + math.pow(10, Settings.atan_exp)
                end,
                function()
                    Settings.tas.atan_r = Settings.tas.atan_r - math.pow(10, Settings.atan_exp)
                end)


            atan_field(2,
                'D: ' .. tostring(Settings.tas.atan_d),
                function()
                    Settings.tas.atan_d = Settings.tas.atan_d + math.pow(10, Settings.atan_exp)
                end,
                function()
                    Settings.tas.atan_d = Settings.tas.atan_d - math.pow(10, Settings.atan_exp)
                end)

            atan_field(3,
                'N: ' .. tostring(Settings.tas.atan_n),
                function()
                    Settings.tas.atan_n = math.max(0,
                        Settings.tas.atan_n + math.pow(10, math.max(-0.6020599913279624, Settings.atan_exp)), 2)
                end,
                function()
                    Settings.tas.atan_n = math.max(0,
                        Settings.tas.atan_n - math.pow(10, math.max(-0.6020599913279624, Settings.atan_exp)), 2)
                end)

            atan_field(4,
                'S: ' .. tostring(Settings.tas.atan_start),
                function()
                    Settings.tas.atan_start = math.max(0, Settings.tas.atan_start - math.pow(10, math.max(0, Settings.atan_exp)))
                end,
                function()
                    Settings.tas.atan_start = math.max(0, Settings.tas.atan_start + math.pow(10, math.max(0, Settings.atan_exp)))
                end)
        end

        -- Shift elements down to make place for atan panel if atan strain is enabled.
        local YORG = Settings.tas.atan_strain and 4 or 3

        BreitbandGraphics.draw_text(
            grid_rect(4, YORG, 2, 1),
            'center',
            'center',
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            'Consolas',
            'X: ' .. stick_x)

        BreitbandGraphics.draw_text(
            grid_rect(6, YORG, 2, 1),
            'center',
            'center',
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            'Consolas',
            'Y: ' .. stick_y)

        BreitbandGraphics.draw_text(
            grid_rect(4, YORG + 1, 2, 1),
            'center',
            'center',
            { aliased = not theme.cleartype, fit = true },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            'Consolas',
            'Mag: ' .. Formatter.u(Engine.get_magnitude_for_stick(stick_x, stick_y), 0))

        Settings.tas.goal_mag = math.abs(ugui.numberbox({
            uid = UID.GoalMag,
            rectangle = grid_rect(4, YORG + 2, 2, 1),
            places = 3,
            value = Settings.tas.goal_mag,
        }))

        if ugui.button({
                uid = UID.ResetMag,
                rectangle = grid_rect(4, YORG + 3, 1, 1),
                text = Locales.str('MAG_RESET'),
            }) then
            action.invoke(ACTION_RESET_MAGNITUDE)
        end

        local high_magnitude, meta = ugui.toggle_button({
            uid = UID.HighMagnitude,
            rectangle = grid_rect(5, YORG + 3, 1, 1),
            text = Locales.str('MAG_HI'),
            is_checked = Settings.tas.high_magnitude,
        })
        if meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_TOGGLE_HIGH_MAGNITUDE)
        end

        if ugui.button({
                uid = UID.SpeedKick,
                rectangle = grid_rect(6, YORG + 1, 2, 1),
                text = Locales.str('SPDKICK'),
            }) then
            action.invoke(ACTION_SET_SPDKICK)
        end

        local _, meta = ugui.toggle_button({
            uid = UID.FrameWalk,
            rectangle = grid_rect(6, YORG + 2, 2, 1),
            text = Locales.str('FRAMEWALK'),
            is_checked = Settings.tas.framewalk,
        })
        if meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_TOGGLE_FRAMEWALK)
        end

        local _, meta = ugui.toggle_button({
            uid = UID.Swim,
            rectangle = grid_rect(6, YORG + 3, 2, 1),
            text = Locales.str('SWIM'),
            is_checked = Settings.tas.swim,
        })
        if meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_TOGGLE_SWIM)
        end

        local joystick_rect = grid(0, YORG, 4, 4)
        local displayPosition = { x = Engine.stick_for_input_x(Settings.tas), y = -Engine.stick_for_input_y(Settings.tas) }
        local newPosition, meta = ugui.joystick({
            uid = UID.Joystick,
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

        if Settings.enable_manual_on_joystick_interact and meta.signal_change == ugui.signal_change_states.started then
            action.invoke(ACTION_SET_MOVEMENT_MODE_MANUAL)
        end

        if Settings.enable_manual_on_joystick_interact then
            Settings.tas.manual_joystick_x = math.min(127, math.floor(newPosition.x + 0.5))
            Settings.tas.manual_joystick_y = math.min(127, -math.floor(newPosition.y + 0.5))
        end

        ugui.listbox({
            uid = UID.ProcessedValues,
            rectangle = grid_rect(0, YORG + 4, 8, (8 - YORG) + 4),
            selected_index = nil,
            items = VarWatch.processed_values,
        })
    end,
}
