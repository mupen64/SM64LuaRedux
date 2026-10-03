--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- A button filled with `control.color` ({r, g, b}). It's a registry entry rather than a
-- button with a rectangle drawn over it because ugui renders its scene at the end of the
-- frame, which would paint the button over anything drawn directly here.
ugui.registry.color_button = {
    uids = ugui.registry.button.uids,
    validate = ugui.registry.button.validate,
    logic = ugui.registry.button.logic,
    draw = function(control)
        ugui.standard_styler.draw_button(control)
        local c = control.color
        BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, -4),
            { r = c[1], g = c[2], b = c[3], a = control.is_enabled == false and 80 or 255 })
    end,
}

function rgb_to_str(rgb)
    return string.format('#%02X%02X%02X', rgb[1], rgb[2], rgb[3])
end

---Parses a hex color string (with or without a leading '#'). Returns nil if invalid.
function parse_hex_color(text)
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

---Converts HSV (h: 0-360, s/v: 0-1) to an RGB table (0-255 integers).
local function hsv_to_rgb(h, s, v)
    h = h % 360
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r, g, b
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return {
        math.floor((r + m) * 255 + 0.5),
        math.floor((g + m) * 255 + 0.5),
        math.floor((b + m) * 255 + 0.5),
    }
end

---Converts an RGB table (0-255) to HSV (h: 0-360, s/v: 0-1).
local function rgb_to_hsv(rgb)
    local r, g, b = rgb[1] / 255, rgb[2] / 255, rgb[3] / 255
    local max_c, min_c = math.max(r, g, b), math.min(r, g, b)
    local delta = max_c - min_c
    local h = 0
    if delta > 0 then
        if max_c == r then
            h = 60 * (((g - b) / delta) % 6)
        elseif max_c == g then
            h = 60 * (((b - r) / delta) + 2)
        else
            h = 60 * (((r - g) / delta) + 4)
        end
    end
    return h, (max_c == 0 and 0 or delta / max_c), max_c
end

-- color picker state; hue/saturation are kept between frames so dragging value to 0
-- (or saturation to 0) doesn't lose the hue the way a round trip through RGB would
local picker = {
    open = false,
    ghost_id = nil,   -- ghost being edited while open
    original = nil,   -- color to restore on cancel
    hue = 0,
    sat = 0,
    val = 1,
    last_color = nil, -- hex string of the color the picker last saw or produced
    drag = nil,       -- nil | 'wheel' | 'bar'
}

---Draws an HSV wheel with a value bar beside it inside `rect`.
---@param rect Rectangle
---@param rgb integer[] # the current color, {r, g, b} in 0-255
---@return integer[] | nil # the new color while the user is dragging, nil otherwise
function picker.draw(rect, rgb)
    local hex = rgb_to_str(rgb)
    if hex ~= picker.last_color then
        -- resync when the color was changed elsewhere (textbox, different ghost selected)
        picker.hue, picker.sat, picker.val = rgb_to_hsv(rgb)
        picker.last_color = hex
        picker.drag = nil
    end

    local bar_width = math.floor(rect.width * 0.1)
    local gap = math.floor(bar_width / 2)
    local wheel_size = math.min(rect.height, rect.width - bar_width - gap)
    local radius = wheel_size / 2
    local wheel_x = rect.x + math.floor((rect.width - wheel_size - gap - bar_width) / 2)
    local cx, cy = wheel_x + radius, rect.y + radius
    local bar_rect = { x = wheel_x + wheel_size + gap, y = rect.y, width = bar_width, height = wheel_size }

    -- input: a drag only starts on a fresh click inside the wheel or bar
    local env = ugui.internal.environment
    if not env.is_primary_down then
        picker.drag = nil
    elseif ugui.internal.is_mouse_just_down() then
        local down = ugui.internal.mouse_down_position
        local dx, dy = down.x - cx, down.y - cy
        if dx * dx + dy * dy <= radius * radius then
            picker.drag = 'wheel'
        elseif BreitbandGraphics.is_point_inside_rectangle(down, bar_rect) then
            picker.drag = 'bar'
        end
    end

    local result = nil
    if picker.drag then
        local mouse = env.mouse_position
        if picker.drag == 'wheel' then
            local dx, dy = mouse.x - cx, mouse.y - cy
            picker.hue = math.deg(math.atan(-dy, dx)) % 360
            picker.sat = math.min(math.sqrt(dx * dx + dy * dy) / radius, 1)
        else
            picker.val = 1 - math.max(0, math.min(1, (mouse.y - bar_rect.y) / bar_rect.height))
        end
        result = hsv_to_rgb(picker.hue, picker.sat, picker.val)
        picker.last_color = rgb_to_str(result)
    end

    -- hue/saturation wheel, approximated with small filled cells at full value
    local cell = math.max(2, math.floor(wheel_size / 24))
    for gy = 0, wheel_size - 1, cell do
        for gx = 0, wheel_size - 1, cell do
            local dx, dy = gx + cell / 2 - radius, gy + cell / 2 - radius
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= radius then
                local c = hsv_to_rgb(math.deg(math.atan(-dy, dx)), dist / radius, 1)
                BreitbandGraphics.fill_rectangle(
                    { x = wheel_x + gx, y = rect.y + gy, width = cell, height = cell },
                    { r = c[1], g = c[2], b = c[3] })
            end
        end
    end

    -- value bar: selected hue/saturation at the top fading to black
    local top = hsv_to_rgb(picker.hue, picker.sat, 1)
    for gy = 0, bar_rect.height - 1, 2 do
        local t = 1 - gy / bar_rect.height
        BreitbandGraphics.fill_rectangle(
            { x = bar_rect.x, y = bar_rect.y + gy, width = bar_rect.width, height = 2 },
            { r = math.floor(top[1] * t), g = math.floor(top[2] * t), b = math.floor(top[3] * t) })
    end
    BreitbandGraphics.draw_rectangle(bar_rect, Drawing.foreground_color(), 1)

    -- markers for the current selection
    local rad = math.rad(picker.hue)
    local dot_x = cx + picker.sat * radius * math.cos(rad)
    local dot_y = cy - picker.sat * radius * math.sin(rad)
    local dot = { x = dot_x - 4, y = dot_y - 4, width = 8, height = 8 }
    BreitbandGraphics.fill_ellipse(dot, { r = 255, g = 255, b = 255 })
    BreitbandGraphics.draw_ellipse(dot, { r = 0, g = 0, b = 0 }, 1)

    local marker = { x = bar_rect.x - 2, y = bar_rect.y + (1 - picker.val) * bar_rect.height - 2, width = bar_rect.width + 4, height = 4 }
    BreitbandGraphics.fill_rectangle(marker, { r = 255, g = 255, b = 255 })
    BreitbandGraphics.draw_rectangle(marker, { r = 0, g = 0, b = 0 }, 1)

    return result
end

return picker
