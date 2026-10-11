--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = ugui.color_source_to_rgba8('#4C5945')
theme.textbox.selection = ugui.color_source_to_rgba8('#4FA33D')
theme.numberbox.selection = ugui.color_source_to_rgba8('#4FA33D')
theme.font_size = 11.4
theme.font_name = 'Tahoma'
theme.cleartype = false

theme.button.text = {
    [1] = ugui.color_source_to_rgba8('#FFFFFF'),
    [2] = ugui.color_source_to_rgba8('#FFFFFF'),
    [3] = ugui.color_source_to_rgba8('#FFFFFF'),
    [0] = ugui.color_source_to_rgba8('#838383'),
}
theme.textbox.text = {
    [1] = ugui.color_source_to_rgba8('#FFFFFF'),
    [2] = ugui.color_source_to_rgba8('#FFFFFF'),
    [3] = ugui.color_source_to_rgba8('#FFFFFF'),
    [0] = ugui.color_source_to_rgba8('#6D6D6D'),
}
theme.listbox_item.text = {
    [1] = ugui.color_source_to_rgba8('#FFFFFF'),
    [2] = ugui.color_source_to_rgba8('#FFFFFF'),
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
    [1] = ugui.color_source_to_rgba8('#4FA33D'),
    [2] = ugui.color_source_to_rgba8('#4FA33D'),
    [3] = ugui.color_source_to_rgba8('#4FA33D'),
    [0] = ugui.color_source_to_rgba8('#4FA33D'),
}
theme.joystick.inner_mag = {
    [1] = ugui.color_source_to_rgba8('#4FA33D22'),
    [2] = ugui.color_source_to_rgba8('#4FA33D22'),
    [3] = ugui.color_source_to_rgba8('#4FA33D22'),
    [0] = ugui.color_source_to_rgba8('#4FA33D22'),
}
theme.joystick.outer_mag = {
    [1] = ugui.color_source_to_rgba8('#4FA33D'),
    [2] = ugui.color_source_to_rgba8('#4FA33D'),
    [3] = ugui.color_source_to_rgba8('#4FA33D'),
    [0] = ugui.color_source_to_rgba8('#4FA33D'),
}
theme.joystick.line = {
    [1] = ugui.color_source_to_rgba8('#00CE4B'),
    [2] = ugui.color_source_to_rgba8('#00CE4B'),
    [3] = ugui.color_source_to_rgba8('#00CE4B'),
    [0] = ugui.color_source_to_rgba8('#00CE4B'),
}
theme.joystick.tip = {
    [1] = ugui.color_source_to_rgba8('#00CE4B'),
    [2] = ugui.color_source_to_rgba8('#00CE4B'),
    [3] = ugui.color_source_to_rgba8('#00CE4B'),
    [0] = ugui.color_source_to_rgba8('#00CE4B'),
}

return {
    name = 'Steam',
    theme = theme,
}
