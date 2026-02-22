local BreitbandGraphics = {
    _VERSION = 'v2.0.0',
    _URL = 'https://github.com/Aurumaker72/mupen-lua-ugui',
    _DESCRIPTION = 'Powerful rendering abstraction layer',
    _LICENSE = 'GPL-3',
}

if d2d and d2d.create_render_target then
    error('BreitbandGraphics: mupen64-rr-lua 1.1.7 or newer is required to use BreitbandGraphics.')
end

---@class Color
---@field public r integer The red channel in the range 0 - 255.
---@field public g integer The green channel in the range 0 - 255.
---@field public b integer The blue channel in the range 0 - 255.
---@field public a integer? The alpha channel in the range 0 - 255. If nil, 255 is assumed.

---@class FloatColor
---@field public r number The red channel in the range 0.0 - 1.0.
---@field public g number The green channel in the range 0.0 - 1.0.
---@field public b number The blue channel in the range 0.0 - 1.0.
---@field public a number? The alpha channel in the range 0.0 - 1.0. If nil, 1.0 is assumed.

---@alias ArrayColor { [1]: integer, [2]: integer, [3]: integer, [4]: integer? }
---An integer color array in the format `{r, g, b, a?}`, with channels in the range 0 - 255.

---@alias ArrayFloatColor { [1]: number, [2]: number, [3]: number, [4]: number? }
---An integer color array in the format `{r, g, b, a?}`, with channels in the range 0.0 - 1.0.

---@alias HexColor string
---A hexadecimal color string in the format `#RRGGBB` or `#RRGGBBAA`.

---@alias RawColor integer
---A raw color value in the format `0xRRGGBBAA`.

---@alias ColorSource Color|FloatColor|ArrayColor|ArrayFloatColor|HexColor|RawColor
---A color-providing object that can be converted to a Color.

---@class Vector2
---@field public x number The X component.
---@field public y number The Y component.

---@class Size
---@field public width number The width.
---@field public height number The height.

---@class Rectangle
---@field public x number The X coordinate.
---@field public y number The Y coordinate.
---@field public width number The width.
---@field public height number The height.

---@class TextStyle
---@field public is_bold boolean? Whether the text is bold. If nil, false is assumed.
---@field public is_italic boolean? Whether the text is italic. If nil, false is assumed.
---@field public clip boolean? Whether the text should be clipped to the bounding rectangle. If nil, false is assumed.
---@field public grayscale boolean? Whether the text should be drawn in grayscale. If nil, false is assumed.
---@field public aliased boolean? Whether the text should be drawn with no text filtering. If nil, false is assumed.
---@field public fit boolean? Whether the text should be resized to fit the bounding rectangle. If nil, false is assumed.

---@class DrawTextParams
---@field public text string? The text. If nil, no text will be drawn.
---@field public rectangle Rectangle The text's bounding rectangle.
---@field public color ColorSource The text color.
---@field public font_name string The font name.
---@field public font_size number The font size.
---@field public align_x Alignment? The text's horizontal alignment inside the bounding rectangle. If nil, Alignment.center is assumed.
---@field public align_y Alignment? The text's vertical alignment inside the bounding rectangle. If nil, Alignment.center is assumed.
---@field public is_bold boolean? Whether the text is bold. If nil, false is assumed.
---@field public is_italic boolean? Whether the text is italic. If nil, false is assumed.
---@field public clip boolean? Whether the text should be clipped to the bounding rectangle. If nil, false is assumed.
---@field public grayscale boolean? Whether the text should be drawn in grayscale. If nil, false is assumed.
---@field public aliased boolean? Whether the text should be drawn with no text filtering. If nil, false is assumed.
---@field public fit boolean? Whether the text should be resized to fit the bounding rectangle. If nil, false is assumed.

---@class ImageInfo
---@field public width number The width.
---@field public height number The height.
---Contains information about an image.

