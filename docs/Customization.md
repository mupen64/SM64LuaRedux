# Adding a custom theme

For light themes:

1. Create a copy of the `windows-11` folder under `res/`

For dark themes:

1. Create a copy of the `windows-10-dark` folder under `res/`

***

2. Rename the folder to your theme's name fitting the same format.
3. Change the theme's name in `style.lua` to your theme's name
4. Edit the texture atlas under `style.png` as desired
5. Change the background color, font, or atlas coordinates by modifying the `theme` returned from `get_base_style()` as desired (see `windows-7/style.lua`)
6. Add your theme's folder name to the `styles` table in `Presets.lua`
