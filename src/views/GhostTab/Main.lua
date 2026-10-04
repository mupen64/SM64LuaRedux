--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('GhostTab', function(enum_next)
    return {
        TabControl = enum_next(UIDProvider.unknown),
    }
end)

dofile(views_path .. 'GhostTab/VarWatch.lua')

local tabs = {
    dofile(views_path .. 'GhostTab/Recording.lua'),
    dofile(views_path .. 'GhostTab/Playback.lua'),
    dofile(views_path .. 'GhostTab/Settings.lua'),
}

return {
    name = function() return Locales.str('GHOST_TAB_NAME') end,
    draw = function()
        local data = ugui.tabcontrol({
            uid = UID.TabControl,
            rectangle = grid_rect(0, 0, 8, 15),
            items = lualinq.select(tabs, function(v) return v.name() end),
            selected_index = Settings.ghost_tab_index or 1,
        })
        Settings.ghost_tab_index = data.selected_index
        tabs[Settings.ghost_tab_index].draw()
    end,
}
