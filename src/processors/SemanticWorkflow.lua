--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local override = nil
local last_override_nil = true
local stored_tas_state = NewTASState()

return {
    transform = {
        process = function(input)
            last_override = override == nil
            override = CurrentSemanticWorkflowOverride()

            -- Store and restore the TAS state during override.
            if last_override_nil and override ~= nil then
                stored_tas_state = ugui.internal.deep_clone(Settings.tas)
            end
            if not last_override_nil and override == nil then
                Settings.tas = ugui.internal.deep_clone(stored_tas_state)
            end

            if override then
                Settings.tas = ugui.internal.deep_clone(override.tas_state)
                return ugui.internal.deep_clone(override.joy)
            else
                return input
            end
        end,
    },
    readback = {
        process = function(input)
            if override then
                override.joy.X = input.X
                override.joy.Y = input.Y
            end
            return input
        end,
    },
}
