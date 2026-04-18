--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@type SectionInputs
---@diagnostic disable-next-line:assign-type-mismatch
local __impl = __impl

function __impl.new()
    local tmp = {}
    CloneInto(tmp, Joypad.input)
    ---@type SectionInputs
    return {
        tas_state = NewTASState(),
        joy = tmp,
        timeout = 1,
        end_action = 0,
        editing = false,
    }
end