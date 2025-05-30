---@type Section
---@diagnostic disable-next-line:assign-type-mismatch
local __impl = __impl

function __impl.new(endAction, timeout)
    local tmp = {}
    CloneInto(tmp, Joypad.input)
    return {
        endAction = endAction,
        timeout = timeout,
        inputs = { { tasState = NewTASState(), joy = tmp, } },
        collapsed = false,
    }
end