---@enum StandardColors
--- A table of standard colors.
BreitbandGraphics.colors = {
    --- The color white.
    white = {
        r = 255,
        g = 255,
        b = 255,
    },

    --- The color black.
    black = {
        r = 0,
        g = 0,
        b = 0,
    },

    --- The color red.
    red = {
        r = 255,
        g = 0,
        b = 0,
    },

    --- The color green.
    green = {
        r = 0,
        g = 255,
        b = 0,
    },

    --- The color blue.
    blue = {
        r = 0,
        g = 0,
        b = 255,
    },

    --- The color yellow.
    yellow = {
        r = 255,
        g = 255,
        b = 0,
    },

    --- The color orange.
    orange = {
        r = 255,
        g = 128,
        b = 0,
    },

    --- The color magenta.
    magenta = {
        r = 255,
        g = 0,
        b = 255,
    },
}

--- Creates a FloatColor from a Color.
--- Channels with nil values will be converted to `0.0`, unless they are the alpha channel, in which case it will be converted to `1.0`.
--- @param color Color The color to be converted.
--- @return FloatColor # The color with remapped channels.
local function color_to_float(color)
    return {
        r = (color.r and (color.r / 255.0) or 0.0),
        g = (color.g and (color.g / 255.0) or 0.0),
        b = (color.b and (color.b / 255.0) or 0.0),
        a = (color.a and (color.a / 255.0) or 1.0),
    }
end

---Convers a color source to a FloatColor.
---@param source ColorSource The color source.
---@return FloatColor # The converted color.
local function color_source_to_float_color(source)

    -- Match RawColor
    if math.type(source) == "integer" then
        return {
            r = (source >> 24) & 0xFF,
            g = (source >> 16) & 0xFF,
            b = (source >> 8) & 0xFF,
            a = source & 0xFF,
        }
    end

    -- Match HexColor
    if type(source) == 'string' then
        return color_to_float(BreitbandGraphics.hex_to_color(source))
    end

    -- Match ArrayColor and ArrayFloatColor
    if source[1] or source[2] or source[3] or source[4] then
        -- Match ArrayFloatColor
        if math.type(source[1]) == 'float' or math.type(source[2]) == 'float' or math.type(source[3]) == 'float' then
            return {
                r = source[1] or 0.0,
                g = source[2] or 0.0,
                b = source[3] or 0.0,
                a = source[4] or 1.0,
            }
        end

        -- Match ArrayColor
        return color_to_float({
            r = source[1] or 0,
            g = source[2] or 0,
            b = source[3] or 0,
            a = source[4] or 255,
        })
    end

    -- Match FloatColor
    if math.type(source.r) == 'float' or math.type(source.g) == 'float' or math.type(source.b) == 'float' then
        return {
            r = source.r and source.r or 0.0,
            g = source.g and source.g or 0.0,
            b = source.b and source.b or 0.0,
            a = source.a and source.a or 1.0,
        }
    end

    -- Match Color
    if math.type(source.r) == 'integer' or math.type(source.g) == 'integer' or math.type(source.b) == 'integer' then
        return color_to_float(source)
    end

    if type(source) == "table" then
        return color_to_float({})        
    end

    print('Invalid color source:')
    print(source)
    error('See above.')
end


BreitbandGraphics.internal = {
    ---@type table<string, integer>
    ---Map of color keys to brush handles.
    brushes = {},

    ---@type table<string, integer>
    ---Map of image paths to image handles.
    images = {},

    ---Gets a brush from a color value, creating one and caching it if it doesn't already exist in the cache.
    ---@param color ColorSource The color value to create a brush from.
    ---@return integer # The brush handle.
    brush_from_color = function(color)
        local float = color_source_to_float_color(color)
        local converted = BreitbandGraphics.float_to_color(float)
        local key = (converted.r << 24) | (converted.g << 16) | (converted.b << 8) | (converted.a and converted.a or 255)
        if not BreitbandGraphics.internal.brushes[key] then
            BreitbandGraphics.internal.brushes[key] = d2d.create_brush(float.r, float.g, float.b, float.a)
        end
        return BreitbandGraphics.internal.brushes[key]
    end,

    ---Gets an image from a path, creating one and caching it if it doesn't already exist in the cache.
    ---@param path string The path to the image.
    ---@return integer # The image handle.
    image_from_path = function(path)
        if not BreitbandGraphics.internal.images[path] then
            BreitbandGraphics.internal.images[path] = d2d.load_image(path)
        end
        return BreitbandGraphics.internal.images[path]
    end,
}

