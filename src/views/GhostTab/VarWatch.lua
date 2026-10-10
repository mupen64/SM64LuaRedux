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
function frame_varwatch_data(data)
    local items = {
        entry('VARWATCH_GLOBAL_TIMER_LABEL', Memory.current.global_timer),
        entry('VARWATCH_POS_X_LABEL', Formatter.u(data.position.x)),
        entry('VARWATCH_POS_Y_LABEL', Formatter.u(data.position.y)),
        entry('VARWATCH_POS_Z_LABEL', Formatter.u(data.position.z)),
        entry('VARWATCH_FACING_YAW_LABEL', Formatter.angle(data.yaw)),
        entry('VARWATCH_PITCH_LABEL', Formatter.angle(data.pitch)),
        entry('GHOST_DATA_ROLL', Formatter.angle(data.roll or 0)),
        entry('GHOST_DATA_ANIMATION', Formatter.u(data.animation_index)),
        entry('GHOST_DATA_ANIMATION_FRAME', Formatter.u(data.animation_frame)),
    }
    return items
end

function ghost_varwatch_data(ghost)
    if not ghost then
        return frame_varwatch_data(get_mario_data())
    end
    local data = Ghosts.get_ghost_data(ghost, Memory.current.global_timer)
    return frame_varwatch_data(data)
end
