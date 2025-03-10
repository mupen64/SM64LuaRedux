-- mupen-lua-ugui-ext 2.0.0
-- https://github.com/Aurumaker72/mupen-lua-ugui

if not ugui then
    error('ugui must be present in the global scope prior to executing ugui-ext', 0)
    return
end

ugui_ext = {

    ---Gets the digit at a specific index in a number with a specific padded length.
    ---@param value integer The number.
    ---@param length integer The number's padded length (number of digits).
    ---@param index integer The index to get digit from.
    ---@return integer # The digit at the specified index.
    get_digit = function(value, length, index)
        return math.floor(value / math.pow(10, length - index)) % 10
    end,

    ---Sets the digit at a specific index in a number with a specific padded length.
    ---@param value integer The number.
    ---@param length integer The number's padded length (number of digits).
    ---@param digit_value integer The new digit value.
    ---@param index integer The index to get digit from.
    ---@return integer # The new number.
    set_digit = function(value, length, digit_value, index)
        local old_digit_value = ugui_ext.get_digit(value, length, index)
        local new_value = value + (digit_value - old_digit_value) * math.pow(10, length - index)
        local max = math.pow(10, length)
        return (new_value + max) % max
    end,

    internal = {
        drawings = {},
        rectangle_to_key = function(rectangle)
            return rectangle.x .. rectangle.y .. rectangle.width .. rectangle.height
        end,
        params_to_key = function(type, rectangle, visual_state)
            return type .. visual_state .. ugui_ext.internal.rectangle_to_key(rectangle)
        end,

    },
}

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
    print(
        'mupen-lua-ugui-ext: No supported cached rendering method found, falling back to uncached drawing. Performance will be affected. Please update to the latest version of mupen64-rr-lua.')
    ugui_ext.internal.cached_draw = function(key, rectangle, draw_callback)
        draw_callback(rectangle)
    end
end

ugui.standard_styler.params.spinner = {
    button_size = 15,
}

ugui.standard_styler.params.tabcontrol = {
    rail_size = 17,
    draw_frame = true,
    gap_x = 0,
    gap_y = 0,
}

ugui.standard_styler.params.numberbox = {
    font_scale = 1.5,
}

---Places a Spinner, or NumericUpDown control
---
---Additional fields in the `control` table:
---
--- `value` — `number` The spinner's numerical value
--- `minimum_value` — `number` The spinner's minimum numerical value
--- `maximum_value` — `number` The spinner's maximum numerical value
--- `increment` — `number` The increment applied when the + or - buttons are clicked
---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
---@return _ number The new value
ugui.spinner = function(control)
    ugui.internal.validate_control(control)

    local increment = control.increment or 1
    local value = control.value or 0

    local function clamp_value(value)
        if control.minimum_value and control.maximum_value then
            return ugui.internal.clamp(value, control.minimum_value, control.maximum_value)
        end

        if control.minimum_value then
            return math.max(value, control.minimum_value)
        end

        if control.maximum_value then
            return math.min(value, control.maximum_value)
        end

        return value
    end

    local textbox_rect = {
        x = control.rectangle.x,
        y = control.rectangle.y,
        width = control.rectangle.width - ugui.standard_styler.params.spinner.button_size * 2,
        height = control.rectangle.height,
    }

    local new_text = ugui.textbox({
        uid = control.uid,
        rectangle = textbox_rect,
        text = tostring(value),
    })

    local ignored = BreitbandGraphics.is_point_inside_any_rectangle(
        ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects)

    if tonumber(new_text) then
        value = clamp_value(tonumber(new_text))
    end

    if control.is_enabled ~= false
        and not ignored
        and (BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, textbox_rect) or ugui.internal.active_control == control.uid)
    then
        if ugui.internal.is_mouse_wheel_up() then
            value = clamp_value(value + increment)
        end
        if ugui.internal.is_mouse_wheel_down() then
            value = clamp_value(value - increment)
        end
    end

    if control.is_horizontal then
        if (ugui.button({
                uid = control.uid + 1,
                is_enabled = not (value == control.minimum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        ugui.standard_styler.params.spinner.button_size * 2,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.params.spinner.button_size,
                    height = control.rectangle.height,
                },
                text = '-',
            }))
        then
            value = clamp_value(value - increment)
        end

        if (ugui.button({
                uid = control.uid + 2,
                is_enabled = not (value == control.maximum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        ugui.standard_styler.params.spinner.button_size,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.params.spinner.button_size,
                    height = control.rectangle.height,
                },
                text = '+',
            }))
        then
            value = clamp_value(value + increment)
        end
    else
        if (ugui.button({
                uid = control.uid + 1,
                is_enabled = not (value == control.maximum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        ugui.standard_styler.params.spinner.button_size * 2,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.params.spinner.button_size * 2,
                    height = control.rectangle.height / 2,
                },
                text = '+',
            }))
        then
            value = clamp_value(value + increment)
        end

        if (ugui.button({
                uid = control.uid + 2,
                is_enabled = not (value == control.minimum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        ugui.standard_styler.params.spinner.button_size * 2,
                    y = control.rectangle.y + control.rectangle.height / 2,
                    width = ugui.standard_styler.params.spinner.button_size * 2,
                    height = control.rectangle.height / 2,
                },
                text = '-',
            }))
        then
            value = clamp_value(value - increment)
        end
    end

    ugui.internal.handle_tooltip(control)
    return clamp_value(value)
