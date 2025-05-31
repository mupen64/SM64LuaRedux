---@alias FrameListViewIndex integer
---Angle and control sticks; 1: Section end action

---@class FrameListGui : Gui
---@field view_index FrameListViewIndex The index of the information kind to show.
local __clsFrameListGui = {
    view_index = 0
}

__impl = __clsFrameListGui
dofile(views_path .. "SemanticWorkflow/Implementations/FrameListGui.lua")
__impl = nil

return __clsFrameListGui