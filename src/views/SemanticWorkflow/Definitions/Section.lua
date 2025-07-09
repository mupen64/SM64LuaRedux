---@class Section Describes a single section of a sheet.
---@field end_action integer The 32-bit representation of Mario's action that, when reached in playback, ends this section.
---@field timeout integer The maximum number of frames this section goes on for.
---@field inputs SectionInputs[] The TAS states and button presses for the earliest frames of this section. If the segment is longer than this array, its last element being held out until the end of this section.
---@field collapsed boolean Whether the section's earliest inputs should be hidden in the FrameListGui.
local cls_section = {}

---Constructs a new section with a single initial input frame.
---@param end_action integer The action that should terminate this section.
---@param timeout integer The maximum number of frames this section processes before it is terminated.
function cls_section.new(end_action, timeout) end

__impl = cls_section
dofile(views_path .. "SemanticWorkflow/Implementations/Section.lua")
__impl = nil

return cls_section