end

---Places a tab control for navigation
---
---Additional fields in the `control` table:
---
--- `items` — `string[]` The tab headers
--- `selected_index` — `number` The selected index into the `items` array
---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
---@return _ table A table structured as follows: { selected_index, rectangle }
ugui.tabcontrol = function(control)
    ugui.internal.do_layout(control)
    ugui.internal.validate_and_register_control(control)

    ugui.internal.control_data[control.uid] = ugui.internal.control_data[control.uid] or {}

    if ugui.internal.control_data[control.uid].y_translation == nil then
        ugui.internal.control_data[control.uid].y_translation = 0
    end

    if ugui.standard_styler.params.tabcontrol.draw_frame then
        local clone = ugui.internal.deep_clone(control)
        clone.items = {}
        ugui.standard_styler.draw_list(clone, clone.rectangle)
    end

    local x = 0
    local y = 0
    local selected_index = control.selected_index

    local num_items = control.items and #control.items or 0
    for i = 1, num_items, 1 do
        local item = control.items[i]

        local width = ugui.standard_styler.compute_rich_text(item, control.plaintext).size.x + 10

        -- if it would overflow, we wrap onto a new line
        if x + width > control.rectangle.width then
            x = 0
            y = y + ugui.standard_styler.params.tabcontrol.rail_size + ugui.standard_styler.params.tabcontrol.gap_y
        end

        local previous = selected_index == i
        local new = ugui.toggle_button({
            uid = control.uid + i,
            is_enabled = control.is_enabled,
            rectangle = {
                x = control.rectangle.x + x,
                y = control.rectangle.y + y,
                width = width,
                height = ugui.standard_styler.params.tabcontrol.rail_size,
            },
            text = control.items[i],
            is_checked = selected_index == i,
        })

        if not previous == new then
            selected_index = i
        end

        x = x + width + ugui.standard_styler.params.tabcontrol.gap_x
    end

    ugui.internal.handle_tooltip(control)
    return {
        selected_index = selected_index,
        rectangle = {
            x = control.rectangle.x,
            y = control.rectangle.y + ugui.standard_styler.params.tabcontrol.rail_size + y,
            width = control.rectangle.width,
            height = control.rectangle.height - y - ugui.standard_styler.params.tabcontrol.rail_size,
        },
    }
end

