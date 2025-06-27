---@class PreferencesTab : Tab
local cls_preferences_tab = {}

__impl = cls_preferences_tab
dofile(views_path .. "SemanticWorkflow/Implementations/PreferencesTab.lua")
__impl = nil

return cls_preferences_tab