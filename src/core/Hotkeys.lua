local hotkey_funcs = {
    movement_mode_disabled = function()
        TASState.movement_mode = MovementModes.disabled
    end,
    movement_mode_match_yaw = function()
        TASState.movement_mode = MovementModes.match_yaw
    end,
    movement_mode_reverse_angle = function()
        TASState.movement_mode = MovementModes.reverse_angle
    end,
    movement_mode_match_angle = function()
        TASState.movement_mode = MovementModes.match_angle
    end,
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
    toggle_spdkick = function ()
        Engine.toggle_speedkick()
    end,
    toggle_navbar = function ()
        Settings.navbar_visible = not Settings.navbar_visible
    end,
}

local last_pressed_hotkey = nil
local last_pressed_hotkey_time = 0

local function call_hotkey_func(identifier)
    if not Settings.hotkeys_allow_with_active_control
    and ugui.internal.active_control then
        return
    end 

    local result = hotkey_funcs[identifier]()

    if result ~= false then
        Notifications.show("Hotkey " .. identifier .. " pressed")
    end
end

return {
    on_key_down = function(keys)
        if not emu.ismainwindowinforeground() or not Settings.hotkeys_enabled then
            return
        end
        for _, hotkey in pairs(Settings.hotkeys) do
            local activated = true

            if #hotkey.keys == 0 then
                activated = false
            else
                for _, key in pairs(hotkey.keys) do
                    if not keys[key] then
                        activated = false
                    end
                end
            end

            if activated then
                last_pressed_hotkey_time = os.clock()
                last_pressed_hotkey = hotkey.identifier
                call_hotkey_func(hotkey.identifier)
                return
            end
        end
    end,

    update = function()
        if not emu.ismainwindowinforeground() or not last_pressed_hotkey then
            return
        end

        local hotkey = lualinq.first(Settings.hotkeys, function(x)
            return x.identifier == last_pressed_hotkey
        end)

        if not hotkey.mode or hotkey.mode == HOTKEY_MODE_ONESHOT then
            return
        end

        local activated = true

        for _, key in pairs(hotkey.keys) do
            if not ugui.internal.environment.held_keys[key] then
                activated = false
            end
        end

        if activated then
            local time_since_press = os.clock() - last_pressed_hotkey_time

            if time_since_press > 0.75 then
                local invocation_frequency = math.ceil(math.pow(time_since_press, 2))

                for _ = 1, invocation_frequency, 1 do
                    call_hotkey_func(last_pressed_hotkey)
                end
            else
                if time_since_press > 0.3 then
                    call_hotkey_func(last_pressed_hotkey)
                end
            end
        end
    end,

    ---Gets whether a hotkey with the specified identifier has a callback.
    ---@param identifier string The hotkey identifier.
    hotkey_exists = function (identifier)
        return hotkey_funcs[identifier] ~= nil        
    end
}
