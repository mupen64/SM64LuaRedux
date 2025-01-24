local UID = dofile(views_path .. "PianoRoll/UID.lua")
local _, Selection = dofile(views_path .. "PianoRoll/PianoRoll.lua")

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
local col1 = 1.0
local col2 = 1.5
local col3 = 1.8
local col4 = 2.0
local col5 = 2.8
local col6 = 3.0
local col_1 = 8.0

local row0 = 1.00
local row1 = 1.50
local row2 = 2.25

local buttonColumnWidth = 0.3
local buttonSize = 0.22
local frameColumnHeight = 0.5
local scrollbarWidth = 0.3

local maxDisplayedFrames = 15
local scrollOffset = 0

local buttonColors = {
    {background={r=000, g=000, b=255, a=100}, button={r=000, g=000, b=190, a=255}}, -- A
    {background={r=000, g=177, b=022, a=100}, button={r=000, g=230, b=044, a=255}}, -- B
    {background={r=111, g=111, b=111, a=100}, button={r=200, g=200, b=200, a=255}}, -- Z
    {background={r=200, g=000, b=000, a=100}, button={r=255, g=000, b=000, a=255}}, -- Start
    {background={r=200, g=200, b=000, a=100}, button={r=255, g=255, b=000, a=255}}, -- 4 C Buttons
    {background={r=111, g=111, b=111, a=100}, button={r=200, g=200, b=200, a=255}}, -- L + R Buttons
    {background={r=055, g=055, b=055, a=100}, button={r=035, g=035, b=035, a=255}}, -- 4 DPad Buttons
}

---logic---

local function NumDisplayFrames()
    return math.min(PianoRollProject:AssertedCurrent():numFrames(), maxDisplayedFrames)
end

local function MaxScroll()
    return PianoRollProject:AssertedCurrent():numFrames() - maxDisplayedFrames
end

local function UpdateScroll(wheel)
    scrollOffset = math.max(0, math.min(MaxScroll(), scrollOffset - wheel))
end

local function InterpolateVectorsToInt(a, b, f)
    local result = {}
    for k, v in pairs(a) do
        result[k] = math.floor(v + (b[k] - v) * f)
    end
    return result
end

local function DrawHeaders(pianoRoll, draw, buttonDrawData)
    local backgroundColor = InterpolateVectorsToInt(draw.backgroundColor, {r = 127, g = 127, b = 127}, 0.25)
    BreitbandGraphics.fill_rectangle(grid_rect(0, row0, col_1, row2 - row0, 0), backgroundColor)

    draw:text(grid_rect(0, row0, 2, 1), "start", "Start: " .. pianoRoll.startGT)
    draw:text(grid_rect(3, row0, 1, 0.5), "start", "Name")
    local prev_font_size = ugui.standard_styler.params.font_size
    ugui.standard_styler.params.font_size = ugui.standard_styler.params.font_size * 0.75
    pianoRoll.name = ugui.textbox({
        uid = UID.PianoRollName,
        is_enabled = true,
        rectangle = grid_rect(4, row0, 4, 0.5),
        text = pianoRoll.name
    })
    PianoRollProject:SetCurrentName(pianoRoll.name)
    ugui.standard_styler.params.font_size = prev_font_size
    draw:text(grid_rect(col0, row1, col1 - col0, 1), "start", "Frame")
    draw:text(grid_rect(col1, row1, col6 - col1, 1), "start", "Joystick")

    local rect = grid_rect(0, row1, 0.333, 1)
    for i, v in ipairs(Buttons) do
        rect.x = buttonDrawData[i].x
        draw:text(rect, "center", v.text)
    end
end

