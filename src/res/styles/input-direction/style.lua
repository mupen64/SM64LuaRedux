--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = BreitbandGraphics.hex_to_color('#222222')
theme.button.states = {
    [1] = {
        source = expand_rect({ 1, 1, 11, 9 }),
        center = expand_rect({ 2, 2, 8, 6 }),
    },
    [2] = {
        source = expand_rect({ 1, 12, 11, 9 }),
        center = expand_rect({ 2, 13, 8, 6 }),
    },
    [3] = {
        source = expand_rect({ 1, 23, 11, 9 }),
        center = expand_rect({ 2, 24, 8, 6 }),
    },
    [0] = {
        source = expand_rect({ 1, 34, 11, 9 }),
        center = expand_rect({ 2, 35, 8, 6 }),
    },
}
theme.button.text = {
    [1] = BreitbandGraphics.colors.black,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(131),
}
theme.textbox.text = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.black,
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox_item.text = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.joystick.back = {
    [1] = BreitbandGraphics.hex_to_color('#222222'),
    [2] = BreitbandGraphics.hex_to_color('#222222'),
    [3] = BreitbandGraphics.hex_to_color('#222222'),
    [0] = BreitbandGraphics.hex_to_color('#222222'),
}
theme.joystick.outline = {
    [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
    [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
    [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
    [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
}
theme.joystick.inner_mag = {
    [1] = BreitbandGraphics.hex_to_color('#FF000022'),
    [2] = BreitbandGraphics.hex_to_color('#FF000022'),
    [3] = BreitbandGraphics.hex_to_color('#FF000022'),
    [0] = BreitbandGraphics.hex_to_color('#FF000022'),
}
theme.joystick.outer_mag = {
    [1] = BreitbandGraphics.hex_to_color('#FF0000'),
    [2] = BreitbandGraphics.hex_to_color('#FF0000'),
    [3] = BreitbandGraphics.hex_to_color('#FF0000'),
    [0] = BreitbandGraphics.hex_to_color('#FF0000'),
}
theme.joystick.line = {
    [1] = BreitbandGraphics.hex_to_color('#00FF08'),
    [2] = BreitbandGraphics.hex_to_color('#00FF08'),
    [3] = BreitbandGraphics.hex_to_color('#00FF08'),
    [0] = BreitbandGraphics.hex_to_color('#00FF08'),
}
theme.joystick.tip = {
    [1] = BreitbandGraphics.hex_to_color('#FF0000'),
    [2] = BreitbandGraphics.hex_to_color('#FF0000'),
    [3] = BreitbandGraphics.hex_to_color('#FF0000'),
    [0] = BreitbandGraphics.hex_to_color('#FF0000'),
}

return {
    name = 'InputDirection',
    theme = theme,
}
