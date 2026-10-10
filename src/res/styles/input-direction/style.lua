--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = ugui.color_source_to_rgba8('#222222')
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
    [1] = ugui.color_source_to_rgba8('#000000'),
    [2] = ugui.color_source_to_rgba8('#FFFFFF'),
    [3] = ugui.color_source_to_rgba8('#FFFFFF'),
    [0] = ugui.color_source_to_rgba8('#838383'),
}
theme.textbox.text = {
    [1] = ugui.color_source_to_rgba8('#FFFFFF'),
    [2] = ugui.color_source_to_rgba8('#FFFFFF'),
    [3] = ugui.color_source_to_rgba8('#000000'),
    [0] = ugui.color_source_to_rgba8('#6D6D6D'),
}
theme.listbox_item.text = {
    [1] = ugui.color_source_to_rgba8('#FFFFFF'),
    [2] = ugui.color_source_to_rgba8('#FFFFFF'),
    [3] = ugui.color_source_to_rgba8('#FFFFFF'),
    [0] = ugui.color_source_to_rgba8('#D1D1D1'),
}
theme.joystick.back = {
    [1] = ugui.color_source_to_rgba8('#222222'),
    [2] = ugui.color_source_to_rgba8('#222222'),
    [3] = ugui.color_source_to_rgba8('#222222'),
    [0] = ugui.color_source_to_rgba8('#222222'),
}
theme.joystick.outline = {
    [1] = ugui.color_source_to_rgba8('#FFFFFF'),
    [2] = ugui.color_source_to_rgba8('#FFFFFF'),
    [3] = ugui.color_source_to_rgba8('#FFFFFF'),
    [0] = ugui.color_source_to_rgba8('#FFFFFF'),
}
theme.joystick.inner_mag = {
    [1] = ugui.color_source_to_rgba8('#FF000022'),
    [2] = ugui.color_source_to_rgba8('#FF000022'),
    [3] = ugui.color_source_to_rgba8('#FF000022'),
    [0] = ugui.color_source_to_rgba8('#FF000022'),
}
theme.joystick.outer_mag = {
    [1] = ugui.color_source_to_rgba8('#FF0000'),
    [2] = ugui.color_source_to_rgba8('#FF0000'),
    [3] = ugui.color_source_to_rgba8('#FF0000'),
    [0] = ugui.color_source_to_rgba8('#FF0000'),
}
theme.joystick.line = {
    [1] = ugui.color_source_to_rgba8('#00FF08'),
    [2] = ugui.color_source_to_rgba8('#00FF08'),
    [3] = ugui.color_source_to_rgba8('#00FF08'),
    [0] = ugui.color_source_to_rgba8('#00FF08'),
}
theme.joystick.tip = {
    [1] = ugui.color_source_to_rgba8('#FF0000'),
    [2] = ugui.color_source_to_rgba8('#FF0000'),
    [3] = ugui.color_source_to_rgba8('#FF0000'),
    [0] = ugui.color_source_to_rgba8('#FF0000'),
}

return {
    name = 'InputDirection',
    theme = theme,
}
