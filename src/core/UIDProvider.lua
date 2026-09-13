--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

if UIDProvider then return end

local enumerator = 1

local function enum_next(count)
    local current = enumerator
    enumerator = enumerator + (count or 1)
    return current
end

local allocated = {}

local function allocate_once(key, allocator)
    if not allocated[key] then allocated[key] = allocator(enum_next) end
    return allocated[key]
end


UIDProvider = {
    allocate_once = allocate_once,
    -- To be used as a placeholder for unknown UID allocations. Big enough to fit most things.
    unknown = 4096,
}
