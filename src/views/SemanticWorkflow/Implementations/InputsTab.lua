---@type InputsTab
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

__impl.name = "Inputs"
__impl.help_key = "INPUTS_TAB"

---@type FrameListGui
local FrameListGui = dofile(views_path .. "SemanticWorkflow/Definitions/FrameListGui.lua")
local Section = dofile(views_path .. "SemanticWorkflow/Definitions/Section.lua")

---constants---

local UID <const> = dofile(views_path .. "SemanticWorkflow/UID.lua")[__impl.name]

local MEDIUM_CONTROL_HEIGHT <const> = 0.75
local SMALL_CONTROL_HEIGHT <const> = 0.50
local LARGE_CONTROL_HEIGHT <const> = 0.75
local LABEL_HEIGHT <const> = 0.25

local TOP <const> = 10.25
local MAX_ACTION_GUESSES <const> = 5

---logic---

local selected_view_index = 1

function __impl.allocate_uids(enum_next)
    return {
        ViewCarrousel = enum_next(),
        InsertInput = enum_next(),
        DeleteInput = enum_next(),

        -- Joystick Controls
        Joypad = enum_next(),
        JoypadSpinnerX = enum_next(3),
        JoypadSpinnerY = enum_next(3),
        GoalAngle = enum_next(),
        GoalMag = enum_next(),
        StrainLeft = enum_next(),
        StrainRight = enum_next(),
        StrainAlways = enum_next(),
        StrainSpeedTarget = enum_next(),
        MovementModeManual = enum_next(),
        MovementModeMatchYaw = enum_next(),
        MovementModeMatchAngle = enum_next(),
        MovementModeReverseAngle = enum_next(),
        DYaw = enum_next(),
        Atan = enum_next(),
        AtanN = enum_next(3),
        AtanD = enum_next(3),
        AtanS = enum_next(3),
        AtanE = enum_next(3),
        SpeedKick = enum_next(),
        ResetMag = enum_next(),

        -- Section Controls
        InsertSection = enum_next(),
        DeleteSection = enum_next(),
        Kind = enum_next(),
        Timeout = enum_next(),
        EndAction = enum_next(),
        EndActionTextbox = enum_next(),
        AvailableActions = enum_next(MAX_ACTION_GUESSES),
    }
end

local function any_entries(table) for _ in pairs(table) do return true end return false end

--- ### Section controls ### ---

local end_action_search_text = nil

local function controls_for_end_action(section, draw, column, top)
    draw:text(grid_rect(column, top, 4, LABEL_HEIGHT), "start", Locales.str("SEMANTIC_WORKFLOW_INPUTS_END_ACTION"))
    if end_action_search_text == nil then
        -- end action "dropdown" is not visible
        if ugui.button({
            uid = UID.EndAction,
            rectangle = grid_rect(column, top + LABEL_HEIGHT, 4, LARGE_CONTROL_HEIGHT),
            text = section.end_action,
            tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TOOL_TIP"),
        }) then
            end_action_search_text = ""
            ugui.internal.active_control = UID.EndActionTextbox
            ugui.internal.clear_active_control_after_mouse_up = false
        end
    end
    if end_action_search_text ~= nil then
        -- end action "dropdown" is visible
        end_action_search_text = ugui.textbox({
            uid = UID.EndActionTextbox,
            rectangle = grid_rect(column, top + LABEL_HEIGHT, 4, LARGE_CONTROL_HEIGHT),
            text = end_action_search_text,
            tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TYPE_TO_SEARCH_TOOL_TIP"),
        }):lower()
        local i = 0
        local match_pattern = "^" .. end_action_search_text
        for _, action_name in pairs(Locales.raw().ACTIONS) do
            if action_name:find(match_pattern) ~= nil then
                if ugui.button({
                    uid = UID.AvailableActions + i,
                    rectangle = grid_rect(column, top + LABEL_HEIGHT + LARGE_CONTROL_HEIGHT + i * SMALL_CONTROL_HEIGHT, 4, SMALL_CONTROL_HEIGHT),
                    text = action_name,
                }) then
                    end_action_search_text = nil
                    section.end_action = action_name
                    any_changes = true
                end

                i = i + 1
                if (i >= MAX_ACTION_GUESSES) then break end
            end
        end
    end
end

