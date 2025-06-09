---@class InputsTab : Tab
local cls_inputs_tab = {}

__impl = cls_inputs_tab
dofile(views_path .. "SemanticWorkflow/Implementations/InputsTab.lua")
__impl = nil

return cls_inputs_tab