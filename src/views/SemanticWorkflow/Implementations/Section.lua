--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@type Section
---@diagnostic disable-next-line:assign-type-mismatch
local __impl = __impl

function __impl.new(end_action, timeout)
    local tmp = {}
    CloneInto(tmp, Joypad.input)
    return {
        end_action = end_action,
        timeout = timeout,
        inputs = { { tas_state = NewTASState(), joy = tmp, } },
        collapsed = false,
    }
end