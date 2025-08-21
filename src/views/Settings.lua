--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local views = {
    dofile(views_path .. 'VisualSettings.lua'),
    dofile(views_path .. 'InteractionSettings.lua'),
    dofile(views_path .. 'VarWatchSettings.lua'),
    dofile(views_path .. 'MemorySettings.lua'),
}

return {
    name = Locales.str('SETTINGS_TAB_NAME'),
    draw = function()
        local data = ugui.tabcontrol({
            uid = 100,
            rectangle = grid_rect(0, 0, 8, 15),
            items = lualinq.select_key(views, 'name'),
            selected_index = Settings.settings_tab_index,
        })
        Settings.settings_tab_index = data.selected_index

        Drawing.push_offset(0, data.rectangle.y)
        views[Settings.settings_tab_index].draw()
        Drawing.pop_offset()
    end,
}
