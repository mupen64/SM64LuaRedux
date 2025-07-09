---@class SectionInputs Describes how an input is to be made on a given frame of a section.
---@field tas_state table The TAS state to derive the control stick inputs from, which behaves mostly like the controls in the "TAS" view.
---@field joy table The joypad data, that is, pressed buttons and joystick values (joystick values only apply when the tas_state's movement_mode is set to "manual").
---@field editing boolean Whether the input is selected for editing.
local cls_section_inputs = {}