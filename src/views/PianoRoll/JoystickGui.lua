local name = "Inputs"

local UID = dofile(views_path .. "PianoRoll/UID.lua")[name]
local FrameListGui = dofile(views_path .. "PianoRoll/FrameListGui.lua")

local mediumControlHeight = 0.75
local smallControlHeight = 0.50
local largeControlHeight = 0.75
local labelHeight = 0.25

local TOP = 10.25
local MAX_ACTION_GUESSES = 5

local selectedViewIndex = 1

local function AllocateUids(EnumNext)
    return {
        ViewCarrousel = EnumNext(),
        InsertInput = EnumNext(),
        DeleteInput = EnumNext(),

        -- Joystick Controls
        Joypad = EnumNext(),
        JoypadSpinnerX = EnumNext(3),
        JoypadSpinnerY = EnumNext(3),
        GoalAngle = EnumNext(),
        GoalMag = EnumNext(),
        StrainLeft = EnumNext(),
        StrainRight = EnumNext(),
        StrainAlways = EnumNext(),
        StrainSpeedTarget = EnumNext(),
        MovementModeManual = EnumNext(),
        MovementModeMatchYaw = EnumNext(),
        MovementModeMatchAngle = EnumNext(),
        MovementModeReverseAngle = EnumNext(),
        DYaw = EnumNext(),
        SpeedKick = EnumNext(),
        ResetMag = EnumNext(),

        -- Section Controls
        InsertSection = EnumNext(),
        DeleteSection = EnumNext(),
        Kind = EnumNext(),
        Timeout = EnumNext(),
        EndAction = EnumNext(),
        EndActionTextbox = EnumNext(),
        AvailableActions = EnumNext(MAX_ACTION_GUESSES),
    }
end

local function AnyEntries(table) for _ in pairs(table) do return true end return false end

--- ### Section controls ### ---

local endActionSearchText = nil

local function ControlsForEndAction(section, draw, column, top)
    draw:text(grid_rect(column, top, 4, labelHeight), "start", Locales.str("PIANO_ROLL_TIMELINE_END_ACTION"))
    if endActionSearchText == nil then
        -- end action "dropdown" is not visible
        if ugui.button({
            uid = UID.EndAction,
            rectangle = grid_rect(column, top + labelHeight, 4, largeControlHeight),
            text = section.endAction
        }) then
            endActionSearchText = ""
            ugui.internal.active_control = UID.EndActionTextbox
            ugui.internal.clear_active_control_after_mouse_up = false
        end
    end
    if endActionSearchText ~= nil then
        -- end action "dropdown" is visible
        endActionSearchText = ugui.textbox({
            uid = UID.EndActionTextbox,
            rectangle = grid_rect(column, top + labelHeight, 4, largeControlHeight),
            text = endActionSearchText,
        }):lower()
        local i = 0
        local matchPattern = "^" .. endActionSearchText
        for _, actionName in pairs(Locales.raw().ACTIONS) do
            if actionName:find(matchPattern) ~= nil then
                if ugui.button({
                    uid = UID.AvailableActions + i,
                    rectangle = grid_rect(column, top + labelHeight + largeControlHeight + i * smallControlHeight, 4, smallControlHeight),
                    text = actionName
                }) then
                    endActionSearchText = nil
                    section.endAction = actionName
                    anyChanges = true
                end

                i = i + 1
                if (i >= MAX_ACTION_GUESSES) then break end
            end
        end
    end
end

local function SectionControlsForSelected(draw)
    local sheet = PianoRollProject:AssertedCurrent()

    local top = TOP
    local col_timeout = 4

    local anyChanges = false
    local hasValidSelection = sheet.sections[sheet.activeFrame.sectionIndex]

    if not hasValidSelection then
        draw:text(grid_rect(0, top, 8, 1), "center", Locales.str("PIANO_ROLL_NO_SELECTION"))
        return
    end

    if ugui.button({
        uid = UID.InsertSection,
        rectangle = grid_rect(0, top, 1.5, largeControlHeight),
        text = Locales.str("PIANO_ROLL_TIMELINE_INSERT"),
    }) then
        local newSection = Section.new("idle", 150)
        table.insert(sheet.sections, sheet.activeFrame.sectionIndex + 1, newSection)
        anyChanges = true
    end

    if ugui.button({
        uid = UID.DeleteSection,
        rectangle = grid_rect(1.5, top, 1.5, largeControlHeight),
        text = Locales.str("PIANO_ROLL_TIMELINE_DELETE"),
    }) then
        ---@param x Section
        sheet.sections = lualinq.where(sheet.sections, function(x) return not x.inputs[1].editing end)
    end

    local section = sheet.sections[sheet.activeFrame.sectionIndex]
    if section == nil then return end

    top = top + 1

    draw:text(grid_rect(col_timeout, top, 2, labelHeight), "start", Locales.str("PIANO_ROLL_TIMELINE_TIMEOUT"))
    local oldTimeout = section.timeout
    section.timeout = ugui.numberbox({
        uid = UID.Timeout,
        rectangle = grid_rect(col_timeout, top + labelHeight, 2, largeControlHeight),
        value = section.timeout,
        places = 4,
    })
    anyChanges = anyChanges or oldTimeout ~= section.timeout

    ControlsForEndAction(section, draw, 0, top)

    if anyChanges then
        sheet:runToPreview()
    end