---@enum Alignment
--- The alignment inside a container.
BreitbandGraphics.alignment = {
    --- The item is aligned to the start of the container.
    start = 1,
    --- The item is aligned to the center of the container.
    center = 2,
    --- The item is aligned to the end of the container.
    ['end'] = 3,
    --- The item is stretched to fill the container.
    stretch = 4,
}

--- Converts a color to its corresponding hexadecimal representation.
--- @param color ColorSource The color source to convert.
--- @returns string # The hexadecimal representation of the color.
BreitbandGraphics.color_to_hex = function(color)
    local converted = BreitbandGraphics.float_to_color(color_source_to_float_color(color))
    return string.format('#%06X', (converted.r * 0x10000) + (converted.g * 0x100) + converted.b)
end

--- Converts a color's hexadecimal representation into a color table.
--- @param hex string The hexadecimal color to convert.
--- @return Color # The color.
BreitbandGraphics.hex_to_color = function(hex)
    if #hex > 7 then
        return
        {
            r = tonumber(hex:sub(2, 3), 16),
            g = tonumber(hex:sub(4, 5), 16),
            b = tonumber(hex:sub(6, 7), 16),
            a = tonumber(hex:sub(8, 9), 16),
        }
    end
    return
    {
        r = tonumber(hex:sub(2, 3), 16),
        g = tonumber(hex:sub(4, 5), 16),
        b = tonumber(hex:sub(6, 7), 16),
    }
end

--- Creates a color with the red, green and blue channels assigned to the specified value.
--- @param value number The value to be used for the red, green and blue channels.
--- @return Color # The color with the red, green and blue channels set to the specified value.
BreitbandGraphics.repeated_to_color = function(value)
    return
    {
        r = value,
        g = value,
        b = value,
    }
end

---Inverts a color source.
---@param color ColorSource The color source to invert.
---@return Color # The new inverted color.
BreitbandGraphics.invert_color = function(color)
    local converted = color_source_to_float_color(color)
    return BreitbandGraphics.float_to_color({
        r = 1.0 - converted.r,
        g = 1.0 - converted.g,
        b = 1.0 - converted.b,
        a = converted.a,
    })
end

--- Creates a FloatColor from a ColorSource.
--- Channels with nil values will be converted to `0.0`, unless they are the alpha channel, in which case it will be converted to `1.0`.
--- @param color ColorSource The color to be converted.
--- @return FloatColor # The color with remapped channels.
BreitbandGraphics.color_to_float = function(color)
    return color_source_to_float_color(color)
end

--- Creates a Color from a FloatColor.
--- Channels with nil values will be converted to `0`, unless they are the alpha channel, in which case it will be converted to `255`.
--- @param color FloatColor The color to be converted.
--- @return Color # The color with remapped channels.
BreitbandGraphics.float_to_color = function(color)
    return {
        r = (color.r and (math.tointeger(math.floor(color.r * 255 + 0.5))) or 0),
        g = (color.g and (math.tointeger(math.floor(color.g * 255 + 0.5))) or 0),
        b = (color.b and (math.tointeger(math.floor(color.b * 255 + 0.5))) or 0),
        a = (color.a and (math.tointeger(math.floor(color.a * 255 + 0.5))) or 255),
    }
end

---Checks whether a point is inside a rectangle.
---@param point Vector2 The point.
---@param rectangle Rectangle The rectangle.
---@return boolean # Whether the point is inside the rectangle.
BreitbandGraphics.is_point_inside_rectangle = function(point, rectangle)
    return point.x > rectangle.x and
        point.y > rectangle.y and
        point.x < rectangle.x + rectangle.width and
        point.y < rectangle.y + rectangle.height
end

