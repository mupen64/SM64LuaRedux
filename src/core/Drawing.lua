--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Drawing = {
    initial_size = nil,
    size = nil,
    scale = 1,
    offset_stack = {},
}

function Drawing.size_up()
    Drawing.initial_size = wgui.info()
    Drawing.scale = (Drawing.initial_size.height - 23) / 600
    Drawing.scale = MoreMaths.round(Drawing.scale, 2)

    local extra_space = (Settings.grid_size * 8) * Drawing.scale
    wgui.resize(math.floor(Drawing.initial_size.width + extra_space), Drawing.initial_size.height)
    Drawing.size = wgui.info()
    print('Scale factor ' .. Drawing.scale)
end

function Drawing.size_down()
    wgui.resize(wgui.info().width - (wgui.info().width - Drawing.initial_size.width), wgui.info().height)
end

local function adjust_rect(rect)
    for _, value in pairs(Drawing.offset_stack) do
        rect.x = rect.x + value.x
        rect.y = rect.y + value.y
    end
    return rect
end
local function adjust_raw_rect(rect)
    for _, value in pairs(Drawing.offset_stack) do
        rect[1] = rect[1] + value.x
        rect[2] = rect[2] + value.y
    end
    return rect
end

function grid(x, y, x_span, y_span, abs, gap)
    if not gap then
        gap = Settings.grid_gap
    end
    if not x_span then
        x_span = 1
    end
    if not y_span then
        y_span = 1
    end

    local baseline_x = abs and 0 or Drawing.initial_size.width

    local base_x = baseline_x + (Settings.grid_size * x)
    local base_y = (Settings.grid_size * y)

    local rect = {
        base_x + gap,
        base_y + gap,
        (Settings.grid_size * x_span) - gap * 2,
        (Settings.grid_size * y_span) - gap * 2,
    }

    rect[1] = (baseline_x + (Settings.grid_size * x * Drawing.scale)) + gap
    rect[2] = rect[2] * Drawing.scale
    rect[3] = rect[3] * Drawing.scale
    rect[4] = rect[4] * Drawing.scale

    return adjust_raw_rect({ math.floor(rect[1]), math.floor(rect[2]), math.floor(rect[3]), math.floor(rect[4]) })
end

function Drawing.push_offset(x, y)
    Drawing.offset_stack[#Drawing.offset_stack + 1] = { x = x, y = y }
end

function Drawing.pop_offset()
    if #Drawing.offset_stack == 0 then
        return
    end
    table.remove(Drawing.offset_stack, #Drawing.offset_stack)
end

---Draws a setting item list.
---@param items { text: string, func: fun(rect: Rectangle) }[] An array of setting items with their names and control spawning functions.
---@param pos Vector2 The initial position of the settings list in grid coordinates.
function Drawing.setting_list(items, pos)
    local theme = Styles.theme()
    local foreground_color = Drawing.foreground_color()

    local y = pos.y
    for i = 1, #items, 1 do
        local item = items[i]

        BreitbandGraphics.draw_text(
            grid_rect(pos.x, y, 8, 0.5),
            'start',
            'center',
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            item.text)

        item.func(grid_rect(pos.x, y + 0.6, 4, 1))

        y = y + 1.75
    end
end

function Drawing.foreground_color()
    return BreitbandGraphics.invert_color(Styles.theme().background_color)
end

function grid_rect(x, y, x_span, y_span, gap)
    local value = grid(x, y, x_span, y_span, false, gap)
    return {
        x = value[1],
        y = value[2],
        width = value[3],
        height = value[4],
    }
end

function grid_pos(width, height)
    local value = grid(0, 0, width, height, false, nil)
    return {
        x = 0,
        y = 0,
        width = value[3],
        height = value[4],
    }
end

function grid_rect_abs(x, y, x_span, y_span, gap)
    local value = grid(x, y, x_span, y_span, true, gap)
    return {
        x = value[1],
        y = value[2],
        width = value[3],
        height = value[4],
    }
end
