--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local theme = get_base_style()

theme.menu = {
    back = {
        [1] = BreitbandGraphics.hex_to_color('#F9F9F9'),
        [2] = BreitbandGraphics.hex_to_color('#F9F9F9'),
        [3] = BreitbandGraphics.hex_to_color('#F9F9F9'),
        [0] = BreitbandGraphics.hex_to_color('#F9F9F9'),
    },
    border = {
        [1] = BreitbandGraphics.hex_to_color('#E5E5E5'),
        [2] = BreitbandGraphics.hex_to_color('#E5E5E5'),
        [3] = BreitbandGraphics.hex_to_color('#E5E5E5'),
        [0] = BreitbandGraphics.hex_to_color('#E5E5E5'),
    },
}

theme.menu_item = {
    back = {
        [1] = BreitbandGraphics.hex_to_color('#00000000'),
        [2] = BreitbandGraphics.hex_to_color('#F0F0F0'),
        [3] = BreitbandGraphics.hex_to_color('#F0F0F0'),
        [0] = BreitbandGraphics.hex_to_color('#00000000'),
    },
    border = {
        [1] = BreitbandGraphics.hex_to_color('#00000000'),
        [2] = BreitbandGraphics.hex_to_color('#F0F0F0'),
        [3] = BreitbandGraphics.hex_to_color('#F0F0F0'),
        [0] = BreitbandGraphics.hex_to_color('#00000000'),
    },
}

return {
    name = 'Windows 11',
    theme = theme,
}
