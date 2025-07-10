--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- written by aurum baker at 2am while caffeinated
-- maybe not best quality and stability
local tries = 0
local falling = false

local function get_left_inputs(input)
    local result = Engine.inputsForAngle(Memory.current.mario_facing_yaw + 32768 / Settings.grind_divisor, input)
    return {
        X = result.X,
        Y = result.Y,
    }
end

local function get_right_inputs(input)
    local result = Engine.inputsForAngle(Memory.current.mario_facing_yaw - 32768 / Settings.grind_divisor, input)
    return {
        X = result.X,
        Y = result.Y,
    }
end

Grind = {
    start = function()
        tries = 0
        falling = Memory.current.mario_action == 0x0100088C
        print("starting grind")
    end
}

return {
    process = function(input)
        if not Settings.grind then
            return input
        end

        if Memory.current.mario_action == 0x00880456 then
            if falling then
                falling = false
                tries = 0
                print("one cycle, now sliding")
            end
            tries = tries + 1
            local grind_input = Settings.grind_left and get_right_inputs(input) or get_left_inputs(input)
            input.X = grind_input.X + tries
            input.Y = grind_input.Y + tries
            input.B = true
        end

        if Memory.current.mario_action == 0x0100088C then
            if not falling then
                falling = true
                tries = 0
                print("one cycle, now falling")
            end
            tries = tries + 1
            local grind_input = Settings.grind_left and get_left_inputs(input) or get_right_inputs(input)
            input.X = grind_input.X + tries
            input.Y = grind_input.Y + tries
            input.B = true
        end
        return input
    end

}
