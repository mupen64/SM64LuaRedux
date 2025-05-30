---@type FrameListGui
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

---constants---

local UID <const> = dofile(views_path .. "PianoRoll/UID.lua")["FrameList"]

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
    {background={r=000, g=000, b=255, a=100}, button={r=000, g=000, b=190, a=255}}, -- A
    {background={r=000, g=177, b=022, a=100}, button={r=000, g=230, b=044, a=255}}, -- B
    {background={r=111, g=111, b=111, a=100}, button={r=200, g=200, b=200, a=255}}, -- Z
    {background={r=200, g=000, b=000, a=100}, button={r=255, g=000, b=000, a=255}}, -- Start
    {background={r=200, g=200, b=000, a=100}, button={r=255, g=255, b=000, a=255}}, -- 4 C Buttons
    {background={r=111, g=111, b=111, a=100}, button={r=200, g=200, b=200, a=255}}, -- L + R Buttons
    {background={r=055, g=055, b=055, a=100}, button={r=035, g=035, b=035, a=255}}, -- 4 DPad Buttons
}

local VIEW_MODE_HEADERS <const> = { "PIANO_ROLL_FRAMELIST_STICK", "PIANO_ROLL_FRAMELIST_UNTIL" }

---logic---

local scrollOffset = 0

function __impl.allocate_uids(EnumNext)
    local base = EnumNext(MAX_DISPLAYED_SECTIONS * NUM_UIDS_PER_ROW)
    return {
        SheetName = EnumNext(),
        Scrollbar = EnumNext(),
        Row = function(index)
            return base + (index - 1) * NUM_UIDS_PER_ROW
        end,
    }
end

---@function Iterates all sections as an input row, including their follow-up frames for non-collapsed sections
---@param sheet Sheet The sheet over whose sections to iterate
local function IterateInputRows(sheet, callback)
    local totalInputsCounted = 1
    local totalSectionsCounted = 1
    for sectionIndex = 1, sheet:num_sections(), 1 do
        local section = sheet.sections[sectionIndex]
        for inputIndex = 1, #section.inputs, 1 do
            if callback and callback(section, section.inputs[inputIndex], totalSectionsCounted, totalInputsCounted, inputIndex) then
                return totalInputsCounted
            end

            totalInputsCounted = totalInputsCounted + 1
            if section.collapsed then break end
        end
        totalSectionsCounted = totalSectionsCounted + 1
    end
    return totalInputsCounted - 1
end

local function UpdateScroll(wheel, numRows)
    scrollOffset = math.max(0, math.min(numRows - MAX_DISPLAYED_SECTIONS, scrollOffset - wheel))
end

local function InterpolateVectorsToInt(a, b, f)
    local result = {}
    for k, v in pairs(a) do
        result[k] = math.floor(v + (b[k] - v) * f)
    end
    return result
end

local function DrawHeaders(sheet, draw, viewIndex, buttonDrawData)
    local backgroundColor = InterpolateVectorsToInt(draw.backgroundColor, {r = 127, g = 127, b = 127}, 0.25)
    BreitbandGraphics.fill_rectangle(grid_rect(0, ROW0, COL_1, ROW2 - ROW0, 0), backgroundColor)

    draw:text(grid_rect(0, ROW0, 2, 1), "start", Locales.str("PIANO_ROLL_FRAMELIST_START") .. sheet.startGT)

    draw:text(grid_rect(3, ROW0, 1, 0.5), "start", Locales.str("PIANO_ROLL_FRAMELIST_NAME"))
    local prev_font_size = ugui.standard_styler.params.font_size
    ugui.standard_styler.params.font_size = ugui.standard_styler.params.font_size * 0.75
    sheet.name = ugui.textbox({
        uid = UID.SheetName,
        is_enabled = true,
        rectangle = grid_rect(4, ROW0, 4, 0.5),
        text = sheet.name
    })
    PianoRollProject:set_current_name(sheet.name)
    ugui.standard_styler.params.font_size = prev_font_size
    ugui.standard_styler.font_size = prev_font_size

    draw:text(grid_rect(COL0, ROW1, COL1 - COL0, 1), "start", Locales.str("PIANO_ROLL_FRAMELIST_SECTION"))
    draw:text(grid_rect(COL1, ROW1, COL6 - COL1, 1), "start", Locales.str(VIEW_MODE_HEADERS[viewIndex]))

    if not buttonDrawData then return end

    local rect = grid_rect(0, ROW1, 0.333, 1)
    for i, v in ipairs(BUTTONS) do
        rect.x = buttonDrawData[i].x
        draw:text(rect, "center", v.text)
    end
end

