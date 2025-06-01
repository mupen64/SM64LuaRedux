---@class ProjectTab : Tab
local __clsProjectTab = {}

__impl = __clsProjectTab
dofile(views_path .. "SemanticWorkflow/Implementations/ProjectTab.lua")
__impl = nil

return __clsProjectTab