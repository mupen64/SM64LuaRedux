--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- This code has been adapted from an old script
-- Original Author unknown
local SWIMMING_ANIMATION_2 = 0x300024D1
local WATER_ACTION_END = 0x300022C2
local WATER_IDLE = 0x380022C0

return {
	process = function(input)
		if not Settings.tas.swim then
			return input
		end

		if Memory.current.mario_action == SWIMMING_ANIMATION_2
			or Memory.current.mario_action == WATER_ACTION_END
			or Memory.current.mario_action == WATER_IDLE
			or Memory.current.mario_action == 0x300024D4
			or Memory.current.mario_action == 0x380022C1 then
			input[Settings.swimming_button] = 1
		end
		return input
	end,
}
