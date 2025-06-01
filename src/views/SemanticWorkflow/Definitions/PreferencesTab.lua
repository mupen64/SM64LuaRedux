---@class PreferencesTab : Tab
local __clsPreferencesTab = {}

__impl = __clsPreferencesTab
dofile(views_path .. "SemanticWorkflow/Implementations/PreferencesTab.lua")
__impl = nil

return __clsPreferencesTab