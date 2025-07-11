--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

MoreMaths = {}

local tab = {
    ['0'] = '0000',
    ['1'] = '0001',
    ['2'] = '0010',
    ['3'] = '0011',
    ['4'] = '0100',
    ['5'] = '0101',
    ['6'] = '0110',
    ['7'] = '0111',
    ['8'] = '1000',
    ['9'] = '1001',
    ['a'] = '1010',
    ['b'] = '1011',
    ['c'] = '1100',
    ['d'] = '1101',
    ['e'] = '1110',
    ['f'] = '1111',
    ['A'] = '1010',
    ['B'] = '1011',
    ['C'] = '1100',
    ['D'] = '1101',
    ['E'] = '1110',
    ['F'] = '1111',
}

---Converts the raw representation of a float (as an integer) to a float.
---@param input integer # The raw integer to convert.
---@return integer
---@nodiscard
function MoreMaths.raw_to_float(input)
    if input == nil then
        print(debug.traceback())
        return 0
    end

    local str = string.format('%x', input)
    local str1 = ''
    local a
    for z = 1, string.len(str) do
        a = string.sub(str, z, z)
        str1 = str1 .. tab[a]
    end
    local pm = string.sub(str1, 1, 1)
    local exp = string.sub(str1, 2, 9)
    local c = tonumber(exp, 2) - 127
    local p = math.pow(2, c)
    local man = '1' .. string.sub(str1, 10, 32)
    local x = 0
    for z = 1, string.len(man) do
        if string.sub(man, z, z) == '1' then
            x = x + p
        end
        p = p / 2
    end
    if pm == '1' then
        x = -x
    end

    return x
end

---Rounds the given number to the specified number of decimal places.
---@param val number # The number to round.
---@param places integer # The number of decimal places to round to.
---@return number # The rounded number.
---@nodiscard
function MoreMaths.round(val, places)
    if val == math.floor(val) or places == 0 then
        return math.floor(val)
    end
    local mult = 10 ^ (places or 0)
    return math.floor(val * mult + 0.5) / mult
end
