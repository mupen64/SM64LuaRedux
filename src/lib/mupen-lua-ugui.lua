-- mupen-lua-ugui 2.0.0
-- https://github.com/Aurumaker72/mupen-lua-ugui

local function folder(file)
    local s = debug.getinfo(2, 'S').source:sub(2)
    local p = file:gsub('[%(%)%%%.%+%-%*%?%^%$]', '%%%0'):gsub('[\\/]', '[\\/]') .. '$'
    return s:gsub(p, '')
end

dofile(folder('mupen-lua-ugui.lua') .. 'breitbandgraphics.lua')

---@alias UID number
---Unique identifier for a control. Must be unique within a frame.

---@alias ControlRectangleComputationDelegate fun(layout: LayoutSection, index: integer, control: Control): Rectangle
---A function which computes the rectangle for a control using the specified layout section.

---@alias RichText string
---Text which can contain other inline elements, such as icons.
---
---Examples:
---
---    [icon:arrow_left] Go Back
---    Move up [icon:arrow_up]
---    Hello World!

---@alias RichTextSegment { type: ["text"|"icon"], value: string }
---Represents a computed segment from a rich text string.

---@class Environment
---@field public mouse_position { x: number, y: number } The mouse position.
---@field public wheel number The mouse wheel delta.
---@field public is_primary_down boolean? Whether the primary mouse button is being pressed.
---@field public held_keys table<string, boolean> A map of held key identifiers to booleans. A key not being present or its value being 'false' means it is not held.
---@field public window_size { x: number, y: number }? The rendering bounds. If nil, no rendering bounds are considered and certain controls, such as menus, might overflow off-screen.

---@class LayoutSection
---@field public rectangle { x: number?, y: number?, width: number?, height: number? }? The rectangle region of the layout section. Depending on the section type, some components might be ignored. If nil or any contained field is nil, the field or the entire rectangle will be replaced with the corresponding value from the current state of the layout operation.
---@field package compute_control_rectangle ControlRectangleComputationDelegate? The layout section's bounds internal computation function. Doesn't need to be provided by external callers utilizing the layout section API via push_xyz().
---@field package data any? The layout section's internal data. Doesn't need to be provided by external callers utilizing the layout section API via push_xyz().
---The base class for all layout sections.

---@class StackPanel : LayoutSection
---@field public horizontal boolean? Whether the layout flow is horizontal. If nil, false is assumed.
---@field public gap number? The gap between elements. If nil, 0 is assumed.
---A StackPanel layout section, which orders its elements sequentially on the specified axis, adding gaps inbetween if specified.

---@class Control
---@field public uid UID The unique identifier of the control.
---@field public rectangle Rectangle The rectangle in which the control is drawn.
---@field public is_enabled boolean? Whether the control is enabled. If nil or true, the control is enabled.
---@field public tooltip string? The control's tooltip. If nil, no tooltip will be shown.
---@field package plaintext boolean? Whether the control's text content is drawn as plain text without rich rendering.
---@field package topmost boolean? Whether the control is drawn at the end of the frame, after all other controls.
---The base class for all controls.

---@class Button : Control
---@field public text RichText The text displayed on the button.
---A button which can be clicked.

---@class ToggleButton : Button
---@field public is_checked boolean Whether the button is checked.
---A button which can be toggled on and off.

---@class CarrouselButton : Control
---@field public items string[] The items contained in the carrousel button.
---@field public selected_index integer The index of the currently selected item into the items array.
---A button which can be toggled on and off.
---TODO: Make wraparound optional

---@class TextBox : Control
---@field public text string The text contained in the textbox.
---A textbox which can be edited.

---@class Joystick : Control
---@field public position Vector2 The joystick's position with the range 0-128 on both axes.
---@field public mag number? The joystick's magnitude circle radius with the range `0-128`. If nil, no magnitude circle will be drawn.
---A joystick which can be interacted with.

---@class Trackbar : Control
---@field public value number The current value in the range 0-1.
---A trackbar which can have its value adjusted.

---@class ComboBox : Control
---@field public items RichText[] The items contained in the control.
---@field public selected_index integer The index of the currently selected item into the items array.
---A combobox which allows the user to choose from a list of items.

---@class ListBox : Control
---@field public items RichText[] The items contained in the control.
---@field public selected_index integer The index of the currently selected item into the items array.
---@field public horizontal_scroll boolean? Whether horizontal scrolling will be enabled when items go beyond the width of the control. Will impact performance greatly, use with care.
---A listbox which allows the user to choose from a list of items.
---If the items don't fit in the control's bounds vertically, vertical scrolling will be enabled.
---If the items don't fit in the control's bounds horizontally, horizontal scrolling will be enabled if horizontal_scroll is true.

---@class ScrollBar : Control
---@field public value number The scroll proportion in the range 0-1.
---@field public ratio number The overflow ratio, which is calculated by dividing the desired content dimensions by the relevant attached control's (e.g.: a listbox's) dimensions.
---A scrollbar which allows scrolling horizontally or vertically, depending on the control's dimensions.

---@class MenuItem
---@field public items MenuItem[]? The item's child items. If nil or empty, the item has no child items and is clickable.
---@field public enabled boolean? Whether the item is enabled. If nil or true, the item is enabled.
---@field public checked boolean? Whether the item is checked. If true, the item is checked.
---@field public text RichText The item's text.
---Represents an item inside of a Menu.

---@class MenuResult
---@field public item MenuItem? The item that was clicked, or nil if none was.
---@field public dismissed boolean Whether the menu was dismissed by clicking outside of it.

---@class Menu : Control
---@field public items MenuItem[] The items contained in the menu.
---A menu, which allows the user to choose from a list of items.

---@class ToolTip
---@field public text RichText The tooltip's text.
---A tooltip, which can be used to show additional information about a control.

