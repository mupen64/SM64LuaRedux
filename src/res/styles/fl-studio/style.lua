--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.background_color = { r = 107, g = 116, b = 121 }
theme.font_size = 14
-- not preinstalled
-- theme.font_name = "Cuprum"
theme.font_name = 'Candara'

theme.textbox.text = {
    [1] = ugui.color_source_to_rgba8('#A5ABAF'),
    [2] = ugui.color_source_to_rgba8('#A5ABAF'),
    [3] = ugui.color_source_to_rgba8('#A5ABAF'),
    [0] = ugui.color_source_to_rgba8('#D1D1D1'),
}
theme.button.text = {
    [1] = ugui.color_source_to_rgba8('#DAD8D2'),
    [2] = ugui.color_source_to_rgba8('#DAD8D2'),
    [3] = ugui.color_source_to_rgba8('#DAD8D2'),
    [0] = ugui.color_source_to_rgba8('#D1D1D1'),
}
theme.listbox_item.text = {
    [1] = ugui.color_source_to_rgba8('#A5ABAF'),
    [2] = ugui.color_source_to_rgba8('#A5ABAF'),
    [3] = ugui.color_source_to_rgba8('#A5ABAF'),
    [0] = ugui.color_source_to_rgba8('#D1D1D1'),
}

return {
    name = 'FL Studio',
    theme = theme,
}
