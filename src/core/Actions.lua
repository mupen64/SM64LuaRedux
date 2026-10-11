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
ACTION_SET_MOVEMENT_MODE_REVERSE_YAW = ACTION_MOVEMENT_MODE .. ' > Reverse Yaw'
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
ACTION_SET_SPDKICK = ROOT .. 'Speedkick'
ACTION_SET_DUSTLESS_WALK = ROOT .. 'Dustless Walk'
ACTION_TOGGLE_FRAMEWALK = ROOT .. 'Framewalk'
ACTION_TOGGLE_SWIM = ROOT .. 'Swim'
ACTION_TOGGLE_AUTOFIRSTIES = ROOT .. 'Auto-Firsties ---'
ACTION_PRESET = ROOT .. 'Preset > '
ACTION_SET_PRESET_DOWN = ACTION_PRESET .. 'Select Previous'
ACTION_SET_PRESET_UP = ACTION_PRESET .. 'Select Next ---'
ACTION_TOGGLE_REMEMBER_TAS_STATE = ACTION_PRESET .. 'Remember TAS State'
ACTION_RESET_PRESET = ACTION_PRESET .. 'Reset to Default'
ACTION_DELETE_ALL_PRESETS = ACTION_PRESET .. 'Delete All'
ACTION_SETTINGS = ROOT .. 'Settings ---'
ACTION_SETTINGS_SET_STYLE = ACTION_SETTINGS .. ' > Set Style...'
ACTION_SETTINGS_SET_LANGUAGE = ACTION_SETTINGS .. ' > Set Language...'
ACTION_SETTINGS_TOGGLE_CONSOLE_NOTIFICATIONS = ACTION_SETTINGS .. ' > Toggle Console Notifications'
ACTION_SETTINGS_SET_FF_FPS = ACTION_SETTINGS .. ' > Set Fast-Forward FPS... ---'
ACTION_SETTINGS_TOGGLE_MANUAL_ON_JOYSTICK = ACTION_SETTINGS .. ' > Manual On Joystick Interact'
ACTION_SETTINGS_TOGGLE_LOCK_HOTKEYS = ACTION_SETTINGS .. ' > Lock Hotkeys When Control Active ---'
ACTION_SETTINGS_SELECT_MAP_FILE = ACTION_SETTINGS .. ' > Select Map File'
ACTION_SETTINGS_SET_REGION = ACTION_SETTINGS .. ' > Set Region...'
ACTION_SETTINGS_AUTODETECT_NOW = ACTION_SETTINGS .. ' > Detect Address Now'
ACTION_SETTINGS_TOGGLE_AUTODETECT = ACTION_SETTINGS .. ' > Detect Address On Start ---'
ACTION_SETTINGS_SET_ANGLE_FORMAT = ACTION_SETTINGS .. ' > Set Angle Format...'
ACTION_SETTINGS_SET_DECIMAL_POINTS = ACTION_SETTINGS .. ' > Set Decimal Points...'
ACTION_TOGGLE_NAVBAR = ROOT .. 'Navigation Bar'
ACTION_TOGGLE_DEBUG_MODE = ROOT .. 'Debug Mode'

---@class ActionParamsWithDefaultHotkey : ActionAddParams
---@field hotkey Hotkey?

---Wraps callbacks of action parameters to show notifications.
---@param params ActionParamsWithDefaultHotkey
---@return ActionParamsWithDefaultHotkey
local function wrap_params(params)
    local new_params = ugui.internal.deep_clone(params)

    -- No-op for now.

    return new_params
end

---Finds the 1-based index of the option whose name matches `value`, case-insensitively.
---@param names string[]
---@param value string?
---@return integer?
local function option_index(names, value)
    if not value then
        return nil
    end

    local lower_value = value:lower()
    for i = 1, #names, 1 do
        if names[i]:lower() == lower_value then
            return i
        end
    end

    return nil
end