local function DrawColorCodes()

    local unit = Settings.grid_size * Drawing.scale
    local numDisplayFrames = NumDisplayFrames()
    local baseline = grid_rect(col_1, row2, buttonColumnWidth, frameColumnHeight, 0)
    local scrollbarRect = {
        x = baseline.x - scrollbarWidth * unit,
        y = baseline.y,
        width = scrollbarWidth * unit,
        height = baseline.height * numDisplayFrames
    }
    local rect = {
        x = scrollbarRect.x - baseline.width * #Buttons,
        y = baseline.y,
        width = baseline.width,
        height = baseline.height * numDisplayFrames
     }

    if numDisplayFrames > 0 then
        local maxScroll = MaxScroll()
        local relativeScroll = ugui.scrollbar({
            uid = UID.FrameListScrollbar,
            rectangle = scrollbarRect,
            value = scrollOffset / maxScroll,
            ratio = 1 / (PianoRollProject:AssertedCurrent():numFrames() / numDisplayFrames),
        })
        scrollOffset = math.floor(relativeScroll * maxScroll + 0.5)
    end

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
local function PlaceAndUnplaceButtons(frameRect, buttonDrawData)
    local currentSheet = PianoRollProject:AssertedCurrent()
    local mouseX = ugui_environment.mouse_position.x
    local relativeY = ugui_environment.mouse_position.y - frameRect.y
    local inRange = mouseX >= frameRect.x and mouseX <= frameRect.x + frameRect.width and relativeY >= 0
    local frameIndex = math.floor(relativeY / frameRect.height)
    local hoveringGlobalTimer = frameIndex + scrollOffset + currentSheet.startGT
    local frame = currentSheet.frames[hoveringGlobalTimer]
    local anyChange = false
    inRange = inRange and frameIndex < maxDisplayedFrames
    UpdateScroll(inRange and ugui_environment.wheel or 0)
    if inRange then
        -- act as if the mouse wheel was not moved in order to prevent other controls from scrolling on accident
        ugui_environment.wheel = 0
        ugui.internal.environment.wheel = 0
    end

    if inRange and frame ~= nil then
        for buttonIndex, v in ipairs(Buttons) do
            local inRangeX = mouseX >= buttonDrawData[buttonIndex].x and mouseX < buttonDrawData[buttonIndex + 1].x
            if ugui.internal.is_mouse_just_down() and inRangeX then
                placing = frame.joy[v.input] and -1 or 1
                frame.joy[v.input] = placing
                anyChange = true
            elseif ugui.internal.environment.is_primary_down and placing ~= 0 then
                if inRangeX then
                    anyChange = frame.joy[v.input] ~= (placing == 1)
                    frame.joy[v.input] = placing == 1
                end
            else
                placing = 0
            end
        end
    end
    return anyChange
end

