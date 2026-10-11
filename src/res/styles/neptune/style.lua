--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = { r = 24, g = 27, b = 40 }
theme.textbox.selection = ugui.color_source_to_rgba8('#6EE4E7')
theme.numberbox.selection = ugui.color_source_to_rgba8('#6EE4E7')
theme.button.text = {
    [1] = ugui.color_source_to_rgba8('#C2C6D0'),
    [2] = ugui.color_source_to_rgba8('#0D1016'),
    [3] = ugui.color_source_to_rgba8('#4B0054'),
    [0] = ugui.color_source_to_rgba8('#838383'),
}
theme.textbox.text = {
    [1] = ugui.color_source_to_rgba8('#C2C6D0'),
    [2] = ugui.color_source_to_rgba8('#C2C6D0'),
    [3] = ugui.color_source_to_rgba8('#FFFFFF'),
    [0] = ugui.color_source_to_rgba8('#6D6D6D'),
}
theme.listbox_item.text = {
    [1] = ugui.color_source_to_rgba8('#C2C6D0'),
    [2] = ugui.color_source_to_rgba8('#C2C6D0'),
    [3] = ugui.color_source_to_rgba8('#FFFFFF'),
    [0] = ugui.color_source_to_rgba8('#D1D1D1'),
}
theme.joystick.back = {
    [1] = ugui.color_source_to_rgba8('#00000000'),
    [2] = ugui.color_source_to_rgba8('#00000000'),
    [3] = ugui.color_source_to_rgba8('#00000000'),
    [0] = ugui.color_source_to_rgba8('#00000000'),
}
theme.joystick.outline = {
    [1] = ugui.color_source_to_rgba8('#6EE4E7'),
    [2] = ugui.color_source_to_rgba8('#6EE4E7'),
    [3] = ugui.color_source_to_rgba8('#6EE4E7'),
    [0] = ugui.color_source_to_rgba8('#6EE4E7'),
}
theme.joystick.inner_mag = {
    [1] = ugui.color_source_to_rgba8('#55A0CC22'),
    [2] = ugui.color_source_to_rgba8('#55A0CC22'),
    [3] = ugui.color_source_to_rgba8('#55A0CC22'),
    [0] = ugui.color_source_to_rgba8('#55A0CC22'),
}
theme.joystick.outer_mag = {
    [1] = ugui.color_source_to_rgba8('#99DADB'),
    [2] = ugui.color_source_to_rgba8('#99DADB'),
    [3] = ugui.color_source_to_rgba8('#99DADB'),
    [0] = ugui.color_source_to_rgba8('#99DADB'),
}
theme.joystick.line = {
    [1] = ugui.color_source_to_rgba8('#D05DF3'),
    [2] = ugui.color_source_to_rgba8('#D05DF3'),
    [3] = ugui.color_source_to_rgba8('#D05DF3'),
    [0] = ugui.color_source_to_rgba8('#D05DF3'),
}
theme.joystick.tip = {
    [1] = ugui.color_source_to_rgba8('#D05DF3'),
    [2] = ugui.color_source_to_rgba8('#D05DF3'),
    [3] = ugui.color_source_to_rgba8('#D05DF3'),
    [0] = ugui.color_source_to_rgba8('#D05DF3'),
}
theme.menu = {
    back = {
        [1] = ugui.color_source_to_rgba8('#1E2233'),
        [2] = ugui.color_source_to_rgba8('#1E2233'),
        [3] = ugui.color_source_to_rgba8('#1E2233'),
        [0] = ugui.color_source_to_rgba8('#1E2233'),
    },
    border = {
        [1] = ugui.color_source_to_rgba8('#00091E'),
        [2] = ugui.color_source_to_rgba8('#00091E'),
        [3] = ugui.color_source_to_rgba8('#00091E'),
        [0] = ugui.color_source_to_rgba8('#00091E'),
    },
}
theme.menu_item = {
    back = {
        [1] = ugui.color_source_to_rgba8('#00000000'),
        [2] = ugui.color_source_to_rgba8('#6EE4E7'),
        [3] = ugui.color_source_to_rgba8('#6EE4E7'),
        [0] = ugui.color_source_to_rgba8('#00000000'),
    },
    border = {
        [1] = ugui.color_source_to_rgba8('#00000000'),
        [2] = ugui.color_source_to_rgba8('#141721'),
        [3] = ugui.color_source_to_rgba8('#141721'),
        [0] = ugui.color_source_to_rgba8('#00000000'),
    },
    text = {
        [1] = ugui.color_source_to_rgba8('#C2C6D0'),
        [2] = ugui.color_source_to_rgba8('#0D1016'),
        [3] = ugui.color_source_to_rgba8('#4B0054'),
        [0] = ugui.color_source_to_rgba8('#838383'),
    },
}

return {
    name = 'Neptune',
    theme = theme,
}
