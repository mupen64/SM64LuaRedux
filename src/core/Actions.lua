--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Actions = {}

ROOT = 'SM64 Lua Redux > '
ACTION_MOVEMENT_MODE = ROOT .. 'Movement Mode ---'
ACTION_SET_MOVEMENT_MODE_MANUAL = ACTION_MOVEMENT_MODE .. ' > Manual ---'
ACTION_SET_MOVEMENT_MODE_DISABLED = ACTION_MOVEMENT_MODE .. ' > Disabled'
ACTION_SET_MOVEMENT_MODE_MATCH_YAW = ACTION_MOVEMENT_MODE .. ' > Match Yaw'
ACTION_SET_MOVEMENT_MODE_REVERSE_ANGLE = ACTION_MOVEMENT_MODE .. ' > Reverse Angle'
ACTION_SET_MOVEMENT_MODE_MATCH_ANGLE = ACTION_MOVEMENT_MODE .. ' > Match Angle'
ACTION_SET_GOAL_ANGLE_TO_FACING_YAW = ROOT .. 'Set Angle to Facing Yaw'
ACTION_SET_GOAL_ANGLE_TO_INTENDED_YAW = ROOT .. 'Set Angle to Intended Yaw'
ACTION_DECREMENT_ANGLE = ROOT .. 'Angle -1'
ACTION_INCREMENT_ANGLE = ROOT .. 'Angle +1'
ACTION_TOGGLE_D99_ENABLED = ROOT .. '.99 --- > Enabled ---'
ACTION_TOGGLE_D99_ALWAYS = ROOT .. '.99 --- > Always'
ACTION_TOGGLE_DYAW = ROOT .. 'D-Yaw > Enabled ---'
ACTION_TOGGLE_STRAIN_LEFT = ROOT .. 'D-Yaw > Strain Left'
ACTION_TOGGLE_STRAIN_RIGHT = ROOT .. 'D-Yaw > Strain Right'
ACTION_SET_GOAL_ANGLE = ROOT .. 'Set Angle... ---'
ACTION_RESET_MAGNITUDE = ROOT .. 'Magnitude --- > Reset'
ACTION_SET_MAGNITUDE = ROOT .. 'Magnitude --- > Set... ---'
ACTION_TOGGLE_HIGH_MAGNITUDE = ROOT .. 'Magnitude --- > High-Magnitude'
ACTION_SET_SPDKICK = ROOT .. 'Speedkick'
ACTION_TOGGLE_FRAMEWALK = ROOT .. 'Framewalk'
ACTION_TOGGLE_SWIM = ROOT .. 'Swim'
ACTION_TOGGLE_AUTOFIRSTIES = ROOT .. 'Auto-Firsties ---'
ACTION_PRESET = ROOT .. 'Preset > '
ACTION_SET_PRESET_DOWN = ACTION_PRESET .. 'Select Previous'
ACTION_SET_PRESET_UP = ACTION_PRESET .. 'Select Next ---'
ACTION_TOGGLE_REMEMBER_TAS_STATE = ACTION_PRESET .. 'Remember TAS State'
ACTION_RESET_PRESET = ACTION_PRESET .. 'Reset to Default'
ACTION_TOGGLE_NAVBAR = ROOT .. 'Navigation Bar'

---@class ActionParamsWithDefaultHotkey : ActionParams
---@field hotkey Hotkey?

---Wraps callbacks of action parameters to show notifications.
---@param params ActionParamsWithDefaultHotkey
---@return ActionParamsWithDefaultHotkey
local function wrap_params(params)
    local new_params = ugui.internal.deep_clone(params)

    -- No-op for now.

    return new_params
end