---Checks whether a point is inside any of the rectangles.
---@param point Vector2 The point.
---@param rectangles Rectangle[] The rectangles.
---@return boolean # Whether the point is inside any of the rectangles.
BreitbandGraphics.is_point_inside_any_rectangle = function(point, rectangles)
    for i = 1, #rectangles, 1 do
        if BreitbandGraphics.is_point_inside_rectangle(point, rectangles[i]) then
            return true
        end
    end
    return false
end

--- Creates a rectangle inflated around its center by the specified amount.
--- @param rectangle Rectangle The rectangle to be inflated.
--- @param amount number The amount to inflate the rectangle by.
--- @return Rectangle # The inflated rectangle.
BreitbandGraphics.inflate_rectangle = function(rectangle, amount)
    return {
        x = rectangle.x - amount,
        y = rectangle.y - amount,
        width = rectangle.width + amount * 2,
        height = rectangle.height + amount * 2,
    }
end

---Computes the bounding box of a text string given a font size and font name.
---@param text string The string to be measured.
---@param font_size number The font size.
---@param font_name string The font name.
---@return Size # The text's bounding box.
BreitbandGraphics.get_text_size = function(text, font_size, font_name)
    return d2d.get_text_size(text, font_name, font_size, 99999999, 99999999)
end

---Draws a rectangle's outline.
---@param rectangle Rectangle The shape's bounding rectangle.
---@param color ColorSource The outline's color.
---@param thickness number The outline's thickness.
BreitbandGraphics.draw_rectangle = function(rectangle, color, thickness)
    local brush = BreitbandGraphics.internal.brush_from_color(color)
    d2d.draw_rectangle(
        rectangle.x,
        rectangle.y,
        rectangle.x + rectangle.width,
        rectangle.y + rectangle.height,
        thickness,
        brush)
end

---Draws a filled-in rectangle.
---@param rectangle Rectangle The shape's bounding rectangle.
---@param color ColorSource The fill color.
BreitbandGraphics.fill_rectangle = function(rectangle, color)
    local brush = BreitbandGraphics.internal.brush_from_color(color)
    d2d.fill_rectangle(
        rectangle.x,
        rectangle.y,
        rectangle.x + rectangle.width,
        rectangle.y + rectangle.height,
        brush)
end

---Draws a rounded rectangle's outline.
---@param rectangle Rectangle The shape's bounding rectangle.
---@param color ColorSource The outline's color.
---@param radii Vector2 The corner radii.
---@param thickness number The outline's thickness.
BreitbandGraphics.draw_rounded_rectangle = function(rectangle, color, radii, thickness)
    local brush = BreitbandGraphics.internal.brush_from_color(color)
    d2d.draw_rounded_rectangle(
        rectangle.x,
        rectangle.y,
        rectangle.x + rectangle.width,
        rectangle.y + rectangle.height,
        radii.x,
        radii.y,
        thickness,
        brush)
end

---Draws a filled-in rounded rectangle.
---@param rectangle Rectangle The shape's bounding rectangle.
---@param color ColorSource The fill color.
---@param radii Vector2 The corner radii.
BreitbandGraphics.fill_rounded_rectangle = function(rectangle, color, radii)
    local brush = BreitbandGraphics.internal.brush_from_color(color)
    d2d.fill_rounded_rectangle(
        rectangle.x,
        rectangle.y,
        rectangle.x + rectangle.width,
        rectangle.y + rectangle.height,
        radii.x,
        radii.y,
        brush)
end

---Draws an ellipse's outline.
---@param rectangle Rectangle The shape's bounding rectangle.
---@param color ColorSource The outline's color.
---@param thickness number The outline's thickness.
BreitbandGraphics.draw_ellipse = function(rectangle, color, thickness)
    local brush = BreitbandGraphics.internal.brush_from_color(color)
    d2d.draw_ellipse(
        rectangle.x + rectangle.width / 2,
        rectangle.y + rectangle.height / 2,
        rectangle.width / 2,
        rectangle.height / 2,
        thickness,
        brush)
end

