--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local function get_mario_data()
    return {
        position = {
            x = Memory.current.mario_x,
            y = Memory.current.mario_y,
            z = Memory.current.mario_z
        },
        animation_index = Memory.current.mario_animation,
        animation_frame = Memory.current.mario_animation_timer,
        pitch = Memory.current.mario_pitch,
        yaw = Memory.current.mario_facing_yaw,
        roll = Memory.current.mario_roll
    }
end

local function entry(label_id, value)
    return string.format('%s: %s', Locales.str(label_id), value)
end

---Formats a frame of ghost or object data as varwatch lines.
---@param extra string[]? # extra variable lines, placed after facing yaw and before the less important fields
function frame_varwatch_data(data, extra)
    local items = {
        entry('VARWATCH_GLOBAL_TIMER_LABEL', Memory.current.global_timer),
        entry('VARWATCH_POS_X_LABEL', Formatter.u(data.position.x)),
        entry('VARWATCH_POS_Y_LABEL', Formatter.u(data.position.y)),
        entry('VARWATCH_POS_Z_LABEL', Formatter.u(data.position.z)),
        entry('VARWATCH_FACING_YAW_LABEL', Formatter.angle(data.yaw)),
    }
    table.move(extra or {}, 1, #(extra or {}), #items + 1, items)
    for _, line in ipairs({
        entry('VARWATCH_PITCH_LABEL', Formatter.angle(data.pitch)),
        entry('GHOST_DATA_ROLL', Formatter.angle(data.roll or 0)),
        entry('GHOST_DATA_ANIMATION', Formatter.u(data.animation_index)),
        entry('GHOST_DATA_ANIMATION_FRAME', Formatter.u(data.animation_frame)),
    }) do
        items[#items + 1] = line
    end
    return items
end

local function format_action(action)
    return Locales.raw().ACTIONS[action] or (Locales.str('VARWATCH_UNKNOWN_ACTION') .. action)
end

-- extra data that can be recorded with a ghost, picked in the ghost settings tab. `label` is what's
-- stored in the file (max 15 bytes), so it stays in English; `locale` is what's displayed
---@type {id: string, label: string, locale: string, type: integer, read: fun(): number, format: fun(value: number): string}[]
GHOST_RECORDABLE_VARIABLES = {
    {
        id = 'action',
        label = 'Action',
        locale = 'VARWATCH_ACTION_LABEL',
        type = Ghosts.VARIABLE_TYPES.int,
        read = function() return Memory.current.mario_action end,
        format = format_action
    },
    {
        id = 'rng',
        label = 'RNG',
        locale = 'VARWATCH_RNG_LABEL',
        type = Ghosts.VARIABLE_TYPES.word,
        read = function() return Memory.current.rng_value end,
        format = tostring
    },
    {
        id = 'h_spd',
        label = 'H Spd',
        locale = 'VARWATCH_H_SPEED_LABEL',
        type = Ghosts.VARIABLE_TYPES.float,
        read = function() return Memory.current.mario_h_speed end,
        format = Formatter.ups
    },
    {
        id = 'v_spd',
        label = 'Y Spd',
        locale = 'VARWATCH_Y_SPEED_LABEL',
        type = Ghosts.VARIABLE_TYPES.float,
        read = function() return Memory.current.mario_v_speed end,
        format = Formatter.ups
    },
    {
        id = 'spd_efficiency',
        label = 'Spd Efficiency',
        locale = 'VARWATCH_SPD_EFFICIENCY_LABEL',
        type = Ghosts.VARIABLE_TYPES.float,
        read = Engine.get_speed_efficiency,
        format = Formatter.percent
    },
    {
        id = 'yaw_intended',
        label = 'Intended Yaw',
        locale = 'VARWATCH_INTENDED_YAW_LABEL',
        type = Ghosts.VARIABLE_TYPES.word,
        read = function() return Memory.current.mario_intended_yaw end,
        format = Formatter.angle
    },
}

---Registers the variables enabled in the settings with the ghost module; call before a recording starts.
function sync_ghost_recorded_variables()
    for _, variable in ipairs(GHOST_RECORDABLE_VARIABLES) do
        if Settings.ghost_recorded_variables and Settings.ghost_recorded_variables[variable.id] then
            Ghosts.record_variable(variable.label, variable.type, variable.read)
        else
            Ghosts.stop_recording_variable(variable.label)
        end
    end
end

---Formats a recorded value: known labels use their varwatch name and formatting, others are shown raw.
local function variable_entry(variable)
    if variable.label == 'Action' then
        return entry('VARWATCH_ACTION_LABEL', format_action(variable.value))
    end
    for _, known in ipairs(GHOST_RECORDABLE_VARIABLES) do
        if known.label == variable.label then
            return entry(known.locale, known.format(variable.value))
        end
    end
    local value = variable.type == Ghosts.VARIABLE_TYPES.float and Formatter.u(variable.value) or tostring(variable.value)
    return string.format('%s: %s', variable.label, value)
end

---Lines for the current values of the variables selected in the ghost settings tab, i.e. what a recording would store.
---@return string[]
function selected_variable_lines()
    local lines = {}
    for _, variable in ipairs(GHOST_RECORDABLE_VARIABLES) do
        if Settings.ghost_recorded_variables and Settings.ghost_recorded_variables[variable.id] then
            lines[#lines + 1] = entry(variable.locale, variable.format(variable.read()))
        end
    end
    return lines
end

function ghost_varwatch_data(ghost)
    if not ghost then
        return frame_varwatch_data(get_mario_data(), selected_variable_lines())
    end
    local data = Ghosts.get_ghost_data(ghost, Memory.current.global_timer)
    local lines = {}
    for _, variable in ipairs(Ghosts.get_ghost_variables(ghost, Memory.current.global_timer)) do
        lines[#lines + 1] = variable_entry(variable)
    end
    return frame_varwatch_data(data, lines)
end
