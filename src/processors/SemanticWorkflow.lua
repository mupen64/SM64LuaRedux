--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local override
return {
    transform = {
        process = function(input)
            override = CurrentSemanticWorkflowOverride()
            if override then
                TASState = ugui.internal.deep_clone(override.tas_state)
                return ugui.internal.deep_clone(override.joy)
            else
                TASState = DefaultTASState
                return input
            end
        end
    },
    readback = {
        process = function(input)
            if override then
                override.joy.X = input.X
                override.joy.Y = input.Y
            end
            return input
        end
    }
}
