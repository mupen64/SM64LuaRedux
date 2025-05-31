---@class SectionInputs
---@field tas_state table TAS states to derive the control stick inputs from - note that arctan straining will refer to the section's timeout for its length
---@field joy table The joypad data, that is, pressed buttons and joystick values.
---@field editing boolean Whether the input is selected for editing.
local __clsSectionInputs = {}