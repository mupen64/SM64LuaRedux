local name = "Joystick"

local UID = dofile(views_path .. "PianoRoll/UID.lua")[name]
local FrameListGui = dofile(views_path .. "PianoRoll/FrameListGui.lua")

local function AllocateUids(EnumNext)
    return {
        CopyEntireState = EnumNext(),
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
        AtanStrain = EnumNext(),
        AtanN = EnumNext(3),
        AtanD = EnumNext(3),
        AtanE = EnumNext(3),
        TrimEnd = EnumNext(),
    }
end

local function AnyEntries(table) for _ in pairs(table) do return true end return false end

local function MagnitudeControls(draw, sheet, newValues, top)
    local mediumControlHeight = 0.75

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
        text=Locales.str("PIANO_ROLL_CONTROL_SPDKICK"),
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
        text=Locales.str("MAG_RESET"),
    }) then
        newValues.goal_mag = 127
    end
end

local function AtanControls(draw, sheet, newValues, top)
    local controlHeight = 0.75
    local newAtan = ugui.toggle_button({
        uid = UID.AtanStrain,
        rectangle = grid_rect(0, top, 1.5, controlHeight),
        text=Locales.str("PIANO_ROLL_CONTROL_ATAN"),
        is_checked = newValues.atan_strain
    })
    if sheet.selection ~= nil and newAtan and not newValues.atan_strain then
        -- TODO: document why these +1 are correct (if they are lol)
        newValues.atan_start = sheet.selection:min() + sheet.startGT + 1
        newValues.atan_n = sheet.selection:max() - sheet.selection:min() + 1
        newValues.dyaw = true
        newValues.movement_mode = MovementModes.match_angle
    end
    newValues.atan_strain = newAtan
    if newValues.movement_mode ~= MovementModes.match_angle then
        newValues.atan_strain = false
    end

    draw:text(grid_rect(1.5, top, 0.75, controlHeight), "end", "Qf:")
    local quarterStep = (newValues.atan_n % 1) * 4
    local newQuarterstep = ugui.spinner({
        uid = UID.AtanN,

        rectangle = grid_rect(2.25, top, 1.25, controlHeight),
        value = quarterStep == 0 and 4 or quarterStep,
        minimum_value = 1,
        maximum_value = 4,
    })
    newValues.atan_n = math.ceil(newValues.atan_n - 1) + newQuarterstep / 4

    draw:text(grid_rect(3.5, top, 0.75, controlHeight), "end", "D:")
    newValues.atan_d = ugui.spinner({
        uid = UID.AtanD,

        rectangle = grid_rect(4.25, top, 2.25, controlHeight),
        value = newValues.atan_d,
        minimum_value = -1000000,
        maximum_value = 1000000,
        increment = math.pow(10, Settings.atan_exp),
    })

    draw:text(grid_rect(6.5, top, 0.5, controlHeight), "end", "E:")
    Settings.atan_exp = ugui.spinner({
        uid = UID.AtanE,

        rectangle = grid_rect(7, top, 1, controlHeight),
        value = Settings.atan_exp,
        minimum_value = -9,
        maximum_value = 5,
    })
end

local function ControlsForSelected(draw)

    local smallControlHeight = 0.5
    local largeControlHeight = 1.0
    local top = 10

    local sheet = PianoRollProject:AssertedCurrent()

    local newValues = {}
    CloneInto(newValues, TASState)

    local displayPosition = {x = TASState.manual_joystick_x or 0, y = -(TASState.manual_joystick_y or 0)}
    local newPosition = ugui.joystick({
        uid = UID.Joypad,
        rectangle = grid_rect(0, top + 1, 2, 2),
        position = displayPosition,
    })
    if newPosition.x ~= displayPosition.x or newPosition.y ~= displayPosition.y then
        newValues.movement_mode = MovementModes.manual
        newValues.manual_joystick_x = math.min(127, math.floor(newPosition.x + 0.5)) or TASState.manual_joystick_x
        newValues.manual_joystick_y = math.min(127, -math.floor(newPosition.y + 0.5)) or TASState.manual_joystick_y
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
        maximum_value = 127
    })
    rect.x = rect.x + rect.width
    newValues.manual_joystick_y = ugui.spinner({
        uid = UID.JoypadSpinnerY,
        rectangle = rect,
        value = newValues.manual_joystick_y,
        minimum_value = -128,
        maximum_value = 127
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
        text=Locales.str("PIANO_ROLL_CONTROL_MANUAL"),
        is_checked = newValues.movement_mode == MovementModes.manual
    }) then
        newValues.movement_mode = MovementModes.manual
    end

    if ugui.toggle_button({
        uid = UID.MovementModeMatchYaw,
        rectangle = grid_rect(6.5, top + 1, 1.5, largeControlHeight),
        text=Locales.str("PIANO_ROLL_CONTROL_MATCH_YAW"),
        is_checked = newValues.movement_mode == MovementModes.match_yaw
    }) then
        newValues.movement_mode = MovementModes.match_yaw
    end

    if ugui.toggle_button({
        uid = UID.MovementModeMatchAngle,
        rectangle = grid_rect(5, top + 2, 1.5, largeControlHeight),
        text=Locales.str("PIANO_ROLL_CONTROL_MATCH_ANGLE"),
        is_checked = newValues.movement_mode == MovementModes.match_angle
    }) then
        newValues.movement_mode = MovementModes.match_angle
    end

    if ugui.toggle_button({
        uid = UID.MovementModeReverseAngle,
        rectangle = grid_rect(6.5, top + 2, 1.5, largeControlHeight),
        text=Locales.str("PIANO_ROLL_CONTROL_REVERSE_ANGLE"),
        is_checked = newValues.movement_mode == MovementModes.reverse_angle
    }) then
        newValues.movement_mode = MovementModes.reverse_angle
    end

    newValues.dyaw = ugui.toggle_button({
        uid = UID.DYaw,
        rectangle = grid_rect(2, top + 2, 1, largeControlHeight),
        text=Locales.str("PIANO_ROLL_CONTROL_DYAW"),
        is_checked = newValues.dyaw
    })

    MagnitudeControls(draw, sheet, newValues, top + 3)
    AtanControls(draw, sheet, newValues, top + 4)

    ugui.standard_styler.params.spinner.button_size = previousThickness

    local changes = CloneInto(TASState, newValues)
    local anyChanges = AnyEntries(changes)
    local currentSheet = PianoRollProject:AssertedCurrent()
    if anyChanges and sheet.selection ~= nil then
        for i = sheet.selection:min(), sheet.selection:max(), 1 do
            local dest = currentSheet.frames[i]
            -- we need to restore the button state in case PianoRollProject.copyEntireState is true
            local btns = dest.joy
            CloneInto(dest, PianoRollProject.copyEntireState and TASState or changes)
            dest.joy = btns
        end
    end

    if anyChanges then
        currentSheet:jumpTo(currentSheet.previewIndex)
    end

    local controlHeight = 0.75
    if ugui.button({
        uid = UID.TrimEnd,
        rectangle = grid_rect(0, top + 0.25, 1.5, controlHeight),
        text = "Trim",
    }) then
        currentSheet:trimEnd()
    end

    PianoRollProject.copyEntireState = ugui.toggle_button({
        uid = UID.CopyEntireState,
        rectangle = grid_rect(4.5, top + 0.25, 3.5, controlHeight),
        text = "Copy entire state",
        is_checked = PianoRollProject.copyEntireState,
    })
end

return {
    name = name,
    Render = function(draw)
        ControlsForSelected(draw)
        FrameListGui.Render(draw)
    end,
    AllocateUids = AllocateUids,
}