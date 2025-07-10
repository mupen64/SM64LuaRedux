--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@class ProjectTab : Tab The project tab.
local cls_project_tab = {}

__impl = cls_project_tab
dofile(views_path .. 'SemanticWorkflow/Implementations/ProjectTab.lua')
__impl = nil

return cls_project_tab
