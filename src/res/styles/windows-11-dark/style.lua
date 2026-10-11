--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = ugui.color_source_to_rgba8('#393939')
theme.textbox.selection = ugui.color_source_to_rgba8('#0078D7')
theme.numberbox.selection = ugui.color_source_to_rgba8('#0078D7')
theme.font_name = 'MS Sans Serif'
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
    [1] = ugui.color_source_to_rgba8('#9B9B9B'),
    [2] = ugui.color_source_to_rgba8('#9B9B9B'),
    [3] = ugui.color_source_to_rgba8('#9B9B9B'),
    [0] = ugui.color_source_to_rgba8('#9B9B9B'),
}
theme.joystick.inner_mag = {
    [1] = ugui.color_source_to_rgba8('#66666622'),
    [2] = ugui.color_source_to_rgba8('#66666622'),
    [3] = ugui.color_source_to_rgba8('#66666622'),
    [0] = ugui.color_source_to_rgba8('#66666622'),
}
theme.joystick.outer_mag = {
    [1] = ugui.color_source_to_rgba8('#666666'),
    [2] = ugui.color_source_to_rgba8('#666666'),
    [3] = ugui.color_source_to_rgba8('#666666'),
    [0] = ugui.color_source_to_rgba8('#666666'),
}
theme.joystick.line = {
    [1] = ugui.color_source_to_rgba8('#AAAAAA'),
    [2] = ugui.color_source_to_rgba8('#AAAAAA'),
    [3] = ugui.color_source_to_rgba8('#AAAAAA'),
    [0] = ugui.color_source_to_rgba8('#AAAAAA'),
}
theme.joystick.tip = {
    [1] = ugui.color_source_to_rgba8('#BBBBBB'),
    [2] = ugui.color_source_to_rgba8('#BBBBBB'),
    [3] = ugui.color_source_to_rgba8('#BBBBBB'),
    [0] = ugui.color_source_to_rgba8('#BBBBBB'),
}

return {
    name = 'Windows 11 Dark',
    theme = theme,
}
