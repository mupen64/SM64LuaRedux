-- mupen-lua-ugui-ext 2.0.0
-- https://github.com/Aurumaker72/mupen-lua-ugui

local ugui_ext = {
    _VERSION = 'v2.0.0',
    _URL = 'https://github.com/Aurumaker72/mupen-lua-ugui',
    _DESCRIPTION = 'Extension library for mupen-lua-ugui',
    _LICENSE = 'GPL-3',
}

if not ugui then
    error('ugui must be present in the global scope as \'ugui\' prior to executing ugui-ext', 0)
    return
end

ugui_ext.internal = {}

ugui_ext.internal.drawings = {}

ugui_ext.internal.rectangle_to_key = function(rectangle)
    return rectangle.x .. rectangle.y .. rectangle.width .. rectangle.height
end

ugui_ext.internal.params_to_key = function(type, rectangle, visual_state)
    return type .. visual_state .. ugui_ext.internal.rectangle_to_key(rectangle)
end

if d2d.draw_to_image then
    if not UGUI_QUIET then
        print('mupen-lua-ugui-ext: Using high-performance cached drawing for mupen64-rr-lua 1.1.7+')
    end

    ugui_ext.internal.cached_draw = function(key, rectangle, draw_callback)
        if not ugui_ext.internal.drawings[key] then
            ugui_ext.internal.drawings[key] = d2d.draw_to_image(rectangle.width, rectangle.height, function()
                draw_callback({
                    x = 0,
                    y = 0,
                    width = math.floor(rectangle.width),
                    height = math.floor(rectangle.height),
                })
            end)
        end
        d2d.draw_image(
            math.floor(rectangle.x),
            math.floor(rectangle.y),
            math.floor(rectangle.x + rectangle.width),
            math.floor(rectangle.y + rectangle.height),
            0,
            0,
            math.floor(rectangle.width),
            math.floor(rectangle.height), 1, 0, ugui_ext.internal.drawings[key])
    end
    ugui_ext.free = function()
        for key, value in pairs(ugui_ext.internal.drawings) do
            d2d.free_image(value)
        end
        ugui_ext.internal.drawings = {}
    end
end

if not d2d.create_render_target and not d2d.draw_to_image then
    print('mupen-lua-ugui-ext: No supported cached rendering method found, falling back to uncached drawing. Performance will be affected. Please update to the latest version of mupen64-rr-lua.')
    ugui_ext.internal.cached_draw = function(key, rectangle, draw_callback)
        draw_callback(rectangle)
    end
end

local function scale_and_center(inner, outer, max_size, adjust_even_odd)
    local inner_aspect = inner.width / inner.height
    local outer_aspect = outer.width / outer.height

    local scale

    if inner_aspect > outer_aspect then
        scale = outer.width / inner.width
    else
        scale = outer.height / inner.height
    end
    if max_size then
        scale = math.min(scale, max_size / inner.width, max_size / inner.height)
    end

    local new_width = inner.width * scale
    local new_height = inner.height * scale

    local new_x = outer.x + (outer.width - new_width) / 2
    local new_y = outer.y + (outer.height - new_height) / 2

    if adjust_even_odd then
        if (inner.width % 2 == 0 and new_width % 2 ~= 0) or (inner.width % 2 ~= 0 and new_width % 2 == 0) then
            new_width = new_width + 1
        end
        if (inner.height % 2 == 0 and new_height % 2 ~= 0) or (inner.height % 2 ~= 0 and new_height % 2 == 0) then
            new_height = new_height + 1
        end
    end

    return {
        x = math.ceil(new_x),
        y = math.ceil(new_y),
        width = math.ceil(new_width),
        height = math.ceil(new_height),
    }
end

ugui_ext.apply_nineslice = function(style)
    if not d2d then
        print('No D2D available, falling back to unchanged standard styler to avoid performance issues')
        return
    end
    ugui_ext.free()

    local function draw_icon_placeholder(rectangle)
        BreitbandGraphics.fill_rectangle(rectangle, BreitbandGraphics.colors.red)
    end
    local original_draw_icon = ugui.standard_styler.draw_icon
    ugui.standard_styler.draw_icon = function(rectangle, color, visual_state, key)
        local rectangles = style.icons[key]

        if not rectangles then
            original_draw_icon(rectangle, color, visual_state, key)
            return
        end

        local rect = rectangles[visual_state]
        if not rect then
            draw_icon_placeholder(rectangle)
            return
        end

        local adjusted_rect = scale_and_center(rect, rectangle, ugui.standard_styler.params.icon_size, true)
        BreitbandGraphics.draw_image(adjusted_rect, rectangles[visual_state], Styles.theme().path,
            BreitbandGraphics.colors.white, 'linear')
    end

    ugui.standard_styler.draw_raised_frame = function(control, visual_state)
        local key = ugui_ext.internal.params_to_key('raised_frame', control.rectangle, visual_state)

        ugui_ext.internal.cached_draw(key, control.rectangle, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.button.states[visual_state].source,
                style.button.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, 'nearest')
        end)
    end

    ugui.standard_styler.draw_edit_frame = function(control, rectangle,
        visual_state)
        local key = ugui_ext.internal.params_to_key('edit_frame', rectangle, visual_state)

        ugui_ext.internal.cached_draw(key, rectangle, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.textbox.states[visual_state].source,
                style.textbox.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, 'nearest')
        end)
    end

    ugui.standard_styler.draw_list_frame = function(rectangle, visual_state)
        local key = ugui_ext.internal.params_to_key('list_frame', rectangle, visual_state)

        ugui_ext.internal.cached_draw(key, rectangle, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.listbox.states[visual_state].source,
                style.listbox.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, 'nearest')
        end)
    end

    ugui.standard_styler.draw_list_item = function(control, item, rectangle, visual_state)
        if not item then
            return
        end

        local rect = BreitbandGraphics.inflate_rectangle(rectangle, -1)

        -- bad idea to cache these
        BreitbandGraphics.draw_image_nineslice(rect,
            style.listbox_item.states[visual_state].source,
            style.listbox_item.states[visual_state].center,
            style.path, BreitbandGraphics.colors.white, 'nearest')

        local text_rect = {
            x = rectangle.x + 2,
            y = rectangle.y,
            width = rectangle.width,
            height = rectangle.height,
        }

        ugui.standard_styler.draw_rich_text(text_rect, BreitbandGraphics.alignment.start, nil, item, ugui.standard_styler.params.listbox_item.text[visual_state], control.plaintext)
    end

    ugui.standard_styler.draw_scrollbar = function(control, thumb_rectangle)
        local visual_state = ugui.get_visual_state(control)

        BreitbandGraphics.draw_image(control.rectangle,
            style.scrollbar_rail,
            style.path, BreitbandGraphics.colors.white, 'nearest')

        local key = ugui_ext.internal.params_to_key('scrollbar_thumb', thumb_rectangle, visual_state)

        ugui_ext.internal.cached_draw(
            key,
            thumb_rectangle,
            function(eff_rectangle)
                BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                    style.scrollbar_thumb.states[visual_state].source,
                    style.scrollbar_thumb.states[visual_state].center,
                    style.path, BreitbandGraphics.colors.white, 'nearest')
            end)
    end
end

return ugui_ext