---Draws a filled-in ellipse.
---@param rectangle Rectangle The shape's bounding rectangle.
---@param color ColorSource The fill color.
BreitbandGraphics.fill_ellipse = function(rectangle, color)
    local brush = BreitbandGraphics.internal.brush_from_color(color)
    d2d.fill_ellipse(
        rectangle.x + rectangle.width / 2,
        rectangle.y + rectangle.height / 2,
        rectangle.width / 2,
        rectangle.height / 2,
        brush)
end

---Draws text with the specified parameters.
---Deprecated, use `draw_text2` instead.
---@param rectangle Rectangle The text's bounding rectangle.
---@param horizontal_alignment "center"|"start"|"end"|"stretch" The text's horizontal alignment inside the bounding rectangle.
---@param vertical_alignment "center"|"start"|"end"|"stretch" The text's vertical alignment inside the bounding rectangle.
---@param style TextStyle The text style options.
---@param color ColorSource The text color.
---@param font_size number The font size.
---@param font_name string The font name.
---@param text string The text.
---@deprecated
BreitbandGraphics.draw_text = function(rectangle, horizontal_alignment, vertical_alignment, style, color, font_size, font_name,
    text)
    if text == nil then
        text = ''
    end

    local rect_x = rectangle.x
    local rect_y = rectangle.y
    local rect_w = rectangle.width
    local rect_h = rectangle.height
    local brush = BreitbandGraphics.internal.brush_from_color(color)
    local d_horizontal_alignment = 0
    local d_vertical_alignment = 0
    local d_style = 0
    local d_weight = 400
    local d_options = 0
    local d_text_antialias_mode = 1

    if horizontal_alignment == 'center' then
        d_horizontal_alignment = 2
    elseif horizontal_alignment == 'start' then
        d_horizontal_alignment = 0
    elseif horizontal_alignment == 'end' then
        d_horizontal_alignment = 1
    elseif horizontal_alignment == 'stretch' then
        d_horizontal_alignment = 3
    end

    if vertical_alignment == 'center' then
        d_vertical_alignment = 2
    elseif vertical_alignment == 'start' then
        d_vertical_alignment = 0
    elseif vertical_alignment == 'end' then
        d_vertical_alignment = 1
    end

    if style.is_bold then
        d_weight = 700
    end
    if style.is_italic then
        d_style = 2
    end
    if style.clip then
        d_options = d_options | 0x00000002
    end
    if style.grayscale then
        d_text_antialias_mode = 2
    end
    if style.aliased then
        d_text_antialias_mode = 3
    end
    if style.fit then
        -- Try to fit the text into the specified rectangle by reducing the font size
        local text_size = d2d.get_text_size(text, font_name, font_size, math.maxinteger, math.maxinteger)

        if text_size.width > rectangle.width then
            font_size = font_size / math.max(0.01, (text_size.width / rectangle.width))
        end
        if text_size.height > rectangle.height then
            font_size = font_size / math.max(0.01, (text_size.height / rectangle.height))
        end

        local text_size = d2d.get_text_size(text, font_name, font_size, math.maxinteger, math.maxinteger)

        -- Since the rect stays the same, the text will want to wrap.
        -- We solve that by recomputing the rect and alignments
        if horizontal_alignment == 'center' or horizontal_alignment == 'stretch' then
            rect_x = rect_x + rect_w / 2 - text_size.width / 2
        elseif horizontal_alignment == 'start' then
            rect_x = rect_x
        elseif horizontal_alignment == 'end' then
            rect_x = rect_x + rect_w - text_size.width
        end

        if vertical_alignment == 'center' or vertical_alignment == 'stretch' then
            rect_y = rect_y + rect_h / 2 - text_size.height / 2
        elseif vertical_alignment == 'start' then
            rect_y = rect_y
        elseif vertical_alignment == 'end' then
            rect_y = rect_y + rect_h - text_size.height
        end

        d_horizontal_alignment = 0
        d_vertical_alignment = 0

        rect_w = text_size.width + 1
        rect_h = text_size.height + 1
    end
    if type(text) ~= 'string' then
        text = tostring(text)
    end
    d2d.set_text_antialias_mode(d_text_antialias_mode)
    d2d.draw_text(
        rect_x,
        rect_y,
        rect_x + rect_w,
        rect_y + rect_h,
        text,
        font_name,
        font_size,
        d_weight,
        d_style,
        d_horizontal_alignment,
        d_vertical_alignment,
        d_options,
        brush)
