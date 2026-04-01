--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@type Validation
---@diagnostic disable-next-line:assign-type-mismatch
local __impl = __impl

function __impl.validate_sheet(data)
    if type(data) ~= 'table' then
        return false, 'Sheet file is not valid JSON'
    end
    if type(data.version) ~= 'string' then
        return false, 'Sheet file is missing a version field'
    end
    if data.version ~= SEMANTIC_WORKFLOW_FILE_VERSION then
        return false, 'Sheet version ' .. tostring(data.version) .. ' is not compatible with current version ' .. SEMANTIC_WORKFLOW_FILE_VERSION
    end
    if type(data.name) ~= 'string' then
        return false, 'Sheet file is missing a name field'
    end
    if type(data.sections) ~= 'table' then
        return false, 'Sheet file is missing a sections field'
    end
    for i, section in ipairs(data.sections) do
        if type(section.end_action) ~= 'number' then
            return false, 'Section ' .. i .. ' is missing a valid end_action field'
        end
        if type(section.timeout) ~= 'number' then
            return false, 'Section ' .. i .. ' is missing a valid timeout field'
        end
        if type(section.inputs) ~= 'table' then
            return false, 'Section ' .. i .. ' is missing a valid inputs field'
        end
    end
    return true, nil
end

function __impl.validate_project(data)
    if type(data) ~= 'table' then
        return false, 'Project file is not valid JSON'
    end
    if type(data.version) ~= 'string' then
        return false, 'Project file is missing a version field'
    end
    if data.version ~= SEMANTIC_WORKFLOW_FILE_VERSION then
        return false, 'Project version ' .. tostring(data.version) .. ' is not compatible with current version ' .. SEMANTIC_WORKFLOW_FILE_VERSION
    end
    if type(data.sheets) ~= 'table' then
        return false, 'Project file is missing a sheets field'
    end
    for i, sheet_meta in ipairs(data.sheets) do
        if type(sheet_meta.name) ~= 'string' or #sheet_meta.name == 0 then
            return false, 'Sheet entry ' .. i .. ' is missing a valid name field'
        end
    end
    return true, nil
end
