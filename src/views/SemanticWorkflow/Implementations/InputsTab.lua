--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@type InputsTab
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

__impl.name = function() return Locales.str('SEMANTIC_WORKFLOW_INPUTS_TAB_NAME') end
__impl.help_key = 'INPUTS_TAB'

---@type InputListGui
local InputListGui = dofile(views_path .. 'SemanticWorkflow/Definitions/InputListGui.lua')

---@type Gui
local Gui = dofile(views_path .. 'SemanticWorkflow/Definitions/Gui.lua')

--#region Constants

local LABEL_HEIGHT <const> = 0.25

local TOP <const> = 10.25
local MAX_ACTION_GUESSES <const> = 5

--#endregion

--#region Logic

local previous_preview_input
local atan_start = 0

local UID = UIDProvider.allocate_once('InputsTab', function(enum_next)
    return {
        ViewCarrousel = enum_next(),

        -- Joystick Controls
        Joypad = enum_next(),
        JoypadSpinnerX = enum_next(4),
        JoypadSpinnerY = enum_next(4),
        GoalAngle = enum_next(2),
        GoalMag = enum_next(2),
        HighMag = enum_next(),
        StrainLeft = enum_next(),
        StrainRight = enum_next(),
        StrainAlways = enum_next(),
        StrainSpeedTarget = enum_next(),
        MovementModeManual = enum_next(),
        MovementModeMatchYaw = enum_next(),
        MovementModeMatchAngle = enum_next(),
        MovementModeReverseYaw = enum_next(),
        DYaw = enum_next(),
        Atan = enum_next(),
        AtanReverse = enum_next(),
        AtanRetime = enum_next(),
        AtanButtons = enum_next(10),
        AtanFieldLabels = enum_next(5),
        SpeedKick = enum_next(),
        ResetMag = enum_next(),
        Swim = enum_next(),

        -- Section Controls
        Timeout = enum_next(2),
        EndAction = enum_next(),
        EndActionTextbox = enum_next(),
        AvailableActions = enum_next(MAX_ACTION_GUESSES),
    }
end)

local function any_entries(table)
    for _ in pairs(table) do return true end
    return false
end

--#region Timeout and end condition controls

local end_action_search_text = nil

local function controls_for_end_action(input, draw, column, top)
    draw:text(grid_rect(column, top, 4, LABEL_HEIGHT), 'start', Locales.str('SEMANTIC_WORKFLOW_INPUTS_END_ACTION'))
    if end_action_search_text == nil then
        -- end action "dropdown" is not visible
        if ugui.button({
                uid = UID.EndAction,
                rectangle = grid_rect(column, top + LABEL_HEIGHT, 4, Gui.MEDIUM_CONTROL_HEIGHT),
                text = Locales.action(input.end_action),
                tooltip = Locales.str('SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TOOL_TIP'),
            }) then
            end_action_search_text = ''
            ugui.internal.keyboard_captured_control = UID.EndActionTextbox
            ugui.internal.clear_active_control_after_mouse_up = false
        end
    end
    if end_action_search_text ~= nil then
        -- end action "dropdown" is visible
        end_action_search_text = ugui.textbox({
            uid = UID.EndActionTextbox,
            rectangle = grid_rect(column, top + LABEL_HEIGHT, 4, Gui.MEDIUM_CONTROL_HEIGHT),
            text = end_action_search_text,
            tooltip = Locales.str('SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TYPE_TO_SEARCH_TOOL_TIP'),
        }):lower()
        local i = 0
        local match_pattern = '^' .. end_action_search_text
        for action, action_name in pairs(Locales.raw().ACTIONS) do
            if action_name:find(match_pattern) ~= nil then
                if ugui.button({
                        uid = UID.AvailableActions + i,
                        rectangle = grid_rect(column, top + LABEL_HEIGHT + Gui.MEDIUM_CONTROL_HEIGHT + i * Gui.SMALL_CONTROL_HEIGHT, 4, Gui.SMALL_CONTROL_HEIGHT),
                        text = action_name,
                    }) then
                    end_action_search_text = nil
                    input.end_action = action
                end

                i = i + 1
                if (i >= MAX_ACTION_GUESSES) then break end
            end
        end
    end
end