end

---Draws text with the specified parameters.
---@param params DrawTextParams The text drawing parameters.
BreitbandGraphics.draw_text2 = function(params)
    if not params.text then
        return
    end

    local internal_alignment_to_d2d_alignment_map = {
        [BreitbandGraphics.alignment.start] = 0,
        [BreitbandGraphics.alignment.center] = 2,
        [BreitbandGraphics.alignment['end']] = 1,
        [BreitbandGraphics.alignment.stretch] = 3,
    }

    local rect_x = params.rectangle.x
    local rect_y = params.rectangle.y
    local rect_w = params.rectangle.width
    local rect_h = params.rectangle.height
    local brush = BreitbandGraphics.internal.brush_from_color(params.color)
    local d_horizontal_alignment = params.align_x and internal_alignment_to_d2d_alignment_map[params.align_x] or internal_alignment_to_d2d_alignment_map[BreitbandGraphics.alignment.center]
    local d_vertical_alignment = params.align_y and internal_alignment_to_d2d_alignment_map[params.align_y] or internal_alignment_to_d2d_alignment_map[BreitbandGraphics.alignment.center]
    local d_style = 0
    local d_weight = 400
    local d_options = 0
    local d_text_antialias_mode = 1
    local font_size = params.font_size

    if params.is_bold then
        d_weight = 700
    end
    if params.is_italic then
        d_style = 2
    end
    if params.clip then
        d_options = d_options | 0x00000002
    end
    if params.grayscale then
        d_text_antialias_mode = 2
    end
    if params.aliased then
        d_text_antialias_mode = 3
    end
    if params.fit then
        -- Try to fit the text into the specified rectangle by reducing the font size
        local text_size = d2d.get_text_size(params.text, params.font_name, params.font_size, math.maxinteger, math.maxinteger)

        if text_size.width > params.rectangle.width then
            font_size = font_size / math.max(0.01, (text_size.width / params.rectangle.width))
        end
        if text_size.height > params.rectangle.height then
            font_size = font_size / math.max(0.01, (text_size.height / params.rectangle.height))
        end

        local text_size = d2d.get_text_size(params.text, params.font_name, font_size, math.maxinteger, math.maxinteger)

        -- Since the rect stays the same, the text will want to wrap.
        -- We solve that by recomputing the rect and alignments
        if params.align_x == BreitbandGraphics.alignment.center or params.align_x == BreitbandGraphics.alignment.stretch then
            rect_x = rect_x + rect_w / 2 - text_size.width / 2
        elseif params.align_x == BreitbandGraphics.alignment.start then
            rect_x = rect_x
        elseif params.align_x == BreitbandGraphics.alignment['end'] then
            rect_x = rect_x + rect_w - text_size.width
        end

        if params.align_y == BreitbandGraphics.alignment.center or params.align_y == BreitbandGraphics.alignment.stretch then
            rect_y = rect_y + rect_h / 2 - text_size.height / 2
        elseif params.align_y == BreitbandGraphics.alignment.start then
            rect_y = rect_y
        elseif params.align_y == BreitbandGraphics.alignment['end'] then
            rect_y = rect_y + rect_h - text_size.height
        end

        d_horizontal_alignment = 0
        d_vertical_alignment = 0

        rect_w = text_size.width + 1
        rect_h = text_size.height + 1
    end


    d2d.set_text_antialias_mode(d_text_antialias_mode)
    d2d.draw_text(
        rect_x,
        rect_y,
        rect_x + rect_w,
        rect_y + rect_h,
        params.text,
        params.font_name,
        font_size,
        d_weight,
        d_style,
        d_horizontal_alignment,
        d_vertical_alignment,
        d_options,
        brush)