local function DrawScrollbar(numRows)
    local baseline = grid_rect(COL_1, ROW2, BUTTON_COLUMN_WIDTH, FRAME_COLUMN_HEIGHT, 0)
    local unit = Settings.grid_size * Drawing.scale
    local numActuallyShownRows = math.min(MAX_DISPLAYED_SECTIONS, numRows)
    local scrollbarRect = {
        x = baseline.x - SCROLLBAR_WIDTH * unit,
        y = baseline.y,
        width = SCROLLBAR_WIDTH * unit,
        height = baseline.height * numActuallyShownRows,
    }

    local maxScroll = numRows - MAX_DISPLAYED_SECTIONS
    if numRows > 0 and maxScroll > 0 then
        local relativeScroll = ugui.scrollbar({
            uid = UID.Scrollbar,
            rectangle = scrollbarRect,
            value = scrollOffset / maxScroll,
            ratio = numActuallyShownRows / numRows,
        })
        scrollOffset = math.floor(relativeScroll * maxScroll + 0.5)
    end

    return baseline, scrollbarRect
end

local function DrawColorCodes(baseline, scrollbarRect, numDisplaySections)
    local rect = {
        x = scrollbarRect.x - baseline.width * #BUTTONS,
        y = baseline.y,
        width = baseline.width,
        height = baseline.height * numDisplaySections,
    }

    local i = 1
    local colorIndex = 1
    local buttonDrawData = {}

    local function DrawNext(amount)
        for k = 0, amount - 1, 1 do
            buttonDrawData[i] = {x = rect.x + k * rect.width, colorIndex = colorIndex}
            i = i + 1
        end
        BreitbandGraphics.fill_rectangle(
            {x = rect.x, y = rect.y, width = rect.width * amount, height = rect.height},
            BUTTON_COLORS[colorIndex].background
        )
        colorIndex = colorIndex + 1
        rect.x = rect.x + rect.width * amount
    end

    DrawNext(1) -- A
    DrawNext(1) -- B
    DrawNext(1) -- Z
    DrawNext(1) -- Start
    DrawNext(4) -- 4 C Buttons
    DrawNext(2) -- L + R Buttons
    DrawNext(4) -- 4 DPad Buttons
    buttonDrawData[#buttonDrawData + 1] = { x = rect.x }

    return buttonDrawData
end

local placing = 0
local function HandleScrollAndButtons(sectionRect, buttonDrawData, numRows)
    local mouseX = ugui_environment.mouse_position.x
    local relativeY = ugui_environment.mouse_position.y - sectionRect.y
    local inRange = mouseX >= sectionRect.x and mouseX <= sectionRect.x + sectionRect.width and relativeY >= 0
    local unscrolledHoverIndex = math.ceil(relativeY / sectionRect.height)
    local hoveringIndex = unscrolledHoverIndex + scrollOffset
    local anyChange = false
    inRange = inRange and unscrolledHoverIndex <= MAX_DISPLAYED_SECTIONS
    UpdateScroll(inRange and ugui_environment.wheel or 0, numRows)
    if inRange then
        -- act as if the mouse wheel was not moved in order to prevent other controls from scrolling on accident
        ugui_environment.wheel = 0
        ugui.internal.environment.wheel = 0
    end

    if not buttonDrawData then return end

    IterateInputRows(PianoRollProject:asserted_current(), function(section, input, sectionIndex, inputIndex)
        if inputIndex == hoveringIndex and inRange and section ~= nil then
            for buttonIndex, v in ipairs(BUTTONS) do
                local inRangeX = mouseX >= buttonDrawData[buttonIndex].x and mouseX < buttonDrawData[buttonIndex + 1].x
                if ugui.internal.is_mouse_just_down() and inRangeX then
                    placing = input.joy[v.input] and -1 or 1
                    input.joy[v.input] = placing
                    anyChange = true
                elseif ugui.internal.environment.is_primary_down and placing ~= 0 then
                    if inRangeX then
                        anyChange = input.joy[v.input] ~= (placing == 1)
                        input.joy[v.input] = placing == 1
                    end
                else
                    placing = 0
                end
            end
        end
    end)
    return anyChange
end

---@param sheet Sheet
local function DrawSectionsGui(sheet, draw, viewIndex, sectionRect, buttonDrawData)

    local function span(x1, x2, height)
        local r = grid_rect(x1, 0, x2 - x1, height, 0)
        return {x = r.x, y = sectionRect.y, width = r.width, height = height and r.height or sectionRect.height}
    end

    ---@param section Section
    IterateInputRows(sheet, function(section, input, sectionIndex, totalInputs, inputSubIndex)
        if totalInputs <= scrollOffset then return false end

        --TODO: color code section success
        local shade = totalInputs % 2 == 0 and 123 or 80
        local blueMultiplier = sectionIndex % 2 == 1 and 2 or 1

        if totalInputs > MAX_DISPLAYED_SECTIONS + scrollOffset then
            local extraSections = sheet:num_sections() - sectionIndex
            BreitbandGraphics.fill_rectangle(span(0, COL_1), {r=138, g=148, b=138, a=66})
            draw:text(span(COL1, COL_1), "start", "+ " .. extraSections .. " sections")
            return true
        end

        local tasState = input.tasState
        local frameBox = span(COL0 + 0.3, COL1)

        local uidBase = UID.Row(totalInputs - scrollOffset)
        local uidOffset = -1
        local function NextUid() uidOffset = uidOffset + 1 return uidOffset + uidBase end

        BreitbandGraphics.fill_rectangle(sectionRect, {r=shade, g=shade, b=shade * blueMultiplier, a=66})

        if inputSubIndex == 1 then
            section.collapsed = not ugui.toggle_button({
                uid = NextUid(),
                rectangle = span(COL0, COL0 + 0.3),
                text = section.collapsed and "[icon:arrow_right]" or "[icon:arrow_down]",
                tooltip = Locales.str(section.collapsed and "PIANO_ROLL_INPUTS_EXPAND_SECTION" or "PIANO_ROLL_INPUTS_COLLAPSE_SECTION"),
                is_checked = not section.collapsed,
                is_enabled = #section.inputs > 1
            }) or #section.inputs == 1;
        end

        draw:text(frameBox, "end", sectionIndex .. ":")

        if ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, frameBox) then
            sheet.previewFrame = { sectionIndex = sectionIndex, frameIndex =  inputSubIndex }
            sheet:run_to_preview()
        end

        if viewIndex == 1 then
            local joystickBox = span(COL1, COL2)
            ugui.joystick({
                uid = NextUid(),
                rectangle = span(COL1, COL2, FRAME_COLUMN_HEIGHT),
                position = {x = input.joy.X, y = -input.joy.Y},
            })

            if BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, joystickBox) then
                if ugui.internal.is_mouse_just_down() and not ugui_environment.held_keys["control"] then
                    for _, section in pairs(sheet.sections) do
                        for _, input in pairs(section.inputs) do
                            input.editing = false
                        end
                    end
                    input.editing = true
                elseif ugui.internal.environment.is_primary_down then
                    sheet.activeFrame = { sectionIndex = sectionIndex, frameIndex = inputSubIndex }
                    input.editing = true
                end
            end

            if input.editing then
                BreitbandGraphics.fill_rectangle(joystickBox, {r = 0, g = 200, b = 0, a = 100})
            end

            draw:text(span(COL2, COL3), "center", MODE_TEXTS[tasState.movement_mode + 1])

            if tasState.movement_mode == MovementModes.match_angle then
                draw:text(span(COL4, COL5), "end", tostring(tasState.goal_angle))
                draw:text(span(COL5, COL6), "end", tasState.strain_left and '<' or (tasState.strain_right and '>' or '-'))
            end
        elseif viewIndex == 2 then
            local endActionBox = span(COL1, COL6)
            draw:text(endActionBox, "start", section.endAction)

            if BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, endActionBox) then
                if ugui.internal.is_mouse_just_down() then
                    sheet.activeFrame = { sectionIndex = sectionIndex, frameIndex = 1 }
                end
            end
        end

        -- draw buttons
        local unit = Settings.grid_size * Drawing.scale
        local sz = BUTTON_SIZE * unit
        local rect = {x = 0, y = sectionRect.y + (FRAME_COLUMN_HEIGHT - BUTTON_SIZE) * 0.5 * unit, width = sz, height = sz}
        for buttonIndex, v in ipairs(BUTTONS) do
            rect.x = buttonDrawData[buttonIndex].x + unit * (BUTTON_COLUMN_WIDTH - BUTTON_SIZE) * 0.5
            if input.joy[v.input] then
                BreitbandGraphics.fill_ellipse(rect, BUTTON_COLORS[buttonDrawData[buttonIndex].colorIndex].button)
            end
            BreitbandGraphics.draw_ellipse(rect, {r=0, g=0, b=0, a=input.joy[v.input] and 255 or 80}, 1)
        end

        if sectionIndex == sheet.previewFrame.sectionIndex and sheet.previewFrame.frameIndex == inputSubIndex then
            BreitbandGraphics.draw_rectangle(sectionRect, {r=255, g=0, b=0}, 1)
        end

        if sectionIndex == sheet.activeFrame.sectionIndex and sheet.activeFrame.frameIndex == inputSubIndex then
            BreitbandGraphics.draw_rectangle(sectionRect, {r=100, g=255, b=100}, 1)
        end

        sectionRect.y = sectionRect.y + sectionRect.height
    end)
end

--- Renders the sheets, indicating whether an update by the user has been made that should cause a rerun
function __impl.render(draw)
    local currentSheet = PianoRollProject:asserted_current()

    local numRows = IterateInputRows(PianoRollProject:asserted_current(), nil)
    local baseline, scrollbarRect = DrawScrollbar(numRows)
    local buttonDrawData = DrawColorCodes(baseline, scrollbarRect, math.min(numRows, MAX_DISPLAYED_SECTIONS)) or nil
    DrawHeaders(currentSheet, draw, __impl.view_index, buttonDrawData)

    local sectionRect = grid_rect(COL0, ROW2, COL_1 - COL0 - SCROLLBAR_WIDTH, FRAME_COLUMN_HEIGHT, 0)
    if HandleScrollAndButtons(sectionRect, buttonDrawData, numRows) then
        currentSheet:run_to_preview()
    end

    local prev_joystick_tip_size = ugui.standard_styler.params.joystick.tip_size
    ugui.standard_styler.params.joystick.tip_size = 4 * Drawing.scale
    DrawSectionsGui(currentSheet, draw, __impl.view_index, sectionRect, buttonDrawData)
    ugui.standard_styler.params.joystick.tip_size = prev_joystick_tip_size
end