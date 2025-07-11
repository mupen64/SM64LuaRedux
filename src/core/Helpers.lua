--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- Collection of various helper functions.

---Merges two tables deeply, combining their contents while giving precedence to the second table's values.
---@param a table The first table to merge.
---@param b table The second table to merge.
---@return table The merged table.
---@nodiscard
function deep_merge(a, b)
    local result = {}

    local function merge(t1, t2)
        local merged = {}
        for key, value in pairs(t1) do
            if type(value) == 'table' and type(t2[key]) == 'table' then
                merged[key] = merge(value, t2[key])
            else
                merged[key] = value
            end
        end

        for key, value in pairs(t2) do
            if type(value) == 'table' and type(t1[key]) == 'table' then
            else
                merged[key] = value
            end
        end

        return merged
    end

    return merge(a, b)
end

---Applies shims to the `math` library which make pre-5.4 functions work in a 5.4 environment.
function apply_math_shim()
    -- forward-compat lua 5.4 shims
    if not math.pow then
        math.pow = function(x, y)
            return x ^ y
        end
    end
    if not math.atan2 then
        math.atan2 = math.atan
    end
end

---Swaps two elements in-place based on their indicies in an array.
---@param arr any[] The array to swap elements in.
---@param index_1 integer The index of the first element to swap.
---@param index_2 integer The index of the second element to swap.
function swap(arr, index_1, index_2)
    local tmp = arr[index_2]
    arr[index_2] = arr[index_1]
    arr[index_1] = tmp
end

---Expands an array-based rectangle into a named-table rectangle.
---@param t { [1]: number, [2]: number, [3]: number, [4]: number } The rectangle.
---@return { x: number, y: number, width: number, height: number } The expanded rectangle.
---@nodiscard
function expand_rect(t)
    return {
        x = t[1],
        y = t[2],
        width = t[3],
        height = t[4],
    }
end

---Gets the amount of keys in a dictionary.
---@param t table The dictionary to count keys in.
---@return integer The number of keys in the dictionary.
---@nodiscard
function dictlen(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