---Returns the option names that complete the typed value.
---@param names string[]
---@param value string?
---@return string[]
local function option_hints(names, value)
    local lower_value = (value or ''):lower()
    local hints = {}

    for i = 1, #names, 1 do
        if lower_value == '' or names[i]:lower():sub(1, #lower_value) == lower_value then
            hints[#hints + 1] = names[i]
        end
    end

    return hints
end

---Returns the names of a list of `{ name, value }` options.
---@param options { name: string, value: any }[]
---@return string[]
local function option_names(options)
    local names = {}
    for i = 1, #options, 1 do
        names[i] = options[i].name
    end

    return names
end

---Returns the angle formatting options, localized to the current locale.
---@return { name: string, value: boolean }[]
local function angle_format_options()
    return {
        { name = Locales.str('SETTINGS_VARWATCH_ANGLE_FORMAT_SHORT'), value = false },
        { name = Locales.str('SETTINGS_VARWATCH_ANGLE_FORMAT_DEGREE'), value = true },
    }
end

---Returns the display names of all address sources.
---@return string[]
local function region_names()
    local names = {}
    for i = 1, #Addresses, 1 do
        names[i] = Addresses[i].name()
    end

    return names
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
        Settings.tas.atan_readonly_r = nil
        action.notify_active_changed(ACTION_MOVEMENT_MODE .. '>*')
    end,
    get_active = function()
        return Settings.tas.movement_mode == MovementModes.match_yaw
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MOVEMENT_MODE_REVERSE_YAW,
    hotkey = { ctrl = true, key = string.byte('3') },
    on_press = function()
        Settings.tas.movement_mode = MovementModes.reverse_yaw
        action.notify_active_changed(ACTION_MOVEMENT_MODE .. '>*')
    end,
    get_active = function()
        return Settings.tas.movement_mode == MovementModes.reverse_yaw
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
        if is_keyboard_captured then
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
        if is_keyboard_captured then
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
    params = {
        {
            key = 'angle',
            name = 'Angle',
            validator = Validators.number,
        }
    },
    on_press = function(params)
        local angle = tonumber(params.angle) % 65536
        Settings.tas.goal_angle = angle
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_RESET_MAGNITUDE,
    on_press = function()
        Settings.tas.goal_mag = 64
        Settings.tas.maximize_airspeed = false
        Settings.tas.dustless_walk = false
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_MAGNITUDE,
    params = {
        {
            key = 'magnitude',
            name = 'Magnitude',
            validator = Validators.number,
        }
    },
    on_press = function(params)
        local magnitude = tonumber(params.magnitude)
        Settings.tas.goal_mag = math.min(magnitude, 64)
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_SPDKICK,
    on_press = function()
        if Settings.tas.dustless_walk or Settings.tas.goal_mag ~= 48 then
            Settings.tas.goal_mag = 48
            Settings.tas.maximize_airspeed = true
		else
		    Settings.tas.goal_mag = 64
            Settings.tas.maximize_airspeed = false
        end
        Settings.tas.dustless_walk = false
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SET_DUSTLESS_WALK,
    on_press = function()
        if Settings.tas.dustless_walk then
            Settings.tas.goal_mag = 64
        else
            Settings.tas.maximize_airspeed = false
        end
        Settings.tas.dustless_walk = not Settings.tas.dustless_walk
    end
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
        Actions.notify_all_changed()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_DELETE_ALL_PRESETS,
    on_press = function()
        Presets.delete_all()
        Actions.notify_all_changed()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_SET_STYLE,
    params = {
        {
            key = 'style',
            name = 'Style',
            get_initial_value = function()
                return Styles.theme_names()[Settings.active_style_index]
            end,
            get_hints = function(value)
                return option_hints(Styles.theme_names(), value)
            end,
            validator = function(value)
                if option_index(Styles.theme_names(), value) then
                    return nil
                end

                return 'Unknown style.'
            end,
        },
    },
    on_press = function(params)
        local index = option_index(Styles.theme_names(), params.style)
        if index then
            Settings.active_style_index = index
            Styles.update_style()
        end
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_SET_LANGUAGE,
    params = {
        {
            key = 'language',
            name = 'Language',
            get_initial_value = function()
                return Locales.names()[Settings.locale_index]
            end,
            get_hints = function(value)
                return option_hints(Locales.names(), value)
            end,
            validator = function(value)
                if option_index(Locales.names(), value) then
                    return nil
                end

                return 'Unknown language.'
            end,
        },
    },
    on_press = function(params)
        local index = option_index(Locales.names(), params.language)
        if index then
            Settings.locale_index = index
        end
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_TOGGLE_CONSOLE_NOTIFICATIONS,
    on_press = function()
        Settings.notification_style = Settings.notification_style == NOTIFICATION_STYLE_CONSOLE
            and NOTIFICATION_STYLE_BUBBLE
            or NOTIFICATION_STYLE_CONSOLE
        action.notify_active_changed(ACTION_SETTINGS_TOGGLE_CONSOLE_NOTIFICATIONS)
    end,
    get_active = function()
        return Settings.notification_style == NOTIFICATION_STYLE_CONSOLE
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_SET_FF_FPS,
    params = {
        {
            key = 'fps',
            name = 'FPS',
            get_initial_value = function()
                return tostring(Settings.ff_fps)
            end,
            validator = Validators.number,
        },
    },
    on_press = function(params)
        Settings.ff_fps = math.max(1, tonumber(params.fps))
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_TOGGLE_MANUAL_ON_JOYSTICK,
    on_press = function()
        Settings.enable_manual_on_joystick_interact = not Settings.enable_manual_on_joystick_interact
        action.notify_active_changed(ACTION_SETTINGS_TOGGLE_MANUAL_ON_JOYSTICK)
    end,
    get_active = function()
        return Settings.enable_manual_on_joystick_interact
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_TOGGLE_LOCK_HOTKEYS,
    on_press = function()
        Settings.lock_hotkeys_when_control_active = not Settings.lock_hotkeys_when_control_active
        action.notify_active_changed(ACTION_SETTINGS_TOGGLE_LOCK_HOTKEYS)
    end,
    get_active = function()
        return Settings.lock_hotkeys_when_control_active
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_SELECT_MAP_FILE,
    on_press = function()
        Mapping.load_map_file_dialog()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_SET_REGION,
    params = {
        {
            key = 'region',
            name = 'Region',
            get_initial_value = function()
                return region_names()[Settings.address_source_index]
            end,
            get_hints = function(value)
                return option_hints(region_names(), value)
            end,
            validator = function(value)
                if option_index(region_names(), value) then
                    return nil
                end

                return 'Unknown region.'
            end,
        },
    },
    on_press = function(params)
        local index = option_index(region_names(), params.region)
        if index then
            Settings.address_source_index = index
        end
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_AUTODETECT_NOW,
    on_press = function()
        Settings.address_source_index = Memory.find_matching_address_source_index()
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_TOGGLE_AUTODETECT,
    on_press = function()
        Settings.autodetect_address = not Settings.autodetect_address
        action.notify_active_changed(ACTION_SETTINGS_TOGGLE_AUTODETECT)
    end,
    get_active = function()
        return Settings.autodetect_address
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_SET_ANGLE_FORMAT,
    params = {
        {
            key = 'format',
            name = 'Format',
            get_initial_value = function()
                local options = angle_format_options()
                for i = 1, #options, 1 do
                    if options[i].value == Settings.format_angles_degrees then
                        return options[i].name
                    end
                end

                return nil
            end,
            get_hints = function(value)
                return option_hints(option_names(angle_format_options()), value)
            end,
            validator = function(value)
                if option_index(option_names(angle_format_options()), value) then
                    return nil
                end

                return 'Unknown angle format.'
            end,
        },
    },
    on_press = function(params)
        local options = angle_format_options()
        local index = option_index(option_names(options), params.format)
        if index then
            Settings.format_angles_degrees = options[index].value
        end
    end,
})

actions[#actions + 1] = wrap_params({
    path = ACTION_SETTINGS_SET_DECIMAL_POINTS,
    params = {
        {
            key = 'points',
            name = 'Decimal Points',
            get_initial_value = function()
                return tostring(Settings.format_decimal_points)
            end,
            validator = Validators.number,
        },
    },
    on_press = function(params)
        Settings.format_decimal_points = math.max(0, tonumber(params.points))
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

actions[#actions + 1] = wrap_params({
    path = ACTION_TOGGLE_DEBUG_MODE,
    on_press = function()
        ugui.DEBUG = not ugui.DEBUG
        action.notify_active_changed(ACTION_TOGGLE_DEBUG_MODE)
    end,
    get_active = function()
        return ugui.DEBUG
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
