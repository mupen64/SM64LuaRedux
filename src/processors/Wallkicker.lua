--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local AIR_HIT_WALL = 0x000008A7
return {
    process = function(input)
        if not Settings.auto_firsties then
            return input
        end

        if Memory.current.mario_action == AIR_HIT_WALL then
            input['A'] = true
        end
        return input
    end,
}
