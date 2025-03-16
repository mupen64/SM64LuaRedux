local lualinq = {
    _VERSION = 'v0.1.0',
    _URL = 'https://github.com/aurumaker72/lualinq',
    _DESCRIPTION = 'Simple LINQ-like functions for Lua',
    _LICENSE = 'GPL-3',
}

---Transforms all items in the collection via the predicate
---@param collection table
---@param predicate function A function which takes a collection element as a parameter and returns the modified element. This function should be pure in regards to the parameter.
---@return table table A collection of the transformed items
function lualinq.select(collection, predicate)
    local t = {}
    for i = 1, #collection, 1 do
        t[i] = predicate(collection[i], i)
    end
    return t
end

---Transforms all items in the collection directly via the predicate
---@param collection table
---@param predicate function A function which takes a collection element as a parameter and returns the modified element. This function should be pure in regards to the parameter.
function lualinq.select_direct(collection, predicate)
    for i = 1, #collection, 1 do
        collection[i] = predicate(collection[i])
    end
end

---Transforms all items in the collection by selecting a key based on its name
---@param collection table
---@param prop_name any An index or key into an individual collection item
---@return table table A collection of the transformed items
function lualinq.select_key(collection, prop_name)
    local t = {}
    for i = 1, #collection, 1 do
        t[i] = collection[i][prop_name]
    end
    return t
end

---Filters all items in the collection by the predicate
---@param table table
---@param predicate function A function which takes a collection element as a parameter and returns a truthy value if the element matches, and a falsy one otherwise. This function should be pure in regards to the parameter.
---@return table table A collection of the filtered items
function lualinq.where(table, predicate)
    local vals = {}
    for _, value in pairs(table) do
        if predicate(value) then
            vals[#vals + 1] = value
        end
    end
    return vals
end

---Returns the first match in the collection
---@param table table
---@param predicate function A function which takes a collection element as a parameter and returns a truthy value if the element matches, and a falsy one otherwise. This function should be pure in regards to the parameter.
---@return any any The first match in the collection, or nil if no element matches
function lualinq.first(table, predicate)
    for _, value in pairs(table) do
        if predicate(value) then
            return value
        end
    end
    return nil
end

return lualinq