---@type ActionParamsWithDefaultHotkey[]
local actions = {}

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_MANUAL,
    on_press = function()
        Settings.tas.movement_mode = MovementModes.manual
        action.notify_active_changed(ACTION_MOVEMENT_MODE .. '>*')
    end,
    get_active = function()
        return Settings.tas.movement_mode == MovementModes.manual
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_DISABLED,
    hotkey = { ctrl = true, key = string.byte('1') },
    on_press = function()
        Settings.tas.movement_mode = MovementModes.disabled
        action.notify_active_changed(ACTION_MOVEMENT_MODE .. '>*')
    end,
    get_active = function()
        return Settings.tas.movement_mode == MovementModes.disabled
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_MATCH_YAW,
    hotkey = { ctrl = true, key = string.byte('2') },
    on_press = function()
        Settings.tas.movement_mode = MovementModes.match_yaw
        action.notify_active_changed(ACTION_MOVEMENT_MODE .. '>*')
    end,
    get_active = function()
        return Settings.tas.movement_mode == MovementModes.match_yaw
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_REVERSE_ANGLE,
    hotkey = { ctrl = true, key = string.byte('3') },
    on_press = function()
        Settings.tas.movement_mode = MovementModes.reverse_angle
        action.notify_active_changed(ACTION_MOVEMENT_MODE .. '>*')
    end,
    get_active = function()
        return Settings.tas.movement_mode == MovementModes.reverse_angle
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_MATCH_ANGLE,
    hotkey = { ctrl = true, key = string.byte('4') },
    on_press = function()
        Settings.tas.movement_mode = MovementModes.match_angle
        action.notify_active_changed(ACTION_MOVEMENT_MODE .. '>*')
    end,
    get_active = function()
        return Settings.tas.movement_mode == MovementModes.match_angle
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_GOAL_ANGLE_TO_FACING_YAW,
    on_press = function()
        Settings.tas.goal_angle = Memory.current.mario_facing_yaw
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_GOAL_ANGLE_TO_INTENDED_YAW,
    on_press = function()
        Settings.tas.goal_angle = Memory.current.mario_intended_yaw
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_DECREMENT_ANGLE,
    hotkey = { ctrl = true, key = Mupen.VKeycodes.VK_OEM_MINUS },
    on_press = function()
        if ugui.internal.active_control then
            return
        end

        Settings.tas.goal_angle = Settings.tas.goal_angle - 16

        if Settings.tas.goal_angle < 0 then
            Settings.tas.goal_angle = 65535
        else
            if Settings.tas.goal_angle % 16 ~= 0 then
                Settings.tas.goal_angle = math.floor((Settings.tas.goal_angle + 8) / 16) * 16
            end
        end
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_INCREMENT_ANGLE,
    hotkey = { ctrl = true, key = Mupen.VKeycodes.VK_OEM_PLUS },
    on_press = function()
        if ugui.internal.active_control then
            return
        end

        Settings.tas.goal_angle = Settings.tas.goal_angle + 16

        if Settings.tas.goal_angle < 0 then
            Settings.tas.goal_angle = 65535
        else
            if Settings.tas.goal_angle % 16 ~= 0 then
                Settings.tas.goal_angle = math.floor((Settings.tas.goal_angle + 8) / 16) * 16
            end
        end
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_D99_ENABLED,
    on_press = function()
        Settings.tas.strain_speed_target = not Settings.tas.strain_speed_target
        action.notify_active_changed(ACTION_TOGGLE_D99_ENABLED)
    end,
    get_active = function()
        return Settings.tas.strain_speed_target
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_D99_ALWAYS,
    on_press = function()
        Settings.tas.strain_always = not Settings.tas.strain_always
        action.notify_active_changed(ACTION_TOGGLE_D99_ALWAYS)
    end,
    get_active = function()
        return Settings.tas.strain_always
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_DYAW,
    on_press = function()
        Settings.tas.dyaw = not Settings.tas.dyaw
        action.notify_active_changed(ACTION_TOGGLE_DYAW)
    end,
    get_active = function()
        return Settings.tas.dyaw
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_STRAIN_LEFT,
    on_press = function()
        if Settings.tas.strain_left then
            Settings.tas.strain_left = false
        else
            Settings.tas.strain_left = true
            Settings.tas.strain_right = false
        end
        action.notify_active_changed(ACTION_TOGGLE_STRAIN_LEFT)
        action.notify_active_changed(ACTION_TOGGLE_STRAIN_RIGHT)
    end,
    get_active = function()
        return Settings.tas.strain_left
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_STRAIN_RIGHT,
    on_press = function()
        if Settings.tas.strain_right then
            Settings.tas.strain_right = false
        else
            Settings.tas.strain_right = true
            Settings.tas.strain_left = false
        end
        action.notify_active_changed(ACTION_TOGGLE_STRAIN_LEFT)
        action.notify_active_changed(ACTION_TOGGLE_STRAIN_RIGHT)
    end,
    get_active = function()
        return Settings.tas.strain_right
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_GOAL_ANGLE,
    on_press = function()
        local result = tonumber(input.prompt(action.get_display_name(ACTION_SET_GOAL_ANGLE), tostring(Settings.tas.goal_angle)))
        if result == nil then
            return
        end
        Settings.tas.goal_angle = result
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_RESET_MAGNITUDE,
    on_press = function()
        Settings.tas.goal_mag = 127
        Settings.tas.high_magnitude = false
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MAGNITUDE,
    on_press = function()
        local result = tonumber(input.prompt(action.get_display_name(ACTION_SET_MAGNITUDE), tostring(Settings.tas.goal_mag)))
        if result == nil then
            return
        end
        Settings.tas.goal_mag = result
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_HIGH_MAGNITUDE,
    on_press = function()
        Settings.tas.high_magnitude = not Settings.tas.high_magnitude
        action.notify_active_changed(ACTION_TOGGLE_HIGH_MAGNITUDE)
    end,
    get_active = function()
        return Settings.tas.high_magnitude
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_SPDKICK,
    on_press = function()
        Engine.toggle_speedkick()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_FRAMEWALK,
    on_press = function()
        Settings.tas.framewalk = not Settings.tas.framewalk
        action.notify_active_changed(ACTION_TOGGLE_FRAMEWALK)
    end,
    get_active = function()
        return Settings.tas.framewalk
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_SWIM,
    on_press = function()
        Settings.tas.swim = not Settings.tas.swim
        action.notify_active_changed(ACTION_TOGGLE_SWIM)
    end,
    get_active = function()
        return Settings.tas.swim
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_AUTOFIRSTIES,
    on_press = function()
        Settings.auto_firsties = not Settings.auto_firsties
        action.notify_active_changed(ACTION_TOGGLE_AUTOFIRSTIES)
    end,
    get_active = function()
        return Settings.auto_firsties
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_PRESET_DOWN,
    on_press = function()
        Presets.change_index(Presets.persistent.current_index - 1)
        Actions.notify_all_changed()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_PRESET_UP,
    on_press = function()
        Presets.change_index(Presets.persistent.current_index + 1)
        Actions.notify_all_changed()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_RESET_PRESET,
    on_press = function()
        Presets.reset(Presets.persistent.current_index)
        Presets.apply(Presets.persistent.current_index)
        Actions.notify_all_changed()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_NAVBAR,
    on_press = function()
        Settings.navbar_visible = not Settings.navbar_visible
        action.notify_active_changed(ACTION_TOGGLE_NAVBAR)
    end,
    get_active = function()
        return Settings.navbar_visible
    end,
})

---Registers all actions. Can only be called once.
function Actions.register_all()
    action.begin_batch_work()
    for _, params in pairs(actions) do
        assert(action.add(params))

        if params.hotkey then
            assert(action.associate_hotkey(params.path, params.hotkey))
        end
    end
    action.end_batch_work()
end

---Notifies the action system that all actions have changed their state.
function Actions.notify_all_changed()
    -- We only deal with the active state for now since it's all we use
    action.notify_active_changed(ROOT .. '*')
end