local function section_controls_for_selected(draw)
    local sheet = SemanticWorkflowProject:asserted_current()

    local top = TOP
    local col_timeout = 4

    local any_changes = false
    local has_valid_selection = sheet.sections[sheet.active_frame.section_index]

    if not has_valid_selection then
        draw:text(grid_rect(0, top, 8, 1), "center", Locales.str("SEMANTIC_WORKFLOW_NO_SELECTION"))
        return
    end

    if ugui.button({
        uid = UID.InsertSection,
        rectangle = grid_rect(0, top, 1.5, LARGE_CONTROL_HEIGHT),
        text = Locales.str("SEMANTIC_WORKFLOW_INPUTS_INSERT_SECTION"),
        tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_INSERT_SECTION_TOOL_TIP"),
    }) then
        local new_section = Section.new("idle", 150)
        table.insert(sheet.sections, sheet.active_frame.section_index + 1, new_section)
        any_changes = true
    end

    if ugui.button({
        uid = UID.DeleteSection,
        rectangle = grid_rect(1.5, top, 1.5, LARGE_CONTROL_HEIGHT),
        text = Locales.str("SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION"),
        tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION_TOOL_TIP"),
    }) then
        table.remove(sheet.sections, sheet.active_frame.section_index)
        any_changes = true
    end

    local section = sheet.sections[sheet.active_frame.section_index]
    if section == nil then return end

    top = top + 1

    draw:text(grid_rect(col_timeout, top, 2, LABEL_HEIGHT), "start", Locales.str("SEMANTIC_WORKFLOW_INPUTS_TIMEOUT"))
    local old_timeout = section.timeout
    section.timeout = ugui.numberbox({
        uid = UID.Timeout,
        rectangle = grid_rect(col_timeout, top + LABEL_HEIGHT, 2, LARGE_CONTROL_HEIGHT),
        value = section.timeout,
        places = 4,
        tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_TIMEOUT_TOOL_TIP"),
    })
    any_changes = any_changes or old_timeout ~= section.timeout

    controls_for_end_action(section, draw, 0, top)

    if any_changes then
        sheet:run_to_preview()
    end
end

-- ### Joystick Controls ### ---

local function magnitude_controls(draw, sheet, new_values, top)
    draw:text(grid_rect(2, top, 2, MEDIUM_CONTROL_HEIGHT), "end", Locales.str("SEMANTIC_WORKFLOW_CONTROL_MAG"))
    new_values.goal_mag = ugui.numberbox({
        uid = UID.GoalMag,
        rectangle = grid_rect(4, top, 1.5, MEDIUM_CONTROL_HEIGHT),
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
        rectangle = grid_rect(5.5, top, 1.5, MEDIUM_CONTROL_HEIGHT),
        text = Locales.str("SEMANTIC_WORKFLOW_CONTROL_SPDKICK"),
    }) then
        if new_values.goal_mag ~= 48 then
            new_values.goal_mag = 48
        else
            new_values.goal_mag = 127
        end
    end

    if ugui.button({
        uid = UID.ResetMag,
        rectangle = grid_rect(7, top, 1, MEDIUM_CONTROL_HEIGHT),
        text = Locales.str("MAG_RESET"),
    }) then
        new_values.goal_mag = 127
    end
end

local function atan_controls(draw, sheet, new_values, top)
    local label_offset = -0.5
    local new_atan = ugui.toggle_button({
        uid = UID.Atan,
        rectangle = grid_rect(0, top, 1.5, MEDIUM_CONTROL_HEIGHT),
        text=Locales.str("SEMANTIC_WORKFLOW_CONTROL_ATAN"),
        is_checked = new_values.atan_strain
    })
    if new_atan and not new_values.atan_strain then
        new_values.atan_start = Memory.current.mario_global_timer
    end
    new_values.atan_strain = new_atan
    if new_values.movement_mode ~= MovementModes.match_angle then
        new_values.atan_strain = false
    end

    draw:text(grid_rect(1.5, top + label_offset, 0.75, MEDIUM_CONTROL_HEIGHT), "start", "N:")
    new_values.atan_n = ugui.spinner({
        uid = UID.AtanN,
        rectangle = grid_rect(1.5, top, 1.25, MEDIUM_CONTROL_HEIGHT),
        value = new_values.atan_n,
        minimum_value = 1,
        maximum_value = 4000,
        increment = math.max(0.25, math.pow(10, Settings.atan_exp)),
    })

    draw:text(grid_rect(2.75, top + label_offset, 0.75, MEDIUM_CONTROL_HEIGHT), "start", "D:")
    new_values.atan_d = ugui.spinner({
        uid = UID.AtanD,
        rectangle = grid_rect(2.75, top, 1.75, MEDIUM_CONTROL_HEIGHT),
        value = new_values.atan_d,
        minimum_value = -1000000,
        maximum_value = 1000000,
        increment = math.pow(10, Settings.atan_exp),
    })

    draw:text(grid_rect(4.5, top + label_offset, 2.35, MEDIUM_CONTROL_HEIGHT), "start", "Start:")
    new_values.atan_start = ugui.spinner({
        uid = UID.AtanS,
        rectangle = grid_rect(4.5, top, 2.35, MEDIUM_CONTROL_HEIGHT),
        value = new_values.atan_start,
        minimum_value = 0,
        maximum_value = 0xFFFFFFFF,
        increment = math.pow(10, Settings.atan_exp),
    })

    draw:text(grid_rect(7, top + label_offset, 0.5, MEDIUM_CONTROL_HEIGHT), "start", "E:")
    Settings.atan_exp = ugui.spinner({
        uid = UID.AtanE,
        rectangle = grid_rect(7, top, 1, MEDIUM_CONTROL_HEIGHT),
        value = Settings.atan_exp,
        minimum_value = -9,
        maximum_value = 5,
        increment = 1,
    })
