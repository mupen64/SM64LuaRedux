--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

return {
    process = function(input)
        if Settings.tas.movement_mode == MovementModes.disabled then
            return input
        elseif Settings.tas.movement_mode == MovementModes.manual then
            Joypad.input.X = Settings.tas.manual_joystick_x or input.x
            Joypad.input.Y = Settings.tas.manual_joystick_y or input.y
            return Joypad.input
        end
        Memory.update()
        local result = Engine.inputs_for_angle(Settings.tas.goal_angle, input, Settings.tas.movement_mode)
        if Settings.tas.dustless_walk then
            Engine.scale_inputs_for_dustless_walk(result)
        elseif Settings.tas.goal_mag then
            Engine.scale_inputs_to_magnitude(result, Settings.tas.goal_mag, Settings.tas.maximize_airspeed)
        end
        input.X = result.X
        input.Y = result.Y
        return input
    end,
}
