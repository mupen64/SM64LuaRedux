--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.menu = {
    back = {
        [1] = ugui.color_source_to_rgba8('#F9F9F9'),
        [2] = ugui.color_source_to_rgba8('#F9F9F9'),
        [3] = ugui.color_source_to_rgba8('#F9F9F9'),
        [0] = ugui.color_source_to_rgba8('#F9F9F9'),
    },
    border = {
        [1] = ugui.color_source_to_rgba8('#E5E5E5'),
        [2] = ugui.color_source_to_rgba8('#E5E5E5'),
        [3] = ugui.color_source_to_rgba8('#E5E5E5'),
        [0] = ugui.color_source_to_rgba8('#E5E5E5'),
    },
}

theme.menu_item = {
    back = {
        [1] = ugui.color_source_to_rgba8('#00000000'),
        [2] = ugui.color_source_to_rgba8('#F0F0F0'),
        [3] = ugui.color_source_to_rgba8('#F0F0F0'),
        [0] = ugui.color_source_to_rgba8('#00000000'),
    },
    border = {
        [1] = ugui.color_source_to_rgba8('#00000000'),
        [2] = ugui.color_source_to_rgba8('#F0F0F0'),
        [3] = ugui.color_source_to_rgba8('#F0F0F0'),
        [0] = ugui.color_source_to_rgba8('#00000000'),
    },
}

return {
    name = 'Windows 11 V2',
    theme = theme,
}
