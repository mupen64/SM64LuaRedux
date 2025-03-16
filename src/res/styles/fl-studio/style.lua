local theme = get_base_style()

theme.background_color = { r = 107, g = 116, b = 121 }
theme.font_size = 14
-- not preinstalled
-- theme.font_name = "Cuprum"
theme.font_name = "Candara"

theme.textbox.text = {
    [1] = BreitbandGraphics.hex_to_color("#A5ABAF"),
    [2] = BreitbandGraphics.hex_to_color("#A5ABAF"),
    [3] = BreitbandGraphics.hex_to_color("#A5ABAF"),
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.button.text = {
    [1] = BreitbandGraphics.hex_to_color("#DAD8D2"),
    [2] = BreitbandGraphics.hex_to_color("#DAD8D2"),
    [3] = BreitbandGraphics.hex_to_color("#DAD8D2"),
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.listbox_item.text = {
    [1] = BreitbandGraphics.hex_to_color("#A5ABAF"),
    [2] = BreitbandGraphics.hex_to_color("#A5ABAF"),
    [3] = BreitbandGraphics.hex_to_color("#A5ABAF"),
    [0] = BreitbandGraphics.repeated_to_color(209),
}

return {
    name = 'FL Studio',
    theme = theme
}
