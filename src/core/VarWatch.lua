--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local var_funcs = {
    ['yaw_facing'] = function()
        local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_facing_yaw) or Memory.current.mario_facing_yaw)
        local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_facing_yaw) + 32768) % 65536 or (Memory.current.mario_facing_yaw + 32768) % 65536)
        return string.format(Locales.str('VARWATCH_FACING_YAW'), Formatter.angle(angle), Formatter.angle(opposite))
    end,
    ['yaw_intended'] = function()
        local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_intended_yaw) or Memory.current.mario_intended_yaw)
        local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_intended_yaw) + 32768) % 65536 or (Memory.current.mario_intended_yaw + 32768) % 65536)
        return string.format(Locales.str('VARWATCH_INTENDED_YAW'), Formatter.angle(angle), Formatter.angle(opposite))
    end,
    ['h_spd'] = function()
        local h_speed = Memory.current.mario_h_speed
        local h_sliding_speed = Engine.GetHSlidingSpeed()
        return string.format(Locales.str('VARWATCH_H_SPEED'), Formatter.ups(h_speed), Formatter.ups(h_sliding_speed))
    end,
    ['v_spd'] = function()
        local y_speed = Memory.current.mario_v_speed
        return string.format(Locales.str('VARWATCH_Y_SPEED'), Formatter.ups(y_speed))
    end,
    ['spd_efficiency'] = function()
        if Settings.spd_efficiency_fraction then
            local spd_efficiency = Engine.GetSpeedEfficiency()
            local d
            if spd_efficiency < 0.01 then
                d = 0
            elseif spd_efficiency < 0.25 then
                d = 1
            elseif spd_efficiency < 0.5 then
                d = 2
            elseif spd_efficiency < 0.75 then
                d = 3
            else
                d = 4
            end
            return string.format(Locales.str('VARWATCH_SPD_EFFICIENCY_FRACTION'), d)
        else
            return string.format(Locales.str('VARWATCH_SPD_EFFICIENCY_PERCENTAGE'),
                Formatter.percent(Engine.GetSpeedEfficiency()))
        end
    end,
    ['position_x'] = function()
        return string.format(Locales.str('VARWATCH_POS_X'), Formatter.u(Memory.current.mario_x))
    end,
    ['position_y'] = function()
        return string.format(Locales.str('VARWATCH_POS_Y'), Formatter.u(Memory.current.mario_y))
    end,
    ['position_z'] = function()
        return string.format(Locales.str('VARWATCH_POS_Z'), Formatter.u(Memory.current.mario_z))
    end,
    ['pitch'] = function()
        return string.format(Locales.str('VARWATCH_PITCH'), Formatter.angle(Memory.current.mario_pitch))
    end,
    ['yaw_vel'] = function()
        return string.format(Locales.str('VARWATCH_YAW_VEL'), Formatter.angle(Memory.current.mario_yaw_vel))
    end,
    ['pitch_vel'] = function()
        return string.format(Locales.str('VARWATCH_PITCH_VEL'), Formatter.angle(Memory.current.mario_pitch_vel))
    end,
    ['xz_movement'] = function()
        return string.format(Locales.str('VARWATCH_XZ_MOVEMENT'),
            Formatter.u(Engine.get_xz_distance_moved_since_last_frame()))
    end,
    ['action'] = function()
        local name = Locales.raw().ACTIONS[Memory.current.mario_action]
        local fallback = Locales.str('VARWATCH_UNKNOWN_ACTION') .. Memory.current.mario_action
        return Locales.str('VARWATCH_ACTION') .. (name or fallback)
    end,
    ['rng'] = function()
        return Locales.str('VARWATCH_RNG') ..
            Memory.current.rng_value ..
            ' (' .. Locales.str('VARWATCH_RNG_INDEX') .. RNG.get_index(Memory.current.rng_value) .. ')'
    end,
    ['global_timer'] = function()
        return string.format(Locales.str('VARWATCH_GLOBAL_TIMER'), (Memory.current.mario_global_timer))
    end,
    ['moved_dist'] = function()
        local dist = Settings.track_moved_distance and Engine.get_distance_moved() or Settings.moved_distance
        return string.format(Locales.str('VARWATCH_DIST_MOVED'), Formatter.u(dist))
    end,
    ['atan_basic'] = function()
        return string.format('E: %s R: %s D: %s N: %s', Settings.atan_exp,
            MoreMaths.round(Settings.tas.atan_r, Settings.format_decimal_points),
            MoreMaths.round(Settings.tas.atan_d, Settings.format_decimal_points),
            MoreMaths.round(Settings.tas.atan_n, Settings.format_decimal_points)
        )
    end,
    ['atan_start_frame'] = function()
        return 'S: ' .. math.floor(Settings.tas.atan_start + 1)
    end,
}
VarWatch = {
    processed_values = {},
}

VarWatch_compute_value = function(key)
    return var_funcs[key]()
end

VarWatch_update = function()
    VarWatch.processed_values = {}
    for key, value in pairs(Settings.variables) do
        if value.visible then
            VarWatch.processed_values[#VarWatch.processed_values + 1] = var_funcs[value.identifier]()
        end
    end
end
