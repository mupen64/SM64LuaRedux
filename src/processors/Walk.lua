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
        local result = Engine.inputsForAngle(Settings.tas.goal_angle, input)
        if Settings.tas.goal_mag then
            Engine.scaleInputsForMagnitude(result, Settings.tas.goal_mag, Settings.tas.high_magnitude)
        end

        input.X = result.X
        input.Y = result.Y
        return input
    end,
}
