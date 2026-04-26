--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@type InputListGui
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

---@type Section
local Section = dofile(views_path .. 'SemanticWorkflow/Definitions/Section.lua')

--#region Constants

local MODE_TEXTS <const> = { '-', 'D', 'M', 'Y', 'R', 'A' }
local BUTTONS <const> = {
    { input = 'A',      text = 'A' },
    { input = 'B',      text = 'B' },
    { input = 'Z',      text = 'Z' },
    { input = 'start',  text = 'S' },
    { input = 'Cup',    text = '^' },
    { input = 'Cleft',  text = '<' },
    { input = 'Cright', text = '>' },
    { input = 'Cdown',  text = 'v' },
    { input = 'L',      text = 'L' },
    { input = 'R',      text = 'R' },
    { input = 'up',     text = '^' },
    { input = 'left',   text = '<' },
    { input = 'right',  text = '>' },
    { input = 'v',      text = 'v' },
}

local COL_COLLAPSE_OR_PREVIEW_1 <const> = 0.0
local COL_COLLAPSE_OR_PREVIEW_END <const> = 0.3
local COL_ARRANGEMENT_2 <const> = 0.4
local COL_ARRANGEMENT_3 <const> = 0.7
local COL_ARRANGEMENT_4 <const> = 1.0
local COL_ARRANGEMENT_END <const> = 1.3
local COL_TERMINATION_1 <const> = 1.3
local COL_TERMINATION_END <const> = 1.8
local COL_JOYSTICK_1 <const> = 1.8
local COL_JOYSTICK_2 <const> = 2.3
local COL_JOYSTICK_3 <const> = 2.5
local COL_JOYSTICK_4 <const> = 2.6
local COL_JOYSTICK_5 <const> = 3.35
local COL_JOYSTICK_END <const> = 3.5
local COL_BUTTONS_END <const> = 8.0

local COL_MERGE_SECTION_UP_END = 1.6
local COL_SECTION_NAME_END = 6
local COL_SECTION_LENGTH_END = 7.5

local ROW0 <const> = 1.00
local ROW1 <const> = 1.50
local ROW2 <const> = 2.25

local BUTTON_COLUMN_WIDTH <const> = 0.3
local BUTTON_SIZE <const> = 0.22
local FRAME_COLUMN_HEIGHT <const> = 0.5
local SCROLLBAR_WIDTH <const> = 0.3

local MAX_DISPLAYED_SECTIONS <const> = 15

local NUM_UIDS_PER_ROW <const> = 20
local BUTTON_COLORS <const> = {
    { background = '#0000FF64', button = '#0000BEFF' }, -- A
    { background = '#00B11664', button = '#00E62CFF' }, -- B
    { background = '#6F6F6F64', button = '#C8C8C8FF' }, -- Z
    { background = '#C8000064', button = '#FF0000FF' }, -- Start
    { background = '#C8C80064', button = '#FFFF00FF' }, -- 4 C Buttons
    { background = '#6F6F6F64', button = '#C8C8C8FF' }, -- L + R Buttons
    { background = '#37373764', button = '#323232FF' }, -- 4 DPad Buttons
}

--#endregion

--#region logic

local scroll_offset = 0

local UID = UIDProvider.allocate_once('InputListGui', function(enum_next)
    local base = enum_next(MAX_DISPLAYED_SECTIONS * NUM_UIDS_PER_ROW)
    return {
        SheetName = enum_next(),
        Scrollbar = enum_next(),
        Row = function(index)
            return base + (index - 1) * NUM_UIDS_PER_ROW
        end,
    }
end)

---@alias IterateInputsCallback fun(section: Section, input: SectionInputs|nil, section_index: integer, input_index: integer, row_count: integer): boolean?

---@function Iterates all sections as an input row, including their follow-up inputs for non-collapsed sections.
---@param sheet Sheet The sheet over whose sections to iterate.
---@param callback IterateInputsCallback? an optional function that, when it returns true, terminates the enumeration.
local function iterate_input_rows(sheet, callback)
    local total_rows_counted = 1
    local total_sections_counted = 1
    for section_index = 1, #sheet.sections, 1 do
        local section = sheet.sections[section_index]
        for input_index = 0, #section.inputs, 1 do
            if callback and callback(section, input_index > 0 and section.inputs[input_index] or nil, total_sections_counted, input_index, total_rows_counted) then
                return total_rows_counted
            end

            total_rows_counted = total_rows_counted + 1
            if section.collapsed then break end
        end
        total_sections_counted = total_sections_counted + 1
    end
    return total_rows_counted - 1
