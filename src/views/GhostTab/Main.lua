--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('GhostTab', function(enum_next)
    return {
        TabControl = enum_next(UIDProvider.unknown),
        Overlay = enum_next(ugui.listbox_uids()),
        OverlayColor = enum_next(ugui.panel_uids()),
    }
end)

dofile(views_path .. 'GhostTab/VarWatch.lua')

local playback_tab = dofile(views_path .. 'GhostTab/Playback.lua')
local tabs = {
    dofile(views_path .. 'GhostTab/Recording.lua'),
    playback_tab,
    dofile(views_path .. 'GhostTab/Settings.lua'),
}

---Draws the selected playback ghost's data over the game.
---Called every frame from SM64Lua.lua so it stays up outside the Ghost tab.
---@param beside_semantic_workflow boolean # whether to move left of the semantic workflow tab's varwatch overlay
function draw_ghost_overlay(beside_semantic_workflow)
    if not Settings.ghost_overlay_data then
        return
    end
    local item_height = ugui.standard_styler.params.listbox_item.height
    local name, color = playback_tab.selected_name_and_color()

    -- the name is the list's first row so it shares the list's frame and opacity; when there's a
    -- hat color, spaces leave room for a swatch drawn over the start of that row
    local swatch_size = item_height - 4
    if color then
        name = '     ' .. name
    end
    local items = playback_tab.varwatch_items()
    table.insert(items, 1, name)

    -- sized to fit the items (+1px border each side), keeping the bottom where the semantic workflow's ends
    local rectangle = grid_rect(beside_semantic_workflow and -12 or -6, 9, 6, 7)
    local height = #items * item_height + 2
    rectangle.y = rectangle.y + rectangle.height - height
    rectangle.height = height
    ugui.listbox({
        uid = UID.Overlay,
        rectangle = rectangle,
        selected_index = nil,
        items = items,
        styler_mixin = {
            color_filter = { r = 255, g = 255, b = 255, a = 110 },
        },
    })

    -- hat color swatch (Mario ghosts only), vertically centred in the first row where the row's text starts
    if color then
        ugui.panel({
            uid = UID.OverlayColor,
            rectangle = { x = rectangle.x + 3, y = rectangle.y + 1 + (item_height - swatch_size) / 2, width = swatch_size, height = swatch_size },
            fill = color,
        })
    end
end

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
