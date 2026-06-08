--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@class Loop Runtime information for a section loop.
---@field jump_target integer The 1-based index of the input to jump to within the same section. Can be the current input's index (self-loop), but must not be larger than the looping input's index.
---@field count integer The number of repetitions. May be zero.
---@field runtime_counter integer The current repetition during a sheet's run.
local cls_loop = {}

---@class SectionInputs Describes the inputs to be made for one or more frames semantically.
---@field end_action integer|nil The 32-bit representation of Mario's action that, when reached in playback, terminates this input.
---@field timeout integer The maximum number of frames this input is held for. end_action may cause an earlier termination.
---@field tas_state table The TAS state to derive the control stick inputs from, which behaves mostly like the controls in the "TAS" view.
---@field joy table The joypad data, that is, pressed buttons and joystick values (joystick values only apply when the tas_state's movement_mode is set to "manual").
---@field editing boolean Whether the input is selected for editing.
---@field loop Loop|nil The loop info to apply after this input, if applicable.
local cls_section_inputs = {}

function cls_section_inputs.new() end

__impl = cls_section_inputs
dofile(views_path .. 'SemanticWorkflow/Implementations/SectionInputs.lua')
__impl = nil

return cls_section_inputs
