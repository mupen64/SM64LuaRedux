--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@class Section Describes a single section of a sheet.
---@field inputs SectionInputs[] The sequence of SectionInputs that make up this section.
---@field collapsed boolean Whether the inputs list should be hidden in the FrameListGui.
local cls_section = {}

---Constructs a new section with a single initial input frame.
function cls_section.new() end

__impl = cls_section
dofile(views_path .. 'SemanticWorkflow/Implementations/Section.lua')
__impl = nil

return cls_section
