--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@class PreferencesTab : Tab The preferences tab. May be removed in the future.
local cls_preferences_tab = {}

__impl = cls_preferences_tab
dofile(views_path .. 'SemanticWorkflow/Implementations/PreferencesTab.lua')
__impl = nil

return cls_preferences_tab