end

local function update_scroll(wheel, num_rows)
    scroll_offset = math.max(0, math.min(num_rows - MAX_DISPLAYED_SECTIONS, scroll_offset - wheel))
end

local function interpolate_vectors_to_int(a, b, f)
    local result = {}
    for k, v in pairs(a) do
        result[k] = math.floor(v + (b[k] - v) * f)
    end
    return result
end

local function draw_headers(sheet, draw, button_draw_data)
    local background_color = interpolate_vectors_to_int(draw.background_color, { r = 127, g = 127, b = 127 }, 0.25)
    BreitbandGraphics.fill_rectangle(grid_rect(0, ROW0, COL_BUTTONS_END, ROW2 - ROW0, 0), background_color)

    draw:text(grid_rect(3, ROW0, 1, 0.5), 'start', Locales.str('SEMANTIC_WORKFLOW_INPUTLIST_NAME'))
    sheet.name = ugui.textbox({
        uid = UID.SheetName,
        is_enabled = true,
        rectangle = grid_rect(4, ROW0, 4, 0.5),
        text = sheet.name,
        styler_mixin = {
            font_size = ugui.standard_styler.params.font_size * 0.75,
        },
    })
    -- Reject invalid file system characters
    sheet.name = sheet.name:gsub("[<>:\"/\\|?*]", "")

    if not button_draw_data then return end

    local rect = grid_rect(0, ROW1, 0.333, 1)
    for i, v in ipairs(BUTTONS) do
        rect.x = button_draw_data[i].x
        draw:text(ugui.internal.deep_clone(rect), 'center', v.text)
    end
end

local function draw_scrollbar(num_rows)
    local baseline = grid_rect(COL_BUTTONS_END, ROW2, BUTTON_COLUMN_WIDTH, FRAME_COLUMN_HEIGHT, 0)
    local unit = Settings.grid_size * Drawing.scale
    local num_actually_shown_rows = math.min(MAX_DISPLAYED_SECTIONS, num_rows)
    local scrollbar_rect = {
        x = baseline.x - SCROLLBAR_WIDTH * unit,
        y = baseline.y,
        width = SCROLLBAR_WIDTH * unit,
        height = baseline.height * num_actually_shown_rows,
    }

    local max_scroll = num_rows - MAX_DISPLAYED_SECTIONS
    if num_rows > 0 and max_scroll > 0 then
        local relative_scroll = ugui.scrollbar({
            uid = UID.Scrollbar,
            rectangle = scrollbar_rect,
            value = scroll_offset / max_scroll,
            ratio = num_actually_shown_rows / num_rows,
        })
        scroll_offset = math.floor(relative_scroll * max_scroll + 0.5)
    end

    return baseline, scrollbar_rect
end