end

---Draws a line between two points.
---@param from Vector2 The start point.
---@param to Vector2 The end point.
---@param color ColorSource The line's color.
---@param thickness number The line's thickness.
BreitbandGraphics.draw_line = function(from, to, color, thickness)
    local brush = BreitbandGraphics.internal.brush_from_color(color)

    d2d.draw_line(
        from.x,
        from.y,
        to.x,
        to.y,
        thickness,
        brush)
end

---Pushes a clip layer to the clip stack.
---@param rectangle Rectangle The clip bounds.
BreitbandGraphics.push_clip = function(rectangle)
    d2d.push_clip(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
        rectangle.y + rectangle.height)
end

--- Removes the topmost clip layer from the clip stack.
BreitbandGraphics.pop_clip = function()
    d2d.pop_clip()
end

---Draws an image with the specified parameters.
---@param destination_rectangle Rectangle The destination rectangle on the screen.
---@param source_rectangle Rectangle? The source rectangle from the image. If nil, the whole image is taken as the source.
---@param path string The image's absolute path on disk.
---@param color ColorSource? The color filter applied to the image. If nil or white, the image is drawn with no tint.
---@param filter "nearest" | "linear" The texture filter applied to the image.
BreitbandGraphics.draw_image = function(destination_rectangle, source_rectangle, path, color, filter)
    if not filter then
        filter = 'nearest'
    end
    local float_color
    if color then
        float_color = color_source_to_float_color(color)
    else
        float_color = BreitbandGraphics.colors.white
    end
    local image = BreitbandGraphics.internal.image_from_path(path)
    local interpolation = filter == 'nearest' and 0 or 1

    if not source_rectangle then
        local size = BreitbandGraphics.get_image_info(path)
        source_rectangle = {
            x = 0,
            y = 0,
            width = size.width,
            height = size.height,
        }
    end

    d2d.draw_image(
        destination_rectangle.x,
        destination_rectangle.y,
        destination_rectangle.x + destination_rectangle.width,
        destination_rectangle.y + destination_rectangle.height,
        source_rectangle.x,
        source_rectangle.y,
        source_rectangle.x + source_rectangle.width,
        source_rectangle.y + source_rectangle.height,
        float_color.a,
        interpolation,
        image)
end

