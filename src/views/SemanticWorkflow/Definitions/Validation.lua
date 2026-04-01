--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@class Validation Provides validation functions for project and sheet files.
local cls_validation = {}

---Validates the decoded contents of a sheet file (.sws).
---@param data table The decoded JSON data to validate.
---@return boolean ok Whether the data is valid.
---@return string | nil err A human-readable error message if the data is invalid, nil otherwise.
function cls_validation.validate_sheet(data) end

---Validates the decoded contents of a project file (.swp).
---@param data table The decoded JSON data to validate.
---@return boolean ok Whether the data is valid.
---@return string | nil err A human-readable error message if the data is invalid, nil otherwise.
function cls_validation.validate_project(data) end

__impl = cls_validation
dofile(views_path .. 'SemanticWorkflow/Implementations/Validation.lua')
__impl = nil

return cls_validation
