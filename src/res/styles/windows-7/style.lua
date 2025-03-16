local theme = get_base_style()

theme.background_color = { r = 234, g = 235, b = 236 }
theme.font_name = "MS Sans Serif"
theme.button.states = {
    [1] = {
        source = expand_rect({ 1, 1, 11, 21 }),
        center = expand_rect({ 4, 4, 5, 15 }),
    },
    [2] = {
        source = expand_rect({ 1, 24, 11, 21 }),
        center = expand_rect({ 4, 27, 5, 15 }),
    },
    [3] = {
        source = expand_rect({ 1, 47, 11, 21 }),
        center = expand_rect({ 4, 50, 5, 15 }),
    },
    [0] = {
        source = expand_rect({ 1, 70, 11, 21 }),
        center = expand_rect({ 4, 73, 5, 15 }),
    }
}
theme.textbox.states = {
    [1] = {
        source = expand_rect({ 34, 1, 5, 5 }),
        center = expand_rect({ 36, 3, 1, 1 }),
    },
    [2] = {
        source = expand_rect({ 34, 6, 5, 5 }),
        center = expand_rect({ 36, 8, 1, 1 }),
    },
    [3] = {
        source = expand_rect({ 34, 11, 5, 5 }),
        center = expand_rect({ 36, 13, 1, 1 }),
    },
    [0] = {
        source = expand_rect({ 34, 16, 5, 5 }),
        center = expand_rect({ 36, 18, 1, 1 }),
    }
}
theme.listbox.states = {
    [1] = {
        source = expand_rect({ 34, 22, 3, 3 }),
        center = expand_rect({ 35, 23, 1, 1 }),
    },
    [2] = {
        source = expand_rect({ 34, 25, 3, 3 }),
        center = expand_rect({ 35, 26, 1, 1 }),
    },
    [3] = {
        source = expand_rect({ 34, 28, 3, 3 }),
        center = expand_rect({ 35, 29, 1, 1 }),
    },
    [0] = {
        source = expand_rect({ 34, 31, 3, 3 }),
        center = expand_rect({ 35, 32, 1, 1 }),
    }
}
theme.listbox_item.states = {
    [1] = {
        source = expand_rect({ 34, 40, 3, 4 }),
        center = expand_rect({ 35, 41, 1, 2 }),
    },
    [2] = {
        source = expand_rect({ 34, 40, 3, 4 }),
        center = expand_rect({ 35, 41, 1, 2 }),
    },
    [3] = {
        source = expand_rect({ 34, 35, 3, 4 }),
        center = expand_rect({ 35, 36, 1, 2 }),
    },
    [0] = {
        source = expand_rect({ 34, 40, 3, 4 }),
        center = expand_rect({ 35, 41, 1, 2 }),
    }
}
theme.scrollbar_thumb = {
    states = {
        [1] = {
            source = expand_rect({ 55, 57, 17, 22 }),
            center = expand_rect({ 59, 61, 9, 14 }),
        },
        [2] = {
            source = expand_rect({ 55, 79, 17, 22 }),
            center = expand_rect({ 59, 83, 9, 14 }),
        },
        [3] = {
            source = expand_rect({ 55, 101, 17, 22 }),
            center = expand_rect({ 59, 105, 9, 14 }),
        },
        [0] = {
            source = expand_rect({ 55, 145, 17, 22 }),
            center = expand_rect({ 59, 149, 9, 14 }),
        }
    }
}
theme.scrollbar_rail = expand_rect({ 55, 123, 17, 22 })

return {
    name = 'Windows 7',
    theme = theme
}
