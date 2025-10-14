--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@diagnostic disable:missing-return

---@class Gui Encapsulates common functionality that complex user interfaces share.
local cls_gui <const> = {
    LARGE_CONTROL_HEIGHT = 1.0,
    MEDIUM_CONTROL_HEIGHT = 0.75,
    SMALL_CONTROL_HEIGHT = 0.50,
}

---Renders a specific Gui subtype.
---@param draw any A utility object to streamline draw calls.
function cls_gui.render(draw) end

---@class Tab : Gui Encapsulates the functionality needed to display a Gui as a tab.
---@field name string The name to display for this tab and the key in the UID table for this tab.
---@field help_key string The key by which to look up the help page text as well as the tab title for this tab.
local cls_tab = {}

return cls_gui
