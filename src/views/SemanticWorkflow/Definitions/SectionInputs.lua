---@class SectionInputs
---@field tas_state table TAS states to derive the control stick inputs from
---@field joy table The joypad data, that is, pressed buttons and joystick values (joystick values only apply when the tas_state's movement_mode is set to "manual").
---@field editing boolean Whether the input is selected for editing.
local cls_section_inputs = {}