--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Actions = {}

local ROOT = 'SM64 Lua Redux > '
ACTION_SET_MOVEMENT_MODE_MANUAL = ROOT .. 'Movement Mode --- > Manual ---'
ACTION_SET_MOVEMENT_MODE_DISABLED = ROOT .. 'Movement Mode --- > Disabled'
ACTION_SET_MOVEMENT_MODE_MATCH_YAW = ROOT .. 'Movement Mode --- > Match Yaw'
ACTION_SET_MOVEMENT_MODE_REVERSE_ANGLE = ROOT .. 'Movement Mode --- > Reverse Angle'
ACTION_SET_MOVEMENT_MODE_MATCH_ANGLE = ROOT .. 'Movement Mode --- > Match Angle'
ACTION_TOGGLE_D99_ENABLED = ROOT .. '.99 --- > Enabled ---'
ACTION_TOGGLE_D99_ALWAYS = ROOT .. '.99 --- > Always'
ACTION_TOGGLE_DYAW = ROOT .. 'D-Yaw > Enabled ---'
ACTION_TOGGLE_STRAIN_LEFT = ROOT .. 'D-Yaw > Strain Left'
ACTION_TOGGLE_STRAIN_RIGHT = ROOT .. 'D-Yaw > Strain Right'
ACTION_SET_GOAL_ANGLE = ROOT .. 'Set Angle... ---'
ACTION_RESET_MAGNITUDE = ROOT .. 'Magnitude --- > Reset'
ACTION_SET_MAGNITUDE = ROOT .. 'Magnitude --- > Set... ---'
ACTION_SET_HIGH_MAGNITUDE = ROOT .. 'Magnitude --- > High-Magnitude'
ACTION_SET_SPDKICK = ROOT .. 'Speedkick'
ACTION_TOGGLE_FRAMEWALK = ROOT .. 'Framewalk'
ACTION_TOGGLE_SWIM = ROOT .. 'Swim'

---Wraps callbacks of action parameters to show notifications.
---@param params ActionParams
---@return ActionParams
local function wrap_params(params)
    local new_params = ugui.internal.deep_clone(params)

    -- No-op for now.

    return new_params
end



---@type ActionParams[]
local actions = {}

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_MANUAL,
    down_callback = function()
        TASState.movement_mode = MovementModes.manual
    end,
    get_active = function()
        return TASState.movement_mode == MovementModes.manual
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_DISABLED,
    down_callback = function()
        TASState.movement_mode = MovementModes.disabled
    end,
    get_active = function()
        return TASState.movement_mode == MovementModes.disabled
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_MATCH_YAW,
    down_callback = function()
        TASState.movement_mode = MovementModes.match_yaw
    end,
    get_active = function()
        return TASState.movement_mode == MovementModes.match_yaw
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_REVERSE_ANGLE,
    down_callback = function()
        TASState.movement_mode = MovementModes.reverse_angle
    end,
    get_active = function()
        return TASState.movement_mode == MovementModes.reverse_angle
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_MATCH_ANGLE,
    down_callback = function()
        TASState.movement_mode = MovementModes.match_angle
    end,
    get_active = function()
        return TASState.movement_mode == MovementModes.match_angle
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_D99_ENABLED,
    down_callback = function()
        TASState.strain_speed_target = not TASState.strain_speed_target
    end,
    get_active = function()
        return TASState.strain_speed_target
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_D99_ALWAYS,
    down_callback = function()
        TASState.strain_always = not TASState.strain_always
    end,
    get_active = function()
        return TASState.strain_always
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_DYAW,
    down_callback = function()
        TASState.dyaw = not TASState.dyaw
    end,
    get_active = function()
        return TASState.dyaw
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_STRAIN_LEFT,
    down_callback = function()
        if TASState.strain_left then
            TASState.strain_left = false
        else
            TASState.strain_left = true
            TASState.strain_right = false
        end
    end,
    get_active = function()
        return TASState.strain_left
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_STRAIN_RIGHT,
    down_callback = function()
        if TASState.strain_right then
            TASState.strain_right = false
        else
            TASState.strain_right = true
            TASState.strain_left = false
        end
    end,
    get_active = function()
        return TASState.strain_right
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_GOAL_ANGLE,
    down_callback = function()
        local result = tonumber(input.prompt(action.get_display_name(ACTION_SET_GOAL_ANGLE), tostring(TASState.goal_angle)))
        if result == nil then
            return
        end
        TASState.goal_angle = result
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_RESET_MAGNITUDE,
    down_callback = function()
        TASState.goal_mag = 127
        TASState.high_magnitude = false
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MAGNITUDE,
    down_callback = function()
        local result = tonumber(input.prompt(action.get_display_name(ACTION_SET_MAGNITUDE), tostring(TASState.goal_mag)))
        if result == nil then
            return
        end
        TASState.goal_mag = result
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_HIGH_MAGNITUDE,
    down_callback = function()
        TASState.high_magnitude = not TASState.high_magnitude
    end,
    get_active = function()
        return TASState.high_magnitude
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_SPDKICK,
    down_callback = function()
        Engine.toggle_speedkick()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_FRAMEWALK,
    down_callback = function()
        TASState.framewalk = not TASState.framewalk
    end,
    get_active = function()
        return TASState.framewalk
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_SWIM,
    down_callback = function()
        TASState.swim = not TASState.swim
    end,
    get_active = function()
        return TASState.swim
    end,
})

local hotkey_funcs = {
    preset_down = function()
        Presets.apply(Presets.persistent.current_index - 1)
    end,
    preset_up = function()
        Presets.apply(Presets.persistent.current_index + 1)
    end,
    copy_yaw_facing_to_match_angle = function()
        TASState.goal_angle = Memory.current.mario_facing_yaw
    end,
    copy_yaw_intended_to_match_angle = function()
        TASState.goal_angle = Memory.current.mario_intended_yaw
    end,
    toggle_auto_firsties = function()
        Settings.auto_firsties = not Settings.auto_firsties
    end,
    angle_down = function()
        if ugui.internal.active_control then
            return false
        end

        TASState.goal_angle = TASState.goal_angle - 16

        if TASState.goal_angle < 0 then
            TASState.goal_angle = 65535
        else
            if TASState.goal_angle % 16 ~= 0 then
                TASState.goal_angle = math.floor((TASState.goal_angle + 8) / 16) * 16
            end
        end
    end,
    angle_up = function()
        if ugui.internal.active_control then
            return false
        end

        TASState.goal_angle = TASState.goal_angle + 16

        if TASState.goal_angle > 65535 then
            TASState.goal_angle = 0
        end

        if TASState.goal_angle % 16 ~= 0 then
            TASState.goal_angle = math.floor((TASState.goal_angle + 8) / 16) * 16
        end
    end,
    toggle_spdkick = function()
        Engine.toggle_speedkick()
    end,
    toggle_navbar = function()
        Settings.navbar_visible = not Settings.navbar_visible
    end,
}

---Calls a hotkey's function.
---@param identifier string The hotkey identifier.
local function call_hotkey_func(identifier)
    if not Settings.hotkeys_allow_with_active_control
        and ugui.internal.active_control then
        return
    end

    local result = hotkey_funcs[identifier]()

    if result ~= false then
        Notifications.show('Hotkey ' .. identifier .. ' pressed')
    end
end


action.begin_batch_work()
for _, params in pairs(actions) do
    assert(action.add(params))
end
action.end_batch_work()
