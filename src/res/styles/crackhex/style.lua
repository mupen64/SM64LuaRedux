--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.font_name = "Consolas"
theme.background_color = BreitbandGraphics.repeated_to_color(34)
theme.button.text = {
    [1] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [2] = BreitbandGraphics.colors.black,
    [3] = BreitbandGraphics.colors.black,
    [0] = BreitbandGraphics.repeated_to_color(131),
}
theme.textbox.text = {
    [1] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [2] = BreitbandGraphics.colors.black,
    [3] = BreitbandGraphics.colors.black,
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox_item.text = {
    [1] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [2] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [3] = BreitbandGraphics.colors.black,
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.joystick.back = {
    [1] = BreitbandGraphics.hex_to_color("#00000000"),
    [2] = BreitbandGraphics.hex_to_color("#00000000"),
    [3] = BreitbandGraphics.hex_to_color("#00000000"),
    [0] = BreitbandGraphics.hex_to_color("#00000000"),
}
theme.joystick.outline = {
    [1] = BreitbandGraphics.hex_to_color("#386A87"),
    [2] = BreitbandGraphics.hex_to_color("#386A87"),
    [3] = BreitbandGraphics.hex_to_color("#386A87"),
    [0] = BreitbandGraphics.hex_to_color("#386A87"),
}
theme.joystick.inner_mag = {
    [1] = BreitbandGraphics.hex_to_color("#55A0CC22"),
    [2] = BreitbandGraphics.hex_to_color("#55A0CC22"),
    [3] = BreitbandGraphics.hex_to_color("#55A0CC22"),
    [0] = BreitbandGraphics.hex_to_color("#55A0CC22"),
}
theme.joystick.outer_mag = {
    [1] = BreitbandGraphics.hex_to_color("#55A0CC"),
    [2] = BreitbandGraphics.hex_to_color("#55A0CC"),
    [3] = BreitbandGraphics.hex_to_color("#55A0CC"),
    [0] = BreitbandGraphics.hex_to_color("#55A0CC"),
}
theme.joystick.line = {
    [1] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [2] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [3] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [0] = BreitbandGraphics.hex_to_color("#EEAFC0"),
}
theme.joystick.tip = {
    [1] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [2] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [3] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [0] = BreitbandGraphics.hex_to_color("#EEAFC0"),
}
theme.menu = {
    back = {
        [1] = BreitbandGraphics.hex_to_color('#1A1A1C'),
        [2] = BreitbandGraphics.hex_to_color('#1A1A1C'),
        [3] = BreitbandGraphics.hex_to_color('#1A1A1C'),
        [0] = BreitbandGraphics.hex_to_color('#1A1A1C'),
    },
    border = {
        [1] = BreitbandGraphics.hex_to_color('#386A87'),
        [2] = BreitbandGraphics.hex_to_color('#386A87'),
        [3] = BreitbandGraphics.hex_to_color('#386A87'),
        [0] = BreitbandGraphics.hex_to_color('#386A87'),
    },
}
theme.menu_item = {
    back = {
        [1] = BreitbandGraphics.hex_to_color('#00000000'),
        [2] = BreitbandGraphics.hex_to_color('#73CFF4'),
        [3] = BreitbandGraphics.hex_to_color('#73CFF4'),
        [0] = BreitbandGraphics.hex_to_color('#00000000'),
    },
    border = {
        [1] = BreitbandGraphics.hex_to_color('#00000000'),
        [2] = BreitbandGraphics.hex_to_color('#00091E'),
        [3] = BreitbandGraphics.hex_to_color('#00091E'),
        [0] = BreitbandGraphics.hex_to_color('#00000000'),
    },
    text = {
        [1] = BreitbandGraphics.hex_to_color('#F7A8B8'),
        [2] = BreitbandGraphics.hex_to_color('#000000'),
        [3] = BreitbandGraphics.hex_to_color('#000000'),
        [0] = BreitbandGraphics.hex_to_color('#F7A8B8'),
    }
}

return {
    name = 'Crackhex',
    theme = theme
}