---Draws a nineslice-scalable image with the specified parameters.
---@param destination_rectangle Rectangle The destination rectangle on the screen.
---@param source_rectangle Rectangle The source rectangle from the image.
---@param source_rectangle_center Rectangle The source rectangle for the center of the image.
---@param path string The image's absolute path on disk.
---@param color ColorSource The color filter applied to the image. If white, the image is drawn as-is.
---@param filter "nearest" | "linear" The texture filter applied to the image.
BreitbandGraphics.draw_image_nineslice = function(destination_rectangle, source_rectangle, source_rectangle_center, path, color, filter)
    destination_rectangle = {
        x = math.floor(destination_rectangle.x),
        y = math.floor(destination_rectangle.y),
        width = math.ceil(destination_rectangle.width),
        height = math.ceil(destination_rectangle.height),
    }
    source_rectangle = {
        x = math.floor(source_rectangle.x),
        y = math.floor(source_rectangle.y),
        width = math.ceil(source_rectangle.width),
        height = math.ceil(source_rectangle.height),
    }
    local corner_size = {
        x = math.abs(source_rectangle_center.x - source_rectangle.x),
        y = math.abs(source_rectangle_center.y - source_rectangle.y),
    }


    local top_left = {
        x = source_rectangle.x,
        y = source_rectangle.y,
        width = corner_size.x,
        height = corner_size.y,
    }
    local bottom_left = {
        x = source_rectangle.x,
        y = source_rectangle_center.y + source_rectangle_center.height,
        width = corner_size.x,
        height = corner_size.y,
    }
    local left = {
        x = source_rectangle.x,
        y = source_rectangle_center.y,
        width = corner_size.x,
        height = source_rectangle.height - corner_size.y * 2,
    }
    local top_right = {
        x = source_rectangle.x + source_rectangle.width - corner_size.x,
        y = source_rectangle.y,
        width = corner_size.x,
        height = corner_size.y,
    }
    local bottom_right = {
        x = source_rectangle.x + source_rectangle.width - corner_size.x,
        y = source_rectangle_center.y + source_rectangle_center.height,
        width = corner_size.x,
        height = corner_size.y,
    }
    local top = {
        x = source_rectangle_center.x,
        y = source_rectangle.y,
        width = source_rectangle.width - corner_size.x * 2,
        height = corner_size.y,
    }
    local right = {
        x = source_rectangle.x + source_rectangle.width - corner_size.x,
        y = source_rectangle_center.y,
        width = corner_size.x,
        height = source_rectangle.height - corner_size.y * 2,
    }
    local bottom = {
        x = source_rectangle_center.x,
        y = source_rectangle.y + source_rectangle.height - corner_size.y,
        width = source_rectangle.width - corner_size.x * 2,
        height = corner_size.y,
    }

    BreitbandGraphics.draw_image({
        x = destination_rectangle.x,
        y = destination_rectangle.y,
        width = top_left.width,
        height = top_left.height,
    }, top_left, path, color, filter)
    BreitbandGraphics.draw_image({
        x = destination_rectangle.x + destination_rectangle.width - top_right.width,
        y = destination_rectangle.y,
        width = top_right.width,
        height = top_right.height,
    }, top_right, path, color, filter)
    BreitbandGraphics.draw_image({
        x = destination_rectangle.x,
        y = destination_rectangle.y + destination_rectangle.height - bottom_left.height,
        width = bottom_left.width,
        height = bottom_left.height,
    }, bottom_left, path, color, filter)
    BreitbandGraphics.draw_image({
        x = destination_rectangle.x + destination_rectangle.width - bottom_right.width,
        y = destination_rectangle.y + destination_rectangle.height - bottom_right.height,
        width = bottom_right.width,
        height = bottom_right.height,
    }, bottom_right, path, color, filter)
    BreitbandGraphics.draw_image({
        x = destination_rectangle.x + top_left.width,
        y = destination_rectangle.y + top_left.height,
        width = destination_rectangle.width - bottom_right.width * 2,
        height = destination_rectangle.height - bottom_right.height * 2,
    }, source_rectangle_center, path, color, filter)
    BreitbandGraphics.draw_image({
        x = destination_rectangle.x,
        y = destination_rectangle.y + top_left.height,
        width = left.width,
        height = destination_rectangle.height - bottom_left.height * 2,
    }, left, path, color, filter)
    BreitbandGraphics.draw_image({
        x = destination_rectangle.x + destination_rectangle.width - top_right.width,
        y = destination_rectangle.y + top_right.height,
        width = left.width,
        height = destination_rectangle.height - bottom_right.height * 2,
    }, right, path, color, filter)
    BreitbandGraphics.draw_image({
        x = destination_rectangle.x + top_left.width,
        y = destination_rectangle.y,
        width = destination_rectangle.width - top_right.width * 2,
        height = top.height,
    }, top, path, color, filter)
    BreitbandGraphics.draw_image({
        x = destination_rectangle.x + top_left.width,
        y = destination_rectangle.y + destination_rectangle.height - bottom.height,
        width = destination_rectangle.width - bottom_right.width * 2,
        height = bottom.height,
    }, bottom, path, color, filter)
end

---Gets information about an image.
---@param path string The image's absolute path on disk.
---@return ImageInfo # Information about the image.
BreitbandGraphics.get_image_info = function(path)
    local image = BreitbandGraphics.internal.image_from_path(path)
    return d2d.get_image_info(image)
end

---Releases allocated resources.
---Must be called before stopping the Lua environment.
BreitbandGraphics.free = function()
    for key, value in pairs(BreitbandGraphics.internal.brushes) do
        d2d.free_brush(value)
    end
    for key, value in pairs(BreitbandGraphics.internal.images) do
        d2d.free_image(value)
    end
end

return BreitbandGraphics