end

-- ### Joystick Controls ### ---

local function MagnitudeControls(draw, sheet, newValues, top)
    draw:text(grid_rect(2, top, 2, mediumControlHeight), "end", Locales.str("PIANO_ROLL_CONTROL_MAG"))
    newValues.goal_mag = ugui.numberbox({
        uid = UID.GoalMag,
        rectangle = grid_rect(4, top, 1.5, mediumControlHeight),
        places = 3,
        value = math.max(0, math.min(127, newValues.goal_mag))
    })
    -- a value starting with a 9 likely indicates that the user scrolled down
    -- on the most significant digit while its value was 0, so we "clamp" to 0 here
    -- this makes it so typing in a 9 explicitly will set the entire value to 0 as well,
    -- but I'll accept this weirdness for now until a more coherently bounded numberbox implementation exists.
    if newValues.goal_mag >= 900 then newValues.goal_mag = 0 end

    if ugui.button({
        uid = UID.SpeedKick,
        rectangle = grid_rect(5.5, top, 1.5, mediumControlHeight),
        text = Locales.str("PIANO_ROLL_CONTROL_SPDKICK"),
    }) then
        if newValues.goal_mag ~= 48 then
            newValues.goal_mag = 48
        else
            newValues.goal_mag = 127
        end
    end

    if ugui.button({
        uid = UID.ResetMag,
        rectangle = grid_rect(7, top, 1, mediumControlHeight),
        text = Locales.str("MAG_RESET"),
    }) then
        newValues.goal_mag = 127
    end
end

