Styles = {}

local files = {
    "windows-11",
    "windows-11-v2",
    "windows-11-dark",
    "windows-10",
    "windows-10-dark",
    "windows-3-pink",
    "windows-7",
    "windows-xp",
    "input-direction",
    "crackhex",
    "neptune",
    "fl-studio",
    "steam",
}

local styles = {}

for i = 1, #files, 1 do
    local name = files[i]
    styles[i] = dofile(styles_path .. name .. "\\" .. "style.lua")
    styles[i].theme.path = styles_path .. name .. "\\" .. "style.png"
    styles[i].theme = deep_merge(ugui.internal.deep_clone(ugui.standard_styler.params), styles[i].theme)
end

Styles.update_style = function()
    local theme = styles[Settings.active_style_index].theme

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
    return styles[Settings.active_style_index].theme
end

Styles.theme_names = function()
    return lualinq.select_key(styles, "name")
end