end

local function controls_for_selected(draw)
    local small_control_height = 0.5
    local large_control_height = 1.0
    local top = TOP

    local sheet = SemanticWorkflowProject:asserted_current()

    local new_values = {}
    local edited_section = sheet.sections[sheet.active_frame.section_index]
    local edited_input = edited_section and edited_section.inputs[sheet.active_frame.frame_index] or nil

    if edited_input == nil then
        draw:text(grid_rect(0, top, 8, 1), "center", Locales.str("SEMANTIC_WORKFLOW_NO_SELECTION"))
        return
    end

    local old_values = edited_input.tas_state
    CloneInto(new_values, old_values)

    local display_position = {x = old_values.manual_joystick_x or 0, y = -(old_values.manual_joystick_y or 0)}
    local new_position = ugui.joystick({
        uid = UID.Joypad,
        rectangle = grid_rect(0, top + 1, 2, 2),
        position = display_position,
    })
    if new_position.x ~= display_position.x or new_position.y ~= display_position.y then
        new_values.movement_mode = MovementModes.manual
        new_values.manual_joystick_x = math.min(127, math.floor(new_position.x + 0.5)) or old_values.manual_joystick_x
        new_values.manual_joystick_y = math.min(127, -math.floor(new_position.y + 0.5)) or old_values.manual_joystick_y
    end
    local previous_thickness = ugui.standard_styler.params.spinner.button_size
    ugui.standard_styler.params.spinner.button_size = 4
    local rect = grid_rect(0, top + 3, 1, small_control_height, 0)
    rect.y = rect.y + Settings.grid_gap
    new_values.manual_joystick_x = ugui.spinner({
        uid = UID.JoypadSpinnerX,
        rectangle = rect,
        value = new_values.manual_joystick_x,
        minimum_value = -128,
        maximum_value = 127,
        increment = 1,
    })
    rect.x = rect.x + rect.width
    new_values.manual_joystick_y = ugui.spinner({
        uid = UID.JoypadSpinnerY,
        rectangle = rect,
        value = new_values.manual_joystick_y,
        minimum_value = -128,
        maximum_value = 127,
        increment = 1,
    })

    new_values.goal_angle = math.abs(ugui.numberbox({
        uid = UID.GoalAngle,
        is_enabled = new_values.movement_mode == MovementModes.match_angle,
        rectangle = grid_rect(3, top + 2, 2, large_control_height),
        places = 5,
        value = new_values.goal_angle
    }))

    new_values.strain_always = ugui.toggle_button({
        uid = UID.StrainAlways,
        rectangle = grid_rect(2, top + 1, 1.5, small_control_height),
        text = Locales.str("D99_ALWAYS"),
        is_checked = new_values.strain_always
    })

    new_values.strain_speed_target = ugui.toggle_button({
        uid = UID.StrainSpeedTarget,
        rectangle = grid_rect(3.5, top + 1, 1.5, small_control_height),
        text = Locales.str("D99"),
        is_checked = new_values.strain_speed_target
    })

    if ugui.toggle_button({
        uid = UID.StrainLeft,
        rectangle = grid_rect(2, top + 1.5, 1.5, small_control_height),
        text = '[icon:arrow_left]',
        is_checked = new_values.strain_left
    }) then
        new_values.strain_right = false
        new_values.strain_left = true
    else
        new_values.strain_left = false
    end

    if ugui.toggle_button({
        uid = UID.StrainRight,
        rectangle = grid_rect(3.5, top + 1.5, 1.5, small_control_height),
        text = '[icon:arrow_right]',
        is_checked = new_values.strain_right
    }) then
        new_values.strain_left = false
        new_values.strain_right = true
    else
        new_values.strain_right = false
    end

    if ugui.toggle_button({
        uid = UID.MovementModeManual,
        rectangle = grid_rect(5, top + 1, 1.5, large_control_height),
        text = Locales.str("SEMANTIC_WORKFLOW_CONTROL_MANUAL"),
        is_checked = new_values.movement_mode == MovementModes.manual
    }) then
        new_values.movement_mode = MovementModes.manual
    end

    if ugui.toggle_button({
        uid = UID.MovementModeMatchYaw,
        rectangle = grid_rect(6.5, top + 1, 1.5, large_control_height),
        text = Locales.str("SEMANTIC_WORKFLOW_CONTROL_MATCH_YAW"),
        is_checked = new_values.movement_mode == MovementModes.match_yaw
    }) then
        new_values.movement_mode = MovementModes.match_yaw
    end

    if ugui.toggle_button({
        uid = UID.MovementModeMatchAngle,
        rectangle = grid_rect(5, top + 2, 1.5, large_control_height),
        text = Locales.str("SEMANTIC_WORKFLOW_CONTROL_MATCH_ANGLE"),
        is_checked = new_values.movement_mode == MovementModes.match_angle
    }) then
        new_values.movement_mode = MovementModes.match_angle
    end

    if ugui.toggle_button({
        uid = UID.MovementModeReverseAngle,
        rectangle = grid_rect(6.5, top + 2, 1.5, large_control_height),
        text = Locales.str("SEMANTIC_WORKFLOW_CONTROL_REVERSE_ANGLE"),
        is_checked = new_values.movement_mode == MovementModes.reverse_angle
    }) then
        new_values.movement_mode = MovementModes.reverse_angle
    end

    new_values.dyaw = ugui.toggle_button({
        uid = UID.DYaw,
        rectangle = grid_rect(2, top + 2, 1, large_control_height),
        text = Locales.str("SEMANTIC_WORKFLOW_CONTROL_DYAW"),
        is_checked = new_values.dyaw
    })

    magnitude_controls(draw, sheet, new_values, top + 3)
    atan_controls(draw, sheet, new_values, top + 4)

    ugui.standard_styler.params.spinner.button_size = previous_thickness

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

    top = TOP
    if ugui.button({
        uid = UID.InsertInput,
        rectangle = grid_rect(0, top, 1.5, MEDIUM_CONTROL_HEIGHT),
        text = Locales.str("SEMANTIC_WORKFLOW_INPUTS_INSERT_INPUT"),
        tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_INSERT_INPUT_TOOL_TIP"),
    }) then
        table.insert(edited_section.inputs, current_sheet.active_frame.frame_index, ugui.internal.deep_clone(edited_input))
        any_changes = true
    end

    if ugui.button({
        uid = UID.DeleteInput,
        rectangle = grid_rect(1.5, top, 1.5, MEDIUM_CONTROL_HEIGHT),
        text = Locales.str("SEMANTIC_WORKFLOW_INPUTS_DELETE_INPUT"),
        tooltip = Locales.str("SEMANTIC_WORKFLOW_INPUTS_DELETE_INPUT_TOOL_TIP"),
        is_enabled = #edited_section.inputs > 1
    }) then
        table.remove(edited_section.inputs, current_sheet.active_frame.frame_index)
        any_changes = true
    end

    if any_changes then
        current_sheet:run_to_preview()
    end
end

function __impl.render(draw)
    local draw_funcs = { controls_for_selected, section_controls_for_selected }
    selected_view_index = ugui.carrousel_button({
         uid = UID.ViewCarrousel,
         rectangle = grid_rect(6, TOP, 2, MEDIUM_CONTROL_HEIGHT),
         value = selected_view_index,
         items = { "Joystick", "Section" },
         selected_index = selected_view_index,
        })
    draw_funcs[selected_view_index](draw)
    FrameListGui.view_index = selected_view_index
    FrameListGui.render(draw)
end