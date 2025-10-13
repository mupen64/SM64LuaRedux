--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

return {
    process = function(input)
        if not Settings.tas.framewalk then
            return input
        end

        -- walking/hold walking action means 0-input joystick override
        if Memory.current.mario_action == 0x04000440 or Memory.current.mario_action == 0x00000442 then
            input.X = 0
            input.Y = 0
        end

        return input
    end,
}
