--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Styles = {}

local style_dir_names = {
    'windows-11',
    'windows-11-v2',
    'windows-11-dark',
    'windows-10',
    'windows-10-dark',
    'windows-3-pink',
    'windows-7',
    'windows-xp',
    'input-direction',
    'crackhex',
    'neptune',
    'fl-studio',
    'steam',
}

---@type string[]
local style_names = {}

---@type unknown TODO: Type!
local current_style = {}

local standard_styler_params_clone = ugui.internal.deep_clone(ugui.standard_styler.params)

---Gets the definition and image paths for the style with the specified name.
---@param name string
---@return { def_path: string, img_path: string }
local function get_style_paths(name)
    return {
        def_path = styles_path .. name .. '\\' .. 'style.lua',
        img_path = styles_path .. name .. '\\' .. 'style.png',
    }
end

for i = 1, #style_dir_names, 1 do
    local paths = get_style_paths(style_dir_names[i])

    local style = dofile(paths.def_path)
    style_names[i] = style.name
end

Styles.update_style = function()
    local paths = get_style_paths(style_dir_names[Settings.active_style_index])

    local style = dofile(paths.def_path)
    style.theme.path = paths.img_path
    style.theme = deep_merge(ugui.internal.deep_clone(standard_styler_params_clone), style.theme)

    current_style = style

    local theme = style.theme

    local mod_theme = ugui.internal.deep_clone(theme)

    -- HACK: We scale some visual properties according to drawing scale
    local listbox_item_height = theme.listbox_item.height or ugui.standard_styler.params.listbox_item.height
    mod_theme.font_size = theme.font_size * Drawing.scale
    mod_theme.icon_size = theme.icon_size * Drawing.scale
    mod_theme.listbox_item.height = listbox_item_height * Drawing.scale
    mod_theme.joystick.tip_size = (theme.joystick.tip_size or 8) * Drawing.scale

    ugui.standard_styler.params = mod_theme
    ugui.standard_styler.params.tabcontrol.rail_size = grid_rect(0, 0, 0, 1).height
    ugui.standard_styler.params.tabcontrol.draw_frame = false
    ugui.standard_styler.params.tabcontrol.gap_x = Settings.grid_gap
    ugui.standard_styler.params.tabcontrol.gap_y = Settings.grid_gap

    ugui_ext.apply_nineslice(mod_theme)
end

Styles.theme = function()
    return current_style.theme
end

Styles.theme_names = function()
    return style_names
end
