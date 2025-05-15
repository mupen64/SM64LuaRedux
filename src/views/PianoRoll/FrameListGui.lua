local name = "FrameList"

local UID = dofile(views_path .. "PianoRoll/UID.lua")[name]

---constants---

local ModeTexts = { "-", "D", "M", "Y", "R", "A" }
local Buttons = {
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

local col0 = 0.0
local col1 = 1.3
local col2 = 1.8
local col3 = 2.1
local col4 = 2.3
local col5 = 3.1
local col6 = 3.3
local col_1 = 8.0

local row0 = 1.00
local row1 = 1.50
local row2 = 2.25

local buttonColumnWidth = 0.3
local buttonSize = 0.22
local frameColumnHeight = 0.5
local scrollbarWidth = 0.3

local maxDisplayedSections = 15
local scrollOffset = 0

local NUM_UIDS_PER_ROW = 2
local buttonColors = {
    {background={r=000, g=000, b=255, a=100}, button={r=000, g=000, b=190, a=255}}, -- A
    {background={r=000, g=177, b=022, a=100}, button={r=000, g=230, b=044, a=255}}, -- B
    {background={r=111, g=111, b=111, a=100}, button={r=200, g=200, b=200, a=255}}, -- Z
    {background={r=200, g=000, b=000, a=100}, button={r=255, g=000, b=000, a=255}}, -- Start
    {background={r=200, g=200, b=000, a=100}, button={r=255, g=255, b=000, a=255}}, -- 4 C Buttons
    {background={r=111, g=111, b=111, a=100}, button={r=200, g=200, b=200, a=255}}, -- L + R Buttons
    {background={r=055, g=055, b=055, a=100}, button={r=035, g=035, b=035, a=255}}, -- 4 DPad Buttons
}

local VIEW_MODE_HEADERS = { "PIANO_ROLL_FRAMELIST_STICK", "PIANO_ROLL_FRAMELIST_UNTIL" }

local function AllocateUids(EnumNext)
    local base = EnumNext(maxDisplayedSections * NUM_UIDS_PER_ROW)
    return {
        SheetName = EnumNext(),
        Scrollbar = EnumNext(),
        Row = function(index)
            return base + (index - 1) * NUM_UIDS_PER_ROW
        end,
    }
end

---logic---

---@function Iterates all sections as an input row, including their follow-up frames for non-collapsed sections
---@param sheet Sheet The sheet over whose sections to iterate
local function IterateInputRows(sheet, callback)
    local totalInputsCounted = 1
    local totalSectionsCounted = 1
    for sectionIndex = 1, sheet:numSections(), 1 do
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
    scrollOffset = math.max(0, math.min(numRows - maxDisplayedSections, scrollOffset - wheel))
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
    BreitbandGraphics.fill_rectangle(grid_rect(0, row0, col_1, row2 - row0, 0), backgroundColor)

    draw:text(grid_rect(0, row0, 2, 1), "start", Locales.str("PIANO_ROLL_FRAMELIST_START") .. sheet.startGT)

    draw:text(grid_rect(3, row0, 1, 0.5), "start", Locales.str("PIANO_ROLL_FRAMELIST_NAME"))
    local prev_font_size = ugui.standard_styler.params.font_size
    ugui.standard_styler.params.font_size = ugui.standard_styler.params.font_size * 0.75
    sheet.name = ugui.textbox({
        uid = UID.SheetName,
        is_enabled = true,
        rectangle = grid_rect(4, row0, 4, 0.5),
        text = sheet.name
    })
    PianoRollProject:SetCurrentName(sheet.name)
    ugui.standard_styler.params.font_size = prev_font_size
    ugui.standard_styler.font_size = prev_font_size

    draw:text(grid_rect(col0, row1, col1 - col0, 1), "start", Locales.str("PIANO_ROLL_FRAMELIST_SECTION"))
    draw:text(grid_rect(col1, row1, col6 - col1, 1), "start", Locales.str(VIEW_MODE_HEADERS[viewIndex]))

    if not buttonDrawData then return end

    local rect = grid_rect(0, row1, 0.333, 1)
    for i, v in ipairs(Buttons) do
        rect.x = buttonDrawData[i].x
        draw:text(rect, "center", v.text)
    end
end

local function DrawScrollbar(numRows)
    local baseline = grid_rect(col_1, row2, buttonColumnWidth, frameColumnHeight, 0)
    local unit = Settings.grid_size * Drawing.scale
    local numActuallyShownRows = math.min(maxDisplayedSections, numRows)
    local scrollbarRect = {
        x = baseline.x - scrollbarWidth * unit,
        y = baseline.y,
        width = scrollbarWidth * unit,
        height = baseline.height * numActuallyShownRows,
    }

    local maxScroll = numRows - maxDisplayedSections
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
        x = scrollbarRect.x - baseline.width * #Buttons,
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
            buttonColors[colorIndex].background
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
    inRange = inRange and unscrolledHoverIndex <= maxDisplayedSections
    UpdateScroll(inRange and ugui_environment.wheel or 0, numRows)
    if inRange then
        -- act as if the mouse wheel was not moved in order to prevent other controls from scrolling on accident
        ugui_environment.wheel = 0
        ugui.internal.environment.wheel = 0
    end

    if not buttonDrawData then return end

    IterateInputRows(PianoRollProject:AssertedCurrent(), function(section, input, sectionIndex, inputIndex)
        if inputIndex == hoveringIndex and inRange and section ~= nil then
            for buttonIndex, v in ipairs(Buttons) do
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

        if totalInputs > maxDisplayedSections + scrollOffset then
            local extraSections = sheet:numSections() - sectionIndex
            BreitbandGraphics.fill_rectangle(span(0, col_1), {r=138, g=148, b=138, a=66})
            draw:text(span(col1, col_1), "start", "+ " .. extraSections .. " sections")
            return true
        end

        local tasState = input.tasState
        local frameBox = span(col0 + 0.3, col1)

        local uidBase = UID.Row(totalInputs - scrollOffset)
        local uidOffset = -1
        local function NextUid() uidOffset = uidOffset + 1 return uidOffset + uidBase end

        BreitbandGraphics.fill_rectangle(sectionRect, {r=shade, g=shade, b=shade * blueMultiplier, a=66})

        if inputSubIndex == 1 then
            section.collapsed = not ugui.toggle_button({
                uid = NextUid(),
                rectangle = span(col0, col0 + 0.3),
                text = section.collapsed and "[icon:arrow_right]" or "[icon:arrow_down]",
                tooltip = Locales.str(section.collapsed and "PIANO_ROLL_INPUTS_EXPAND_SECTION" or "PIANO_ROLL_INPUTS_COLLAPSE_SECTION"),
                is_checked = not section.collapsed,
                is_enabled = #section.inputs > 1
            }) or #section.inputs == 1;
        end

        draw:text(frameBox, "end", sectionIndex .. ":")

        if ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, frameBox) then
            sheet.previewFrame = { sectionIndex = sectionIndex, frameIndex =  inputSubIndex }
            sheet:runToPreview()
        end

        if viewIndex == 1 then
            local joystickBox = span(col1, col2)
            ugui.joystick({
                uid = NextUid(),
                rectangle = span(col1, col2, frameColumnHeight),
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

            draw:text(span(col2, col3), "center", ModeTexts[tasState.movement_mode + 1])

            if tasState.movement_mode == MovementModes.match_angle then
                draw:text(span(col4, col5), "end", tostring(tasState.goal_angle))
                draw:text(span(col5, col6), "end", tasState.strain_left and '<' or (tasState.strain_right and '>' or '-'))
            end
        elseif viewIndex == 2 then
            local endActionBox = span(col1, col6)
            draw:text(endActionBox, "start", section.endAction)

            if BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, endActionBox) then
                if ugui.internal.is_mouse_just_down() then
                    sheet.activeFrame = { sectionIndex = sectionIndex, frameIndex = 1 }
                end
            end
        end

        -- draw buttons
        local unit = Settings.grid_size * Drawing.scale
        local sz = buttonSize * unit
        local rect = {x = 0, y = sectionRect.y + (frameColumnHeight - buttonSize) * 0.5 * unit, width = sz, height = sz}
        for buttonIndex, v in ipairs(Buttons) do
            rect.x = buttonDrawData[buttonIndex].x + unit * (buttonColumnWidth - buttonSize) * 0.5
            if input.joy[v.input] then
                BreitbandGraphics.fill_ellipse(rect, buttonColors[buttonDrawData[buttonIndex].colorIndex].button)
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

---@class FrameListGui
local __clsFrameListGui = {}

--- Renders the sheets, indicating whether an update by the user has been made that should cause a rerun
function __clsFrameListGui.Render(draw, viewIndex)
    local currentSheet = PianoRollProject:AssertedCurrent()

    local numRows = IterateInputRows(PianoRollProject:AssertedCurrent(), nil)
    local baseline, scrollbarRect = DrawScrollbar(numRows)
    local buttonDrawData = DrawColorCodes(baseline, scrollbarRect, math.min(numRows, maxDisplayedSections)) or nil
    DrawHeaders(currentSheet, draw, viewIndex, buttonDrawData)

    local sectionRect = grid_rect(col0, row2, col_1 - col0 - scrollbarWidth, frameColumnHeight, 0)
    if HandleScrollAndButtons(sectionRect, buttonDrawData, numRows) then
        currentSheet:runToPreview()
    end

    local prev_joystick_tip_size = ugui.standard_styler.params.joystick.tip_size
    ugui.standard_styler.params.joystick.tip_size = 4 * Drawing.scale
    DrawSectionsGui(currentSheet, draw, viewIndex, sectionRect, buttonDrawData)
    ugui.standard_styler.params.joystick.tip_size = prev_joystick_tip_size
end

---@type FrameListGui
return {
    Render = __clsFrameListGui.Render,
    AllocateUids = AllocateUids,
}