local function draw_color_codes(baseline, scrollbar_rect, num_display_sections)
    local rect = {
        x = scrollbar_rect.x - baseline.width * #BUTTONS,
        y = baseline.y,
        width = baseline.width,
        height = baseline.height * num_display_sections,
    }

    local i = 1
    local color_index = 1
    local button_draw_data = {}

    local function draw_next(amount)
        for k = 0, amount - 1, 1 do
            button_draw_data[i] = { x = rect.x + k * rect.width, color_index = color_index }
            i = i + 1
        end
        BreitbandGraphics.fill_rectangle(
            { x = rect.x, y = rect.y, width = rect.width * amount, height = rect.height },
            BUTTON_COLORS[color_index].background
        )
        color_index = color_index + 1
        rect.x = rect.x + rect.width * amount
    end

    draw_next(1) -- A
    draw_next(1) -- B
    draw_next(1) -- Z
    draw_next(1) -- Start
    draw_next(4) -- 4 C Buttons
    draw_next(2) -- L + R Buttons
    draw_next(4) -- 4 DPad Buttons
    button_draw_data[#button_draw_data + 1] = { x = rect.x }

    return button_draw_data
end

local placing = 0
local function handle_scroll_and_buttons(section_rect, button_draw_data, num_rows)
    local mouse_x = ugui_environment.mouse_position.x
    local relative_y = ugui_environment.mouse_position.y - section_rect.y
    local in_range = mouse_x >= section_rect.x and mouse_x <= section_rect.x + section_rect.width and relative_y >= 0
    local unscrolled_hover_index = math.ceil(relative_y / section_rect.height)
    local hovering_index = unscrolled_hover_index + scroll_offset
    local any_change = false
    in_range = in_range and unscrolled_hover_index <= MAX_DISPLAYED_SECTIONS
    update_scroll(in_range and ugui_environment.wheel or 0, num_rows)
    if in_range then
        -- act as if the mouse wheel was not moved in order to prevent other controls from scrolling on accident
        ugui_environment.wheel = 0
        ugui.internal.environment.wheel = 0
    end

    if not button_draw_data then return end

    iterate_input_rows(SemanticWorkflowProject:asserted_current(), function(section, input, section_index, input_index, row_count)
        if input and row_count == hovering_index and in_range and section ~= nil then
            for button_index, v in ipairs(BUTTONS) do
                local in_range_x = mouse_x >= button_draw_data[button_index].x and
                    mouse_x < button_draw_data[button_index + 1].x
                if ugui.internal.is_mouse_just_down() and in_range_x then
                    placing = input.joy[v.input] and -1 or 1
                    input.joy[v.input] = placing
                    any_change = true
                elseif ugui.internal.environment.is_primary_down and placing ~= 0 then
                    if in_range_x then
                        any_change = input.joy[v.input] ~= (placing == 1)
                        input.joy[v.input] = placing == 1
                    end
                else
                    placing = 0
                end
            end
        end
    end)
    return any_change
end

---@param sheet Sheet
local function draw_sections_gui(sheet, draw, section_rect, button_draw_data)
    local function span(x1, x2, height)
        local r = grid_rect(x1, 0, x2 - x1, height, 0)
        return { x = r.x, y = section_rect.y, width = r.width, height = height and r.height or section_rect.height }
    end

    local deferred_calls = { }
    local function queue_table_insert(target, reference_item, new_item, offset)
        deferred_calls[#deferred_calls+1] = function()
            table.insert(target, IndexOf(target, reference_item) + offset, new_item)
            -- any_changes = true -- TODO: is this even worth it?
        end
    end
    local function queue_table_remove(target, item)
        deferred_calls[#deferred_calls+1] = function()
            table.remove(target, IndexOf(target, item))
            -- any_changes = true -- TODO: is this even worth it?
        end
    end

    local loop_targets = {}
    for _, section in ipairs(sheet.sections) do
        for _, inp in ipairs(section.inputs) do
            if inp.loop and inp.loop.jump_target then
                loop_targets[inp.loop.jump_target] = true
            end
        end
    end

    iterate_input_rows(sheet, function(section, input, section_index, input_index, row_count)
        if row_count <= scroll_offset then return false end

        --TODO: color code section success
        local shade = row_count % 2 == 0 and 123 or 80
        local blue_multiplier = section_index % 2 == 1 and 2 or 1

        if row_count > MAX_DISPLAYED_SECTIONS + scroll_offset then
            local extra_sections = #sheet.sections - section_index
            BreitbandGraphics.fill_rectangle(span(0, COL_BUTTONS_END), '#8A948A42')
            draw:text(span(COL_ARRANGEMENT_END, COL_BUTTONS_END), 'start', '+ ' .. extra_sections .. ' sections')
            return true
        end

        local uid_base = UID.Row(row_count - scroll_offset)
        if not input then
            -- section header
            BreitbandGraphics.fill_rectangle(span(0, COL_BUTTONS_END), Drawing.IsLightMode() and '#BABABA' or '#5F5F5F')

            section.collapsed = not ugui.toggle_button({
                uid = uid_base + 0,
                rectangle = span(COL_COLLAPSE_OR_PREVIEW_1, COL_COLLAPSE_OR_PREVIEW_END),
                text = section.collapsed and '[icon:arrow_right]' or '[icon:arrow_down]',
                tooltip = Locales.str(section.collapsed and 'SEMANTIC_WORKFLOW_INPUTS_EXPAND_SECTION' or
                    'SEMANTIC_WORKFLOW_INPUTS_COLLAPSE_SECTION'),
                is_checked = not section.collapsed,
                is_enabled = #section.inputs > 0,
            });

            local function new_section()
                local base_name = section.name:gsub(' %d+$', '')
                local new_name = UniqueName(base_name, lualinq.select(sheet.sections, function(x) return x.name end))
                return Section.new(new_name)
            end

            if ugui.button({
                uid = uid_base + 1,
                rectangle = span(COL_ARRANGEMENT_2, COL_ARRANGEMENT_3),
                text = '[icon:clone_up]',
                tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_PREPEND_SECTION_TOOL_TIP")
            }) then
                queue_table_insert(sheet.sections, section, new_section(), 0)
            end

            if ugui.button({
                uid = uid_base + 2,
                rectangle = span(COL_ARRANGEMENT_3, COL_ARRANGEMENT_4),
                text = '[icon:clone_down]',
                tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_APPEND_SECTION_TOOL_TIP")
            }) then
                queue_table_insert(sheet.sections, section, new_section(), 1)
            end

            if ugui.button({
                uid = uid_base + 3,
                rectangle = span(COL_ARRANGEMENT_4, COL_ARRANGEMENT_END),
                text = '[icon:delete]',
                tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION_TOOL_TIP")
            }) then
                queue_table_remove(sheet.sections, section)
            end

            local index = IndexOf(sheet.sections, section)
            if ugui.button({
                uid = uid_base + 4,
                rectangle = span(COL_ARRANGEMENT_END, COL_MERGE_SECTION_UP_END),
                text = '[icon:merge_up]',
                tooltip = Locales.str('SEMANTIC_WORKFLOW_INPUTS_MERGE_SECTION_UP_TOOL_TIP'),
                enabled = index > 1
            }) then
                local merge_into = sheet.sections[index - 1]
                for _, i in pairs(section.inputs) do
                    merge_into.inputs[#merge_into.inputs+1] = i
                end
                queue_table_remove(sheet.sections, section)
            end

            section.name = ugui.textbox({
                uid = uid_base + 5,
                rectangle = span(COL_MERGE_SECTION_UP_END, COL_SECTION_NAME_END),
                text = section.name or '',
            })

            ugui.label({
                uid = uid_base + 6,
                rectangle = span(COL_SECTION_NAME_END, COL_SECTION_LENGTH_END),
                text = (SemanticWorkflowProject.current.measured_section_lengths[section] or '?') .. 'f',
                color = ugui.standard_styler.params.textbox.text[1],
            })
        else
            -- input
            BreitbandGraphics.fill_rectangle(section_rect, { r = shade, g = shade, b = shade * blue_multiplier, a = 66 })

            local tas_state = input.tas_state

            if ugui.button({
                uid = uid_base + 10,
                rectangle = span(COL_COLLAPSE_OR_PREVIEW_1, COL_COLLAPSE_OR_PREVIEW_END),
                text = '[icon:next_page]',
                tooltip = Locales.str('SEMANTIC_WORKFLOW_INPUTS_RUN_TO_INPUT_TOOL_TIP'),
            }) then
                sheet.preview_input = { section_index = section_index, input_index = input_index }
                sheet:run_to_preview()
            end


            if ugui.button({
                uid = uid_base + 11,
                rectangle = span(COL_ARRANGEMENT_2, COL_ARRANGEMENT_3),
                text = '[icon:clone_up]',
                tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_PREPEND_INPUT_TOOL_TIP")
            }) then
                queue_table_insert(section.inputs, input, ugui.internal.deep_clone(input), 0)
            end

            if ugui.button({
                uid = uid_base + 12,
                rectangle = span(COL_ARRANGEMENT_3, COL_ARRANGEMENT_4),
                text = '[icon:clone_down]',
                tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_APPEND_INPUT_TOOL_TIP")
            }) then
                queue_table_insert(section.inputs, input, ugui.internal.deep_clone(input), 1)
            end

            if ugui.button({
                uid = uid_base + 13,
                rectangle = span(COL_ARRANGEMENT_4, COL_ARRANGEMENT_END),
                text = '[icon:delete]',
                tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_DELETE_INPUT_TOOL_TIP")
            }) then
                queue_table_remove(section.inputs, input)
            end

            local termination_tool_tip =
                (input.end_action ~= 0
                    and Locales.str('SEMANTIC_WORKFLOW_INPUTS_TERMINATION_TOOL_TIP_1')
                        .. Locales.action(input.end_action) .. '\n'
                    or ''
                ) .. Locales.str('SEMANTIC_WORKFLOW_INPUTS_TERMINATION_TOOL_TIP_2') .. input.timeout
            if ugui.button({
                uid = uid_base + 14,
                rectangle = span(COL_TERMINATION_1, COL_TERMINATION_END),
                text = input.end_action ~= 0 and '[icon:action]' or input.timeout < 100 and '' .. input.timeout or '99+',
                tooltip = termination_tool_tip,
            }) then
                __impl.view_index = 2
            end

            local active_input_box = span(COL_ARRANGEMENT_END, COL_JOYSTICK_END)

            -- mini joysticks and yaw numbers
            local joystick_box = span(COL_JOYSTICK_1, COL_JOYSTICK_2)
            local mixin = { joystick = { tip_size = 4 * Drawing.scale } }
            if input.editing then
                mixin.joystick.back = { [1] = '#00C80064' }
            end
            ugui.joystick({
                uid = uid_base + 15,
                rectangle = span(COL_JOYSTICK_1, COL_JOYSTICK_2, FRAME_COLUMN_HEIGHT),
                position = { x = input.joy.X, y = -input.joy.Y },
                styler_mixin = mixin,
            })

            if BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, joystick_box) then
                if ugui.internal.is_mouse_just_down() and not G_KEYS['control'] then
                    for _, section in pairs(sheet.sections) do
                        for _, input in pairs(section.inputs) do
                            input.editing = false
                        end
                    end
                    input.editing = true
                    __impl.view_index = 1
                elseif ugui.internal.environment.is_primary_down then
                    input.editing = true
                    __impl.view_index = 1
                end
            end

            draw:text(span(COL_JOYSTICK_2, COL_JOYSTICK_3), 'center', MODE_TEXTS[tas_state.movement_mode + 1])

            if tas_state.movement_mode == MovementModes.match_angle then
                draw:text(span(COL_JOYSTICK_4, COL_JOYSTICK_5), 'end', tostring(tas_state.goal_angle))
                draw:text(span(COL_JOYSTICK_5, COL_JOYSTICK_END), 'end',
                    tas_state.strain_left and '<' or (tas_state.strain_right and '>' or '-'))
            end

            if BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, active_input_box) then
                if ugui.internal.is_mouse_just_down() then
                    if __impl.special_select_handler then
                        __impl.special_select_handler({ section_index = section_index, input_index = input_index })
                    else
                        sheet.active_input = { section_index = section_index, input_index = input_index }
                    end
                end
            end

            -- draw buttons
            local unit = Settings.grid_size * Drawing.scale
            local sz = BUTTON_SIZE * unit
            local rect = {
                x = 0,
                y = section_rect.y + (FRAME_COLUMN_HEIGHT - BUTTON_SIZE) * 0.5 * unit,
                width = sz,
                height = sz,
            }
            for button_index, v in ipairs(BUTTONS) do
                rect.x = button_draw_data[button_index].x + unit * (BUTTON_COLUMN_WIDTH - BUTTON_SIZE) * 0.5
                if input.joy[v.input] then
                    BreitbandGraphics.fill_ellipse(rect, BUTTON_COLORS[button_draw_data[button_index].color_index].button)
                end
                BreitbandGraphics.draw_ellipse(rect, input.joy[v.input] and '#000000FF' or '#00000050', 1)
            end

            if loop_targets[input] then
                BreitbandGraphics.draw_rectangle(section_rect, '#FF8000FF', 2)
            end

            if input.loop then
                BreitbandGraphics.draw_rectangle(section_rect, '#0064FFFF', 2)
            end

            if section_index == sheet.preview_input.section_index and sheet.preview_input.input_index == input_index then
                BreitbandGraphics.draw_rectangle(section_rect, '#FF0000FF', 1)
            end

            if section_index == sheet.active_input.section_index and sheet.active_input.input_index == input_index then
                BreitbandGraphics.draw_rectangle(section_rect, '#64FF64FF', 1)
            end
        end

        section_rect.y = section_rect.y + section_rect.height
    end)

    for _, deferred in pairs(deferred_calls) do
        deferred()
    end
end

--#endregion

function __impl.render(draw)
    local current_sheet = SemanticWorkflowProject:asserted_current()

    local num_rows = iterate_input_rows(SemanticWorkflowProject:asserted_current(), nil)
    local baseline, scrollbar_rect = draw_scrollbar(num_rows)
    local button_draw_data = draw_color_codes(baseline, scrollbar_rect, math.min(num_rows, MAX_DISPLAYED_SECTIONS)) or
        nil
    draw_headers(current_sheet, draw, button_draw_data)

    local section_rect = grid_rect(COL_COLLAPSE_OR_PREVIEW_1, ROW2, COL_BUTTONS_END - COL_COLLAPSE_OR_PREVIEW_1 - SCROLLBAR_WIDTH, FRAME_COLUMN_HEIGHT, 0)
    if handle_scroll_and_buttons(section_rect, button_draw_data, num_rows) then
        current_sheet:run_to_preview()
    end

    draw_sections_gui(current_sheet, draw, section_rect, button_draw_data)
end
