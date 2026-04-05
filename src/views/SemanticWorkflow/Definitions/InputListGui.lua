--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@class InputListGui : Gui The control that displays and selects the selected sheet's sections.
---@field view_index integer What to show controls for. 0 for joystick semantics, 1 for input termination conditions.
---@field special_select_handler fun(selection_input) | nil A callback that overrides the behavior when an input row would normally be selected.
local cls_input_list_gui = {
    view_index = 1,
    special_select_handler = nil,
}

__impl = cls_input_list_gui
dofile(views_path .. 'SemanticWorkflow/Implementations/InputListGui.lua')
__impl = nil

return cls_input_list_gui
