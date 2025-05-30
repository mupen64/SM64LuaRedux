---@class Section
---@field end_action string The name of the action that, when reached in playback, ends this section
---@field timeout integer The maximum number of frames this section goes on for
---@field inputs SectionInputs[] The TAS states and button presses for the earliest frames of this section. If the segment as longer than this array, its last element being held out until the end of this section.
---@field collapsed boolean Whether the section's earliest inputs should be hidden in the FrameListGui
local __clsSection = {}

---Constructs a new section with a single initial input frame.
---@param end_action string The name of the action that should terminate this section.
---@param timeout integer The maximum number of frames this section processes before it is terminated.
function __clsSection.new(end_action, timeout) end

__impl = __clsSection
dofile(views_path .. "PianoRoll/Implementations/Section.lua")
__impl = nil

return __clsSection