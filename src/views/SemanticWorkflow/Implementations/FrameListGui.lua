---@type FrameListGui
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

--#region Constants

local UID <const> = dofile(views_path .. "SemanticWorkflow/UID.lua")["FrameList"]

local MODE_TEXTS <const> = { "-", "D", "M", "Y", "R", "A" }
local BUTTONS <const> = {
    {input = 'A', text = 'A'},
    {input = 'B', text = 'B'},
    {input = 'Z', text = 'Z'},
    {input = 'start', text = 'S'},
    {input = 'Cup', text = '^'},
    {input = 'Cleft', text = '<'},
    {input = 'Cright', text = '>'},
    {input = 'Cdown', text = 'v'},
    {input = 'L', text = 'L'},
    {input = 'R', text = 'R'},
    {input = 'up', text = '^'},
    {input = 'left', text = '<'},
    {input = 'right', text = '>'},
    {input = 'v', text = 'v'},
}

local COL0 <const> = 0.0
local COL1 <const> = 1.3
local COL2 <const> = 1.8
local COL3 <const> = 2.1
local COL4 <const> = 2.3
local COL5 <const> = 3.1
local COL6 <const> = 3.3
local COL_1 <const> = 8.0

local ROW0 <const> = 1.00
local ROW1 <const> = 1.50
local ROW2 <const> = 2.25

local BUTTON_COLUMN_WIDTH <const> = 0.3
local BUTTON_SIZE <const> = 0.22
local FRAME_COLUMN_HEIGHT <const> = 0.5
local SCROLLBAR_WIDTH <const> = 0.3

local MAX_DISPLAYED_SECTIONS <const> = 15

local NUM_UIDS_PER_ROW <const> = 2
local BUTTON_COLORS <const> = {
    { background = "#0000FF64", button = "#0000BEFF" }, -- A
    { background = "#00B11664", button = "#00E62CFF" }, -- B
    { background = "#6F6F6F64", button = "#C8C8C8FF" }, -- Z
    { background = "#C8000064", button = "#FF0000FF" }, -- Start
    { background = "#C8C80064", button = "#FFFF00FF" }, -- 4 C Buttons
    { background = "#6F6F6F64", button = "#C8C8C8FF" }, -- L + R Buttons
    { background = "#37373764", button = "#323232FF" }, -- 4 DPad Buttons
}

local VIEW_MODE_HEADERS <const> = { "SEMANTIC_WORKFLOW_FRAMELIST_STICK", "SEMANTIC_WORKFLOW_FRAMELIST_UNTIL" }

--#endregion

--#region logic

local scroll_offset = 0

function __impl.allocate_uids(enum_next)
    local base = enum_next(MAX_DISPLAYED_SECTIONS * NUM_UIDS_PER_ROW)
    return {
        SheetName = enum_next(),
        Scrollbar = enum_next(),
        Row = function(index)
            return base + (index - 1) * NUM_UIDS_PER_ROW
        end,
    }
end

---@alias IterateInputsCallback fun(section: Section, input: SectionInputs, section_index: integer, total_inputs_counted: integer, input_index: integer): boolean?

---@function Iterates all sections as an input row, including their follow-up frames for non-collapsed sections
---@param sheet Sheet The sheet over whose sections to iterate
---@param callback IterateInputsCallback? an optional function that, when it returns true, terminates the enumeration
local function iterate_input_rows(sheet, callback)
    local total_inputs_counted = 1
    local total_sections_counted = 1
    for section_index = 1, #sheet.sections, 1 do
        local section = sheet.sections[section_index]
        for input_index = 1, #section.inputs, 1 do
            if callback and callback(section, section.inputs[input_index], total_sections_counted, total_inputs_counted, input_index) then
                return total_inputs_counted
            end

            total_inputs_counted = total_inputs_counted + 1
            if section.collapsed then break end
        end
        total_sections_counted = total_sections_counted + 1
    end
    return total_inputs_counted - 1
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