local function DrawFramesGui(pianoRoll, draw, buttonDrawData)

    if ugui.internal.is_mouse_just_up() and pianoRoll.selection ~= nil then
        pianoRoll:edit(pianoRoll.selection.endGT)
    end

    local frameRect = grid_rect(col0, row2, col_1 - col0 - scrollbarWidth, frameColumnHeight, 0)
    local anyChange = PlaceAndUnplaceButtons(frameRect, buttonDrawData)

    local function span(x1, x2, height)
        local r = grid_rect(x1, 0, x2 - x1, height, 0)
        return {x = r.x, y = frameRect.y, width = r.width, height = height and r.height or frameRect.height}
    end

    local globalTimerValue = Memory.current.mario_global_timer
    for i = 0, pianoRoll:numFrames() - 1, 1 do
        local frameNumber = i + scrollOffset
        local globalTimer = pianoRoll.startGT + frameNumber
        local shade = globalTimer % 2 == 0 and 123 or 80
        local blueMultiplier = globalTimer < globalTimerValue and 2 or 1

        if i >= maxDisplayedFrames then
            local extraFrames = pianoRoll.endGT - globalTimer
            if extraFrames > 0 then
                BreitbandGraphics.fill_rectangle(span(0, col_1), {r=138, g=148, b=138, a=66})
                draw:text(span(col1, col_1), "start", "+ " .. extraFrames .. " frames")
            end
            break
        end

        local input = pianoRoll.frames[globalTimer]
        if input == nil then
            input = {}
            local previous = pianoRoll.frames[globalTimer - 1]
            if previous == nil then
                RecordPianoRollInput(input)
            else
                CloneInto(input, previous)
                input.joy = {}
                CloneInto(input.joy, previous.joy)
             end
            pianoRoll.frames[globalTimer] = input
        end

        local uidBase = UID.UIDCOUNT + i * 20
        local frameBox = span(col0 + 0.25, col1)
        draw:text(frameBox, "end", frameNumber .. ":")

        if ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, frameBox) then
            pianoRoll:jumpTo(globalTimer)
        end

        ugui.joystick({
            uid = uidBase + 1,
            rectangle = span(col1, col2, frameColumnHeight),
            position = {x = input.preview_joystick_x, y = -input.preview_joystick_y},
        })

        local joystickBox = span(col1, col2)
        BreitbandGraphics.fill_rectangle(frameRect, {r=shade, g=shade, b=shade * blueMultiplier, a=66})

        if BreitbandGraphics.is_point_inside_rectangle(ugui_environment.mouse_position, joystickBox) then
            if ugui.internal.is_mouse_just_down()  then
                pianoRoll.selection = Selection.new(input.goal_angle, globalTimer)
            elseif pianoRoll.selection ~= nil and ugui.internal.environment.is_primary_down then
                pianoRoll.selection.endGT = globalTimer
            end
        end
        if pianoRoll.selection ~= nil and pianoRoll.selection:min() <= globalTimer and pianoRoll.selection:max() >= globalTimer then
            BreitbandGraphics.fill_rectangle(joystickBox, {r = 0, g = 200, b = 0, a = 100})
        end

        draw:text(span(col2, col3), "center", ModeTexts[input.movement_mode + 1])

        if input.movement_mode == MovementModes.match_angle then
            draw:text(span(col4, col5), "end", tostring(input.goal_angle))
            draw:text(span(col5, col6), "end", input.strain_left and '<' or (input.strain_right and '>' or '-'))
        end

        local unit = Settings.grid_size * Drawing.scale
        local sz = buttonSize * unit
        local rect = {x = 0, y = frameRect.y + (frameColumnHeight - buttonSize) * 0.5 * unit, width = sz, height = sz}
        for buttonIndex, v in ipairs(Buttons) do
            rect.x = buttonDrawData[buttonIndex].x + unit * (buttonColumnWidth - buttonSize) * 0.5
            if input.joy[v.input] then
                BreitbandGraphics.fill_ellipse(rect, buttonColors[buttonDrawData[buttonIndex].colorIndex].button)
            end
            BreitbandGraphics.draw_ellipse(rect, {r=0, g=0, b=0, a=input.joy[v.input] and 255 or 80}, 1)
        end

        if (globalTimer == pianoRoll.previewGT) then
            BreitbandGraphics.draw_rectangle(frameRect, {r=255, g=0, b=0}, 1)
        end

        if (globalTimer == pianoRoll.editingGT) then
            BreitbandGraphics.draw_rectangle(frameRect, {r=100, g=255, b=100}, 1)
        end

        frameRect.y = frameRect.y + frameRect.height
    end

    return anyChange
end

---@class LuaGui
local __clsLuaGui = {}

--- Renders the piano roll, indicating whether an update by the user has been made that should cause a rerun
function __clsLuaGui.Render() end

---@type LuaGui
return {
    Render = function(draw)
        local currentSheet = PianoRollProject:AssertedCurrent()

        local buttonDrawData = DrawColorCodes()
        DrawHeaders(currentSheet, draw, buttonDrawData)

        local prev_joystick_tip_size = ugui.standard_styler.joystick_tip_size
        ugui.standard_styler.joystick_tip_size = 4 * Drawing.scale
        local anyChanges = DrawFramesGui(currentSheet, draw, buttonDrawData)
        ugui.standard_styler.joystick_tip_size = prev_joystick_tip_size

        if anyChanges then
            currentSheet:jumpTo(currentSheet.previewGT)
        end
    end,
}