local function ControlsForSelected(draw)

    local smallControlHeight = 0.5
    local largeControlHeight = 1.0
    local top = TOP

    local sheet = PianoRollProject:AssertedCurrent()

    local newValues = {}
    local editedSection = sheet.sections[sheet.activeFrame.sectionIndex]
    local editedInput = editedSection and editedSection.inputs[sheet.activeFrame.frameIndex] or nil

    if editedInput == nil then
        draw:text(grid_rect(0, top, 8, 1), "center", Locales.str("PIANO_ROLL_NO_SELECTION"))
        return
    end

    local oldValues = editedInput.tasState
    CloneInto(newValues, oldValues)

    local displayPosition = {x = oldValues.manual_joystick_x or 0, y = -(oldValues.manual_joystick_y or 0)}
    local newPosition = ugui.joystick({
        uid = UID.Joypad,
        rectangle = grid_rect(0, top + 1, 2, 2),
        position = displayPosition,
    })
    if newPosition.x ~= displayPosition.x or newPosition.y ~= displayPosition.y then
        newValues.movement_mode = MovementModes.manual
        newValues.manual_joystick_x = math.min(127, math.floor(newPosition.x + 0.5)) or oldValues.manual_joystick_x
        newValues.manual_joystick_y = math.min(127, -math.floor(newPosition.y + 0.5)) or oldValues.manual_joystick_y
    end
    local previousThickness = ugui.standard_styler.params.spinner.button_size
    ugui.standard_styler.params.spinner.button_size = 4
    local rect = grid_rect(0, top + 3, 1, smallControlHeight, 0)
    rect.y = rect.y + Settings.grid_gap
    newValues.manual_joystick_x = ugui.spinner({
        uid = UID.JoypadSpinnerX,
        rectangle = rect,
        value = newValues.manual_joystick_x,
        minimum_value = -128,
        maximum_value = 127,
        increment = 1,
    })
    rect.x = rect.x + rect.width
    newValues.manual_joystick_y = ugui.spinner({
        uid = UID.JoypadSpinnerY,
        rectangle = rect,
        value = newValues.manual_joystick_y,
        minimum_value = -128,
        maximum_value = 127,
        increment = 1,
    })

    newValues.goal_angle = math.abs(ugui.numberbox({
        uid = UID.GoalAngle,
        is_enabled = newValues.movement_mode == MovementModes.match_angle,
        rectangle = grid_rect(3, top + 2, 2, largeControlHeight),
        places = 5,
        value = newValues.goal_angle
    }))

    newValues.strain_always = ugui.toggle_button({
        uid = UID.StrainAlways,
        rectangle = grid_rect(2, top + 1, 1.5, smallControlHeight),
        text = Locales.str("D99_ALWAYS"),
        is_checked = newValues.strain_always
    })

    newValues.strain_speed_target = ugui.toggle_button({
        uid = UID.StrainSpeedTarget,
        rectangle = grid_rect(3.5, top + 1, 1.5, smallControlHeight),
        text = Locales.str("D99"),
        is_checked = newValues.strain_speed_target
    })

    if ugui.toggle_button({
        uid = UID.StrainLeft,
        rectangle = grid_rect(2, top + 1.5, 1.5, smallControlHeight),
        text = '[icon:arrow_left]',
        is_checked = newValues.strain_left
    }) then
        newValues.strain_right = false
        newValues.strain_left = true
    else
        newValues.strain_left = false
    end

    if ugui.toggle_button({
        uid = UID.StrainRight,
        rectangle = grid_rect(3.5, top + 1.5, 1.5, smallControlHeight),
        text = '[icon:arrow_right]',
        is_checked = newValues.strain_right
    }) then
        newValues.strain_left = false
        newValues.strain_right = true
    else
        newValues.strain_right = false
    end

    if ugui.toggle_button({
        uid = UID.MovementModeManual,
        rectangle = grid_rect(5, top + 1, 1.5, largeControlHeight),
        text = Locales.str("PIANO_ROLL_CONTROL_MANUAL"),
        is_checked = newValues.movement_mode == MovementModes.manual
    }) then
        newValues.movement_mode = MovementModes.manual
    end

    if ugui.toggle_button({
        uid = UID.MovementModeMatchYaw,
        rectangle = grid_rect(6.5, top + 1, 1.5, largeControlHeight),
        text = Locales.str("PIANO_ROLL_CONTROL_MATCH_YAW"),
        is_checked = newValues.movement_mode == MovementModes.match_yaw
    }) then
        newValues.movement_mode = MovementModes.match_yaw
    end

    if ugui.toggle_button({
        uid = UID.MovementModeMatchAngle,
        rectangle = grid_rect(5, top + 2, 1.5, largeControlHeight),
        text = Locales.str("PIANO_ROLL_CONTROL_MATCH_ANGLE"),
        is_checked = newValues.movement_mode == MovementModes.match_angle
    }) then
        newValues.movement_mode = MovementModes.match_angle
    end

    if ugui.toggle_button({
        uid = UID.MovementModeReverseAngle,
        rectangle = grid_rect(6.5, top + 2, 1.5, largeControlHeight),
        text = Locales.str("PIANO_ROLL_CONTROL_REVERSE_ANGLE"),
        is_checked = newValues.movement_mode == MovementModes.reverse_angle
    }) then
        newValues.movement_mode = MovementModes.reverse_angle
    end

    newValues.dyaw = ugui.toggle_button({
        uid = UID.DYaw,
        rectangle = grid_rect(2, top + 2, 1, largeControlHeight),
        text = Locales.str("PIANO_ROLL_CONTROL_DYAW"),
        is_checked = newValues.dyaw
    })

    MagnitudeControls(draw, sheet, newValues, top + 3)

    ugui.standard_styler.params.spinner.button_size = previousThickness

    local changes = CloneInto(oldValues, newValues)
    local anyChanges = AnyEntries(changes)
    local currentSheet = PianoRollProject:AssertedCurrent()
    if anyChanges and editedInput then
        for _, section in pairs(sheet.sections) do
            for _, input in pairs(section.inputs) do
                if input.editing then
                    CloneInto(input.tasState, Settings.piano_roll.edit_entire_state and oldValues or changes)
                end
            end
        end
    end

    top = TOP
    if ugui.button({
        uid = UID.InsertInput,
        rectangle = grid_rect(0, top, 1.5, mediumControlHeight),
        text = Locales.str("PIANO_ROLL_JOYSTICK_INSERT_INPUT"),
    }) then
        table.insert(editedSection.inputs, currentSheet.activeFrame.frameIndex, ugui.internal.deep_clone(editedInput))
        anyChanges = true
    end

    if ugui.button({
        uid = UID.DeleteInput,
        rectangle = grid_rect(1.5, top, 1.5, mediumControlHeight),
        text = Locales.str("PIANO_ROLL_JOYSTICK_REMOVE_INPUT"),
        is_enabled = #editedSection.inputs > 1
    }) then
        table.remove(editedSection.inputs, currentSheet.activeFrame.frameIndex)
        anyChanges = true
    end

    if anyChanges then
        currentSheet:runToPreview()
    end
end

return {
    name = name,
    Render = function(draw)
        local drawFuncs = { ControlsForSelected, SectionControlsForSelected }
        selectedViewIndex = ugui.carrousel_button({
             uid = UID.ViewCarrousel,
             rectangle = grid_rect(6, TOP, 2, mediumControlHeight),
             value = selectedViewIndex,
             items = { "Joystick", "Section" },
             selected_index = selectedViewIndex,
            })
        drawFuncs[selectedViewIndex](draw)
        FrameListGui.Render(draw, selectedViewIndex, selectedViewIndex == 1)
    end,
    AllocateUids = AllocateUids,
    HelpKey = "JOYSTICK_GUI"
}