local function draw_headers(sheet, draw, view_index, button_draw_data)
    local background_color = interpolate_vectors_to_int(draw.background_color, {r = 127, g = 127, b = 127}, 0.25)
    BreitbandGraphics.fill_rectangle(grid_rect(0, ROW0, COL_1, ROW2 - ROW0, 0), background_color)

    draw:text(grid_rect(0, ROW0, 2, 1), "start", Locales.str("SEMANTIC_WORKFLOW_FRAMELIST_START") .. sheet.start_g_t)

    draw:text(grid_rect(3, ROW0, 1, 0.5), "start", Locales.str("SEMANTIC_WORKFLOW_FRAMELIST_NAME"))
    local prev_font_size = ugui.standard_styler.params.font_size
    ugui.standard_styler.params.font_size = ugui.standard_styler.params.font_size * 0.75
    sheet.name = ugui.textbox({
        uid = UID.SheetName,
        is_enabled = true,
        rectangle = grid_rect(4, ROW0, 4, 0.5),
        text = sheet.name
    })
    SemanticWorkflowProject:set_current_name(sheet.name)
    ugui.standard_styler.params.font_size = prev_font_size
    ugui.standard_styler.font_size = prev_font_size

    draw:text(grid_rect(COL0, ROW1, COL1 - COL0, 1), "start", Locales.str("SEMANTIC_WORKFLOW_FRAMELIST_SECTION"))
    draw:text(grid_rect(COL1, ROW1, COL6 - COL1, 1), "start", Locales.str(VIEW_MODE_HEADERS[view_index]))

    if not button_draw_data then return end

    local rect = grid_rect(0, ROW1, 0.333, 1)
    for i, v in ipairs(BUTTONS) do
        rect.x = button_draw_data[i].x
        draw:text(rect, "center", v.text)
    end
end

