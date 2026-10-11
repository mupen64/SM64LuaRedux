--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = { r = 54, g = 30, b = 53 }
theme.font_size = 11.4
theme.font_name = 'Consolas'
theme.cleartype = false

theme.button.text = {
    [1] = ugui.color_source_to_rgba8('#000000'),
    [2] = ugui.color_source_to_rgba8('#000000'),
    [3] = ugui.color_source_to_rgba8('#000000'),
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
    [1] = ugui.color_source_to_rgba8('#2D022B'),
    [2] = ugui.color_source_to_rgba8('#2D022B'),
    [3] = ugui.color_source_to_rgba8('#2D022B'),
    [0] = ugui.color_source_to_rgba8('#2D022B'),
}
theme.joystick.inner_mag = {
    [1] = ugui.color_source_to_rgba8('#2D022B22'),
    [2] = ugui.color_source_to_rgba8('#2D022B22'),
    [3] = ugui.color_source_to_rgba8('#2D022B22'),
    [0] = ugui.color_source_to_rgba8('#2D022B22'),
}
theme.joystick.outer_mag = {
    [1] = ugui.color_source_to_rgba8('#2D022B'),
    [2] = ugui.color_source_to_rgba8('#2D022B'),
    [3] = ugui.color_source_to_rgba8('#2D022B'),
    [0] = ugui.color_source_to_rgba8('#2D022B'),
}
theme.joystick.line = {
    [1] = ugui.color_source_to_rgba8('#2D022B'),
    [2] = ugui.color_source_to_rgba8('#2D022B'),
    [3] = ugui.color_source_to_rgba8('#2D022B'),
    [0] = ugui.color_source_to_rgba8('#2D022B'),
}
theme.joystick.tip = {
    [1] = ugui.color_source_to_rgba8('#560453'),
    [2] = ugui.color_source_to_rgba8('#560453'),
    [3] = ugui.color_source_to_rgba8('#560453'),
    [0] = ugui.color_source_to_rgba8('#560453'),
}
return {
    name = 'Windows 3 Pink',
    theme = theme,
}
