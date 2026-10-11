--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

function get_base_style()
    return {
        background_color = ugui.color_source_to_rgba8('#F0F0F0'),

        font_name = 'MS Sans Serif',
        font_size = 12,

        icon_size = 10,

        button = {
            text = {
                [1] = ugui.color_source_to_rgba8('#000000'),
                [2] = ugui.color_source_to_rgba8('#000000'),
                [3] = ugui.color_source_to_rgba8('#000000'),
                [0] = ugui.color_source_to_rgba8('#838383'),
            },

            states = {
                [1] = {
                    source = expand_rect({ 1, 1, 11, 9 }),
                    center = expand_rect({ 6, 5, 1, 1 }),
                },
                [2] = {
                    source = expand_rect({ 1, 12, 11, 9 }),
                    center = expand_rect({ 6, 16, 1, 1 }),
                },
                [3] = {
                    source = expand_rect({ 1, 23, 11, 9 }),
                    center = expand_rect({ 6, 27, 1, 1 }),
                },
                [0] = {
                    source = expand_rect({ 1, 34, 11, 9 }),
                    center = expand_rect({ 6, 38, 1, 1 }),
                },
            },
        },
        textbox = {
            item_height = 15,
            selection = ugui.color_source_to_rgba8('#0078D7'),

            text = {
                [1] = ugui.color_source_to_rgba8('#000000'),
                [2] = ugui.color_source_to_rgba8('#000000'),
                [3] = ugui.color_source_to_rgba8('#000000'),
                [0] = ugui.color_source_to_rgba8('#6D6D6D'),
            },

            states = {
                [1] = {
                    source = expand_rect({ 74, 1, 5, 5 }),
                    center = expand_rect({ 76, 3, 1, 1 }),
                },
                [2] = {
                    source = expand_rect({ 74, 6, 5, 5 }),
                    center = expand_rect({ 76, 8, 1, 1 }),
                },
                [3] = {
                    source = expand_rect({ 74, 11, 5, 5 }),
                    center = expand_rect({ 76, 13, 1, 1 }),
                },
                [0] = {
                    source = expand_rect({ 74, 16, 5, 5 }),
                    center = expand_rect({ 76, 18, 1, 1 }),
                },
            },
        },
        numberbox = {
            selection = ugui.color_source_to_rgba8('#0078D7'),
        },
        listbox = {
            text = {
                [1] = ugui.color_source_to_rgba8('#000000'),
                [2] = ugui.color_source_to_rgba8('#000000'),
                [3] = ugui.color_source_to_rgba8('#FFFFFF'),
                [0] = ugui.color_source_to_rgba8('#CCCCCC'),
            },
            states = {
                [1] = {
                    source = expand_rect({ 80, 1, 3, 3 }),
                    center = expand_rect({ 81, 2, 1, 1 }),
                },
                [2] = {
                    source = expand_rect({ 80, 1, 3, 3 }),
                    center = expand_rect({ 81, 2, 1, 1 }),
                },
                [3] = {
                    source = expand_rect({ 80, 1, 3, 3 }),
                    center = expand_rect({ 81, 2, 1, 1 }),
                },
                [0] = {
                    source = expand_rect({ 80, 10, 3, 3 }),
                    center = expand_rect({ 81, 11, 1, 1 }),
                },
            },
        },
        listbox_item = {
            states = {
                [1] = {
                    source = expand_rect({ 83, 5, 3, 4 }),
                    center = expand_rect({ 84, 6, 1, 2 }),
                },
                [2] = {
                    source = expand_rect({ 83, 5, 3, 4 }),
                    center = expand_rect({ 84, 6, 1, 2 }),
                },
                [3] = {
                    source = expand_rect({ 83, 1, 3, 4 }),
                    center = expand_rect({ 84, 2, 1, 2 }),
                },
                [0] = {
                    source = expand_rect({ 83, 5, 3, 4 }),
                    center = expand_rect({ 84, 6, 1, 2 }),
                },
            },
        },
        scrollbar_thumb = {
            states = {
                [1] = {
                    source = expand_rect({ 30, 66, 17, 11 }),
                    center = expand_rect({ 38, 70, 2, 3 }),
                },
                [2] = {
                    source = expand_rect({ 30, 77, 17, 11 }),
                    center = expand_rect({ 38, 81, 2, 3 }),
                },
                [3] = {
                    source = expand_rect({ 30, 88, 17, 11 }),
                    center = expand_rect({ 38, 92, 2, 3 }),
                },
                [0] = {
                    source = expand_rect({ 30, 110, 17, 11 }),
                    center = expand_rect({ 38, 114, 2, 3 }),
                },
            },
        },
        joystick = {
            back = {
                [1] = ugui.color_source_to_rgba8('#FFFFFF'),
                [2] = ugui.color_source_to_rgba8('#FFFFFF'),
                [3] = ugui.color_source_to_rgba8('#FFFFFF'),
                [0] = ugui.color_source_to_rgba8('#FFFFFF'),
            },
            outline = {
                [1] = ugui.color_source_to_rgba8('#000000'),
                [2] = ugui.color_source_to_rgba8('#000000'),
                [3] = ugui.color_source_to_rgba8('#000000'),
                [0] = ugui.color_source_to_rgba8('#000000'),
            },
            tip = {
                [1] = ugui.color_source_to_rgba8('#FF0000'),
                [2] = ugui.color_source_to_rgba8('#FF0000'),
                [3] = ugui.color_source_to_rgba8('#FF0000'),
                [0] = ugui.color_source_to_rgba8('#FF8080'),
            },
            line = {
                [1] = ugui.color_source_to_rgba8('#0000FF'),
                [2] = ugui.color_source_to_rgba8('#0000FF'),
                [3] = ugui.color_source_to_rgba8('#0000FF'),
                [0] = ugui.color_source_to_rgba8('#8080FF'),
            },
            inner_mag = {
                [1] = ugui.color_source_to_rgba8('#FF000022'),
                [2] = ugui.color_source_to_rgba8('#FF000022'),
                [3] = ugui.color_source_to_rgba8('#FF000022'),
                [0] = ugui.color_source_to_rgba8('#00000000'),
            },
            outer_mag = {
                [1] = ugui.color_source_to_rgba8('#FF0000'),
                [2] = ugui.color_source_to_rgba8('#FF0000'),
                [3] = ugui.color_source_to_rgba8('#FF0000'),
                [0] = ugui.color_source_to_rgba8('#FF8080'),
            },
            mag_thicknesses = {
                [1] = 2,
                [2] = 2,
                [3] = 2,
                [0] = 2,
            },
        },
        scrollbar_rail = expand_rect({ 30, 99, 17, 11 }),
    }
end
