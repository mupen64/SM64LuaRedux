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

    -- helper to compute how many grid cells a piece of text needs
    local function resolve_text(t)
        if type(t) == 'function' then
            t = t()
        end
        return t
    end

    local function text_span(text)
        text = resolve_text(text)
        if not text or text == '' then
            return 1
        end
        local size = BreitbandGraphics.get_text_size(
            text,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name)
        local cell_width = Settings.grid_size * Drawing.scale
        local span = math.ceil(size.width / cell_width)
        return math.max(8, span) -- never shrink below default eight cells
    end

    local y = pos.y
    for i = 1, #items, 1 do
        local item = items[i]
        local span = text_span(item.text)

        local display_text = resolve_text(item.text)
        BreitbandGraphics.draw_text(
            grid_rect(pos.x, y, span, 0.5),
            'start',
            'center',
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            display_text)

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

---Returns a grid rectangle whose horizontal span is at least the provided
---`default_span` but will grow to fit the given text if the string is
---too wide for the allotted number of cells. This is handy for buttons and
---other controls that ought to accomodate translated labels without
---overflowing.
---@param text string The text that will be drawn inside the rectangle.
---@param x number Grid x coordinate
---@param y number Grid y coordinate
---@param default_span number The minimum x span (cells)
---@param y_span number The y span (cells)
---@param gap? number Optional gap parameter passed to grid_rect
---@return Rectangle
function Drawing.auto_grid_rect(text, x, y, default_span, y_span, gap)
    -- resolve possibly-lazy text (callbacks used by some views)
    if type(text) == 'function' then
        text = text()
    end

    -- measure the text at the current UI font settings
    local theme = Styles.theme()
    local font_size = theme.font_size * Drawing.scale
    local font_name = theme.font_name
    local size = BreitbandGraphics.get_text_size(text, font_size, font_name)

    -- compute cell width in pixels
    local cell_width = Settings.grid_size * Drawing.scale
    local needed_span = math.ceil((size.width + (gap or Settings.grid_gap) * 2) / cell_width)
    if needed_span < default_span then
        needed_span = default_span
    end

    return grid_rect(x, y, needed_span, y_span, gap)
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
