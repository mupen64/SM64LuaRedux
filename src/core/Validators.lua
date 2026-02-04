--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local validators = {}

---Validates that the given string represents a number.
---@param str string
---@return string?
function validators.number(str)
    local num = tonumber(str)
    if num == nil then
        return "Value must be a number."
    end

    return nil
end

---Validates that the given string represents a number or is empty.
---@param str string
---@return string?
function validators.number_optional(str)
    if #str == 0 then
        return nil
    end

    local num = tonumber(str)
    if num == nil then
        return "Value must be a number or empty."
    end

    return nil
end

return validators