---Places a number editing box
---
---Additional fields in the `control` table:
---
--- `places` — `number` The amount of places the number is padded to
--- `value` — `number` The current value
---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
---@return _ number The new value
ugui.numberbox = function(control)
    ugui.internal.do_layout(control)
    ugui.internal.validate_and_register_control(control)

    ugui.internal.control_data[control.uid] = ugui.internal.control_data[control.uid] or {}
    if ugui.internal.control_data[control.uid].caret_index == nil then
        ugui.internal.control_data[control.uid].caret_index = 1
    end

    local is_positive = control.value >= 0

    -- conditionally visible negative sign button
    if control.show_negative then
        local negative_button_size = control.rectangle.width / 8

        -- NOTE: we clobber the rect ref!!
        control.rectangle = {
            x = control.rectangle.x + negative_button_size,
            y = control.rectangle.y,
            width = control.rectangle.width - negative_button_size,
            height = control.rectangle.height,
        }
        if ugui.button({
                uid = control.uid + 1,
                is_enabled = true,
                rectangle = {
                    x = control.rectangle.x - negative_button_size,
                    y = control.rectangle.y,
                    width = negative_button_size,
                    height = control.rectangle.height,
                },
                text = is_positive and '+' or '-',
            }) then
            control.value = -control.value
            is_positive = not is_positive
        end
    end

    -- we dont want sign in display
    control.value = math.abs(control.value)

    local pushed = ugui.internal.process_push(control)

    if pushed then
        ugui.internal.clear_active_control_after_mouse_up = false
    end

    -- if active and user clicks elsewhere, deactivate
    if ugui.internal.active_control == control.uid then
        if not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
            if ugui.internal.is_mouse_just_down() then
                -- deactivate, then clear selection
                ugui.internal.active_control = nil
                ugui.internal.control_data[control.uid].selection_start = nil
                ugui.internal.control_data[control.uid].selection_end = nil
            end
        end
    end

    local font_size = ugui.standard_styler.params.font_size * ugui.standard_styler.params.numberbox.font_scale
    local font_name = ugui.standard_styler.params.monospace_font_name

    local function get_caret_index_at_relative_x(text, x)
        -- award for most painful basic geometry
        local full_width = BreitbandGraphics.get_text_size(text,
            font_size,
            font_name).width

        local positions = {}
        for i = 1, #text, 1 do
            local width = BreitbandGraphics.get_text_size(text:sub(1, i),
                font_size,
                font_name).width

            local left = control.rectangle.width / 2 - full_width / 2
            positions[#positions + 1] = width + left
        end

        for i = #positions, 1, -1 do
            if x > positions[i] then
                return ugui.internal.clamp(i + 1, 1, #positions)
            end
        end
        return 1
    end

    local function increment_digit(index, value)
        control.value = ugui_ext.set_digit(control.value, control.places,
            ugui_ext.get_digit(control.value, control.places,
                index) + value,
            index)
    end

    local visual_state = ugui.get_visual_state(control)
    if ugui.internal.active_control == control.uid and control.is_enabled then
        visual_state = ugui.visual_states.active
    end
    ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

    local text = string.format('%0' .. tostring(control.places) .. 'd', control.value)

    BreitbandGraphics.draw_text2({
        text = text,
        rectangle = control.rectangle,
        color = ugui.standard_styler.params.textbox.text[visual_state],
        font_name = font_name,
        font_size = font_size,
        aliased = not ugui.standard_styler.params.cleartype,
    })

    local text_width_up_to_caret = BreitbandGraphics.get_text_size(
        text:sub(1, ugui.internal.control_data[control.uid].caret_index - 1),
        font_size,
        font_name).width

    local full_width = BreitbandGraphics.get_text_size(text,
        font_size,
        font_name).width

    local left = control.rectangle.width / 2 - full_width / 2

    local selected_char_rect = {
        x = control.rectangle.x + left + text_width_up_to_caret,
        y = control.rectangle.y,
        width = font_size / 2,
        height = control.rectangle.height,
    }

    if ugui.internal.active_control == control.uid then
        -- find the clicked number, change caret index
        if ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
            ugui.internal.control_data[control.uid].caret_index = get_caret_index_at_relative_x(text,
                ugui.internal.environment.mouse_position.x - control.rectangle.x)
        end

        -- handle number key press
        for key, _ in pairs(ugui.internal.get_just_pressed_keys()) do
            local num_1 = tonumber(key)
            local num_2 = tonumber(key:sub(7))
            local value = num_1 and num_1 or num_2

            if value then
                local oldkey = math.floor(control.value /
                    math.pow(10, control.places - ugui.internal.control_data[control.uid].caret_index)) % 10
                control.value = control.value +
                    (value - oldkey) *
                    math.pow(10, control.places - ugui.internal.control_data[control.uid].caret_index)
                ugui.internal.control_data[control.uid].caret_index = ugui.internal.control_data
                    [control.uid]
                    .caret_index + 1
            end

            if key == 'left' then
                ugui.internal.control_data[control.uid].caret_index = ugui.internal.control_data
                    [control.uid]
                    .caret_index - 1
            end
            if key == 'right' then
                ugui.internal.control_data[control.uid].caret_index = ugui.internal.control_data
                    [control.uid]
                    .caret_index + 1
            end
            if key == 'up' then
                increment_digit(ugui.internal.control_data[control.uid].caret_index, 1)
            end
            if key == 'down' then
                increment_digit(ugui.internal.control_data[control.uid].caret_index, -1)
            end
        end

        if ugui.internal.is_mouse_wheel_up() then
            increment_digit(ugui.internal.control_data[control.uid].caret_index, 1)
        end
        if ugui.internal.is_mouse_wheel_down() then
            increment_digit(ugui.internal.control_data[control.uid].caret_index, -1)
        end
        -- draw the char at caret index in inverted color
        BreitbandGraphics.fill_rectangle(selected_char_rect, BreitbandGraphics.hex_to_color('#0078D7'))
        BreitbandGraphics.push_clip(selected_char_rect)
        BreitbandGraphics.draw_text2({
            text = text,
            rectangle = control.rectangle,
            color = BreitbandGraphics.invert_color(ugui.standard_styler.params.textbox.text[visual_state]),
            font_name = font_name,
            font_size = font_size,
            aliased = not ugui.standard_styler.params.cleartype,
        })
        BreitbandGraphics.pop_clip()
    end

    ugui.internal.control_data[control.uid].caret_index = ugui.internal.clamp(
        ugui.internal.control_data[control.uid].caret_index, 1,
        control.places)

    ugui.internal.handle_tooltip(control)
    return math.floor(control.value) * (is_positive and 1 or -1)
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
    ugui.standard_styler.draw_icon = function(rectangle, color, visual_state, key)
        local rectangles = style.icons[key]

        if not rectangles then
            draw_icon_placeholder(rectangle)
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

    ugui.standard_styler.draw_scrollbar = function(container_rectangle, thumb_rectangle, visual_state)
        BreitbandGraphics.draw_image(container_rectangle,
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
