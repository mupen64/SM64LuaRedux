--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Formatter = {}

---Formats a number as an angle
---@param value number The value to be formatted
---@return string The value's string representation
Formatter.angle = function(value)
    if Settings.format_angles_degrees then
        return string.format('%sdeg',
            MoreMaths.round(ugui.internal.remap(value, 0, 65536, 0, 360), Settings.format_decimal_points))
    else
        return tostring(MoreMaths.round(value, Settings.format_decimal_points))
    end
end

---Formats a number as a units/s value
---@param value number The value to be formatted
---@return string The value's string representation
Formatter.ups = function(value)
    return tostring(MoreMaths.round(value, Settings.format_decimal_points))
end

---Formats a number as a unit
---@param value number The value to be formatted
---@param places number? The number of decimal places to round to. Defaults to `Settings.format_decimal_points`.
---@return string The value's string representation
Formatter.u = function(value, places)
    places = places or Settings.format_decimal_points
    return tostring(MoreMaths.round(value, places))
end

---Formats a number (standard bounds 0-1) as a percentage
---@param value number The value to be formatted
---@param inf_threshold number? The threshold after which the percentage is considered infinite. Defaults to 1000000.
---@return string The value's string representation
Formatter.percent = function(value, inf_threshold)
    inf_threshold = inf_threshold or 1000000
    if value > inf_threshold then
        return '∞%'
    end
    return MoreMaths.round(value * 100, Settings.format_decimal_points) .. '%'
end

---Formats a number as a fraction.
---@param value number A number in the range 0-1.
---@param denominator number The denominator of the fraction.
---@return string The value's string representation as a fraction.
Formatter.fraction = function(value, denominator)
    if value > 1 then
        return string.format('>%d/%d', denominator, denominator)
    end
    if value < 0 then
        return string.format('<%d/%d', 0, denominator)
    end

    local n = math.floor(value * denominator + 0.5)
    if n > denominator then
        n = denominator
    end

    return string.format("%d/%d", n, denominator)
end
