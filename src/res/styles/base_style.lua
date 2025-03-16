function get_base_style()
    return {
        background_color = BreitbandGraphics.repeated_to_color(240),

        font_name = 'MS Sans Serif',
        font_size = 12,

        icon_size = 10,

        button = {
            text = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.black,
                [0] = BreitbandGraphics.repeated_to_color(131),
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
                }
            }
        },
        textbox = {
            item_height = 15,

            text = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.black,
                [0] = BreitbandGraphics.repeated_to_color(109),
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
                }
            }
        },
        listbox = {
            text = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.white,
                [0] = BreitbandGraphics.repeated_to_color(204),
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
                }
            }
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
                }
            }
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
                }
            }
        },
        joystick = {
            back = {
                [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
                [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            },
            outline  = {
                [1] = BreitbandGraphics.hex_to_color('#000000'),
                [2] = BreitbandGraphics.hex_to_color('#000000'),
                [3] = BreitbandGraphics.hex_to_color('#000000'),
                [0] = BreitbandGraphics.hex_to_color('#000000'),
            },
            tip = {
                [1] = BreitbandGraphics.hex_to_color('#FF0000'),
                [2] = BreitbandGraphics.hex_to_color('#FF0000'),
                [3] = BreitbandGraphics.hex_to_color('#FF0000'),
                [0] = BreitbandGraphics.hex_to_color('#FF8080'),
            },
            line = {
                [1] = BreitbandGraphics.hex_to_color('#0000FF'),
                [2] = BreitbandGraphics.hex_to_color('#0000FF'),
                [3] = BreitbandGraphics.hex_to_color('#0000FF'),
                [0] = BreitbandGraphics.hex_to_color('#8080FF'),
            },
            inner_mag = {
                [1] = BreitbandGraphics.hex_to_color('#FF000022'),
                [2] = BreitbandGraphics.hex_to_color('#FF000022'),
                [3] = BreitbandGraphics.hex_to_color('#FF000022'),
                [0] = BreitbandGraphics.hex_to_color('#00000000'),
            },
            outer_mag = {
                [1] = BreitbandGraphics.hex_to_color('#FF0000'),
                [2] = BreitbandGraphics.hex_to_color('#FF0000'),
                [3] = BreitbandGraphics.hex_to_color('#FF0000'),
                [0] = BreitbandGraphics.hex_to_color('#FF8080'),
            },
            mag_thicknesses = {
                [1] = 2,
                [2] = 2,
                [3] = 2,
                [0] = 2,
            },
        },
        scrollbar_rail = expand_rect({ 30, 99, 17, 11 }),
        icons = {
            arrow_left = {
                [1] = expand_rect({ 74, 171, 7, 10 }),
                [2] = expand_rect({ 55, 171, 7, 10 }),
                [3] = expand_rect({ 36, 171, 7, 10 }),
                [0] = expand_rect({ 17, 171, 7, 10 }),
            },
            arrow_right = {
                [1] = expand_rect({ 17, 184, 7, 10 }),
                [2] = expand_rect({ 36, 184, 7, 10 }),
                [3] = expand_rect({ 55, 184, 7, 10 }),
                [0] = expand_rect({ 74, 184, 7, 10 }),
            },
            arrow_up = {
                [1] = expand_rect({ 72, 254, 10, 7 }),
                [2] = expand_rect({ 72, 235, 10, 7 }),
                [3] = expand_rect({ 72, 216, 10, 7 }),
                [0] = expand_rect({ 72, 197, 10, 7 }),
            },
            arrow_down = {
                [1] = expand_rect({ 58, 197, 10, 7 }),
                [2] = expand_rect({ 58, 216, 10, 7 }),
                [3] = expand_rect({ 58, 235, 10, 7 }),
                [0] = expand_rect({ 58, 254, 10, 7 }),
            },
        },
    }
end
