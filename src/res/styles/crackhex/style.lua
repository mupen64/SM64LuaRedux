--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.font_name = 'Consolas'
theme.background_color = ugui.color_source_to_rgba8('#222222')
theme.textbox.selection = ugui.color_source_to_rgba8('#A8294BFF')
theme.numberbox.selection = ugui.color_source_to_rgba8('#A8294BFF')
theme.button.text = {
    [1] = ugui.color_source_to_rgba8('#F7A8B8'),
    [2] = ugui.color_source_to_rgba8('#000000'),
    [3] = ugui.color_source_to_rgba8('#000000'),
    [0] = ugui.color_source_to_rgba8('#838383'),
}
theme.textbox.text = {
    [1] = ugui.color_source_to_rgba8('#F7A8B8'),
    [2] = ugui.color_source_to_rgba8('#000000'),
    [3] = ugui.color_source_to_rgba8('#000000'),
    [0] = ugui.color_source_to_rgba8('#6D6D6D'),
}
theme.listbox_item.text = {
    [1] = ugui.color_source_to_rgba8('#F7A8B8'),
    [2] = ugui.color_source_to_rgba8('#F7A8B8'),
    [3] = ugui.color_source_to_rgba8('#000000'),
    [0] = ugui.color_source_to_rgba8('#D1D1D1'),
}
theme.joystick.back = {
    [1] = ugui.color_source_to_rgba8('#00000000'),
    [2] = ugui.color_source_to_rgba8('#00000000'),
    [3] = ugui.color_source_to_rgba8('#00000000'),
    [0] = ugui.color_source_to_rgba8('#00000000'),
}
theme.joystick.outline = {
    [1] = ugui.color_source_to_rgba8('#386A87'),
    [2] = ugui.color_source_to_rgba8('#386A87'),
    [3] = ugui.color_source_to_rgba8('#386A87'),
    [0] = ugui.color_source_to_rgba8('#386A87'),
}
theme.joystick.inner_mag = {
    [1] = ugui.color_source_to_rgba8('#55A0CC22'),
    [2] = ugui.color_source_to_rgba8('#55A0CC22'),
    [3] = ugui.color_source_to_rgba8('#55A0CC22'),
    [0] = ugui.color_source_to_rgba8('#55A0CC22'),
}
theme.joystick.outer_mag = {
    [1] = ugui.color_source_to_rgba8('#55A0CC'),
    [2] = ugui.color_source_to_rgba8('#55A0CC'),
    [3] = ugui.color_source_to_rgba8('#55A0CC'),
    [0] = ugui.color_source_to_rgba8('#55A0CC'),
}
theme.joystick.line = {
    [1] = ugui.color_source_to_rgba8('#EEAFC0'),
    [2] = ugui.color_source_to_rgba8('#EEAFC0'),
    [3] = ugui.color_source_to_rgba8('#EEAFC0'),
    [0] = ugui.color_source_to_rgba8('#EEAFC0'),
}
theme.joystick.tip = {
    [1] = ugui.color_source_to_rgba8('#EEAFC0'),
    [2] = ugui.color_source_to_rgba8('#EEAFC0'),
    [3] = ugui.color_source_to_rgba8('#EEAFC0'),
    [0] = ugui.color_source_to_rgba8('#EEAFC0'),
}
theme.menu = {
    back = {
        [1] = ugui.color_source_to_rgba8('#1A1A1C'),
        [2] = ugui.color_source_to_rgba8('#1A1A1C'),
        [3] = ugui.color_source_to_rgba8('#1A1A1C'),
        [0] = ugui.color_source_to_rgba8('#1A1A1C'),
    },
    border = {
        [1] = ugui.color_source_to_rgba8('#386A87'),
        [2] = ugui.color_source_to_rgba8('#386A87'),
        [3] = ugui.color_source_to_rgba8('#386A87'),
        [0] = ugui.color_source_to_rgba8('#386A87'),
    },
}
theme.menu_item = {
    back = {
        [1] = ugui.color_source_to_rgba8('#00000000'),
        [2] = ugui.color_source_to_rgba8('#73CFF4'),
        [3] = ugui.color_source_to_rgba8('#73CFF4'),
        [0] = ugui.color_source_to_rgba8('#00000000'),
    },
    border = {
        [1] = ugui.color_source_to_rgba8('#00000000'),
        [2] = ugui.color_source_to_rgba8('#00091E'),
        [3] = ugui.color_source_to_rgba8('#00091E'),
        [0] = ugui.color_source_to_rgba8('#00000000'),
    },
    text = {
        [1] = ugui.color_source_to_rgba8('#F7A8B8'),
        [2] = ugui.color_source_to_rgba8('#000000'),
        [3] = ugui.color_source_to_rgba8('#000000'),
        [0] = ugui.color_source_to_rgba8('#F7A8B8'),
    },
}

return {
    name = 'Crackhex',
    theme = theme,
}
