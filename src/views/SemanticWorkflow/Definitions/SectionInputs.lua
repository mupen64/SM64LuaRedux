--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@class SectionInputs Describes the inputs to be made for one or more frames semantically.
---@field end_action integer|nil The 32-bit representation of Mario's action that, when reached in playback, terminates this input.
---@field timeout integer The maximum number of frames this input is held for. end_action may cause an earlier termination.
---@field tas_state table The TAS state to derive the control stick inputs from, which behaves mostly like the controls in the "TAS" view.
---@field joy table The joypad data, that is, pressed buttons and joystick values (joystick values only apply when the tas_state's movement_mode is set to "manual").
---@field editing boolean Whether the input is selected for editing.
local cls_section_inputs = {}
