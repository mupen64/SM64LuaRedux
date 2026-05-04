--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@alias VarWatchEntry { label: string?, value: string }

VarWatch = {
    ---@type string[]
    processed_values = {},

    ---@type table<string, fun(): VarWatchEntry>
    var_funcs = {},
}

VarWatch.var_funcs = {
    ['yaw_facing'] = function()
        local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_facing_yaw) or Memory.current.mario_facing_yaw)
        local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_facing_yaw) + 32768) % 65536 or (Memory.current.mario_facing_yaw + 32768) % 65536)
        return {
            label = Locales.str('VARWATCH_FACING_YAW_LABEL'),
            value = string.format(Locales.str('VARWATCH_FACING_YAW'),
                Formatter.angle(angle), Formatter.angle(opposite))
        }
    end,
    ['yaw_intended'] = function()
        local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_intended_yaw) or Memory.current.mario_intended_yaw)
        local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_intended_yaw) + 32768) % 65536 or (Memory.current.mario_intended_yaw + 32768) % 65536)
        return {
            label = Locales.str('VARWATCH_INTENDED_YAW_LABEL'),
            value = string.format(
                Locales.str('VARWATCH_INTENDED_YAW'), Formatter.angle(angle), Formatter.angle(opposite))
        }
    end,
    ['h_spd'] = function()
        local h_speed = Memory.current.mario_h_speed
        local h_sliding_speed = Engine.GetHSlidingSpeed()
        return {
            label = Locales.str('VARWATCH_H_SPEED_LABEL'),
            value = string.format(Locales.str('VARWATCH_H_SPEED'),
                Formatter.ups(h_speed), Formatter.ups(h_sliding_speed))
        }
    end,
    ['v_spd'] = function()
        local y_speed = Memory.current.mario_v_speed
        return {
            label = Locales.str('VARWATCH_Y_SPEED_LABEL'),
            value = Formatter.ups(y_speed)
        }
    end,
    ['spd_efficiency'] = function()
        local spd_efficiency = Engine.GetSpeedEfficiency()
        local percentage = Formatter.percent(spd_efficiency)
        local fraction = Formatter.fraction(spd_efficiency, 4)
        local full = string.format("%s (%s)", percentage, fraction)

        return {
            label = Locales.str('VARWATCH_SPD_EFFICIENCY_LABEL'),
            value = full
        }
    end,
    ['position_x'] = function()
        return {
            label = Locales.str('VARWATCH_POS_X_LABEL'),
            value = Formatter.u(Memory.current.mario_x)
        }
    end,
    ['position_y'] = function()
        return {
            label = Locales.str('VARWATCH_POS_Y_LABEL'),
            value = Formatter.u(Memory.current.mario_y)
        }
    end,
    ['position_z'] = function()
        return {
            label = Locales.str('VARWATCH_POS_Z_LABEL'),
            value = Formatter.u(Memory.current.mario_z)
        }
    end,
    ['pitch'] = function()
        return {
            label = Locales.str('VARWATCH_PITCH_LABEL'),
            value = Formatter.angle(Memory.current.mario_pitch)
        }
    end,
    ['yaw_vel'] = function()
        return {
            label = Locales.str('VARWATCH_YAW_VEL_LABEL'),
            value = Formatter.angle(Memory.current.mario_yaw_vel)
        }
    end,
    ['pitch_vel'] = function()
        return {
            label = Locales.str('VARWATCH_PITCH_VEL_LABEL'),
            value = Formatter.angle(Memory.current.mario_pitch_vel)
        }
    end,
    ['xz_movement'] = function()
        return {
            label = Locales.str('VARWATCH_XZ_MOVEMENT_LABEL'),
            value = Formatter.u(Engine.get_xz_distance_moved_since_last_frame())
        }
    end,
    ['action'] = function()
        local name = Locales.raw().ACTIONS[Memory.current.mario_action]
        local fallback = Locales.str('VARWATCH_UNKNOWN_ACTION') .. Memory.current.mario_action
        return {
            label = Locales.str('VARWATCH_ACTION_LABEL'),
            value = (name or fallback)
        }
    end,
    ['rng'] = function()
        return {
            label = Locales.str('VARWATCH_RNG_LABEL'),
            value = string.format("%d (%s %d)",
                Memory.current.rng_value,
                Locales.str('VARWATCH_RNG_INDEX_LABEL'),
                RNG.get_index(Memory.current.rng_value))
        }
    end,
    ['global_timer'] = function()
        return {
            label = Locales.str('VARWATCH_GLOBAL_TIMER_LABEL'),
            value = tostring(Memory.current.mario_global_timer)
        }
    end,
    ['moved_dist'] = function()
        local dist = Settings.track_moved_distance and Engine.get_distance_moved() or Settings.moved_distance
        return {
            label = Locales.str('VARWATCH_DIST_MOVED_LABEL'),
            value = Formatter.u(dist)
        }
    end,
    ['atan_basic'] = function()
        return {
            value = string.format('E: %s R: %s D: %s N: %s', Settings.atan_exp,
                MoreMaths.round(Settings.tas.atan_r, Settings.format_decimal_points),
                MoreMaths.round(Settings.tas.atan_d, Settings.format_decimal_points),
                MoreMaths.round(Settings.tas.atan_n, Settings.format_decimal_points)
            )
        }
    end,
    ['atan_start_frame'] = function()
        return {
            value = 'S: ' .. math.floor(Settings.tas.atan_start + 1)
        }
    end,
}


VarWatch_compute_value = function(key)
    return VarWatch.var_funcs[key]()
end

VarWatch_update = function()
    VarWatch.processed_values = {}
    for key, value in pairs(Settings.variables) do
        if not value.visible then
            goto continue
        end

        local entry = VarWatch.var_funcs[value.identifier]()

        local str
        if entry.label then
            str = string.format('%s: %s', entry.label, entry.value)
        else
            str = entry.value
        end
        VarWatch.processed_values[#VarWatch.processed_values + 1] = str

        ::continue::
    end
end
