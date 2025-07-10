--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = BreitbandGraphics.repeated_to_color(57)
theme.font_name = 'MS Sans Serif'
theme.button.text = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(131),
}
theme.textbox.text = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox_item.text = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.joystick.back = {
    [1] = BreitbandGraphics.hex_to_color('#00000000'),
    [2] = BreitbandGraphics.hex_to_color('#00000000'),
    [3] = BreitbandGraphics.hex_to_color('#00000000'),
    [0] = BreitbandGraphics.hex_to_color('#00000000'),
}
theme.joystick.outline = {
    [1] = BreitbandGraphics.hex_to_color('#9B9B9B'),
    [2] = BreitbandGraphics.hex_to_color('#9B9B9B'),
    [3] = BreitbandGraphics.hex_to_color('#9B9B9B'),
    [0] = BreitbandGraphics.hex_to_color('#9B9B9B'),
}
theme.joystick.inner_mag = {
    [1] = BreitbandGraphics.hex_to_color('#66666622'),
    [2] = BreitbandGraphics.hex_to_color('#66666622'),
    [3] = BreitbandGraphics.hex_to_color('#66666622'),
    [0] = BreitbandGraphics.hex_to_color('#66666622'),
}
theme.joystick.outer_mag = {
    [1] = BreitbandGraphics.hex_to_color('#666666'),
    [2] = BreitbandGraphics.hex_to_color('#666666'),
    [3] = BreitbandGraphics.hex_to_color('#666666'),
    [0] = BreitbandGraphics.hex_to_color('#666666'),
}
theme.joystick.line = {
    [1] = BreitbandGraphics.hex_to_color('#AAAAAA'),
    [2] = BreitbandGraphics.hex_to_color('#AAAAAA'),
    [3] = BreitbandGraphics.hex_to_color('#AAAAAA'),
    [0] = BreitbandGraphics.hex_to_color('#AAAAAA'),
}
theme.joystick.tip = {
    [1] = BreitbandGraphics.hex_to_color('#BBBBBB'),
    [2] = BreitbandGraphics.hex_to_color('#BBBBBB'),
    [3] = BreitbandGraphics.hex_to_color('#BBBBBB'),
    [0] = BreitbandGraphics.hex_to_color('#BBBBBB'),
}

return {
    name = 'Windows 10 Dark',
    theme = theme,
}
