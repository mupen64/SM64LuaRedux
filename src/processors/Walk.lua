--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

return {
    process = function(input)
        if TASState.movement_mode == MovementModes.disabled then
            return input
        elseif TASState.movement_mode == MovementModes.manual then
            Joypad.input.X = TASState.manual_joystick_x or input.x
            Joypad.input.Y = TASState.manual_joystick_y or input.y
            return Joypad.input
        end
        Memory.update()
        local result = Engine.inputsForAngle(TASState.goal_angle, input)
        if TASState.goal_mag then
            Engine.scaleInputsForMagnitude(result, TASState.goal_mag, TASState.high_magnitude)
        end

        input.X = result.X
        input.Y = result.Y
        return input
    end
}
