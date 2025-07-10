--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@class InputsTab : Tab The inputs tab.
local cls_inputs_tab = {}

__impl = cls_inputs_tab
dofile(views_path .. 'SemanticWorkflow/Implementations/InputsTab.lua')
__impl = nil

return cls_inputs_tab
