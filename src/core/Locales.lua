--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Locales = {}

local locales = {}

local files = {
    "en_US",
}

for i = 1, #files, 1 do
    local name = files[i]
    locales[i] = dofile(string.format("%s%s.lua", locales_path, name))
end

Locales.names = function ()
    return lualinq.select_key(locales, "name")
end

Locales.str = function (id)
    local val = locales[Settings.locale_index][id]
    return val or id
end

Locales.raw = function ()
    return locales[Settings.locale_index]
end

Locales.action = function (raw)
    return Locales.raw().ACTIONS[raw] or string.format("%x", raw)
end