---@alias FrameListViewIndex integer Determines which kind of detail to show in the FrameListGui
---Angle and control sticks; 1: Section end action

---@class FrameListGui : Gui
---@field view_index FrameListViewIndex The index of the information kind to show.
local cls_frame_list_gui = {
    view_index = 0
}

__impl = cls_frame_list_gui
dofile(views_path .. "SemanticWorkflow/Implementations/FrameListGui.lua")
__impl = nil

return cls_frame_list_gui