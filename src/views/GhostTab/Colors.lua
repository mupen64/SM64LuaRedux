--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- color helpers shared by the ghost tab's color pickers; colors are {r, g, b} arrays of 0-255 integers
local Colors = {}

---@param rgb HatColor
---@return string # e.g. '#FF0000'
function Colors.rgb_to_str(rgb)
    return string.format('#%02X%02X%02X', rgb[1], rgb[2], rgb[3])
end

---Parses a hex color string (with or without a leading '#'). Returns nil if invalid.
---@param text string
---@return HatColor | nil
function Colors.parse_hex_color(text)
    if not text then
        return nil
    end
    local hex = text:gsub('#', ''):gsub('%s', '')
    if #hex ~= 6 or hex:match('%X') then
        return nil
    end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then
        return nil
    end
    return {r, g, b}
end

---@param rgb HatColor
---@return UguiRGBAF
function Colors.rgb_to_ugui_color(rgb)
    return {r = rgb[1] / 255, g = rgb[2] / 255, b = rgb[3] / 255, a = 1}
end

---@param color UguiRGBAF
---@return HatColor
function Colors.ugui_color_to_rgb(color)
    return {
        math.floor(color.r * 255 + 0.5),
        math.floor(color.g * 255 + 0.5),
        math.floor(color.b * 255 + 0.5),
    }
end

return Colors
