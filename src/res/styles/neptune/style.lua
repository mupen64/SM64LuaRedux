--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = { r = 24, g = 27, b = 40 }
theme.button.text = {
    [1] = BreitbandGraphics.hex_to_color('#C2C6D0'),
    [2] = BreitbandGraphics.hex_to_color('#0D1016'),
    [3] = BreitbandGraphics.hex_to_color('#4B0054'),
    [0] = BreitbandGraphics.repeated_to_color(131),
}
theme.textbox.text = {
    [1] = BreitbandGraphics.hex_to_color('#C2C6D0'),
    [2] = BreitbandGraphics.hex_to_color('#C2C6D0'),
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox_item.text = {
    [1] = BreitbandGraphics.hex_to_color('#C2C6D0'),
    [2] = BreitbandGraphics.hex_to_color('#C2C6D0'),
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
    [1] = BreitbandGraphics.hex_to_color('#6EE4E7'),
    [2] = BreitbandGraphics.hex_to_color('#6EE4E7'),
    [3] = BreitbandGraphics.hex_to_color('#6EE4E7'),
    [0] = BreitbandGraphics.hex_to_color('#6EE4E7'),
}
theme.joystick.inner_mag = {
    [1] = BreitbandGraphics.hex_to_color('#55A0CC22'),
    [2] = BreitbandGraphics.hex_to_color('#55A0CC22'),
    [3] = BreitbandGraphics.hex_to_color('#55A0CC22'),
    [0] = BreitbandGraphics.hex_to_color('#55A0CC22'),
}
theme.joystick.outer_mag = {
    [1] = BreitbandGraphics.hex_to_color('#99DADB'),
    [2] = BreitbandGraphics.hex_to_color('#99DADB'),
    [3] = BreitbandGraphics.hex_to_color('#99DADB'),
    [0] = BreitbandGraphics.hex_to_color('#99DADB'),
}
theme.joystick.line = {
    [1] = BreitbandGraphics.hex_to_color('#D05DF3'),
    [2] = BreitbandGraphics.hex_to_color('#D05DF3'),
    [3] = BreitbandGraphics.hex_to_color('#D05DF3'),
    [0] = BreitbandGraphics.hex_to_color('#D05DF3'),
}
theme.joystick.tip = {
    [1] = BreitbandGraphics.hex_to_color('#D05DF3'),
    [2] = BreitbandGraphics.hex_to_color('#D05DF3'),
    [3] = BreitbandGraphics.hex_to_color('#D05DF3'),
    [0] = BreitbandGraphics.hex_to_color('#D05DF3'),
}
theme.menu = {
    back = {
        [1] = BreitbandGraphics.hex_to_color('#1E2233'),
        [2] = BreitbandGraphics.hex_to_color('#1E2233'),
        [3] = BreitbandGraphics.hex_to_color('#1E2233'),
        [0] = BreitbandGraphics.hex_to_color('#1E2233'),
    },
    border = {
        [1] = BreitbandGraphics.hex_to_color('#00091E'),
        [2] = BreitbandGraphics.hex_to_color('#00091E'),
        [3] = BreitbandGraphics.hex_to_color('#00091E'),
        [0] = BreitbandGraphics.hex_to_color('#00091E'),
    },
}
theme.menu_item = {
    back = {
        [1] = BreitbandGraphics.hex_to_color('#00000000'),
        [2] = BreitbandGraphics.hex_to_color('#6EE4E7'),
        [3] = BreitbandGraphics.hex_to_color('#6EE4E7'),
        [0] = BreitbandGraphics.hex_to_color('#00000000'),
    },
    border = {
        [1] = BreitbandGraphics.hex_to_color('#00000000'),
        [2] = BreitbandGraphics.hex_to_color('#141721'),
        [3] = BreitbandGraphics.hex_to_color('#141721'),
        [0] = BreitbandGraphics.hex_to_color('#00000000'),
    },
    text = {
        [1] = BreitbandGraphics.hex_to_color('#C2C6D0'),
        [2] = BreitbandGraphics.hex_to_color('#0D1016'),
        [3] = BreitbandGraphics.hex_to_color('#4B0054'),
        [0] = BreitbandGraphics.repeated_to_color(131),
    },
}

return {
    name = 'Neptune',
    theme = theme,
}
