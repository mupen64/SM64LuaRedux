--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@type Section
---@diagnostic disable-next-line:assign-type-mismatch
local __impl = __impl

function __impl.new(name)
    local tmp = {}
    CloneInto(tmp, Joypad.input)
    return {
        inputs = { { tas_state = NewTASState(), joy = tmp, timeout = 1, end_action = 0 } },
        collapsed = false,
        name = name
    }
end