local function draw_scrollbar(num_rows)
    local baseline = grid_rect(COL_1, ROW2, BUTTON_COLUMN_WIDTH, FRAME_COLUMN_HEIGHT, 0)
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

    local f = Settings.grid_size * Drawing.scale
    BreitbandGraphics.fill_rectangle(
        {x = COL0 * f + Drawing.initial_size.width, y = rect.y, width = (COL1 - COL0) * f, height = rect.height},
        "#FF000028"
    )

    local i = 1
    local color_index = 1
    local button_draw_data = {}

    local function draw_next(amount)
        for k = 0, amount - 1, 1 do
            button_draw_data[i] = {x = rect.x + k * rect.width, color_index = color_index}
            i = i + 1
        end
        BreitbandGraphics.fill_rectangle(
            {x = rect.x, y = rect.y, width = rect.width * amount, height = rect.height},
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

    iterate_input_rows(SemanticWorkflowProject:asserted_current(), function(section, input, section_index, input_index)
        if input_index == hovering_index and in_range and section ~= nil then
            for button_index, v in ipairs(BUTTONS) do
                local in_range_x = mouse_x >= button_draw_data[button_index].x and mouse_x < button_draw_data[button_index + 1].x
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
local function draw_sections_gui(sheet, draw, view_index, section_rect, button_draw_data)

    local function span(x1, x2, height)
        local r = grid_rect(x1, 0, x2 - x1, height, 0)
        return {x = r.x, y = section_rect.y, width = r.width, height = height and r.height or section_rect.height}
    end

    iterate_input_rows(sheet, function(section, input, section_index, total_inputs, input_sub_index)
        if total_inputs <= scroll_offset then return false end

        --TODO: color code section success
        local shade = total_inputs % 2 == 0 and 123 or 80
        local blue_multiplier = section_index % 2 == 1 and 2 or 1

        if total_inputs > MAX_DISPLAYED_SECTIONS + scroll_offset then
            local extra_sections = #sheet.sections - section_index
            BreitbandGraphics.fill_rectangle(span(0, COL_1), "#8A948A42")
            draw:text(span(COL1, COL_1), "start", "+ " .. extra_sections .. " sections")
            return true
        end

        local tas_state = input.tas_state
        local frame_box = span(COL0 + 0.3, COL1)

        local uid_base = UID.Row(total_inputs - scroll_offset)
        local uid_offset = -1
        local function next_uid() uid_offset = uid_offset + 1 return uid_offset + uid_base end

        BreitbandGraphics.fill_rectangle(section_rect, { r = shade, g = shade, b = shade * blue_multiplier, a = 66 })

        if input_sub_index == 1 then
            section.collapsed = not ugui.toggle_button({
                uid = next_uid(),
                rectangle = span(COL0, COL0 + 0.3),
                text = section.collapsed and "[icon:arrow_right]" or "[icon:arrow_down]",
                tooltip = Locales.str(section.collapsed and "SEMANTIC_WORKFLOW_INPUTS_EXPAND_SECTION" or "SEMANTIC_WORKFLOW_INPUTS_COLLAPSE_SECTION"),
                is_checked = not section.collapsed,
                is_enabled = #section.inputs > 1
            }) or #section.inputs == 1;
        end

        draw:text(frame_box, "end", section_index .. ":")

        if ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, frame_box) then
            sheet.preview_frame = { section_index = section_index, frame_index = input_sub_index }
            sheet:run_to_preview()
        end

        local active_frame_box = span(COL1, COL6)
        if view_index == 1 then
            -- mini joysticks and yaw numbers
            local joystick_box = span(COL1, COL2)
            ugui.joystick({
                uid = next_uid(),
                rectangle = span(COL1, COL2, FRAME_COLUMN_HEIGHT),
                position = {x = input.joy.X, y = -input.joy.Y},
            })

            if BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, joystick_box) then
                if ugui.internal.is_mouse_just_down() and not ugui_environment.held_keys["control"] then
                    for _, section in pairs(sheet.sections) do
                        for _, input in pairs(section.inputs) do
                            input.editing = false
                        end
                    end
                    input.editing = true
                elseif ugui.internal.environment.is_primary_down then
                    input.editing = true
                end
            end

            if input.editing then
                BreitbandGraphics.fill_rectangle(joystick_box, "#00C80064")
            end

            draw:text(span(COL2, COL3), "center", MODE_TEXTS[tas_state.movement_mode + 1])

            if tas_state.movement_mode == MovementModes.match_angle then
                draw:text(span(COL4, COL5), "end", tostring(tas_state.goal_angle))
                draw:text(span(COL5, COL6), "end", tas_state.strain_left and '<' or (tas_state.strain_right and '>' or '-'))
            end
        elseif view_index == 2 then
            -- end action
            draw:text(active_frame_box, "start", Locales.action(section.end_action))
        end

        if BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, active_frame_box) then
            if ugui.internal.is_mouse_just_down() then
                if __impl.special_select_handler then
                    __impl.special_select_handler({ section_index = section_index, frame_index = input_sub_index })
                else
                    sheet.active_frame = { section_index = section_index, frame_index = input_sub_index }
                end
            end
        end

        -- draw buttons
        local unit = Settings.grid_size * Drawing.scale
        local sz = BUTTON_SIZE * unit
        local rect = {x = 0, y = section_rect.y + (FRAME_COLUMN_HEIGHT - BUTTON_SIZE) * 0.5 * unit, width = sz, height = sz}
        for button_index, v in ipairs(BUTTONS) do
            rect.x = button_draw_data[button_index].x + unit * (BUTTON_COLUMN_WIDTH - BUTTON_SIZE) * 0.5
            if input.joy[v.input] then
                BreitbandGraphics.fill_ellipse(rect, BUTTON_COLORS[button_draw_data[button_index].color_index].button)
            end
            BreitbandGraphics.draw_ellipse(rect, input.joy[v.input] and "#000000FF" or "#00000050", 1)
        end

        if section_index == sheet.preview_frame.section_index and sheet.preview_frame.frame_index == input_sub_index then
            BreitbandGraphics.draw_rectangle(section_rect, "#FF0000FF", 1)
        end

        if section_index == sheet.active_frame.section_index and sheet.active_frame.frame_index == input_sub_index then
            BreitbandGraphics.draw_rectangle(section_rect, "#64FF64FF", 1)
        end

        section_rect.y = section_rect.y + section_rect.height
    end)
end

--#endregion

function __impl.render(draw)
    local current_sheet = SemanticWorkflowProject:asserted_current()

    local num_rows = iterate_input_rows(SemanticWorkflowProject:asserted_current(), nil)
    local baseline, scrollbar_rect = draw_scrollbar(num_rows)
    local button_draw_data = draw_color_codes(baseline, scrollbar_rect, math.min(num_rows, MAX_DISPLAYED_SECTIONS)) or nil
    draw_headers(current_sheet, draw, __impl.view_index, button_draw_data)

    local section_rect = grid_rect(COL0, ROW2, COL_1 - COL0 - SCROLLBAR_WIDTH, FRAME_COLUMN_HEIGHT, 0)
    if handle_scroll_and_buttons(section_rect, button_draw_data, num_rows) then
        current_sheet:run_to_preview()
    end

    local prev_joystick_tip_size = ugui.standard_styler.params.joystick.tip_size
    ugui.standard_styler.params.joystick.tip_size = 4 * Drawing.scale
    draw_sections_gui(current_sheet, draw, __impl.view_index, section_rect, button_draw_data)
    ugui.standard_styler.params.joystick.tip_size = prev_joystick_tip_size
end