ugui = {

    internal = {
        ---@type table<UID, any>
        ---Map of control UIDs to their data.
        control_data = {},

        ---@type Environment
        ---The environment for the current frame.
        environment = nil,

        ---@type Environment
        ---The environment for the previous frame.
        previous_environment = nil,

        ---@type Vector2
        -- The position of the mouse the last time the primary button was pressed.
        mouse_down_position = {x = 0, y = 0},

        ---@type UID|nil
        -- UID of the currently active control.
        active_control = nil,

        ---@type boolean
        -- Whether the active control will be reset to nil after the mouse is released.
        clear_active_control_after_mouse_up = true,

        ---@type Rectangle[]
        -- Rectangles which are excluded from hittesting (e.g.: the popped up list of a combobox)
        hittest_free_rects = {},

        ---@type function[]
        -- Functions which will be called at the end of the frame. This array is reset when a new frame begins.
        late_callbacks = {},

        ---@type { [UID]: boolean }
        -- Map of uids used in an active section (between begin_frame and end_frame). Used to prevent uid collisions.
        used_uids = {},

        ---@type LayoutSection[]
        ---The current layout stack.
        layout_stack = {},

        ---@type Rectangle
        ---The rectangle of the most recently shown control. Reset on frame end.
        last_control_rectangle = nil,

        ---Whether a frame is currently in progress.
        frame_in_progress = false,

        ---Validates the structure of a control. Must be called in every control function.
        ---@param control Control A control which may or may not abide by the mupen-lua-ugui control contract
        validate_control = function(control)
            if not control.uid
                or not control.rectangle
                or not control.rectangle.x
                or not control.rectangle.y
                or not control.rectangle.width
                or not control.rectangle.height
            then
                error('Attempted to show a malformed control.\r\n' .. debug.traceback())
            end
        end,

        ---Validates the structure of a control and registers its uid. Must be called in every control function.
        ---@param control Control A control which may or may not abide by the mupen-lua-ugui control contract
        validate_and_register_control = function(control)
            ugui.internal.validate_control(control)
            if ugui.internal.used_uids[control.uid] then
                error(string.format('Attempted to show a control with uid %d, which is already in use! Note that some controls reserve more than one uid slot after them.', control.uid))
            end
            ugui.internal.used_uids[control.uid] = true
            ugui.internal.last_control_rectangle = control.rectangle
        end,

        ---Deeply clones a table.
        ---@param obj table The table to clone.
        ---@param seen table? Internal. Pass nil as a caller.
        ---@return table A cloned instance of the table.
        deep_clone = function(obj, seen)
            if type(obj) ~= 'table' then return obj end
            if seen and seen[obj] then return seen[obj] end
            local s = seen or {}
            local res = setmetatable({}, getmetatable(obj))
            s[obj] = res
            for k, v in pairs(obj) do
                res[ugui.internal.deep_clone(k, s)] = ugui.internal.deep_clone(
                    v, s)
            end
            return res
        end,

        ---Removes a range of characters from a string.
        ---@param string string The string to remove characters from.
        ---@param start_index integer The index of the first character to remove.
        ---@param end_index integer The index of the last character to remove.
        ---@return string # A new string with the characters removed.
        remove_range = function(string, start_index, end_index)
            if start_index > end_index then
                start_index, end_index = end_index, start_index
            end
            return string.sub(string, 1, start_index - 1) .. string.sub(string, end_index)
        end,

        ---@return boolean # Whether LMB was just pressed.
        is_mouse_just_down = function()
            local value = ugui.internal.environment.is_primary_down and not ugui.internal.previous_environment.is_primary_down
            return value and true or false
        end,

        ---@return boolean # Whether LMB was just released.
        is_mouse_just_up = function()
            local value = not ugui.internal.environment.is_primary_down and ugui.internal.previous_environment.is_primary_down
            return value and true or false
        end,

        ---@return boolean # Whether the mouse wheel was just moved up.
        is_mouse_wheel_up = function()
            return ugui.internal.environment.wheel == 1
        end,

        ---@return boolean # Whether the mouse wheel was just moved down.
        is_mouse_wheel_down = function()
            return ugui.internal.environment.wheel == -1
        end,

        ---Removes the character at the specified index from a string.
        ---@param string string The string to remove the character from.
        ---@param index integer The index of the character to remove.
        ---@return string # A new string with the character removed.
        remove_at = function(string, index)
            if index == 0 then
                return string
            end
            return string:sub(1, index - 1) .. string:sub(index + 1, string:len())
        end,

        ---Inserts a string into another string at the specified index.
        ---@param string string The original string to insert the other string into.
        ---@param string2 string The other string.
        ---@param index integer The index into the first string to begin inserting the second string at.
        ---@return string # A new string with the other string inserted.
        insert_at = function(string, string2, index)
            return string:sub(1, index) .. string2 .. string:sub(index + string2:len(), string:len())
        end,

        ---Remaps a value from one range to another.
        ---@param value number The value.
        ---@param from1 number The lower bound of the first range.
        ---@param to1 number The upper bound of the first range.
        ---@param from2 number The lower bound of the second range.
        ---@param to2 number The upper bound of the second range.
        ---@return number # The new remapped value.
        remap = function(value, from1, to1, from2, to2)
            return (value - from1) / (to1 - from1) * (to2 - from2) + from2
        end,

        ---Limits a value to a range.
        ---@param value number The value.
        ---@param min number The lower bound.
        ---@param max number The upper bound.
        ---@return number # The new limited value.
        clamp = function(value, min, max)
            -- FIXME: Remove this nil check, deal with the fallout.
            if value == nil then
                return value
            end
            return math.max(math.min(value, max), min)
        end,

        ---Gets all the keys that are newly pressed since the last frame.
        ---@return table<string, boolean> # The newly pressed keys.
        get_just_pressed_keys = function()
            local keys = {}
            for key, _ in pairs(ugui.internal.environment.held_keys) do
                if not ugui.internal.previous_environment.held_keys[key] then
                    keys[key] = 1
                end
            end
            return keys
        end,

        ---Processes clicking on a control.
        ---@param control Control A control.
        ---@return boolean # Whether the control was clicked.
        process_push = function(control)
            if control.is_enabled == false then
                return false
            end

            if ugui.internal.environment.is_primary_down and not ugui.internal.previous_environment.is_primary_down then
                if BreitbandGraphics.is_point_inside_rectangle(ugui.internal.mouse_down_position,
                        control.rectangle) then
                    if not control.topmost and BreitbandGraphics.is_point_inside_any_rectangle(ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects) then
                        return false
                    end

                    ugui.internal.active_control = control.uid
                    ugui.internal.clear_active_control_after_mouse_up = true
                    return true
                end
            end
            return false
        end,

        ---Gets the character index for the specified relative x position in a textbox.
        ---Considers font_size and font_name, as provided by the styler.
        ---@param text string The textbox's text.
        ---@param relative_x number The relative x position.
        ---@return integer The character index.
        ---FIXME: This should be moved to BreitbandGraphics!!!
        get_caret_index = function(text, relative_x)
            local positions = {}
            for i = 1, #text, 1 do
                local width = BreitbandGraphics.get_text_size(text:sub(1, i),
                    ugui.standard_styler.params.font_size,
                    ugui.standard_styler.params.font_name).width

                positions[#positions + 1] = width
            end

            for i = #positions, 1, -1 do
                if relative_x > positions[i] then
                    return ugui.internal.clamp(i + 1, 1, #positions + 1)
                end
            end

            return 1
        end,

        ---@class TextBoxNavigationKeyProcessingResult
        ---@field public handled boolean Whether the key press was handled.
        ---@field public text string? The new textbox text.
        ---@field public selection_start integer? The new textbox selection start index.
        ---@field public selection_end integer? The new textbox selection end index.
        ---@field public caret_index integer? The new textbox caret index.

        ---Handles navigation key presses in a textbox.
        ---@param key string The pressed key identifier.
        ---@param has_selection boolean Whether the textbox has a selection.
        ---@param text string The textbox's text.
        ---@param selection_start integer The textbox selection start index.
        ---@param selection_end integer The textbox selection end index.
        ---@param caret_index integer The textbox caret index.
        ---@return TextBoxNavigationKeyProcessingResult # The result of the navigation key press processing.
        handle_special_key = function(key, has_selection, text, selection_start, selection_end, caret_index)
            local sel_lo = math.min(selection_start, selection_end)
            local sel_hi = math.max(selection_start, selection_end)

            if key == 'left' then
                if has_selection then
                    -- nuke the selection and set caret index to lower (left)
                    local lower_selection = sel_lo
                    selection_start = lower_selection
                    selection_end = lower_selection
                    caret_index = lower_selection
                else
                    caret_index = caret_index - 1
                end
            elseif key == 'right' then
                if has_selection then
                    -- nuke the selection and set caret index to higher (right)
                    local higher_selection = sel_hi
                    selection_start = higher_selection
                    selection_end = higher_selection
                    caret_index = higher_selection
                else
                    caret_index = caret_index + 1
                end
            elseif key == 'space' then
                if has_selection then
                    -- replace selection contents by one space
                    local lower_selection = sel_lo
                    text = ugui.internal.remove_range(text, sel_lo, sel_hi)
                    caret_index = lower_selection
                    selection_start = lower_selection
                    selection_end = lower_selection
                    text = ugui.internal.insert_at(text, ' ', caret_index - 1)
                    caret_index = caret_index + 1
                else
                    text = ugui.internal.insert_at(text, ' ', caret_index - 1)
                    caret_index = caret_index + 1
                end
            elseif key == 'backspace' then
                if has_selection then
                    local lower_selection = sel_lo
                    text = ugui.internal.remove_range(text, lower_selection, sel_hi)
                    caret_index = lower_selection
                    selection_start = lower_selection
                    selection_end = lower_selection
                else
                    text = ugui.internal.remove_at(text,
                        caret_index - 1)
                    caret_index = caret_index - 1
                end
            else
                return {
                    handled = false,
                }
            end
            return {
                handled = true,
                text = text,
                selection_start = selection_start,
                selection_end = selection_end,
                caret_index = caret_index,
            }
        end,

        ---Performs the required layout operations on the specified control.
        ---@param control Control The control table. Its contents may be mutated.
        do_layout = function(control)
            for i = 1, #ugui.internal.layout_stack, 1 do
                local section = ugui.internal.layout_stack[i]
                control.rectangle = section:compute_control_rectangle(i, control)
            end
        end,

        ---Does tooltip processing for the specified control.
        ---@param control Control The control table.
        handle_tooltip = function(control)
            ugui.internal.control_data[control.uid] = ugui.internal.control_data[control.uid] or {}

            local prev_tooltip_visible = ugui.internal.control_data[control.uid].tooltip_visible

            ugui.internal.control_data[control.uid].tooltip_visible = false

            if not control.tooltip then
                return
            end
            if control.is_enabled == false then
                return
            end
            if not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                return
            end
            if BreitbandGraphics.is_point_inside_any_rectangle(ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects) then
                return
            end

            ugui.internal.control_data[control.uid].tooltip_visible = true

            if ugui.internal.control_data[control.uid].tooltip_visible and not prev_tooltip_visible then
                ugui.internal.control_data[control.uid].tooltip_hover_start = os.clock()
            end

            ugui.internal.late_callbacks[#ugui.internal.late_callbacks + 1] = function()
                ugui.standard_styler.draw_tooltip(control, {
                    x = ugui.internal.environment.mouse_position.x,
                    y = ugui.internal.environment.mouse_position.y,
                }, ugui.internal.control_data[control.uid].tooltip_hover_start)
            end
        end,

        ---Parses rich text into content segments.
        ---@param text RichText The rich text to parse.
        ---@return RichTextSegment[] # The content segments.
        parse_rich_text = function(text)
            local segments = {}
            local pattern = '(.-)(%[icon:[^%]]+%])'

            local last_pos = 1
            for text, icon in text:gmatch(pattern) do
                if text ~= '' then
                    table.insert(segments, {type = 'text', value = text})
                end
                table.insert(segments, {type = 'icon', value = icon:match('%[icon:([^%]]+)%]')})
                last_pos = last_pos + #text + #icon
            end

            if last_pos <= #text then
                local remaining_text = text:sub(last_pos)
                if remaining_text ~= '' then
                    table.insert(segments, {type = 'text', value = remaining_text})
                end
            end

            return segments
        end,
    },

    ---@type table<string, ControlRectangleComputationDelegate>
    ---Map of layout section names to their control rectangle computation delegates.
    layout_computation_functions = {
        ['StackPanel'] = function(layout, index, control)
            ---@cast layout StackPanel

            if index ~= #ugui.internal.layout_stack then
                return control.rectangle
            end

            if not layout.data then
                layout.data = {x = layout.rectangle.x, y = layout.rectangle.y, i = 1}
            end

            local rectangle = ugui.internal.deep_clone(control.rectangle)
            local gap = layout.gap or 0

            local function add_accumulators()
                if layout.horizontal then
                    layout.data.x = layout.data.x + rectangle.width + gap
                else
                    layout.data.y = layout.data.y + rectangle.height + gap
                end
            end

            if (layout.horizontal and layout.rectangle.width ~= 0)
                or (not layout.horizontal and layout.rectangle.height ~= 0) then
                add_accumulators()
            end

            rectangle.x = layout.data.x
            rectangle.y = layout.data.y
            layout.data.i = layout.data.i + 1

            if (layout.horizontal and layout.rectangle.width == 0)
                or (not layout.horizontal and layout.rectangle.height == 0) then
                add_accumulators()
            end


            return rectangle
        end,
    },

    ---@enum VisualState
    -- The possible states of a control, which are used by the styler for drawing.
    visual_states = {
        --- The control doesn't accept user interactions.
        disabled = 0,
        --- The control isn't being interacted with.
        normal = 1,
        --- The mouse is over the control.
        hovered = 2,
        --- The control is currently capturing inputs.
        active = 3,
    },

    ---Gets the basic visual state of a control.
    ---@param control Control The control.
    ---@return VisualState # The control's visual state.
    get_visual_state = function(control)
        if control.is_enabled == false then
            return ugui.visual_states.disabled
        end

        if ugui.internal.active_control ~= nil and ugui.internal.active_control == control.uid then
            return ugui.visual_states.active
        end

        local now_inside = BreitbandGraphics.is_point_inside_rectangle(
                ugui.internal.environment.mouse_position,
                control.rectangle)
            and
            not BreitbandGraphics.is_point_inside_any_rectangle(ugui.internal.environment.mouse_position,
                ugui.internal.hittest_free_rects)

        local down_inside = BreitbandGraphics.is_point_inside_rectangle(
                ugui.internal.mouse_down_position, control.rectangle)
            and
            not BreitbandGraphics.is_point_inside_any_rectangle(ugui.internal.mouse_down_position,
                ugui.internal.hittest_free_rects)

        if now_inside and not ugui.internal.environment.is_primary_down then
            return ugui.visual_states.hovered
        end

        if down_inside and ugui.internal.environment.is_primary_down and not now_inside then
            return ugui.visual_states.hovered
        end

        if now_inside and down_inside and ugui.internal.environment.is_primary_down then
            return ugui.visual_states.active
        end

        return ugui.visual_states.normal
    end,

    --- The standard style implementation, which is responsible for drawing controls.
    standard_styler = {

        --- The styler parameters, which determine how controls are drawn.
        params = {

            --- Whether font filtering is enabled.
            cleartype = true,

            --- The font name.
            font_name = 'MS Shell Dlg 2',

            --- The monospace variant font name.
            monospace_font_name = 'Consolas',

            --- The font size.
            font_size = 12,

            --- The icon size.
            icon_size = 12,

            button = {
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#E1E1E1'),
                    [2] = BreitbandGraphics.hex_to_color('#E5F1FB'),
                    [3] = BreitbandGraphics.hex_to_color('#CCE4F7'),
                    [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                },
                border = {
                    [1] = BreitbandGraphics.hex_to_color('#ADADAD'),
                    [2] = BreitbandGraphics.hex_to_color('#0078D7'),
                    [3] = BreitbandGraphics.hex_to_color('#005499'),
                    [0] = BreitbandGraphics.hex_to_color('#BFBFBF'),
                },
                text = {
                    [1] = BreitbandGraphics.hex_to_color('#000000'),
                    [2] = BreitbandGraphics.hex_to_color('#000000'),
                    [3] = BreitbandGraphics.hex_to_color('#000000'),
                    [0] = BreitbandGraphics.hex_to_color('#A0A0A0'),
                },
            },
            textbox = {
                padding = {x = 2, y = 0},
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                },
                border = {
                    [1] = BreitbandGraphics.hex_to_color('#7A7A7A'),
                    [2] = BreitbandGraphics.hex_to_color('#171717'),
                    [3] = BreitbandGraphics.hex_to_color('#0078D7'),
                    [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                },
                text = {
                    [1] = BreitbandGraphics.hex_to_color('#000000'),
                    [2] = BreitbandGraphics.hex_to_color('#000000'),
                    [3] = BreitbandGraphics.hex_to_color('#000000'),
                    [0] = BreitbandGraphics.hex_to_color('#A0A0A0'),
                },
            },
            listbox = {
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                },
                border = {
                    [1] = BreitbandGraphics.hex_to_color('#7A7A7A'),
                    [2] = BreitbandGraphics.hex_to_color('#7A7A7A'),
                    [3] = BreitbandGraphics.hex_to_color('#7A7A7A'),
                    [0] = BreitbandGraphics.hex_to_color('#7A7A7A'),
                },
            },
            listbox_item = {
                height = 15,
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [3] = BreitbandGraphics.hex_to_color('#0078D7'),
                    [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                },
                text = {
                    [1] = BreitbandGraphics.hex_to_color('#000000'),
                    [2] = BreitbandGraphics.hex_to_color('#000000'),
                    [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [0] = BreitbandGraphics.hex_to_color('#A0A0A0'),
                },
            },
            menu = {
                overlap_size = 3,
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#F2F2F2'),
                    [2] = BreitbandGraphics.hex_to_color('#F2F2F2'),
                    [3] = BreitbandGraphics.hex_to_color('#F2F2F2'),
                    [0] = BreitbandGraphics.hex_to_color('#F2F2F2'),
                },
                border = {
                    [1] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                    [2] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                    [3] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                    [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                },
            },
            menu_item = {
                height = 22,
                left_padding = 32,
                right_padding = 32,
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#00000000'),
                    [2] = BreitbandGraphics.hex_to_color('#91C9F7'),
                    [3] = BreitbandGraphics.hex_to_color('#91C9F7'),
                    [0] = BreitbandGraphics.hex_to_color('#00000000'),
                },
                border = {
                    [1] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                    [2] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                    [3] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                    [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                },
                text = {
                    [1] = BreitbandGraphics.hex_to_color('#000000'),
                    [2] = BreitbandGraphics.hex_to_color('#000000'),
                    [3] = BreitbandGraphics.hex_to_color('#000000'),
                    [0] = BreitbandGraphics.hex_to_color('#6D6D6D'),
                },
            },
            joystick = {
                tip_size = 8,
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                    [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                },
                outline = {
                    [1] = BreitbandGraphics.hex_to_color('#000000'),
                    [2] = BreitbandGraphics.hex_to_color('#000000'),
                    [3] = BreitbandGraphics.hex_to_color('#000000'),
                    [0] = BreitbandGraphics.hex_to_color('#000000'),
                },
                tip = {
                    [1] = BreitbandGraphics.hex_to_color('#FF0000'),
                    [2] = BreitbandGraphics.hex_to_color('#FF0000'),
                    [3] = BreitbandGraphics.hex_to_color('#FF0000'),
                    [0] = BreitbandGraphics.hex_to_color('#FF8080'),
                },
                line = {
                    [1] = BreitbandGraphics.hex_to_color('#0000FF'),
                    [2] = BreitbandGraphics.hex_to_color('#0000FF'),
                    [3] = BreitbandGraphics.hex_to_color('#0000FF'),
                    [0] = BreitbandGraphics.hex_to_color('#8080FF'),
                },
                inner_mag = {
                    [1] = BreitbandGraphics.hex_to_color('#FF000022'),
                    [2] = BreitbandGraphics.hex_to_color('#FF000022'),
                    [3] = BreitbandGraphics.hex_to_color('#FF000022'),
                    [0] = BreitbandGraphics.hex_to_color('#00000000'),
                },
                outer_mag = {
                    [1] = BreitbandGraphics.hex_to_color('#FF0000'),
                    [2] = BreitbandGraphics.hex_to_color('#FF0000'),
                    [3] = BreitbandGraphics.hex_to_color('#FF0000'),
                    [0] = BreitbandGraphics.hex_to_color('#FF8080'),
                },
                mag_thicknesses = {
                    [1] = 2,
                    [2] = 2,
                    [3] = 2,
                    [0] = 2,
                },
            },
            scrollbar = {
                thickness = 17,
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#F0F0F0'),
                    [2] = BreitbandGraphics.hex_to_color('#F0F0F0'),
                    [3] = BreitbandGraphics.hex_to_color('#F0F0F0'),
                    [0] = BreitbandGraphics.hex_to_color('#F0F0F0'),
                },
                thumb = {
                    [1] = BreitbandGraphics.hex_to_color('#CDCDCD'),
                    [2] = BreitbandGraphics.hex_to_color('#A6A6A6'),
                    [3] = BreitbandGraphics.hex_to_color('#606060'),
                    [0] = BreitbandGraphics.hex_to_color('#C0C0C0'),
                },
            },
            trackbar = {
                track_thickness = 2,
                bar_width = 6,
                bar_height = 16,
                back = {
                    [1] = BreitbandGraphics.hex_to_color('#E7EAEA'),
                    [2] = BreitbandGraphics.hex_to_color('#E7EAEA'),
                    [3] = BreitbandGraphics.hex_to_color('#E7EAEA'),
                    [0] = BreitbandGraphics.hex_to_color('#E7EAEA'),
                },
                border = {
                    [1] = BreitbandGraphics.hex_to_color('#D6D6D6'),
                    [2] = BreitbandGraphics.hex_to_color('#D6D6D6'),
                    [3] = BreitbandGraphics.hex_to_color('#D6D6D6'),
                    [0] = BreitbandGraphics.hex_to_color('#D6D6D6'),
                },
                thumb = {
                    [1] = BreitbandGraphics.hex_to_color('#007AD9'),
                    [2] = BreitbandGraphics.hex_to_color('#171717'),
                    [3] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                    [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
                },
            },
            tooltip = {
                delay = 0.2,
                padding = 4,
            },
        },

        ---Draws an icon with the specified parameters.
        ---The draw_icon implementation may choose to use either the color or visual_state parameter to determine the icon's appearance.
        ---Therefore, the caller must provide either a color or a visual state, or both.
        ---@param rectangle Rectangle The icon's bounds.
        ---@param color Color? The icon's fill color.
        ---@param visual_state VisualState? The icon's visual state.
        ---@param key string The icon's identifier.
        draw_icon = function(rectangle, color, visual_state, key)
            -- NOTE: visual_state is not utilized by the standard implementation of draw_icon.
            if not color then
                BreitbandGraphics.fill_rectangle(rectangle, BreitbandGraphics.colors.red)
                return
            end

            local font_name = 'Segoe UI Mono'
            local font_size = ugui.standard_styler.params.font_size

            if key == 'arrow_left' then
                BreitbandGraphics.draw_text2({
                    text = '<',
                    rectangle = rectangle,
                    color = color,
                    font_name = font_name,
                    font_size = font_size,
                    aliased = not ugui.standard_styler.params.cleartype,
                })
            elseif key == 'arrow_right' then
                BreitbandGraphics.draw_text2({
                    text = '>',
                    rectangle = rectangle,
                    color = color,
                    font_name = font_name,
                    font_size = font_size,
                    aliased = not ugui.standard_styler.params.cleartype,
                })
            elseif key == 'arrow_up' then
                BreitbandGraphics.draw_text2({
                    text = '^',
                    rectangle = rectangle,
                    color = color,
                    font_name = font_name,
                    font_size = font_size,
                    aliased = not ugui.standard_styler.params.cleartype,
                })
            elseif key == 'arrow_down' then
                BreitbandGraphics.draw_text2({
                    text = 'v',
                    rectangle = rectangle,
                    color = color,
                    font_name = font_name,
                    font_size = font_size,
                    aliased = not ugui.standard_styler.params.cleartype,
                })
            elseif key == 'checkmark' then
                local connection_point = {x = rectangle.x + rectangle.width * 0.3, y = rectangle.y + rectangle.height}
                BreitbandGraphics.draw_line({x = rectangle.x, y = rectangle.y + rectangle.height / 2}, connection_point, color, 1)
                BreitbandGraphics.draw_line(connection_point, {x = rectangle.x + rectangle.width, y = rectangle.y}, color, 1)
            else
                -- Unknown icon, probably a good idea to nag the user
                BreitbandGraphics.fill_rectangle(rectangle, BreitbandGraphics.colors.red)
            end
        end,

        ---Computes the segment data of rich text.
        ---@param text RichText The rich text.
        ---@param plaintext boolean? Whether the text is drawn without rich formatting. If nil, false is assumed.
        ---@return { segment_data: { segment: RichTextSegment, rectangle: Rectangle }[], size: Vector2  } # The computed rich text segment data.
        compute_rich_text = function(text, plaintext)
            if plaintext then

                local size = BreitbandGraphics.get_text_size(text, ugui.standard_styler.params.font_size, ugui.standard_styler.params.font_name)
                return {
                    segment_data = {
                        segment = {
                            type = "text",
                            value = text,
                        },
                        rectangle = {
                            x = 0,
                            y = 0,
                            width = size.width,
                            height = size.height
                        }
                    },
                    size = {
                        x = size.width,
                        y = size.height
                    }
                }
            end
            local segment_data = {}

            local x = 0

            local segments = ugui.internal.parse_rich_text(text)

            -- 1. Compute untranslated (relative to {0,0}) and horizontally stacked rectangles for all segments
            for _, segment in pairs(segments) do
                if segment.type == 'icon' then
                    segment_data[#segment_data + 1] = {
                        segment = segment,
                        rectangle = {
                            x = x,
                            y = 0,
                            width = ugui.standard_styler.params.icon_size,
                            height = ugui.standard_styler.params.icon_size,
                        },
                    }
                    x = x + ugui.standard_styler.params.icon_size
                elseif segment.type == 'text' then
                    local size = BreitbandGraphics.get_text_size(segment.value, ugui.standard_styler.params.font_size, ugui.standard_styler.params.font_name)
                    segment_data[#segment_data + 1] = {
                        segment = segment,
                        rectangle = {
                            x = x,
                            y = 0,
                            width = size.width,
                            height = size.height,
                        },
                    }
                    x = x + size.width
                else
                    error(string.format("Unknown segment type '%s' encountered in measure_rich_text.", segment.type))
                end
            end

            -- 2. Find out total width and max height
            local total_width = 0
            local max_height = 0
            for _, data in pairs(segment_data) do
                total_width = total_width + data.rectangle.width
                if data.rectangle.height > max_height then
                    max_height = data.rectangle.height
                end
            end

            -- 3. Normalize all segments to same max height
            for _, data in pairs(segment_data) do
                data.rectangle.height = max_height
            end

            return {
                segment_data = segment_data,
                size = {
                    x = total_width,
                    y = max_height
                }
            }
        end,

        ---Draws rich text with the specified parameters.
        ---@param rectangle Rectangle The rich text's bounds.
        ---@param align_x Alignment? The rich text's horizontal alignment inside the rectangle. If nil, the default is assumed.
        ---@param align_y Alignment? The rich text's vertical alignment inside the rectangle. If nil, the default is assumed.
        ---@param text RichText The rich text.
        ---@param color Color The colors for rich text.
        ---@param visual_state VisualState The visual state for rich icons.
        ---@param plaintext boolean? Whether the text is drawn without rich formatting. If nil, false is assumed.
        draw_rich_text = function(rectangle, align_x, align_y, text, color, visual_state, plaintext)
            align_x = align_x or BreitbandGraphics.alignment.center
            align_y = align_y or BreitbandGraphics.alignment.center

            if plaintext then
                BreitbandGraphics.draw_text2({
                    text = text,
                    rectangle = rectangle,
                    color = color,
                    align_x = align_x,
                    align_y = align_y,
                    font_name = ugui.standard_styler.params.font_name,
                    font_size = ugui.standard_styler.params.font_size,
                    clip = true,
                    aliased = not ugui.standard_styler.params.cleartype,
                })
                return
            end

            -- 1. Compute rich text segment data
            local computed = ugui.standard_styler.compute_rich_text(text, plaintext)
            local segment_data = computed.segment_data
            local total_width = computed.size.x

            -- 2. Translate all segments to match the specified alignments
            if align_x == BreitbandGraphics.alignment.start then
                for _, data in pairs(segment_data) do
                    data.rectangle.x = data.rectangle.x + rectangle.x
                end
            elseif align_x == BreitbandGraphics.alignment.center then
                local x_offset = rectangle.x + (rectangle.width - total_width) / 2
                for _, data in pairs(segment_data) do
                    data.rectangle.x = data.rectangle.x + x_offset
                end
            elseif align_x == BreitbandGraphics.alignment['end'] then
                local x_offset = rectangle.x + rectangle.width - total_width
                for _, data in pairs(segment_data) do
                    data.rectangle.x = data.rectangle.x + x_offset
                end
            end

            if align_y == BreitbandGraphics.alignment.start then
                for _, data in pairs(segment_data) do
                    data.rectangle.y = data.rectangle.y + rectangle.y
                end
            elseif align_y == BreitbandGraphics.alignment.center then
                for _, data in pairs(segment_data) do
                    data.rectangle.y = data.rectangle.y + rectangle.y + rectangle.height / 2 - data.rectangle.height / 2
                end
            elseif align_y == BreitbandGraphics.alignment['end'] then
                for _, data in pairs(segment_data) do
                    data.rectangle.y = data.rectangle.y + rectangle.y + rectangle.height - data.rectangle.height
                end
            end

            -- 3. Draw the segments
            for _, data in pairs(segment_data) do
                if data.segment.type == 'icon' then
                    ugui.standard_styler.draw_icon(data.rectangle, nil, visual_state, data.segment.value)
                end
                if data.segment.type == 'text' then
                    BreitbandGraphics.draw_text2({
                        text = data.segment.value,
                        rectangle = {
                            x = data.rectangle.x,
                            y = data.rectangle.y,
                            width = data.rectangle.width + 1,
                            height = data.rectangle.height,
                        },
                        color = color,
                        align_x = BreitbandGraphics.alignment.start,
                        align_y = BreitbandGraphics.alignment.start,
                        font_name = ugui.standard_styler.params.font_name,
                        font_size = ugui.standard_styler.params.font_size,
                        clip = true,
                        aliased = not ugui.standard_styler.params.cleartype,
                    })
                end
            end
        end,

        ---Draws a raised frame with the specified parameters.
        ---@param control Control The control table.
        ---@param visual_state VisualState The control's visual state.
        draw_raised_frame = function(control, visual_state)
            BreitbandGraphics.fill_rectangle(control.rectangle,
                ugui.standard_styler.params.button.border[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                ugui.standard_styler.params.button.back[visual_state])
        end,

        ---Draws an edit frame with the specified parameters.
        ---@param control Control The control table.
        ---@param visual_state VisualState The control's visual state.
        draw_edit_frame = function(control, rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(control.rectangle,
                ugui.standard_styler.params.textbox.border[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                ugui.standard_styler.params.textbox.back[visual_state])
        end,

        ---Draws a list frame with the specified parameters.
        ---@param rectangle Rectangle The control bounds.
        ---@param visual_state VisualState The control's visual state.
        draw_list_frame = function(rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(rectangle,
                ugui.standard_styler.params.listbox.border[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                ugui.standard_styler.params.listbox.back[visual_state])
        end,

        ---Draws a joystick's inner part with the specified parameters.
        ---@param rectangle Rectangle The control bounds.
        ---@param visual_state VisualState The control's visual state.
        ---@param position Vector2 The joystick's position.
        draw_joystick_inner = function(rectangle, visual_state, position)
            local back_color = ugui.standard_styler.params.joystick.back[visual_state]
            local outline_color = ugui.standard_styler.params.joystick.outline[visual_state]
            local tip_color = ugui.standard_styler.params.joystick.tip[visual_state]
            local line_color = ugui.standard_styler.params.joystick.line[visual_state]
            local inner_mag_color = ugui.standard_styler.params.joystick.inner_mag[visual_state]
            local outer_mag_color = ugui.standard_styler.params.joystick.outer_mag[visual_state]
            local mag_thickness = ugui.standard_styler.params.joystick.mag_thicknesses[visual_state]

            BreitbandGraphics.fill_ellipse(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                back_color)
            BreitbandGraphics.draw_ellipse(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                outline_color, 1)
            BreitbandGraphics.draw_line({
                x = rectangle.x + rectangle.width / 2,
                y = rectangle.y,
            }, {
                x = rectangle.x + rectangle.width / 2,
                y = rectangle.y + rectangle.height,
            }, outline_color, 1)
            BreitbandGraphics.draw_line({
                x = rectangle.x,
                y = rectangle.y + rectangle.height / 2,
            }, {
                x = rectangle.x + rectangle.width,
                y = rectangle.y + rectangle.height / 2,
            }, outline_color, 1)


            local r = position.r - mag_thickness
            if r > 0 then
                BreitbandGraphics.fill_ellipse({
                    x = rectangle.x + rectangle.width / 2 - r / 2,
                    y = rectangle.y + rectangle.height / 2 - r / 2,
                    width = r,
                    height = r,
                }, inner_mag_color)
                r = position.r

                BreitbandGraphics.draw_ellipse({
                    x = rectangle.x + rectangle.width / 2 - r / 2,
                    y = rectangle.y + rectangle.height / 2 - r / 2,
                    width = r,
                    height = r,
                }, outer_mag_color, mag_thickness)
            end


            BreitbandGraphics.draw_line({
                x = rectangle.x + rectangle.width / 2,
                y = rectangle.y + rectangle.height / 2,
            }, {
                x = position.x,
                y = position.y,
            }, line_color, 3)

            BreitbandGraphics.fill_ellipse({
                x = position.x - ugui.standard_styler.params.joystick.tip_size / 2,
                y = position.y - ugui.standard_styler.params.joystick.tip_size / 2,
                width = ugui.standard_styler.params.joystick.tip_size,
                height = ugui.standard_styler.params.joystick.tip_size,
            }, tip_color)
        end,

        ---Draws a scrollbar with the specified parameters.
        ---@param container_rectangle Rectangle The scrollbar container's bounds.
        ---@param thumb_rectangle Rectangle The scrollbar thumb's bounds.
        ---@param visual_state VisualState The control's visual state.
        draw_scrollbar = function(container_rectangle, thumb_rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(container_rectangle,
                ugui.standard_styler.params.scrollbar.back[visual_state])
            BreitbandGraphics.fill_rectangle(thumb_rectangle,
                ugui.standard_styler.params.scrollbar.thumb[visual_state])
        end,

        ---Draws a list item with the specified parameters.
        ---@param control Control The associated list control.
        ---@param item string The list item's text.
        ---@param rectangle Rectangle The list item's bounds.
        ---@param visual_state VisualState The control's visual state.
        draw_list_item = function(control, item, rectangle, visual_state)
            if not item then
                return
            end
            BreitbandGraphics.fill_rectangle(rectangle,
                ugui.standard_styler.params.listbox_item.back[visual_state])

            local size = BreitbandGraphics.get_text_size(item, ugui.standard_styler.params.font_size, ugui.standard_styler.params.font_name)

            local text_rect = {
                x = rectangle.x + 2,
                y = rectangle.y,
                width = size.width * 2,
                height = rectangle.height,
            }

            ugui.standard_styler.draw_rich_text(text_rect, BreitbandGraphics.alignment.start, nil, item, ugui.standard_styler.params.listbox_item.text[visual_state], visual_state, control.plaintext)
        end,

        ---Draws a list with the specified parameters.
        ---@param control ListBox The control table.
        ---@param rectangle Rectangle The list item's bounds.
        draw_list = function(control, rectangle)
            local visual_state = ugui.get_visual_state(control)
            ugui.standard_styler.draw_list_frame(rectangle, visual_state)

            if not control.items then
                return
            end

            local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)
            -- item y position:
            -- y = (20 * (i - 1)) - (scroll_y * ((20 * #control.items) - control.rectangle.height))
            local scroll_x = ugui.internal.control_data[control.uid].scroll_x and
                ugui.internal.control_data[control.uid].scroll_x or 0
            local scroll_y = ugui.internal.control_data[control.uid].scroll_y and
                ugui.internal.control_data[control.uid].scroll_y or 0

            local index_begin = (scroll_y *
                    (content_bounds.height - rectangle.height)) /
                ugui.standard_styler.params.listbox_item.height

            local index_end = (rectangle.height + (scroll_y *
                    (content_bounds.height - rectangle.height))) /
                ugui.standard_styler.params.listbox_item.height

            index_begin = ugui.internal.clamp(math.floor(index_begin), 1, #control.items)
            index_end = ugui.internal.clamp(math.ceil(index_end), 1, #control.items)

            local x_offset = math.max((content_bounds.width - control.rectangle.width) * scroll_x, 0)

            BreitbandGraphics.push_clip(BreitbandGraphics.inflate_rectangle(rectangle, -1))

            for i = index_begin, index_end, 1 do
                local y_offset = (ugui.standard_styler.params.listbox_item.height * (i - 1)) -
                    (scroll_y * (content_bounds.height - rectangle.height))

                local item_visual_state = ugui.visual_states.normal
                if control.is_enabled == false then
                    item_visual_state = ugui.visual_states.disabled
                end

                if control.selected_index == i then
                    item_visual_state = ugui.visual_states.active
                end

                ugui.standard_styler.draw_list_item(control, control.items[i], {
                    x = rectangle.x - x_offset,
                    y = rectangle.y + y_offset,
                    width = math.max(content_bounds.width, control.rectangle.width),
                    height = ugui.standard_styler.params.listbox_item.height,
                }, item_visual_state)
            end

            BreitbandGraphics.pop_clip()
        end,

        ---Draws a menu frame with the specified parameters.
        ---@param rectangle Rectangle The control's bounds.
        ---@param visual_state VisualState The control's visual state.
        draw_menu_frame = function(rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(rectangle,
                ugui.standard_styler.params.menu.border[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                ugui.standard_styler.params.menu.back[visual_state])
        end,

        ---Draws a menu item with the specified parameters.
        ---@param item MenuItem The menu item.
        ---@param rectangle Rectangle The control's bounds.
        ---@param visual_state VisualState The control's visual state.
        draw_menu_item = function(item, rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(rectangle,
                ugui.standard_styler.params.menu_item.back[visual_state])
            BreitbandGraphics.push_clip({
                x = rectangle.x,
                y = rectangle.y,
                width = rectangle.width,
                height = rectangle.height,
            })

            if item.checked then
                local icon_rect = BreitbandGraphics.inflate_rectangle({
                    x = rectangle.x + (ugui.standard_styler.params.menu_item.left_padding - rectangle.height) * 0.5,
                    y = rectangle.y,
                    width = rectangle.height,
                    height = rectangle.height,
                }, -7)
                ugui.standard_styler.draw_icon(icon_rect, ugui.standard_styler.params.menu_item.height[visual_state], nil, 'checkmark')
            end

            if item.items then
                local icon_rect = BreitbandGraphics.inflate_rectangle({
                    x = rectangle.x + rectangle.width - (ugui.standard_styler.params.menu_item.right_padding),
                    y = rectangle.y,
                    width = ugui.standard_styler.params.menu_item.right_padding,
                    height = rectangle.height,
                }, -7)
                ugui.standard_styler.draw_icon(icon_rect, ugui.standard_styler.params.menu_item.height[visual_state], nil, 'arrow_right')
            end

            local text_rect = {
                x = rectangle.x + ugui.standard_styler.params.menu_item.left_padding,
                y = rectangle.y,
                width = 9999999,
                height = rectangle.height,
            }

            BreitbandGraphics.draw_text2({
                text = item.text,
                rectangle = text_rect,
                color = ugui.standard_styler.params.menu_item.text[visual_state],
                align_x = BreitbandGraphics.alignment.start,
                font_name = ugui.standard_styler.params.font_name,
                font_size = ugui.standard_styler.params.font_size,
                aliased = not ugui.standard_styler.params.cleartype,
            })

            BreitbandGraphics.pop_clip()
        end,

        ---Draws a menu with the specified parameters.
        ---@param control Menu The menu control.
        ---@param rectangle Rectangle The control's bounds.
        draw_menu = function(control, rectangle)
            local visual_state = ugui.get_visual_state(control)
            ugui.standard_styler.draw_menu_frame(rectangle, visual_state)

            local y = rectangle.y

            for i, item in pairs(control.items) do
                local rectangle = BreitbandGraphics.inflate_rectangle({
                    x = rectangle.x,
                    y = y,
                    width = rectangle.width,
                    height = ugui.standard_styler.params.menu_item.height,
                }, -1)

                local visual_state = ugui.visual_states.normal
                if ugui.internal.control_data[control.uid].hovered_index and ugui.internal.control_data[control.uid].hovered_index == i then
                    visual_state = ugui.visual_states.hovered
                end
                if item.enabled == false then
                    visual_state = ugui.visual_states.disabled
                end
                ugui.standard_styler.draw_menu_item(item, rectangle, visual_state)

                y = y + ugui.standard_styler.params.menu_item.height
            end
        end,

        ---Draws a tooltip with the specified parameters.
        ---@param control Control The tooltip's parent control.
        ---@param position Vector2 The tooltip's position.
        ---@param time number The time the user began hovering over the control associated with the tooltip, as returned by os.clock().
        draw_tooltip = function(control, position, time)
            local text = control.tooltip
            if not text then
                return
            end
            if not time then
                return
            end
            if os.clock() - time < ugui.standard_styler.params.tooltip.delay then
                return
            end
            local rectangle = {x = position.x, y = position.y, width = 0, height = 0}
            local size = ugui.standard_styler.compute_rich_text(text, control.plaintext).size

            rectangle.width = size.x
            rectangle.height = math.max(size.y, ugui.standard_styler.params.menu_item.height)
            rectangle.y = rectangle.y + rectangle.height

            if rectangle.x + rectangle.width > ugui.internal.environment.window_size.x then
                rectangle.x = rectangle.x - (rectangle.x + rectangle.width - ugui.internal.environment.window_size.x)
            end
            if rectangle.y + rectangle.height > ugui.internal.environment.window_size.y then
                rectangle.y = rectangle.y - (rectangle.y + rectangle.height - ugui.internal.environment.window_size.y)
            end

            rectangle.x = math.max(rectangle.x, 0)
            rectangle.y = math.max(rectangle.y, 0)

            local fit = false

            if rectangle.width >= ugui.internal.environment.window_size.x then
                fit = true
                rectangle.x = 0
                rectangle.width = ugui.internal.environment.window_size.x
            end

            if rectangle.height >= ugui.internal.environment.window_size.y then
                fit = true
                rectangle.y = 0
                rectangle.height = ugui.internal.environment.window_size.y
            end

            local menu_frame_rect = fit and rectangle or {
                x = rectangle.x - ugui.standard_styler.params.tooltip.padding,
                y = rectangle.y,
                width = rectangle.width + ugui.standard_styler.params.tooltip.padding * 2,
                height = rectangle.height,
            }
            ugui.standard_styler.draw_menu_frame(menu_frame_rect, ugui.visual_states.normal)

            if not fit then
                rectangle.width = 99999
            end

            ugui.standard_styler.draw_rich_text(rectangle, BreitbandGraphics.alignment.start, nil, text, ugui.standard_styler.params.menu_item.text[ugui.visual_states.normal], ugui.visual_states.normal, control.plaintext)
        end,

        ---Draws a Button with the specified parameters.
        ---@param control Button The control table.
        draw_button = function(control)
            local visual_state = ugui.get_visual_state(control)

            -- NOTE: Avoids duplicating code for ToggleButton in this implementation by putting it here
            ---@diagnostic disable-next-line: undefined-field
            if control.is_checked and control.is_enabled ~= false then
                visual_state = ugui.visual_states.active
            end

            ugui.standard_styler.draw_raised_frame(control, visual_state)
            ugui.standard_styler.draw_rich_text(control.rectangle, nil, nil, control.text, ugui.standard_styler.params.button.text[visual_state], visual_state, control.plaintext)
        end,

        ---Draws a ToggleButton with the specified parameters.
        ---@param control ToggleButton The control table.
        draw_togglebutton = function(control)
            ugui.standard_styler.draw_button(control)
        end,

        ---Draws a CarrouselButton with the specified parameters.
        ---@param control CarrouselButton The control table.
        draw_carrousel_button = function(control)
            -- add a "fake" text field
            local copy = ugui.internal.deep_clone(control)
            copy.text = control.items and control.items[control.selected_index] or ''
            ugui.standard_styler.draw_button(copy)

            local visual_state = ugui.get_visual_state(control)

            -- draw the arrows
            ugui.standard_styler.draw_icon({
                x = control.rectangle.x + ugui.standard_styler.params.textbox.padding.x,
                y = control.rectangle.y,
                width = ugui.standard_styler.params.icon_size,
                height = control.rectangle.height,
            }, ugui.standard_styler.params.button.text[visual_state], visual_state, 'arrow_left')
            ugui.standard_styler.draw_icon({
                x = control.rectangle.x + control.rectangle.width - ugui.standard_styler.params.textbox.padding.x -
                    ugui.standard_styler.params.icon_size,
                y = control.rectangle.y,
                width = ugui.standard_styler.params.icon_size,
                height = control.rectangle.height,
            }, ugui.standard_styler.params.button.text[visual_state], visual_state, 'arrow_right')
        end,

        ---Draws a TextBox with the specified parameters.
        ---@param control TextBox The control table.
        draw_textbox = function(control)
            local visual_state = ugui.get_visual_state(control)
            local text = control.text or ''

            if ugui.internal.active_control == control.uid and control.is_enabled ~= false then
                visual_state = ugui.visual_states.active
            end

            ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

            local should_visualize_selection = not (ugui.internal.control_data[control.uid].selection_start == nil) and
                not (ugui.internal.control_data[control.uid].selection_end == nil) and
                control.is_enabled ~= false and
                not (ugui.internal.control_data[control.uid].selection_start == ugui.internal.control_data[control.uid].selection_end)

            if should_visualize_selection then
                local string_to_selection_start = text:sub(1,
                    ugui.internal.control_data[control.uid].selection_start - 1)
                local string_to_selection_end = text:sub(1,
                    ugui.internal.control_data[control.uid].selection_end - 1)

                BreitbandGraphics.fill_rectangle({
                        x = control.rectangle.x +
                            BreitbandGraphics.get_text_size(string_to_selection_start,
                                ugui.standard_styler.params.font_size,
                                ugui.standard_styler.params.font_name)
                            .width + ugui.standard_styler.params.textbox.padding.x,
                        y = control.rectangle.y,
                        width = BreitbandGraphics.get_text_size(string_to_selection_end,
                                ugui.standard_styler.params.font_size,
                                ugui.standard_styler.params.font_name)
                            .width -
                            BreitbandGraphics.get_text_size(string_to_selection_start,
                                ugui.standard_styler.params.font_size,
                                ugui.standard_styler.params.font_name)
                            .width,
                        height = control.rectangle.height,
                    },
                    BreitbandGraphics.hex_to_color('#0078D7'))
            end

            local text_rect = {
                x = control.rectangle.x + ugui.standard_styler.params.textbox.padding.x,
                y = control.rectangle.y,
                width = control.rectangle.width - ugui.standard_styler.params.textbox.padding.x * 2,
                height = control.rectangle.height,
            }

            BreitbandGraphics.draw_text2({
                text = text,
                rectangle = text_rect,
                color = ugui.standard_styler.params.textbox.text[visual_state],
                align_x = BreitbandGraphics.alignment.start,
                align_y = BreitbandGraphics.alignment.start,
                font_name = ugui.standard_styler.params.font_name,
                font_size = ugui.standard_styler.params.font_size,
                clip = true,
                aliased = not ugui.standard_styler.params.cleartype,
            })

            if should_visualize_selection then
                local lower = ugui.internal.control_data[control.uid].selection_start
                local higher = ugui.internal.control_data[control.uid].selection_end
                if ugui.internal.control_data[control.uid].selection_start > ugui.internal.control_data[control.uid].selection_end then
                    lower = ugui.internal.control_data[control.uid].selection_end
                    higher = ugui.internal.control_data[control.uid].selection_start
                end

                local string_to_selection_start = text:sub(1,
                    lower - 1)
                local string_to_selection_end = text:sub(1,
                    higher - 1)

                local selection_start_x = control.rectangle.x +
                    BreitbandGraphics.get_text_size(string_to_selection_start,
                        ugui.standard_styler.params.font_size,
                        ugui.standard_styler.params.font_name).width +
                    ugui.standard_styler.params.textbox.padding.x

                local selection_end_x = control.rectangle.x +
                    BreitbandGraphics.get_text_size(string_to_selection_end,
                        ugui.standard_styler.params.font_size,
                        ugui.standard_styler.params.font_name).width +
                    ugui.standard_styler.params.textbox.padding.x

                BreitbandGraphics.push_clip({
                    x = selection_start_x,
                    y = control.rectangle.y,
                    width = selection_end_x - selection_start_x,
                    height = control.rectangle.height,
                })

                local text_rect = {
                    x = control.rectangle.x + ugui.standard_styler.params.textbox.padding.x,
                    y = control.rectangle.y,
                    width = control.rectangle.width - ugui.standard_styler.params.textbox.padding.x * 2,
                    height = control.rectangle.height,
                }

                BreitbandGraphics.draw_text2({
                    text = text,
                    rectangle = text_rect,
                    color = BreitbandGraphics.invert_color(ugui.standard_styler.params.textbox.text[visual_state]),
                    align_x = BreitbandGraphics.alignment.start,
                    align_y = BreitbandGraphics.alignment.start,
                    font_name = ugui.standard_styler.params.font_name,
                    font_size = ugui.standard_styler.params.font_size,
                    clip = true,
                    aliased = not ugui.standard_styler.params.cleartype,
                })

                BreitbandGraphics.pop_clip()
            end


            local string_to_caret = text:sub(1, ugui.internal.control_data[control.uid].caret_index - 1)
            local caret_x = BreitbandGraphics.get_text_size(string_to_caret,
                    ugui.standard_styler.params.font_size,
                    ugui.standard_styler.params.font_name).width +
                ugui.standard_styler.params.textbox.padding.x

            if visual_state == ugui.visual_states.active and math.floor(os.clock() * 2) % 2 == 0 and not should_visualize_selection then
                BreitbandGraphics.draw_line({
                    x = control.rectangle.x + caret_x,
                    y = control.rectangle.y + 2,
                }, {
                    x = control.rectangle.x + caret_x,
                    y = control.rectangle.y +
                        math.max(15,
                            BreitbandGraphics.get_text_size(string_to_caret, 12,
                                ugui.standard_styler.params.font_name)
                            .height), -- TODO: move text measurement into BreitbandGraphics
                }, {
                    r = 0,
                    g = 0,
                    b = 0,
                }, 1)
            end
        end,

        ---Draws a Joystick with the specified parameters.
        ---@param control Joystick The control table.
        draw_joystick = function(control)
            local visual_state = ugui.get_visual_state(control)
            local x = control.position and control.position.x or 0
            local y = control.position and control.position.y or 0
            local mag = control.mag or 0

            -- joystick has no hover or active states
            if not (visual_state == ugui.visual_states.disabled) then
                visual_state = ugui.visual_states.normal
            end

            ugui.standard_styler.draw_raised_frame(control, visual_state)
            ugui.standard_styler.draw_joystick_inner(control.rectangle, visual_state, {
                x = ugui.internal.remap(ugui.internal.clamp(x, -128, 128), -128, 128,
                    control.rectangle.x, control.rectangle.x + control.rectangle.width),
                y = ugui.internal.remap(ugui.internal.clamp(y, -128, 128), -128, 128,
                    control.rectangle.y, control.rectangle.y + control.rectangle.height),
                r = ugui.internal.remap(ugui.internal.clamp(mag, 0, 128), 0, 128, 0,
                    math.min(control.rectangle.width, control.rectangle.height)),
            })
        end,
        draw_track = function(control, visual_state, is_horizontal)
            local track_rectangle = {}
            if not is_horizontal then
                track_rectangle = {
                    x = control.rectangle.x + control.rectangle.width / 2 -
                        ugui.standard_styler.params.trackbar.track_thickness / 2,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.params.trackbar.track_thickness,
                    height = control.rectangle.height,
                }
            else
                track_rectangle = {
                    x = control.rectangle.x,
                    y = control.rectangle.y + control.rectangle.height / 2 -
                        ugui.standard_styler.params.trackbar.track_thickness / 2,
                    width = control.rectangle.width,
                    height = ugui.standard_styler.params.trackbar.track_thickness,
                }
            end

            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(track_rectangle, 1),
                ugui.standard_styler.params.trackbar.border[visual_state])
            BreitbandGraphics.fill_rectangle(track_rectangle,
                ugui.standard_styler.params.trackbar.back[visual_state])
        end,

        ---Draws a Trackbar's thumb with the specified parameters.
        ---@param control Trackbar The control table.
        ---@param visual_state VisualState The control's visual state.
        ---@param is_horizontal boolean Whether the trackbar is horizontal.
        ---@param value number The trackbar's value.
        draw_thumb = function(control, visual_state, is_horizontal, value)
            local head_rectangle = {}
            local effective_bar_height = math.min(
                (is_horizontal and control.rectangle.height or control.rectangle.width) * 2,
                ugui.standard_styler.params.trackbar.bar_height)
            if not is_horizontal then
                head_rectangle = {
                    x = control.rectangle.x + control.rectangle.width / 2 -
                        effective_bar_height / 2,
                    y = control.rectangle.y + (value * control.rectangle.height) -
                        ugui.standard_styler.params.trackbar.bar_width / 2,
                    width = effective_bar_height,
                    height = ugui.standard_styler.params.trackbar.bar_width,
                }
            else
                head_rectangle = {
                    x = control.rectangle.x + (value * control.rectangle.width) -
                        ugui.standard_styler.params.trackbar.bar_width / 2,
                    y = control.rectangle.y + control.rectangle.height / 2 -
                        effective_bar_height / 2,
                    width = ugui.standard_styler.params.trackbar.bar_width,
                    height = effective_bar_height,
                }
            end
            BreitbandGraphics.fill_rectangle(head_rectangle,
                ugui.standard_styler.params.trackbar.thumb[visual_state])
        end,

        ---Draws a Trackbar with the specified parameters.
        ---@param control Trackbar The control table.
        draw_trackbar = function(control)
            local visual_state = ugui.get_visual_state(control)

            if ugui.internal.active_control == control.uid and control.is_enabled ~= false then
                visual_state = ugui.visual_states.active
            end

            local is_horizontal = control.rectangle.width > control.rectangle.height

            ugui.standard_styler.draw_track(control, visual_state, is_horizontal)
            ugui.standard_styler.draw_thumb(control, visual_state, is_horizontal, control
                .value)
        end,

        ---Draws a ComboBox with the specified parameters.
        ---@param control ComboBox The control table.
        draw_combobox = function(control)
            local visual_state = ugui.get_visual_state(control)
            local selected_item = control.items and (control.selected_index and control.items[control.selected_index] or '') or ''

            if ugui.internal.control_data[control.uid].is_open and control.is_enabled ~= false then
                visual_state = ugui.visual_states.active
            end

            ugui.standard_styler.draw_raised_frame(control, visual_state)

            local text_color = ugui.standard_styler.params.button.text[visual_state]

            local text_rect = {
                x = control.rectangle.x + ugui.standard_styler.params.textbox.padding.x * 2,
                y = control.rectangle.y,
                width = control.rectangle.width,
                height = control.rectangle.height,
            }

            ugui.standard_styler.draw_rich_text(text_rect, BreitbandGraphics.alignment.start, nil, selected_item, text_color, visual_state, control.plaintext)
            ugui.standard_styler.draw_icon({
                x = control.rectangle.x + control.rectangle.width - ugui.standard_styler.params.icon_size - ugui.standard_styler.params.textbox.padding.x * 2,
                y = control.rectangle.y,
                width = ugui.standard_styler.params.icon_size,
                height = control.rectangle.height,
            }, text_color, visual_state, 'arrow_down')
        end,

        ---Draws a ListBox with the specified parameters.
        ---@param control ListBox The control table.
        draw_listbox = function(control)
            ugui.standard_styler.draw_list(control, control.rectangle)
        end,

        ---Gets the desired bounds of a listbox's content.
        ---@param control table A table abiding by the mupen-lua-ugui control contract
        ---@return _ table A rectangle specifying the desired bounds of the content as `{x = 0, y = 0, width: number, height: number}`.
        get_desired_listbox_content_bounds = function(control)
            -- Since horizontal content bounds measuring is expensive, we only do this if explicitly enabled.
            local max_width = 0
            if control.horizontal_scroll == true then
                for _, value in pairs(control.items) do
                    local width = BreitbandGraphics.get_text_size(value, ugui.standard_styler.params.font_size,
                        ugui.standard_styler.params.font_name).width

                    if width > max_width then
                        max_width = width
                    end
                end
            end

            return {
                x = 0,
                y = 0,
                width = max_width,
                height = ugui.standard_styler.params.listbox_item.height * (control.items and #control.items or 0),
            }
        end,
    },

    ---Begins a new frame.
    ---@param environment Environment The environment for the current frame.
    begin_frame = function(environment)
        if ugui.internal.frame_in_progress then
            error('Tried to call begin_frame() while a frame is already in progress. End the previous frame with end_frame() before starting a new one.')
        end

        ugui.internal.frame_in_progress = true

        if not ugui.internal.environment then
            ugui.internal.environment = environment
        end
        if not environment.window_size then
            -- Assume unbounded window size if user is too lazy to provide one
            environment.window_size = {x = math.maxinteger, y = math.maxinteger}
        end
        ugui.internal.previous_environment = ugui.internal.deep_clone(ugui.internal
            .environment)
        ugui.internal.environment = ugui.internal.deep_clone(environment)

        if ugui.internal.is_mouse_just_down() then
            ugui.internal.mouse_down_position = ugui.internal.environment.mouse_position
        end
    end,

    --- Ends the current frame.
    end_frame = function()
        if not ugui.internal.frame_in_progress then
            error("Tried to call end_frame() while a frame wasn't already in progress. Start a frame with begin_frame() before ending an in-progress one.")
        end

        for i = 1, #ugui.internal.late_callbacks, 1 do
            ugui.internal.late_callbacks[i]()
        end

        ugui.internal.late_callbacks = {}
        ugui.internal.hittest_free_rects = {}
        ugui.internal.used_uids = {}
        ugui.internal.last_control_rectangle = nil

        if not ugui.internal.environment.is_primary_down and ugui.internal.clear_active_control_after_mouse_up then
            ugui.internal.active_control = nil
        end

        ugui.internal.frame_in_progress = false
    end,

    ---Pushes a layout section to the layout stack.
    ---@param layout LayoutSection The layout section.
    push = function(layout)
        if not layout.rectangle then
            layout.rectangle = ugui.internal.last_control_rectangle
        else
            local rect = ugui.internal.last_control_rectangle or {x = 0, y = 0, width = 0, height = 0}
            layout.rectangle.x = layout.rectangle.x ~= nil and layout.rectangle.x or rect.x
            layout.rectangle.y = layout.rectangle.y ~= nil and layout.rectangle.y or rect.y
            layout.rectangle.width = layout.rectangle.width ~= nil and layout.rectangle.width or rect.width
            layout.rectangle.height = layout.rectangle.height ~= nil and layout.rectangle.height or rect.height
        end

        ugui.internal.layout_stack[#ugui.internal.layout_stack + 1] = layout
    end,

    ---Pushes a StackPanel layout section to the layout stack.
    ---@param layout StackPanel The layout section.
    push_stackpanel = function(layout)
        layout.compute_control_rectangle = ugui.layout_computation_functions['StackPanel']

        ugui.push(layout)
    end,

    ---Pops the most recent layout section off the layout stack.
    pop = function()
        if #ugui.internal.layout_stack == 0 then
            error('Tried to pop() from an empty layout stack. Note that every layout section pushed to the layout stack needs to be popped off the stack before the end of the frame.')
        end
        table.remove(ugui.internal.layout_stack, #ugui.internal.layout_stack)
    end,

    ---Places a Button.
    ---@param control Button The control table.
    ---@return boolean # Whether the button has been pressed.
    button = function(control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(control)

        local pushed = ugui.internal.process_push(control)
        ugui.standard_styler.draw_button(control)

        ugui.internal.handle_tooltip(control)
        return pushed
    end,

    ---Places a ToggleButton.
    ---@param control ToggleButton The control table.
    ---@return boolean # The new check state.
    toggle_button = function(control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(control)

        local pushed = ugui.internal.process_push(control)
        ugui.standard_styler.draw_togglebutton(control)

        if pushed then
            return not control.is_checked
        end

        ugui.internal.handle_tooltip(control)
        return control.is_checked
    end,

    ---Places a CarrouselButton.
    ---@param control CarrouselButton The control table.
    ---@return integer # The new selected index.
    carrousel_button = function(control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(control)

        local pushed = ugui.internal.process_push(control)
        local selected_index = control.selected_index

        if pushed then
            local relative_x = ugui.internal.environment.mouse_position.x - control.rectangle.x
            if relative_x > control.rectangle.width / 2 then
                selected_index = selected_index + 1
                if selected_index > #control.items then
                    selected_index = 1
                end
            else
                selected_index = selected_index - 1
                if selected_index < 1 then
                    selected_index = #control.items
                end
            end
        end

        ugui.standard_styler.draw_carrousel_button(control)

        ugui.internal.handle_tooltip(control)
        return control.items and ugui.internal.clamp(selected_index, 1, #control.items) or nil
    end,

    ---Places a TextBox.
    ---@param control TextBox The control table.
    ---@return string # The new text.
    textbox = function(control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(control)

        ugui.internal.control_data[control.uid] = ugui.internal.control_data[control.uid] or {}
        if ugui.internal.control_data[control.uid].caret_index == nil then
            ugui.internal.control_data[control.uid].caret_index = 1
        end
        if ugui.internal.control_data[control.uid].caret_index == nil then
            ugui.internal.control_data[control.uid].caret_index = 1
        end

        local pushed = ugui.internal.process_push(control)
        local text = control.text or ''

        if pushed then
            ugui.internal.clear_active_control_after_mouse_up = false
        end

        -- if active and user clicks elsewhere, deactivate
        if ugui.internal.active_control == control.uid
            and not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
            if ugui.internal.is_mouse_just_down() then
                -- deactivate, then clear selection
                ugui.internal.active_control = nil
                ugui.internal.control_data[control.uid].selection_start = nil
                ugui.internal.control_data[control.uid].selection_end = nil
            end
        end


        local function sel_hi()
            return math.max(ugui.internal.control_data[control.uid].selection_start,
                ugui.internal.control_data[control.uid].selection_end)
        end

        local function sel_lo()
            return math.min(ugui.internal.control_data[control.uid].selection_start,
                ugui.internal.control_data[control.uid].selection_end)
        end


        if ugui.internal.active_control == control.uid and control.is_enabled ~= false then
            local theoretical_caret_index = ugui.internal.get_caret_index(text,
                ugui.internal.environment.mouse_position.x - control.rectangle.x)

            -- start a new selection
            if ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                ugui.internal.control_data[control.uid].caret_index = theoretical_caret_index
                ugui.internal.control_data[control.uid].selection_start = theoretical_caret_index
            end

            -- already has selection, move end to appropriate index
            if ugui.internal.environment.is_primary_down and BreitbandGraphics.is_point_inside_rectangle(ugui.internal.mouse_down_position, control.rectangle) then
                ugui.internal.control_data[control.uid].selection_end = theoretical_caret_index
            end

            local just_pressed_keys = ugui.internal.get_just_pressed_keys()
            local has_selection = ugui.internal.control_data[control.uid].selection_start ~=
                ugui.internal.control_data[control.uid].selection_end

            for key, _ in pairs(just_pressed_keys) do
                local result = ugui.internal.handle_special_key(key, has_selection, control.text,
                    ugui.internal.control_data[control.uid].selection_start,
                    ugui.internal.control_data[control.uid].selection_end,
                    ugui.internal.control_data[control.uid].caret_index)


                -- special key press wasn't handled, we proceed to just insert the pressed character (or replace the selection)
                if not result.handled then
                    if #key ~= 1 then
                        goto continue
                    end

                    if has_selection then
                        local lower_selection = sel_lo()
                        text = ugui.internal.remove_range(text, sel_lo(), sel_hi())
                        ugui.internal.control_data[control.uid].caret_index = lower_selection
                        ugui.internal.control_data[control.uid].selection_start = lower_selection
                        ugui.internal.control_data[control.uid].selection_end = lower_selection
                        text = ugui.internal.insert_at(text, key,
                            ugui.internal.control_data[control.uid].caret_index - 1)
                        ugui.internal.control_data[control.uid].caret_index = ugui.internal
                            .control_data[control.uid]
                            .caret_index + 1
                    else
                        text = ugui.internal.insert_at(text, key,
                            ugui.internal.control_data[control.uid].caret_index - 1)
                        ugui.internal.control_data[control.uid].caret_index = ugui.internal
                            .control_data[control.uid]
                            .caret_index + 1
                    end

                    goto continue
                end

                ugui.internal.control_data[control.uid].caret_index = result.caret_index
                ugui.internal.control_data[control.uid].selection_start = result.selection_start
                ugui.internal.control_data[control.uid].selection_end = result.selection_end
                text = result.text

                ::continue::
            end
        end

        ugui.internal.control_data[control.uid].caret_index = ugui.internal.clamp(
            ugui.internal.control_data[control.uid].caret_index, 1, #text + 1)

        ugui.standard_styler.draw_textbox(control)
        ugui.internal.handle_tooltip(control)
        return text
    end,

    ---Places a Joystick.
    ---@param control Joystick The control table.
    ---@return Vector2 # The joystick's new position.
    joystick = function(control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(control)

        ugui.standard_styler.draw_joystick(control)

        local position = control.position and ugui.internal.deep_clone(control.position) or {x = 0, y = 0}

        local pushed = ugui.internal.process_push(control)
        local ignored = BreitbandGraphics.is_point_inside_any_rectangle(
                ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects) and
            not control.topmost

        if ugui.internal.active_control == control.uid and not ignored then
            position.x = ugui.internal.clamp(
                ugui.internal.remap(ugui.internal.environment.mouse_position.x - control.rectangle.x, 0,
                    control.rectangle.width, -128, 128), -128, 128)
            position.y = ugui.internal.clamp(
                ugui.internal.remap(ugui.internal.environment.mouse_position.y - control.rectangle.y, 0,
                    control.rectangle.height, -128, 128), -128, 128)
        end

        ugui.internal.handle_tooltip(control)
        return position
    end,

    ---Places a Trackbar.
    ---@param control Trackbar The control table.
    ---@return number # The trackbar's new value.
    trackbar = function(control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(control)

        ugui.internal.control_data[control.uid] = ugui.internal.control_data[control.uid] or {}
        if ugui.internal.control_data[control.uid].active == nil then
            ugui.internal.control_data[control.uid].active = false
        end

        local pushed = ugui.internal.process_push(control)
        local value = control.value

        if ugui.internal.active_control == control.uid then
            if control.rectangle.width > control.rectangle.height then
                value = ugui.internal.clamp(
                    (ugui.internal.environment.mouse_position.x - control.rectangle.x) /
                    control.rectangle.width,
                    0, 1)
            else
                value = ugui.internal.clamp(
                    (ugui.internal.environment.mouse_position.y - control.rectangle.y) /
                    control.rectangle.height,
                    0, 1)
            end
        end

        ugui.standard_styler.draw_trackbar(control)

        ugui.internal.handle_tooltip(control)
        return value
    end,

    ---Places a ComboBox.
    ---@param control ComboBox The control table.
    ---@return integer # The new selected index.
    combobox = function(control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(control)

        ugui.internal.control_data[control.uid] = ugui.internal.control_data[control.uid] or {}
        if ugui.internal.control_data[control.uid].is_open == nil then
            ugui.internal.control_data[control.uid].is_open = false
        end
        if ugui.internal.control_data[control.uid].hovered_index == nil then
            ugui.internal.control_data[control.uid].hovered_index = control.selected_index
        end

        if control.is_enabled == false then
            ugui.internal.control_data[control.uid].is_open = false
        end

        if ugui.internal.is_mouse_just_down() and control.is_enabled ~= false then
            if BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                ugui.internal.control_data[control.uid].is_open = not ugui.internal.control_data
                    [control.uid].is_open
            else
                local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)
                if not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, {
                        x = control.rectangle.x,
                        y = control.rectangle.y + control.rectangle.height,
                        width = control.rectangle.width,
                        height = content_bounds.height,
                    }) then
                    ugui.internal.control_data[control.uid].is_open = false
                end
            end
        end

        local selected_index = control.selected_index

        if ugui.internal.control_data[control.uid].is_open and control.is_enabled ~= false then
            local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)

            local list_rect = {
                x = control.rectangle.x,
                y = control.rectangle.y + control.rectangle.height,
                width = control.rectangle.width,
                height = content_bounds.height,
            }
            ugui.internal.hittest_free_rects[#ugui.internal.hittest_free_rects + 1] = list_rect

            selected_index = ugui.listbox({
                uid = control.uid + 1,
                -- we tell the listbox to paint itself at the end of the frame, because we need it on top of all other controls
                topmost = true,
                rectangle = list_rect,
                items = control.items,
                selected_index = selected_index,
                plaintext = control.plaintext,
            })
        end

        ugui.standard_styler.draw_combobox(control)

        ugui.internal.handle_tooltip(control)
        return selected_index
    end,

    ---Places a ListBox.
    ---@param control ListBox The control table.
    ---@return integer # The new selected index.
    listbox = function(_control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(_control)

        ugui.internal.control_data[_control.uid] = ugui.internal.control_data[_control.uid] or {}
        if ugui.internal.control_data[_control.uid].scroll_x == nil then
            ugui.internal.control_data[_control.uid].scroll_x = 0
        end
        if ugui.internal.control_data[_control.uid].scroll_y == nil then
            ugui.internal.control_data[_control.uid].scroll_y = 0
        end

        local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(_control)
        local x_overflow = content_bounds.width > _control.rectangle.width
        local y_overflow = content_bounds.height > _control.rectangle.height

        local new_rectangle = ugui.internal.deep_clone(_control.rectangle)
        if x_overflow then
            new_rectangle.height = new_rectangle.height - ugui.standard_styler.params.scrollbar.thickness
        end
        if y_overflow then
            new_rectangle.width = new_rectangle.width - ugui.standard_styler.params.scrollbar.thickness
        end

        -- we need to adjust rectangle to fit scrollbars
        local control = ugui.internal.deep_clone(_control)
        control.rectangle = new_rectangle

        local pushed = ugui.internal.process_push(control)
        local ignored = BreitbandGraphics.is_point_inside_any_rectangle(
                ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects) and
            not control.topmost

        if ugui.internal.active_control == control.uid and not ignored then
            local relative_y = ugui.internal.environment.mouse_position.y - control.rectangle.y
            local new_index = math.ceil((relative_y + (ugui.internal.control_data[control.uid].scroll_y *
                    ((ugui.standard_styler.params.listbox_item.height * #control.items) - control.rectangle.height))) /
                ugui.standard_styler.params.listbox_item.height)
            -- we only assign the new index if it's within bounds, as
            -- this emulates windows commctl behaviour
            if new_index <= #control.items then
                control.selected_index = ugui.internal.clamp(new_index, 1, #control.items)
            end
        end

        if not ignored
            and (BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle)
                or ugui.internal.active_control == control.uid) then
            for key, _ in pairs(ugui.internal.get_just_pressed_keys()) do
                if key == 'up' and control.selected_index ~= nil then
                    control.selected_index = ugui.internal.clamp(control.selected_index - 1, 1, #control.items)
                end
                if key == 'down' and control.selected_index ~= nil then
                    control.selected_index = ugui.internal.clamp(control.selected_index + 1, 1, #control.items)
                end
                if not y_overflow then
                    if key == 'pageup' or key == 'home' then
                        control.selected_index = 1
                    end
                    if key == 'pagedown' or key == 'end' then
                        control.selected_index = #control.items
                    end
                end
            end
        end

        if not ignored
            and y_overflow
            and (BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle)
                or ugui.internal.active_control == control.uid) then
            local inc = 0
            if ugui.internal.is_mouse_wheel_up() then
                inc = -1 / #control.items
            end
            if ugui.internal.is_mouse_wheel_down() then
                inc = 1 / #control.items
            end

            for key, _ in pairs(ugui.internal.get_just_pressed_keys()) do
                if key == 'pageup' then
                    inc = -math.floor(control.rectangle.height / ugui.standard_styler.params.listbox_item.height) / #control.items
                end
                if key == 'pagedown' then
                    inc = math.floor(control.rectangle.height / ugui.standard_styler.params.listbox_item.height) / #control.items
                end
                if key == 'home' then
                    inc = -1
                end
                if key == 'end' then
                    inc = 1
                end
            end

            ugui.internal.control_data[control.uid].scroll_y = ugui.internal.clamp(
                ugui.internal.control_data[control.uid].scroll_y + inc, 0, 1)
        end


        if x_overflow then
            ugui.internal.control_data[control.uid].scroll_x = ugui.scrollbar({
                uid = control.uid + 1,
                is_enabled = control.is_enabled,
                rectangle = {
                    x = control.rectangle.x,
                    y = control.rectangle.y + control.rectangle.height,
                    width = control.rectangle.width,
                    height = ugui.standard_styler.params.scrollbar.thickness,
                },
                value = ugui.internal.control_data[control.uid].scroll_x,
                ratio = 1 / (content_bounds.width / control.rectangle.width),
            })
        end

        if y_overflow then
            ugui.internal.control_data[control.uid].scroll_y = ugui.scrollbar({
                uid = control.uid + 2,
                is_enabled = control.is_enabled,
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.params.scrollbar.thickness,
                    height = control.rectangle.height,
                },
                value = ugui.internal.control_data[control.uid].scroll_y,
                ratio = 1 / (content_bounds.height / control.rectangle.height),
            })
        end

        if control.topmost then
            ugui.internal.late_callbacks[#ugui.internal.late_callbacks + 1] = function()
                ugui.standard_styler.draw_listbox(control)
            end
        else
            ugui.standard_styler.draw_listbox(control)
        end

        ugui.internal.handle_tooltip(control)
        return control.selected_index
    end,

    ---Places a ScrollBar.
    ---@param control ScrollBar The control table.
    ---@return number # The new value.
    scrollbar = function(control)
        ugui.internal.do_layout(control)
        ugui.internal.validate_and_register_control(control)

        local pushed = ugui.internal.process_push(control)
        local is_horizontal = control.rectangle.width > control.rectangle.height

        -- if active and user clicks elsewhere, deactivate
        if ugui.internal.active_control == control.uid then
            if not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                if ugui.internal.is_mouse_just_down() then
                    -- deactivate, then clear selection
                    ugui.internal.active_control = nil
                end
            end
        end

        if ugui.internal.active_control == control.uid and control.is_enabled ~= false and ugui.internal.environment.is_primary_down then
            local relative_mouse = {
                x = ugui.internal.environment.mouse_position.x - control.rectangle.x,
                y = ugui.internal.environment.mouse_position.y - control.rectangle.y,
            }
            local relative_mouse_down = {
                x = ugui.internal.mouse_down_position.x - control.rectangle.x,
                y = ugui.internal.mouse_down_position.y - control.rectangle.y,
            }
            local current
            local start
            if is_horizontal then
                current = relative_mouse.x / control.rectangle.width
                start = relative_mouse_down.x / control.rectangle.width
            else
                current = relative_mouse.y / control.rectangle.height
                start = relative_mouse_down.y / control.rectangle.height
            end
            control.value = ugui.internal.clamp(start + (current - start), 0, 1)
        end

        local thumb_rectangle
        -- we center the scrollbar around the translation value, and shrink it accordingly
        if is_horizontal then
            local scrollbar_width = control.rectangle.width * control.ratio
            local scrollbar_x = ugui.internal.remap(control.value, 0, 1, 0, control.rectangle.width - scrollbar_width)
            thumb_rectangle = {
                x = control.rectangle.x + scrollbar_x,
                y = control.rectangle.y,
                width = scrollbar_width,
                height = control.rectangle.height,
            }
        else
            local scrollbar_height = control.rectangle.height * control.ratio
            local scrollbar_y = ugui.internal.remap(control.value, 0, 1, 0, control.rectangle.height - scrollbar_height)
            thumb_rectangle = {
                x = control.rectangle.x,
                y = control.rectangle.y + scrollbar_y,
                width = control.rectangle.width,
                height = scrollbar_height,
            }
        end

        local visual_state = ugui.get_visual_state(control)
        if ugui.internal.active_control == control.uid and control.is_enabled ~= false and ugui.internal.environment.is_primary_down then
            visual_state = ugui.visual_states.active
        end
        ugui.standard_styler.draw_scrollbar(control.rectangle, thumb_rectangle, visual_state)

        ugui.internal.handle_tooltip(control)
        return control.value
    end,

    ---Places a Menu.
    ---@param control Menu The control table.
    ---@return MenuResult # The menu result.
    menu = function(control)
        -- Avoid tripping the control validation... it's going to be overwritten anyway
        if control.rectangle and not control.rectangle.width then
            control.rectangle.width = 0
        end
        if control.rectangle and not control.rectangle.height then
            control.rectangle.height = 0
        end

        -- NOTE: Menus are exempt from the layout engine.
        ugui.internal.validate_and_register_control(control)

        if not ugui.internal.control_data[control.uid] then
            print('Top-level menu')
            ugui.internal.control_data[control.uid] = {
                hovered_index = nil,
                parent_rectangle = nil,
            }
        end

        -- We adjust the dimensions with what should fit the content
        local max_text_width = 0
        for _, item in pairs(control.items) do
            local size = BreitbandGraphics.get_text_size(item.text, ugui.standard_styler.params.font_size, ugui.standard_styler.params.font_name)
            if size.width > max_text_width then
                max_text_width = size.width
            end
        end

        control.rectangle.width = max_text_width + ugui.standard_styler.params.menu_item.left_padding + ugui.standard_styler.params.menu_item.right_padding
        control.rectangle.height = #control.items * ugui.standard_styler.params.menu_item.height

        -- Overflow avoidance: shift the X/Y position to avoid going out of bounds
        if control.rectangle.x + control.rectangle.width > ugui.internal.environment.window_size.x then
            local parent_rect = ugui.internal.control_data[control.uid].parent_rectangle
            -- If the menu has a parent and there's an overflow on the X axis, try snaking out of the situation by moving left of the menu
            if parent_rect then
                control.rectangle.x = parent_rect.x - control.rectangle.width + ugui.standard_styler.params.menu.overlap_size
            else
                control.rectangle.x = control.rectangle.x - (control.rectangle.x + control.rectangle.width - ugui.internal.environment.window_size.x)
            end
        end
        if control.rectangle.y + control.rectangle.height > ugui.internal.environment.window_size.y then
            control.rectangle.y = control.rectangle.y - (control.rectangle.y + control.rectangle.height - ugui.internal.environment.window_size.y)
        end

        local result = {
            item = nil,
            dismissed = false,
        }

        local mouse_inside_control = BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle)

        if control.is_enabled ~= false then
            ugui.internal.hittest_free_rects[#ugui.internal.hittest_free_rects + 1] = control.rectangle

            if ugui.internal.is_mouse_just_down() and not mouse_inside_control then
                -- This path is also reached when a subitem is clicked, so we'll delay clearing the hover indicies until the submenu has also given a result
                result.dismissed = true
            end

            if mouse_inside_control then
                local i = math.floor((ugui.internal.environment.mouse_position.y - control.rectangle.y) / ugui.standard_styler.params.menu_item.height) + 1
                local item = control.items[i]

                ugui.internal.control_data[control.uid].hovered_index = i

                if ugui.internal.is_mouse_just_up() then
                    if (item.enabled == nil or item.enabled == true) and (item.items == nil or #item.items == 0) then
                        result.item = item
                    end
                end
            end

            if ugui.internal.control_data[control.uid].hovered_index ~= nil then
                local i = ugui.internal.control_data[control.uid].hovered_index
                local item = control.items[i]
                if item.items and (item.enabled == nil or item.enabled == true) then
                    local submenu_uid = control.uid + 1

                    if not ugui.internal.control_data[submenu_uid] then
                        ugui.internal.control_data[submenu_uid] = {
                            hovered_index = nil,
                            parent_rectangle = ugui.internal.deep_clone(control.rectangle),
                        }
                    end

                    local submenu_result = ugui.menu({
                        uid = submenu_uid,
                        rectangle = {
                            x = control.rectangle.x + control.rectangle.width - ugui.standard_styler.params.menu.overlap_size,
                            y = control.rectangle.y + ((i - 1) * ugui.standard_styler.params.menu_item.height),
                            width = nil,
                            height = nil,
                        },
                        items = item.items,
                    })

                    if submenu_result.item then
                        result.dismissed = false
                        result.item = submenu_result.item
                    end
                end
            end
        end

        if result.dismissed or result.item then
            -- We need to clear the hover index or all menus in this tree, which means a massively annoying tree traversal
            local function clear_hover_index_for_menu(uid, items)
                if ugui.internal.control_data[uid] and ugui.internal.control_data[uid].hovered_index then
                    ugui.internal.control_data[uid].hovered_index = nil
                end
                for _, item in pairs(items) do
                    if item.items then
                        clear_hover_index_for_menu(uid + 1, item.items)
                    end
                end
            end
            clear_hover_index_for_menu(control.uid, control.items)
        end

        -- Menus are late-drawn, but in reverse order since submenus must overlap and draw over the parent
        table.insert(ugui.internal.late_callbacks, 1, function()
            ugui.standard_styler.draw_menu(control, control.rectangle)
        end)

        return result
    end,
}
