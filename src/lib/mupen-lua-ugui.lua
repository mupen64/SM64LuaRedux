local ugui = {
    _VERSION = 'v2.0.0',
    _URL = 'https://github.com/Aurumaker72/mupen-lua-ugui',
    _DESCRIPTION = 'Flexible immediate-mode GUI library for Mupen Lua',
    _LICENSE = 'GPL-3',
    DEBUG = false,
}

if not BreitbandGraphics then
    error('BreitbandGraphics must be present in the global scope as \'BreitbandGraphics\' prior to executing ugui', 0)
    return
end

--#region Types

---@alias UID number
---Unique identifier for a control. Must be unique within a frame.

---@alias RichText string
---Text which can contain other inline elements, such as icons.
---
---Examples:
---
---    [icon:arrow_left] Go Back
---    Move up [icon:arrow_up]
---    Down [icon:arrow_down:#FFFF00]
---    [icon:arrow_right:textbox.selection] Go Forward
---    Hello World!

---@alias RichTextSegment { type: ["text"|"icon"], value: string, color: string? }
---Represents a computed segment from a rich text string.

---@class Environment
---@field public mouse_position { x: number, y: number } The mouse position.
---@field public wheel number The mouse wheel delta.
---@field public is_primary_down boolean? Whether the primary mouse button is being pressed.
---@field public held_keys table<string, boolean> A map of held key identifiers to booleans. A key not being present or its value being 'false' means it is not held.
---@field public window_size { x: number, y: number }? The rendering bounds. If nil, no rendering bounds are considered and certain controls, such as menus, might overflow off-screen.

---@class Control
---@field public uid UID The unique identifier of the control.
---@field public rectangle Rectangle The rectangle in which the control is drawn.
---@field public is_enabled boolean? Whether the control is enabled. If nil or true, the control is enabled.
---@field public tooltip string? The control's tooltip. If nil, no tooltip will be shown.
---@field package plaintext boolean? Whether the control's text content is drawn as plain text without rich rendering.
---@field package z_index integer? The control's Z-index. If nil, `0` is assumed.
---The base class for all controls.

---@class Button : Control
---@field public text RichText The text displayed on the button.
---A button which can be clicked.

---@class ToggleButton : Button
---@field public is_checked boolean? Whether the button is checked. If nil, the ToggleButton is considered unchecked.
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
---@field public x_snap integer? The snap distance to 0 on the X axis. If nil, no snap will be applied.
---@field public y_snap integer? The snap distance to 0 on the Y axis. If nil, no snap will be applied.
---A joystick which can be interacted with.

---@class Trackbar : Control
---@field public value number The current value in the range 0-1.
---A trackbar which can have its value adjusted.

---@class ComboBox : Control
---@field public items RichText[] The items contained in the control.
---@field public selected_index integer? The index of the currently selected item into the items array. If nil, no item is selected.
---A combobox which allows the user to choose from a list of items.

---@class ListBox : Control
---@field public items RichText[] The items contained in the control.
---@field public selected_index integer? The index of the currently selected item into the items array.
---@field public horizontal_scroll boolean? Whether horizontal scrolling will be enabled when items go beyond the width of the control. Will impact performance greatly, use with care.
---A listbox which allows the user to choose from a list of items.
---If the items don't fit in the control's bounds vertically, vertical scrolling will be enabled.
---If the items don't fit in the control's bounds horizontally, horizontal scrolling will be enabled if horizontal_scroll is true.
---The `rectangle` field might be mutated to accommodate the scrollbars.

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

---@class Spinner : Control
---@field public value number The spinner's numerical value.
---@field public increment number? The increment applied when the + or - buttons are clicked (negated when - is clicked). If nil, 1 is assumed.
---@field public minimum_value number? The minimum value.
---@field public maximum_value number? The maximum value.
---@field public is_horizontal boolean? Whether the increment buttons are stacked horizontally.
---A spinner, consisting of a textbox and buttons for incrementing or decrementing a number.

---@class TabControl : Control
---@field public items RichText[] The tab headers.
---@field public selected_index integer The index of the currently selected tab.
---A tab control, which allows the user to choose from a list of tabs.

---@class TabControlResult
---@field public selected_index integer The index of the selected tab.
---@field public rectangle Rectangle The visual bounds the selected tab can place its contents in.

---@class NumberBox : Control
---@field public value integer The value.
---@field public places integer The amount of digits the value is padded to.
---@field public show_negative boolean? Whether a button for viewing and toggling the value's sign is shown. If nil, false is assumed.
---A numberbox, which allows modifying a number by typing or by adjusting its individual digits.

---@alias ControlType "button" | "toggle_button" | "carrousel_button" | "textbox" | "joystick" | "trackbar" | "listbox" | "scrollbar" | "combobox" | "menu" | "numberbox"

--#endregion

--#region ugui.internal

ugui.internal = {
    ---@alias SceneEntry { control: Control, type: ControlType }

    ---@type SceneEntry[]
    scene = {},

    ---@type table<UID, any>
    ---Map of control UIDs to their data.
    control_data = {},

    ---@type { [UID]: boolean }
    ---Dictionary of all UIDs that were present in the previous frame. Used for dispatching events related to control lifecycles via `dispatch_events`.
    previous_uids = {},

    ---@type Environment
    ---The environment for the current frame.
    environment = nil,

    ---@type Environment
    ---The environment for the previous frame.
    previous_environment = nil,

    ---@type Vector2
    -- The position of the mouse the last time the primary button was pressed.
    mouse_down_position = {x = 0, y = 0},

    ---@type UID?
    ---The control that was clicked this frame.
    clicked_control = nil,

    ---@type UID?
    ---The control that is being hovered over.
    hovered_control = nil,

    ---@type UID?
    ---The control that is currently capturing mouse inputs.
    mouse_captured_control = nil,

    ---@type UID?
    ---The control that is currently capturing keyboard inputs. Synonymous to a "focused" control.
    keyboard_captured_control = nil,

    ---@type number
    ---The most recent time at which `hovered_control` changed, as returned by `os.clock`.
    hover_start_time = 0,

    ---Whether a frame is currently in progress.
    frame_in_progress = false,

    ---Asserts that the specified condition is true, printing the stacktrace if it's false.
    ---@param condition boolean
    ---@param message string
    assert = function(condition, message)
        if condition then
            return
        end
        print(debug.traceback())
        assert(condition, message)
    end,

    ---Sorts controls stably in the scene by their Z-index.
    sort_scene = function()
        ugui.internal.stable_sort(ugui.internal.scene, function(a, b)
            return (a.control.z_index or 0) < (b.control.z_index or 0)
        end)
    end,

    ---Dispatches events related to controls in the scene.
    dispatch_events = function()
        for _, value in pairs(ugui.internal.scene) do
            local existed_in_previous_frame = false
            for uid, _ in pairs(ugui.internal.previous_uids) do
                if value.control.uid == uid then
                    existed_in_previous_frame = true
                    break
                end
            end

            if not existed_in_previous_frame then
                local registry_entry = ugui.registry[value.type]
                if registry_entry.added then
                    registry_entry.added(value.control, ugui.internal.control_data[value.control.uid])
                end
            end
        end
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

    ---Performs an in-place stable sort on the specified table.
    ---@generic T
    ---@param t T[]
    ---@param cmp? fun(a: T, b: T):boolean
    stable_sort = function(t, cmp)
        local function merge(left, right)
            local result = {}
            local i, j = 1, 1

            while i <= #left and j <= #right do
                -- If left < right, or they are "equal" (cmp false both ways),
                -- take from the left to preserve stability
                if cmp(left[i], right[j]) or (not cmp(right[j], left[i])) then
                    table.insert(result, left[i])
                    i = i + 1
                else
                    table.insert(result, right[j])
                    j = j + 1
                end
            end

            while i <= #left do
                table.insert(result, left[i])
                i = i + 1
            end
            while j <= #right do
                table.insert(result, right[j])
                j = j + 1
            end

            return result
        end

        local function mergesort(arr)
            if #arr <= 1 then return arr end
            local mid = math.floor(#arr / 2)
            local left, right = {}, {}
            for i = 1, mid do table.insert(left, arr[i]) end
            for i = mid + 1, #arr do table.insert(right, arr[i]) end
            return merge(mergesort(left), mergesort(right))
        end

        local sorted = mergesort(t)
        for i = 1, #t do
            t[i] = sorted[i]
        end
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

    ---Checks whether the specified point lies inside the control's bounds, considering special cases such as the enabled state, hittest-free and offscreen regions.
    ---@param point Vector2 A point.
    ---@param control Control A control.
    ---@return boolean # Whether the point lies inside the control.
    is_point_inside_control = function(point, control)
        if control.is_enabled == false then
            return false
        end
        if not BreitbandGraphics.is_point_inside_rectangle(point, control.rectangle) then
            return false
        end
        if point.x < 0 or point.x > ugui.internal.environment.window_size.x
            or point.y < 0 or point.y > ugui.internal.environment.window_size.y then
            return false
        end
        return true
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
        local old_digit_value = ugui.internal.get_digit(value, length, index)
        local new_value = value + (digit_value - old_digit_value) * math.pow(10, length - index)
        local max = math.pow(10, length)
        return (new_value + max) % max
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

    ---Shows the tooltip for the currently hovered control.
    tooltip = function()
        if ugui.internal.hovered_control == nil then
            return
        end
        if (os.clock() - ugui.internal.hover_start_time) < ugui.standard_styler.params.tooltip.delay then
            return
        end

        -- Find hovered control
        for _, entry in pairs(ugui.internal.scene) do
            if entry.control.uid == ugui.internal.hovered_control then
                ugui.standard_styler.draw_tooltip(entry.control, {
                    x = ugui.internal.environment.mouse_position.x,
                    y = ugui.internal.environment.mouse_position.y,
                })
            end
        end
    end,

    ---Parses rich text into content segments.
    ---@param text RichText The rich text to parse.
    ---@return RichTextSegment[] # The content segments.
    parse_rich_text = function(text)
        local segments = {}
        local pattern = '(.-)(%[icon:([^%]:]+)(:?([^%]]*))%])'

        local last_pos = 1
        for before_text, full_icon, icon_name, _, color in text:gmatch(pattern) do
            if before_text ~= '' then
                table.insert(segments, {type = 'text', value = before_text})
            end
            if color:find('.') then
                -- The color is a path in standard_styler.params
                local result = ugui.standard_styler.params
                local index = 1
                local keys = {}
                for segment in color:gmatch('([^%.]+)') do
                    keys[#keys + 1] = segment
                end
                while index <= #keys and result do
                    result = result[keys[index]]
                    index = index + 1
                end
                color = result
            end
            table.insert(segments, {type = 'icon', value = icon_name, color = color ~= '' and color or nil})
            last_pos = last_pos + #before_text + #full_icon
        end

        if last_pos <= #text then
            local remaining_text = text:sub(last_pos)
            if remaining_text ~= '' then
                table.insert(segments, {type = 'text', value = remaining_text})
            end
        end

        return segments
    end,

    ---Does core input processing work, such as control capture/hover/click state management.
    do_input_processing = function()
        local function is_point_inside_rectangle(point, rectangle)
            return point.x >= rectangle.x and
                point.y >= rectangle.y and
                point.x <= rectangle.x + rectangle.width and
                point.y <= rectangle.y + rectangle.height
        end

        ---@type Control?
        local clicked_control = nil

        ---@type SceneEntry?
        local mouse_captured_control = nil
        for i = 1, #ugui.internal.scene, 1 do
            local entry = ugui.internal.scene[i]
            if entry.control.uid == ugui.internal.mouse_captured_control then
                mouse_captured_control = entry
            end
        end

        ---@type SceneEntry?
        local keyboard_captured_control = nil
        for i = 1, #ugui.internal.scene, 1 do
            local entry = ugui.internal.scene[i]
            if entry.control.uid == ugui.internal.keyboard_captured_control then
                keyboard_captured_control = entry
            end
        end


        local prev_hovered_control = ugui.internal.hovered_control
        ugui.internal.hovered_control = nil

        for i = #ugui.internal.scene, 1, -1 do
            local entry = ugui.internal.scene[i]
            local control = entry.control

            -- Determine the clicked control if we haven't already
            if clicked_control == nil then
                if ugui.internal.is_mouse_just_down() then
                    if is_point_inside_rectangle(ugui.internal.mouse_down_position, control.rectangle) then
                        clicked_control = control
                        keyboard_captured_control = entry
                        mouse_captured_control = entry
                    end
                end
            end

            -- Determine the hovered control if we haven't already
            if ugui.internal.hovered_control == nil then
                if is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                    ugui.internal.hovered_control = control.uid

                    if ugui.internal.hovered_control ~= prev_hovered_control then
                        ugui.internal.hover_start_time = os.clock()
                    end
                end
            end
        end

        -- Clear the mouse captured control if we released the mouse
        if not ugui.internal.environment.is_primary_down then
            mouse_captured_control = nil
        end

        -- If we have a captured control, the hovered control must be locked to that as well.
        if mouse_captured_control ~= nil then
            ugui.internal.hovered_control = mouse_captured_control.control.uid
        end

        -- If the clicked control is disabled, we clear it now at the end of input processing, effectively "swallowing" the click.
        if clicked_control and clicked_control.is_enabled == false then
            clicked_control = nil
        end

        -- Clear hovered control if it's disabled
        for i = 1, #ugui.internal.scene, 1 do
            local control = ugui.internal.scene[i].control
            if control.uid == ugui.internal.hovered_control
                and control.is_enabled == false then
                ugui.internal.hovered_control = nil
            end
        end

        -- Clear mouse captured control if it's disabled
        if mouse_captured_control and mouse_captured_control.control.is_enabled == false then
            mouse_captured_control = nil
        end

        -- Clear keyboard captured control if it's disabled
        if keyboard_captured_control and keyboard_captured_control.control.is_enabled == false then
            keyboard_captured_control = nil
        end

        ugui.internal.mouse_captured_control = mouse_captured_control and mouse_captured_control.control.uid or nil
        ugui.internal.keyboard_captured_control = keyboard_captured_control and keyboard_captured_control.control.uid or nil
        ugui.internal.clicked_control = clicked_control and clicked_control.uid or nil
    end,
}

--#endregion

--#region Visualisation and Styles

---@enum VisualState
-- The possible states of a control, which are used by the styler for drawing.
ugui.visual_states = {
    --- The control doesn't accept user interactions.
    disabled = 0,
    --- The control isn't being interacted with.
    normal = 1,
    --- The mouse is over the control.
    hovered = 2,
    --- The control is currently capturing inputs.
    active = 3,
}

---Gets the basic visual state of a control.
---@param control Control The control.
---@return VisualState # The control's visual state.
ugui.get_visual_state = function(control)
    if control.is_enabled == false then
        return ugui.visual_states.disabled
    end

    if ugui.internal.clicked_control == control.uid then
        return ugui.visual_states.active
    end

    if ugui.internal.mouse_captured_control == control.uid then
        return ugui.visual_states.active
    end

    if ugui.internal.hovered_control == control.uid then
        return ugui.visual_states.hovered
    end

    return ugui.visual_states.normal
end

--- The standard style implementation, which is responsible for drawing controls.
ugui.standard_styler = {

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
            selection = BreitbandGraphics.hex_to_color('#0078D7'),
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
        spinner = {
            button_size = 15,
        },
        tabcontrol = {
            rail_size = 17,
            draw_frame = true,
            gap_x = 0,
            gap_y = 0,
        },
        numberbox = {
            font_scale = 1.5,
            selection = BreitbandGraphics.hex_to_color('#0078D7'),
        },
    },

    ---Draws an icon with the specified parameters.
    ---The draw_icon implementation may choose to use either the color or visual_state parameter to determine the icon's appearance.
    ---Therefore, the caller must provide either a color or a visual state, or both.
    ---@param rectangle Rectangle The icon's bounds.
    ---@param color ColorSource? The icon's fill color.
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
        if not text then
            return {segment_data = {}, size = {x = 0, y = 0}}
        end

        if plaintext then
            local size = BreitbandGraphics.get_text_size(text, ugui.standard_styler.params.font_size, ugui.standard_styler.params.font_name)
            return {
                segment_data = {
                    segment = {
                        type = 'text',
                        value = text,
                    },
                    rectangle = {
                        x = 0,
                        y = 0,
                        width = size.width,
                        height = size.height,
                    },
                },
                size = {
                    x = size.width,
                    y = size.height,
                },
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
                y = max_height,
            },
        }
    end,

    ---Draws rich text with the specified parameters.
    ---@param rectangle Rectangle The rich text's bounds.
    ---@param align_x Alignment? The rich text's horizontal alignment inside the rectangle. If nil, the default is assumed.
    ---@param align_y Alignment? The rich text's vertical alignment inside the rectangle. If nil, the default is assumed.
    ---@param text RichText The rich text.
    ---@param color Color The rich text's color. If a rich text segment contains a color, it is used instead.
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
                ugui.standard_styler.draw_icon(data.rectangle, data.segment.color or color, visual_state, data.segment.value)
            end
            if data.segment.type == 'text' then
                BreitbandGraphics.draw_text2({
                    text = data.segment.value,
                    rectangle = {
                        x = data.rectangle.x,
                        y = data.rectangle.y - 1,
                        width = data.rectangle.width + 1,
                        height = data.rectangle.height + 1,
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
    ---@param control ScrollBar
    ---@param thumb_rectangle Rectangle The scrollbar thumb's bounds.
    draw_scrollbar = function(control, thumb_rectangle)
        local visual_state = ugui.get_visual_state(control)
        BreitbandGraphics.fill_rectangle(control.rectangle,
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
        local data = ugui.internal.control_data[control.uid]

        ugui.standard_styler.draw_list_frame(rectangle, visual_state)

        local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)
        -- item y position:
        -- y = (20 * (i - 1)) - (scroll_y * ((20 * #control.items) - control.rectangle.height))
        local scroll_x = data.scroll_x and data.scroll_x or 0
        local scroll_y = data.scroll_y and data.scroll_y or 0

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

            if data.selected_index == i then
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
            ugui.standard_styler.draw_icon(icon_rect, ugui.standard_styler.params.menu_item.height, nil, 'checkmark')
        end

        if item.items then
            local icon_rect = BreitbandGraphics.inflate_rectangle({
                x = rectangle.x + rectangle.width - (ugui.standard_styler.params.menu_item.right_padding),
                y = rectangle.y,
                width = ugui.standard_styler.params.menu_item.right_padding,
                height = rectangle.height,
            }, -7)
            ugui.standard_styler.draw_icon(icon_rect, ugui.standard_styler.params.menu_item.height, nil, 'arrow_right')
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
    draw_tooltip = function(control, position)
        local text = control.tooltip
        if not text then
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
        local data = ugui.internal.control_data[control.uid]
        local visual_state = ugui.get_visual_state(control)
        local text = control.text or ''

        -- Special case: if we're capturing the keyboard, we consider ourselves "active"
        if ugui.internal.keyboard_captured_control == control.uid then
            visual_state = ugui.visual_states.active
        end

        ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

        local should_visualize_selection =
            control.is_enabled ~= false
            and data.selection_start ~= data.selection_end
            and ugui.internal.keyboard_captured_control == control.uid

        if should_visualize_selection then
            local string_to_selection_start = text:sub(1,
                data.selection_start - 1)
            local string_to_selection_end = text:sub(1,
                data.selection_end - 1)

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
                ugui.standard_styler.params.textbox.selection)
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
            local lower = data.selection_start
            local higher = data.selection_end
            if data.selection_start > data.selection_end then
                lower = data.selection_end
                higher = data.selection_start
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


        local string_to_caret = text:sub(1, data.caret_index - 1)
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
        local data = ugui.internal.control_data[control.uid]

        if ugui.internal.mouse_captured_control == control.uid and control.is_enabled ~= false then
            visual_state = ugui.visual_states.active
        end

        local is_horizontal = control.rectangle.width > control.rectangle.height

        ugui.standard_styler.draw_track(control, visual_state, is_horizontal)
        ugui.standard_styler.draw_thumb(control, visual_state, is_horizontal, data.value)
    end,

    ---Draws a ComboBox with the specified parameters.
    ---@param control ComboBox The control table.
    draw_combobox = function(control)
        local visual_state = ugui.get_visual_state(control)
        local data = ugui.internal.control_data[control.uid]
        local selected_item = data.selected_index == nil and '' or control.items[data.selected_index]

        if data.open and control.is_enabled ~= false then
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
}

---@class ControlRegistryEntry
---@field public validate fun(control: Control) Verifies that a control instance matches the desired type.
---@field public setup fun(control: Control, data: any)? Sets up the initial control data to be used in `logic` and `draw`.
---@field public added fun(control: Control, data: any)? Notifies about a control being added to a scene.
---@field public logic fun(control: Control, data: any): any Executes control logic.
---@field public draw fun(control: Control) Draws the control.

---@type { [ControlType]: ControlRegistryEntry }
ugui.registry = {
    button = {
        validate = function(control)
            ---@cast control Button
            ugui.internal.assert(type(control.text) == 'string', 'expected text to be string')
        end,
        logic = function(control, data)
            ---@cast control Button
            return ugui.internal.clicked_control == control.uid
        end,
        draw = function(control)
            ---@cast control Button
            ugui.standard_styler.draw_button(control)
        end,
    },
    toggle_button = {
        validate = function(control)
            ---@cast control ToggleButton
            ugui.registry.button.validate(control)
            ugui.internal.assert(type(control.is_checked) == 'boolean', 'expected is_checked to be boolean')
        end,
        logic = function(control, data)
            ---@cast control ToggleButton
            data.is_checked = control.is_checked
            if ugui.internal.clicked_control == control.uid then
                data.is_checked = not data.is_checked
            end
            return data.is_checked
        end,
        draw = function(control)
            ---@cast control ToggleButton
            ugui.standard_styler.draw_togglebutton(control)
        end,
    },
    carrousel_button = {
        validate = function(control)
            ---@cast control CarrouselButton
            ugui.internal.assert(type(control.items) == 'table', 'expected items to be string[]')
            ugui.internal.assert(type(control.selected_index) == 'number', 'expected selected_index to be number')
        end,
        logic = function(control, data)
            ---@cast control CarrouselButton
            data.selected_index = control.selected_index

            if ugui.internal.clicked_control == control.uid then
                local relative_x = ugui.internal.environment.mouse_position.x - control.rectangle.x
                if relative_x > control.rectangle.width / 2 then
                    data.selected_index = data.selected_index + 1
                    if data.selected_index > #control.items then
                        data.selected_index = 1
                    end
                else
                    data.selected_index = data.selected_index - 1
                    if data.selected_index < 1 then
                        data.selected_index = #control.items
                    end
                end
            end

            return (control.items and ugui.internal.clamp(data.selected_index, 1, #control.items) or nil)
        end,
        draw = function(control)
            ---@cast control CarrouselButton
            ugui.standard_styler.draw_carrousel_button(control)
        end,
    },
    textbox = {
        validate = function(control)
            ---@cast control TextBox
            ugui.internal.assert(type(control.text) == 'string', 'expected text to be string')
        end,
        setup = function(control, data)
            ---@cast control TextBox
            if data.caret_index == nil then
                data.caret_index = 1
            end
            if data.selection_start == nil then
                data.selection_start = 1
            end
            if data.selection_end == nil then
                data.selection_end = 1
            end
        end,
        logic = function(control, data)
            ---@cast control TextBox
            data.text = control.text

            local index_at_mouse = ugui.internal.get_caret_index(data.text, ugui.internal.environment.mouse_position.x - control.rectangle.x)

            -- If the control was just clicked, start a new selection.
            if ugui.internal.clicked_control == control.uid then
                data.caret_index = index_at_mouse
                data.selection_start = index_at_mouse
                data.selection_end = index_at_mouse
            end

            -- If we're dragging the control, extend the existing selection.
            if ugui.internal.mouse_captured_control == control.uid then
                data.selection_end = index_at_mouse
            end

            -- If we're capturing the keyboard, we process all the key presses.
            if ugui.internal.keyboard_captured_control == control.uid then
                local just_pressed_keys = ugui.internal.get_just_pressed_keys()
                local has_selection = data.selection_start ~=
                    data.selection_end

                for key, _ in pairs(just_pressed_keys) do
                    local result = ugui.internal.handle_special_key(key, has_selection, data.text,
                        data.selection_start,
                        data.selection_end,
                        data.caret_index)


                    -- special key press wasn't handled, we proceed to just insert the pressed character (or replace the selection)
                    if not result.handled then
                        if #key ~= 1 then
                            goto continue
                        end

                        if has_selection then
                            local lower_selection = math.min(data.selection_start, data.selection_end)
                            local higher_selection = math.max(data.selection_start, data.selection_end)
                            data.text = ugui.internal.remove_range(data.text, lower_selection, higher_selection)
                            data.caret_index = lower_selection
                            data.selection_start = lower_selection
                            data.selection_end = lower_selection
                            data.text = ugui.internal.insert_at(data.text, key,
                                data.caret_index - 1)
                            data.caret_index = ugui.internal
                                .control_data[control.uid]
                                .caret_index + 1
                        else
                            data.text = ugui.internal.insert_at(data.text, key,
                                data.caret_index - 1)
                            data.caret_index = ugui.internal
                                .control_data[control.uid]
                                .caret_index + 1
                        end

                        goto continue
                    end

                    data.caret_index = result.caret_index
                    data.selection_start = result.selection_start
                    data.selection_end = result.selection_end
                    data.text = result.text

                    ::continue::
                end
            end

            data.caret_index = ugui.internal.clamp(data.caret_index, 1, #data.text + 1)

            return data.text
        end,
        draw = function(control)
            ---@cast control TextBox
            ugui.standard_styler.draw_textbox(control)
        end,
    },
    joystick = {
        validate = function(control)
            ---@cast control Joystick
            ugui.internal.assert(type(control.position) == 'table', 'expected position to be table')
            ugui.internal.assert(type(control.position.x) == 'number', 'expected position.x to be number')
            ugui.internal.assert(type(control.position.y) == 'number', 'expected position.y to be number')
            ugui.internal.assert(type(control.mag) == 'nil' or type(control.mag) == 'number', 'expected mag to be nil or number')
            ugui.internal.assert(type(control.x_snap) == 'nil' or type(control.x_snap) == 'number', 'expected x_snap to be nil or number')
            ugui.internal.assert(type(control.y_snap) == 'nil' or type(control.y_snap) == 'number', 'expected y_snap to be nil or number')
        end,
        logic = function(control, data)
            ---@cast control Joystick
            data.position = control.position

            if ugui.internal.mouse_captured_control == control.uid then
                data.position.x = ugui.internal.clamp(
                    ugui.internal.remap(ugui.internal.environment.mouse_position.x - control.rectangle.x, 0,
                        control.rectangle.width, -128, 128), -128, 128)
                data.position.y = ugui.internal.clamp(
                    ugui.internal.remap(ugui.internal.environment.mouse_position.y - control.rectangle.y, 0,
                        control.rectangle.height, -128, 128), -128, 128)
                if control.x_snap and data.position.x > -control.x_snap and data.position.x < control.x_snap then
                    data.position.x = 0
                end
                if control.y_snap and data.position.y > -control.y_snap and data.position.y < control.y_snap then
                    data.position.y = 0
                end
            end

            return data.position
        end,
        draw = function(control)
            ---@cast control Joystick
            ugui.standard_styler.draw_joystick(control)
        end,
    },
    trackbar = {
        validate = function(control)
            ---@cast control Trackbar
            ugui.internal.assert(type(control.value) == 'number', 'expected position to be number')
        end,
        logic = function(control, data)
            ---@cast control Trackbar
            data.value = control.value

            if ugui.internal.mouse_captured_control == control.uid then
                if control.rectangle.width > control.rectangle.height then
                    data.value = (ugui.internal.environment.mouse_position.x - control.rectangle.x) / control.rectangle.width
                else
                    data.value = (ugui.internal.environment.mouse_position.y - control.rectangle.y) / control.rectangle.height
                end
            end

            data.value = ugui.internal.clamp(data.value, 0, 1)

            return data.value
        end,
        draw = function(control)
            ---@cast control Trackbar
            ugui.standard_styler.draw_trackbar(control)
        end,
    },
    listbox = {
        validate = function(control)
            ---@cast control ListBox
            ugui.internal.assert(type(control.items) == 'table', 'expected items to be table')
            ugui.internal.assert(type(control.selected_index) == 'number' or type(control.selected_index) == 'nil', 'expected selected_index to be number or nil')
            ugui.internal.assert(type(control.horizontal_scroll) == 'nil' or type(control.horizontal_scroll) == 'boolean', 'expected horizontal_scroll to be boolean or nil')
        end,
        setup = function(control, data)
            ---@cast control ListBox
            if data.scroll_x == nil then
                data.scroll_x = 0
            end
            if data.scroll_y == nil then
                data.scroll_y = 0
            end
        end,
        logic = function(control, data)
            ---@cast control ListBox
            data.selected_index = control.selected_index

            local prev_rect = ugui.internal.deep_clone(control.rectangle)
            local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)
            local x_overflow = content_bounds.width > control.rectangle.width
            local y_overflow = content_bounds.height > control.rectangle.height

            if x_overflow then
                control.rectangle.height = control.rectangle.height - ugui.standard_styler.params.scrollbar.thickness
            end
            if y_overflow then
                control.rectangle.width = control.rectangle.width - ugui.standard_styler.params.scrollbar.thickness
            end

            if ugui.internal.mouse_captured_control == control.uid then
                -- Mouse-based selection
                local relative_y = ugui.internal.environment.mouse_position.y - control.rectangle.y
                local new_index = math.ceil((relative_y + (data.scroll_y *
                        ((ugui.standard_styler.params.listbox_item.height * #control.items) - control.rectangle.height))) /
                    ugui.standard_styler.params.listbox_item.height)
                if new_index <= #control.items then
                    data.selected_index = ugui.internal.clamp(new_index, 1, #control.items)
                end
            end

            -- Keyboard-based selection. FIXME: Why is this based on the mouse being inside it???
            -- FIXME: We want the separate concept of "keyboard focus" to be introduced
            if ugui.internal.mouse_captured_control == control.uid or BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                for key, _ in pairs(ugui.internal.get_just_pressed_keys()) do
                    if key == 'up' and data.selected_index ~= nil then
                        data.selected_index = ugui.internal.clamp(data.selected_index - 1, 1, #control.items)
                    end
                    if key == 'down' and data.selected_index ~= nil then
                        data.selected_index = ugui.internal.clamp(data.selected_index + 1, 1, #control.items)
                    end
                    if not y_overflow then
                        if key == 'pageup' or key == 'home' then
                            data.selected_index = 1
                        end
                        if key == 'pagedown' or key == 'end' then
                            data.selected_index = #control.items
                        end
                    end
                end
            end

            if y_overflow and (ugui.internal.mouse_captured_control == control.uid or BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle)) then
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

                data.scroll_y = ugui.internal.clamp(data.scroll_y + inc, 0, 1)
            end

            control.rectangle = prev_rect

            return data.selected_index
        end,
        draw = function(control)
            ---@cast control ListBox
            ugui.standard_styler.draw_listbox(control)
        end,
    },
    scrollbar = {
        validate = function(control)
            ---@cast control ScrollBar
            ugui.internal.assert(type(control.value) == 'number', 'expected value to be number')
            ugui.internal.assert(type(control.ratio) == 'number', 'expected ratio to be number')
        end,
        logic = function(control, data)
            ---@cast control ScrollBar
            data.value = control.value

            local is_horizontal = control.rectangle.width > control.rectangle.height

            if ugui.internal.mouse_captured_control == control.uid then
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
                data.value = ugui.internal.clamp(start + (current - start), 0, 1)
            end

            return data.value
        end,
        draw = function(control)
            ---@cast control ScrollBar
            local data = ugui.internal.control_data[control.uid]
            local is_horizontal = control.rectangle.width > control.rectangle.height

            ---@type Rectangle
            local thumb_rectangle

            if is_horizontal then
                local scrollbar_width = control.rectangle.width * control.ratio
                local scrollbar_x = ugui.internal.remap(data.value, 0, 1, 0, control.rectangle.width - scrollbar_width)
                thumb_rectangle = {
                    x = control.rectangle.x + scrollbar_x,
                    y = control.rectangle.y,
                    width = scrollbar_width,
                    height = control.rectangle.height,
                }
            else
                local scrollbar_height = control.rectangle.height * control.ratio
                local scrollbar_y = ugui.internal.remap(data.value, 0, 1, 0, control.rectangle.height - scrollbar_height)
                thumb_rectangle = {
                    x = control.rectangle.x,
                    y = control.rectangle.y + scrollbar_y,
                    width = control.rectangle.width,
                    height = scrollbar_height,
                }
            end

            ugui.standard_styler.draw_scrollbar(control, thumb_rectangle)
        end,
    },
    combobox = {
        validate = function(control)
            ---@cast control ComboBox
            ugui.internal.assert(type(control.items) == 'table', 'expected items to be table')
            ugui.internal.assert(type(control.selected_index) == 'number', 'expected selected_index to be number')
        end,
        setup = function(control, data)
            ---@cast control ComboBox
            if data.open == nil then
                data.open = false
            end
            if data.hovered_index == nil then
                data.hovered_index = control.selected_index
            end
        end,
        logic = function(control, data)
            ---@cast control ComboBox
            data.selected_index = control.selected_index

            if control.is_enabled == false then
                data.open = false
            end

            if ugui.internal.clicked_control == control.uid then
                data.open = not data.open
            end

            if data.open and ugui.internal.is_mouse_just_down() and not ugui.internal.is_point_inside_control(ugui.internal.environment.mouse_position, control) then
                local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)
                if not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, {
                        x = control.rectangle.x,
                        y = control.rectangle.y + control.rectangle.height,
                        width = control.rectangle.width,
                        height = content_bounds.height,
                    }) then
                    data.open = false
                end
            end

            return data.selected_index
        end,
        draw = function(control)
            ---@cast control ComboBox
            ugui.standard_styler.draw_combobox(control)
        end,
    },
    menu = {
        validate = function(control)
            ---@cast control Menu
            ugui.internal.assert(type(control.items) == 'table', 'expected items to be table')
        end,
        setup = function(control, data)
            data.dismissed = 0
        end,
        logic = function(control, data)
            ---@cast control Menu

            local function reset_hovered_index_for_all_child_menus(uid, items)
                if ugui.internal.control_data[uid] then
                    ugui.internal.control_data[uid].hovered_index = nil
                end
                for _, item in pairs(items) do
                    if item.items then
                        reset_hovered_index_for_all_child_menus(uid + 1, item.items)
                    end
                end
            end

            local result = {
                item = nil,
                dismissed = false,
            }

            -- We want to delay returning the dismissed state by a frame because we don't get to handle inputs otherwise,
            -- so we turn the dismissed flag into a tristate.
            if data.dismissed == 2 then
                data.dismissed = 0
                result.dismissed = true
            end

            if data.dismissed == 1 then
                data.dismissed = 2
            end

            if ugui.internal.is_mouse_just_down() and not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.mouse_down_position, control.rectangle) then
                data.dismissed = 1
            end

            if ugui.internal.hovered_control == control.uid then
                reset_hovered_index_for_all_child_menus(control.uid, control.items)

                local i = math.floor((ugui.internal.environment.mouse_position.y - control.rectangle.y) / ugui.standard_styler.params.menu_item.height) + 1
                data.hovered_index = ugui.internal.clamp(i, 1, #control.items)
            end

            if ugui.internal.clicked_control == control.uid then
                local item = control.items[data.hovered_index]

                -- Only child-less items can be clicked
                if item.enabled ~= false and (item.items == nil or #item.items == 0) then
                    result.item = item
                end
            end

            if result.dismissed or result.item then
                reset_hovered_index_for_all_child_menus(control.uid, control.items)
            end


            return result
        end,
        draw = function(control)
            ---@cast control Menu
            ugui.standard_styler.draw_menu(control, control.rectangle)
        end,
    },
    numberbox = {
        validate = function(control)
            ---@cast control NumberBox
            ugui.internal.assert(type(control.value) == 'number', 'expected value to be number')
            ugui.internal.assert(type(control.places) == 'number', 'expected places to be number')
            ugui.internal.assert(type(control.show_negative) == 'boolean' or type(control.show_negative) == 'nil', 'expected show_negative to be boolean or nil')
        end,
        setup = function(control, data)
            data.caret_index = 1
        end,
        logic = function(control, data)
            ---@cast control NumberBox
            local prev_value_negative = control.value < 0
            data.value = math.abs(control.value)

            local function get_caret_index_at_relative_x(x)
                local font_size = ugui.standard_styler.params.font_size * ugui.standard_styler.params.numberbox.font_scale
                local font_name = ugui.standard_styler.params.monospace_font_name
                local text = string.format('%0' .. tostring(control.places) .. 'd', data.value)

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
                data.value = ugui.internal.set_digit(data.value, control.places,
                    ugui.internal.get_digit(data.value, control.places, index) + value, index)
            end

            if ugui.internal.clicked_control == control.uid then
                data.caret_index = get_caret_index_at_relative_x(ugui.internal.environment.mouse_position.x - control.rectangle.x)
            end

            if ugui.internal.keyboard_captured_control == control.uid then
                -- handle number key press
                for key, _ in pairs(ugui.internal.get_just_pressed_keys()) do
                    local num_1 = tonumber(key)
                    local num_2 = tonumber(key:sub(7))
                    local value = num_1 and num_1 or num_2

                    if value then
                        local oldkey = math.floor(value / math.pow(10, control.places - data.caret_index)) % 10
                        value = value + (value - oldkey) * math.pow(10, control.places - data.caret_index)
                        data.caret_index = data.caret_index + 1
                    end

                    if key == 'left' then
                        data.caret_index = data.caret_index - 1
                    end
                    if key == 'right' then
                        data.caret_index = data.caret_index + 1
                    end
                    if key == 'up' then
                        increment_digit(data.caret_index, 1)
                    end
                    if key == 'down' then
                        increment_digit(data.caret_index, -1)
                    end
                end

                if ugui.internal.is_mouse_wheel_up() then
                    increment_digit(data.caret_index, 1)
                end
                if ugui.internal.is_mouse_wheel_down() then
                    increment_digit(data.caret_index, -1)
                end
            end

            data.caret_index = ugui.internal.clamp(data.caret_index, 1, control.places)

            if prev_value_negative then
                data.value = -math.abs(data.value)
            end

            return data.value
        end,
        draw = function(control)
            ---@cast control NumberBox
            local data = ugui.internal.control_data[control.uid]
            local font_size = ugui.standard_styler.params.font_size * ugui.standard_styler.params.numberbox.font_scale
            local font_name = ugui.standard_styler.params.monospace_font_name
            local text = string.format('%0' .. tostring(control.places) .. 'd', math.abs(control.value))

            local visual_state = ugui.get_visual_state(control)
            if ugui.internal.keyboard_captured_control == control.uid then
                visual_state = ugui.visual_states.active
            end
            ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

            BreitbandGraphics.draw_text2({
                text = text,
                rectangle = control.rectangle,
                color = ugui.standard_styler.params.textbox.text[visual_state],
                font_name = font_name,
                font_size = font_size,
                aliased = not ugui.standard_styler.params.cleartype,
            })

            local text_width_up_to_caret = BreitbandGraphics.get_text_size(
                text:sub(1, data.caret_index - 1),
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

            if ugui.internal.keyboard_captured_control == control.uid then
                BreitbandGraphics.fill_rectangle(selected_char_rect, ugui.standard_styler.params.numberbox.selection)
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
        end,
    },
}

--#endregion

--#region Main API

---Begins a new frame.
---@param environment Environment The environment for the current frame.
ugui.begin_frame = function(environment)
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
end

--- Ends the current frame.
ugui.end_frame = function()
    if not ugui.internal.frame_in_progress then
        error("Tried to call end_frame() while a frame wasn't already in progress. Start a frame with begin_frame() before ending an in-progress one.")
    end

    -- 1. Z-Sorting pass
    ugui.internal.sort_scene()

    -- 2. Input processing pass
    ugui.internal.do_input_processing()

    -- 3. Event dispatching pass
    ugui.internal.dispatch_events()

    -- 4. Rendering pass
    for i = 1, #ugui.internal.scene, 1 do
        local control = ugui.internal.scene[i].control
        local type = ugui.internal.scene[i].type

        ugui.registry[type].draw(control)

        if ugui.DEBUG then
            if ugui.internal.keyboard_captured_control == control.uid then
                BreitbandGraphics.draw_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, 4), '#000000', 2)
            end
            if ugui.internal.mouse_captured_control == control.uid then
                BreitbandGraphics.draw_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, 8), '#FF0000', 2)
            end
        end
    end

    ugui.internal.tooltip()

    -- Store UIDs that were present in this frame
    ugui.internal.previous_uids = {}
    for i = 1, #ugui.internal.scene, 1 do
        local control = ugui.internal.scene[i].control
        ugui.internal.previous_uids[control.uid] = true
    end

    ugui.internal.scene = {}
    ugui.internal.last_control_rectangle = nil
    ugui.internal.frame_in_progress = false
end

---Places a Control of the specified type.
---@param control Control The control.
---@param type ControlType | "" The control's type. If the type is `""`, no control will be placed, but the control data entry will be initialized.
---@return any # The control's return value.
ugui.control = function(control, type)
    if type == '' then
        ugui.internal.control_data[control.uid] = {}
        return
    end

    ---@type ControlRegistryEntry?
    local registry_entry = ugui.registry[type]

    if registry_entry == nil then
        error(string.format("Unknown control type '%s'", type))
    end

    local return_value

    -- If the control has only just been added, we run its setup.
    if ugui.internal.control_data[control.uid] == nil then
        ugui.internal.control_data[control.uid] = {}
        if registry_entry.setup then
            registry_entry.setup(control, ugui.internal.control_data[control.uid])
        end

        -- Run logic once to stabilize the return value for the first state
        return_value = registry_entry.logic(control, ugui.internal.control_data[control.uid])
    end

    -- Check for UID duplicates
    for i = 1, #ugui.internal.scene, 1 do
        local uid = ugui.internal.scene[i].control.uid
        if control.uid == uid then
            error(string.format('Attempted to show a control with uid %d, which is already in use! Note that some controls reserve more than one uid slot after them.', control.uid))
        end
    end

    registry_entry.validate(control)

    -- Run logic pass immediately for the current frame so callers receive an up-to-date value instead of the previous frame's result.
    return_value = registry_entry.logic(control, ugui.internal.control_data[control.uid])

    ugui.internal.scene[#ugui.internal.scene + 1] = {
        control = control,
        type = type,
    }
    return return_value
end

---Places a Button.
---@param control Button The control table.
---@return boolean # Whether the button has been pressed.
ugui.button = function(control)
    return ugui.control(control, 'button')
end

---Places a ToggleButton.
---@param control ToggleButton The control table.
---@return boolean # The new check state.
ugui.toggle_button = function(control)
    return ugui.control(control, 'toggle_button')
end

---Places a CarrouselButton.
---@param control CarrouselButton The control table.
---@return integer # The new selected index.
ugui.carrousel_button = function(control)
    return ugui.control(control, 'carrousel_button')
end

---Places a TextBox.
---@param control TextBox The control table.
---@return string # The new text.
ugui.textbox = function(control)
    return ugui.control(control, 'textbox')
end

---Places a Joystick.
---@param control Joystick The control table.
---@return Vector2 # The joystick's new position.
ugui.joystick = function(control)
    return ugui.control(control, 'joystick')
end

---Places a Trackbar.
---@param control Trackbar The control table.
---@return number # The trackbar's new value.
ugui.trackbar = function(control)
    return ugui.control(control, 'trackbar')
end

---Places a ComboBox.
---@param control ComboBox The control table.
---@return integer # The new selected index.
ugui.combobox = function(control)
    local _ = ugui.control(control, 'combobox')
    local data = ugui.internal.control_data[control.uid]

    if data.open then
        local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)

        local width = control.rectangle.width
        if control.rectangle.x + width > ugui.internal.environment.window_size.x then
            width = ugui.internal.environment.window_size.x - control.rectangle.x
        end

        local height = content_bounds.height
        if control.rectangle.y + height > ugui.internal.environment.window_size.y then
            height = ugui.internal.environment.window_size.y - control.rectangle.y - ugui.standard_styler.params.listbox_item.height * 2
        end

        local list_rect = {
            x = control.rectangle.x,
            y = control.rectangle.y + control.rectangle.height,
            width = width,
            height = height,
        }

        data.selected_index = ugui.listbox({
            uid = control.uid + 1,
            rectangle = list_rect,
            items = control.items,
            selected_index = data.selected_index,
            plaintext = control.plaintext,
            z_index = math.maxinteger,
        })
    end

    return data.selected_index
end

---Places a ListBox.
---@param control ListBox The control table.
---@return integer # The new selected index.
ugui.listbox = function(control)
    local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)
    local x_overflow = content_bounds.width > control.rectangle.width
    local y_overflow = content_bounds.height > control.rectangle.height

    -- If we need scrollbars, we shrink the control rectangle to accomodate them.
    if x_overflow then
        control.rectangle.height = control.rectangle.height - ugui.standard_styler.params.scrollbar.thickness
    end
    if y_overflow then
        control.rectangle.width = control.rectangle.width - ugui.standard_styler.params.scrollbar.thickness
    end

    local result = ugui.control(control, 'listbox')
    local data = ugui.internal.control_data[control.uid]

    if x_overflow then
        data.scroll_x = ugui.scrollbar({
            uid = control.uid + 1,
            is_enabled = control.is_enabled,
            rectangle = {
                x = control.rectangle.x,
                y = control.rectangle.y + control.rectangle.height,
                width = control.rectangle.width,
                height = ugui.standard_styler.params.scrollbar.thickness,
            },
            value = data.scroll_x,
            ratio = 1 / (content_bounds.width / control.rectangle.width),
            z_index = control.z_index,
        })
    end

    if y_overflow then
        data.scroll_y = ugui.scrollbar({
            uid = control.uid + 2,
            is_enabled = control.is_enabled,
            rectangle = {
                x = control.rectangle.x + control.rectangle.width,
                y = control.rectangle.y,
                width = ugui.standard_styler.params.scrollbar.thickness,
                height = control.rectangle.height,
            },
            value = data.scroll_y,
            ratio = 1 / (content_bounds.height / control.rectangle.height),
            z_index = control.z_index,
        })
    end

    return result
end

---Places a ScrollBar.
---@param control ScrollBar The control table.
---@return number # The new value.
ugui.scrollbar = function(control)
    return ugui.control(control, 'scrollbar')
end

---Places a Menu.
---@param control Menu The control table.
---@return MenuResult # The menu result.
ugui.menu = function(control)
    control.z_index = control.z_index or 1000

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
        -- If the menu has a parent and there's an overflow on the X axis, try snaking out of the situation by moving left of the menu
        if control.parent_rectangle then
            control.rectangle.x = control.parent_rectangle.x - control.rectangle.width + ugui.standard_styler.params.menu.overlap_size
        else
            control.rectangle.x = control.rectangle.x - (control.rectangle.x + control.rectangle.width - ugui.internal.environment.window_size.x)
        end
    end
    if control.rectangle.y + control.rectangle.height > ugui.internal.environment.window_size.y then
        control.rectangle.y = control.rectangle.y - (control.rectangle.y + control.rectangle.height - ugui.internal.environment.window_size.y)
    end

    local result = ugui.control(control, 'menu')
    local data = ugui.internal.control_data[control.uid]

    -- Show child menu if there's any hovered one
    if data.hovered_index ~= nil then
        local i = data.hovered_index
        local item = control.items[i]

        if item.items and item.enabled ~= false then
            local submenu_result = ugui.menu({
                uid = control.uid + 1,
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width - ugui.standard_styler.params.menu.overlap_size,
                    y = control.rectangle.y + ((i - 1) * ugui.standard_styler.params.menu_item.height),
                    width = 0,
                    height = 0,
                },
                items = item.items,
                z_index = (control.z_index or 0) + 1,
                parent_rectangle = ugui.internal.deep_clone(control.rectangle),
            })

            if submenu_result.item then
                result.dismissed = false
                result.item = submenu_result.item
            end
        end
    end

    return result
end

---Places a Spinner.
---@param control Spinner The control table.
---@return number # The new value.
ugui.spinner = function(control)
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

    if tonumber(new_text) then
        value = clamp_value(tonumber(new_text))
    end

    if control.is_enabled ~= false
        and (BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, textbox_rect) or ugui.internal.mouse_captured_control == control.uid)
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

    return clamp_value(value)
end

---Places a TabControl.
---@param control TabControl The control table.
---@return TabControlResult # The result.
ugui.tabcontrol = function(control)
    local _ = ugui.control(control, '')
    local data = ugui.internal.control_data[control.uid]

    if data.scroll_x == nil then
        data.scroll_x = 0
    end

    if data.scroll_y == nil then
        data.scroll_y = 0
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

---Places a NumberBox.
---@param control NumberBox The control table.
---@return integer # The new value.
ugui.numberbox = function(control)
    local _ = ugui.control(control, 'numberbox')
    local data = ugui.internal.control_data[control.uid]

    if control.show_negative then
        local negative_button_size = control.rectangle.width / 8

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
                text = data.value >= 0 and '+' or '-',
            }) then
            data.value = -data.value
        end
    end

    return math.floor(data.value)
end

--#endregion

return ugui