local function section_controls_for_selected(draw, edited_input)
    local sheet = SemanticWorkflowProject:asserted_current()

    local top = TOP
    local col_timeout = 4

    local any_changes = false

    if edited_input == nil then return end

    top = top + 1

    draw:text(grid_rect(col_timeout, top, 2, LABEL_HEIGHT), 'start', Locales.str('SEMANTIC_WORKFLOW_INPUTS_TIMEOUT'))
    local old_timeout = edited_input.timeout
    edited_input.timeout = ugui.numberbox({
        uid = UID.Timeout,
        rectangle = grid_rect(col_timeout, top + LABEL_HEIGHT, 2, Gui.MEDIUM_CONTROL_HEIGHT),
        value = edited_input.timeout,
        places = 4,
        tooltip = Locales.str('SEMANTIC_WORKFLOW_INPUTS_TIMEOUT_TOOL_TIP'),
    })
    any_changes = any_changes or old_timeout ~= edited_input.timeout

    controls_for_end_action(edited_input, draw, 0, top)

    if any_changes then
        sheet:run_to_preview()
    end
end

--#endregion

--#region Joystick Controls

local function lower_controls(draw, old_values, new_values, top)
    local display_position = { x = old_values.manual_joystick_x or 0, y = -(old_values.manual_joystick_y or 0) }
    local new_position, meta = ugui.joystick({
        uid = UID.Joypad,
        rectangle = grid_rect(0, top, 2, 2),
        position = display_position,
    })
    if meta.signal_change == ugui.signal_change_states.started then
        new_values.movement_mode = MovementModes.manual
        new_values.manual_joystick_x = math.min(127, math.floor(new_position.x + 0.5)) or old_values.manual_joystick_x
        new_values.manual_joystick_y = math.min(127, -math.floor(new_position.y + 0.5)) or old_values.manual_joystick_y
    end

    draw:text(grid_rect(2, top + 1, 0.5, Gui.SMALL_CONTROL_HEIGHT), 'end', 'X:')
    new_values.manual_joystick_x = ugui.spinner({
        uid = UID.JoypadSpinnerX,
        rectangle = grid_rect(2.5, top + 1, 1.5, Gui.SMALL_CONTROL_HEIGHT, 0),
        value = new_values.manual_joystick_x,
        minimum_value = -128,
        maximum_value = 127,
        increment = 1,
    })

    draw:text(grid_rect(2, top + 1.5, 0.5, Gui.SMALL_CONTROL_HEIGHT), 'end', 'Y:')
    new_values.manual_joystick_y = ugui.spinner({
        uid = UID.JoypadSpinnerY,
        rectangle = grid_rect(2.5, top + 1.5, 1.5, Gui.SMALL_CONTROL_HEIGHT, 0),
        value = new_values.manual_joystick_y,
        minimum_value = -128,
        maximum_value = 127,
        increment = 1,
    })

    new_values.swim = ugui.toggle_button({
        uid = UID.Swim,
        rectangle = grid_rect(6.5, top + 1, 1.5, Gui.LARGE_CONTROL_HEIGHT),
        text = 'Swim',
        is_checked = new_values.swim,
    })

    new_values.goal_mag = ugui.numberbox({
        uid = UID.GoalMag,
        rectangle = grid_rect(2, top, 2, Gui.LARGE_CONTROL_HEIGHT),
        places = 3,
        value = math.max(0, math.min(127, new_values.goal_mag)),
    })
    -- a value starting with a 9 likely indicates that the user scrolled down
    -- on the most significant digit while its value was 0, so we "clamp" to 0 here
    -- this makes it so typing in a 9 explicitly will set the entire value to 0 as well,
    -- but I'll accept this weirdness for now until a more coherently bounded numberbox implementation exists.
    if new_values.goal_mag >= 900 then new_values.goal_mag = 0 end

    if ugui.button({
        uid = UID.SpeedKick,
        rectangle = grid_rect(4, top, 1.5, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('SEMANTIC_WORKFLOW_CONTROL_SPDKICK'),
    }) then
        if new_values.goal_mag ~= 48 then
            new_values.goal_mag = 48
        else
            new_values.goal_mag = 127
        end
    end

    new_values.high_magnitude = ugui.toggle_button({
        uid = UID.HighMag,
        rectangle = grid_rect(5.5, top, 1.5, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('SEMANTIC_WORKFLOW_CONTROL_HIGH_MAG'),
        is_checked = new_values.high_magnitude,
    })

    if ugui.button({
        uid = UID.ResetMag,
        rectangle = grid_rect(7, top, 1, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('MAG_RESET'),
    }) then
        new_values.goal_mag = 127
    end
end

local function noop() end

local function select_atan_end(selection_input)
    local sheet = SemanticWorkflowProject:asserted_current()
    sheet.preview_input = selection_input
    sheet:run_to_preview()
    InputListGui.special_select_handler = noop
end

local function select_atan_start(selection_input)
    print(selection_input)
    local sheet = SemanticWorkflowProject:asserted_current()
    previous_preview_input = sheet.preview_input
    sheet.preview_input = selection_input
    sheet:run_to_preview()
    InputListGui.special_select_handler = select_atan_end
end

local function atan_controls(draw, sheet, new_values, top)
    local any_changes = false

    if not sheet.busy then
        if InputListGui.special_select_handler == select_atan_end then
            atan_start = Memory.current.mario_global_timer - 1
        elseif InputListGui.special_select_handler == noop then
            local atan_end = Memory.current.mario_global_timer
            new_values.atan_start = atan_start
            new_values.atan_n = atan_end - atan_start
            sheet.preview_input = previous_preview_input
            InputListGui.special_select_handler = nil
            any_changes = true
        end
    end

    local atan_retime_state =
        InputListGui.special_select_handler == select_atan_start and 'SEMANTIC_WORKFLOW_CONTROL_ATAN_SELECT_START'
        or InputListGui.special_select_handler == select_atan_end and 'SEMANTIC_WORKFLOW_CONTROL_ATAN_SELECT_END'
        or 'SEMANTIC_WORKFLOW_CONTROL_ATAN_RETIME'
    if ugui.button({
            uid = UID.AtanRetime,
            rectangle = grid_rect(0, top, 2.5, Gui.LARGE_CONTROL_HEIGHT),
            text = Locales.str(atan_retime_state),
            is_enabled = InputListGui.special_select_handler == nil,
        }) then
        InputListGui.special_select_handler = select_atan_start
    end

    local theme = Styles.theme()
    local foreground_color = Drawing.foreground_color()

    local function atan_field(index, text, table, field, increment, low_bound, high_bound)
        local width = 1.6
        local x = index * width
        ugui.label({
            uid = UID.AtanFieldLabels + index,
            rectangle = grid_rect(x, top + 1, width, 0.5),
            text = text .. tostring(table[field]),
            color = foreground_color,
            font_size = theme.font_size * Drawing.scale,
            font_name = 'Consolas',
            align_x = BreitbandGraphics.alignment.center,
            align_y = BreitbandGraphics.alignment.center,
        })

        if ugui.button({
            uid = UID.AtanButtons + index * 2,
            rectangle = grid_rect(x, top + 1.5, width / 2, 0.5),
            text = '-',
        }) then
            table[field] = math.max(low_bound, table[field] - increment)
        end

        if ugui.button({
            uid = UID.AtanButtons + index * 2 + 1,
            rectangle = grid_rect(x + width / 2, top + 1.5, width / 2, 0.5),
            text = '+',
        }) then
            table[field] = math.min(high_bound, table[field] + increment)
        end
    end

    atan_field(0, 'E: ', Settings, 'atan_exp', 1, -4, 4)
    atan_field(1, 'R: ', new_values, 'atan_r', math.pow(10, Settings.atan_exp), -math.huge, math.huge)
    atan_field(2, 'D: ', new_values, 'atan_d', math.pow(10, Settings.atan_exp), -math.huge, math.huge)
    atan_field(3, 'N: ', new_values, 'atan_n', math.pow(10, math.max(-0.6020599913279624, Settings.atan_exp)), 1, math.huge)
    atan_field(4, 'S: ', new_values, 'atan_start', math.pow(10, math.max(0, Settings.atan_exp)), -math.huge, math.huge)
end

local function upper_controls(new_values, top)
    if ugui.toggle_button({
        uid = UID.MovementModeMatchYaw,
        rectangle = grid_rect(0, top, 4, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('SEMANTIC_WORKFLOW_CONTROL_MATCH_YAW'),
        is_checked = new_values.movement_mode == MovementModes.match_yaw,
    }) then
        new_values.movement_mode = MovementModes.match_yaw
    end

    if ugui.toggle_button({
        uid = UID.MovementModeReverseYaw,
        rectangle = grid_rect(4, top, 4, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('SEMANTIC_WORKFLOW_CONTROL_REVERSE_YAW'),
        is_checked = new_values.movement_mode == MovementModes.reverse_yaw,
    }) then
        new_values.movement_mode = MovementModes.reverse_yaw
    end

    new_values.goal_angle = math.abs(ugui.numberbox({
        uid = UID.GoalAngle,
        is_enabled = new_values.movement_mode == MovementModes.match_angle,
        rectangle = grid_rect(6, top + 1, 2, Gui.LARGE_CONTROL_HEIGHT),
        places = 5,
        value = new_values.goal_angle,
    }))

    if ugui.toggle_button({
            uid = UID.MovementModeMatchAngle,
            rectangle = grid_rect(0, top + 1, 3, Gui.LARGE_CONTROL_HEIGHT),
            text = Locales.str('SEMANTIC_WORKFLOW_CONTROL_MATCH_ANGLE'),
            is_checked = new_values.movement_mode == MovementModes.match_angle,
        }) then
        new_values.movement_mode = MovementModes.match_angle
    end

    new_values.dyaw = ugui.toggle_button({
        uid = UID.DYaw,
        rectangle = grid_rect(3, top + 1, 1.5, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('SEMANTIC_WORKFLOW_CONTROL_DYAW'),
        is_checked = new_values.dyaw,
    })

    if ugui.toggle_button({
            uid = UID.StrainLeft,
            rectangle = grid_rect(4.5, top + 1, 0.75, Gui.LARGE_CONTROL_HEIGHT),
            text = '[icon:arrow_left]',
            is_checked = new_values.strain_left,
        }) then
        new_values.strain_right = false
        new_values.strain_left = true
    else
        new_values.strain_left = false
    end

    if ugui.toggle_button({
            uid = UID.StrainRight,
            rectangle = grid_rect(5.25, top + 1, 0.75, Gui.LARGE_CONTROL_HEIGHT),
            text = '[icon:arrow_right]',
            is_checked = new_values.strain_right,
        }) then
        new_values.strain_left = false
        new_values.strain_right = true
    else
        new_values.strain_right = false
    end

    new_values.strain_speed_target = ugui.toggle_button({
        uid = UID.StrainSpeedTarget,
        rectangle = grid_rect(0, top + 2, 2, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('D99'),
        is_checked = new_values.strain_speed_target,
    })

    new_values.strain_always = ugui.toggle_button({
        uid = UID.StrainAlways,
        rectangle = grid_rect(2, top + 2, 2, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('D99_ALWAYS'),
        is_checked = new_values.strain_always,
    })

    local new_atan = ugui.toggle_button({
        uid = UID.Atan,
        rectangle = grid_rect(4, top + 2, 3, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('SEMANTIC_WORKFLOW_CONTROL_ATAN'),
        is_checked = new_values.atan_strain,
    })
    if new_atan and not new_values.atan_strain then
        new_values.movement_mode = MovementModes.match_angle
    end
    new_values.atan_strain = new_atan

    new_values.reverse_arc = ugui.toggle_button({
        uid = UID.AtanReverse,
        rectangle = grid_rect(7, top + 2, 1, Gui.LARGE_CONTROL_HEIGHT),
        text = Locales.str('SEMANTIC_WORKFLOW_CONTROL_ATAN_REVERSE'),
        is_checked = new_values.reverse_arc,
    })
end

local function joystick_controls_for_selected(draw, edited_input)
    local top = TOP

    local sheet = SemanticWorkflowProject:asserted_current()

    local new_values = {}

    local old_values = edited_input.tas_state
    CloneInto(new_values, old_values)

    upper_controls(new_values, top + 0.75)
    if new_values.atan_strain then
        atan_controls(draw, sheet, new_values, top + 3.75)
    else
        lower_controls(draw, old_values, new_values, top + 3.75)
    end


    local changes = CloneInto(old_values, new_values)
    local any_changes = any_entries(changes)
    local current_sheet = SemanticWorkflowProject:asserted_current()
    if any_changes and edited_input then
        for _, section in pairs(sheet.sections) do
            for _, input in pairs(section.inputs) do
                if input.editing then
                    CloneInto(input.tas_state, Settings.semantic_workflow.edit_entire_state and old_values or changes)
                end
            end
        end
    end

    if any_changes then
        current_sheet:run_to_preview()
    end
end

--#endregion

--#endregion

function __impl.render(draw)
    local sheet = SemanticWorkflowProject:asserted_current()

    InputListGui.render(draw)

    local draw_funcs = { joystick_controls_for_selected, section_controls_for_selected }

    local edited_section = sheet.sections[sheet.active_input.section_index]
    local edited_input = edited_section and edited_section.inputs[sheet.active_input.input_index] or nil
    if edited_input then
        draw_funcs[InputListGui.view_index](draw, edited_input)
    end
end
