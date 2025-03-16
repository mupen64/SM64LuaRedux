Formatter = {}

---Formats a number as an angle
---@param value number The value to be formatted
---@return string The value's string representation
Formatter.angle = function(value)
    if Settings.format_angles_degrees then
        return string.format("%sdeg",
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
---@return string The value's string representation
Formatter.u = function(value)
    return tostring(MoreMaths.round(value, Settings.format_decimal_points))
end

---Formats a number (standard bounds 0-1) as a percentage
---@param value number The value to be formatted
---@param inf_threshold number? The threshold after which the percentage is considered infinite. Defaults to 1000000.
---@return string The value's string representation
Formatter.percent = function(value, inf_threshold)
    inf_threshold = inf_threshold or 1000000
    if value > inf_threshold then
        return "∞%"
    end
    return MoreMaths.round(value * 100, Settings.format_decimal_points) .. "%"
end
