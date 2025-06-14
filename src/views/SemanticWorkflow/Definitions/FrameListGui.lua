---@alias FrameListViewIndex integer Determines which kind of detail to show in the FrameListGui
---Angle and control sticks; 1: Section end action

---@class FrameListGui : Gui
---@field view_index FrameListViewIndex The index of the information kind to show.
---@field special_select_handler fun(selection_frame) | nil A callback that overrides the behavior when an input row would normally be selected
local cls_frame_list_gui = {
    view_index = 0,
    special_select_handler = nil
}

__impl = cls_frame_list_gui
dofile(views_path .. "SemanticWorkflow/Implementations/FrameListGui.lua")
__impl = nil

return cls_frame_list_gui