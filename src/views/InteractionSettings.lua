--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('InteractionSettings', function(enum_next)
    return {
        EnableManualOnJoystickInteract = enum_next()
    }
end)

local items = {
    {
        text = Locales.str('SETTINGS_INTERACTION_MANUAL_ON_JOYSTICK_INTERACT'),
        func = function(rect)
            Settings.enable_manual_on_joystick_interact = ugui.toggle_button({
                uid = UID.EnableManualOnJoystickInteract,
                rectangle = rect,
                is_checked = Settings.enable_manual_on_joystick_interact,
                text = Locales.str('GENERIC_ON'),
            })
        end,
    },
}

return {
    name = Locales.str('SETTINGS_INTERACTION_TAB_NAME'),
    draw = function()
        Drawing.setting_list(items, { x = 0, y = 0.1 })
    end,
}
