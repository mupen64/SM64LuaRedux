__PianoRollUids = nil or __PianoRollUids
if __PianoRollUids then return __PianoRollUids end

local enumerator = 1000
local function EnumNext(count)
    local current = enumerator
    enumerator = enumerator + (count or 1)
    return current
end

--TODO: document how this works
---Allocates uids for a table abiding to the "Renderer" class contract
---@param renderer any
---@return table
local function FromRenderer(renderer)
    local table = {}
    for k, v in pairs(renderer.AllocateUids(EnumNext)) do
        table[k] = v
    end
    return table
end

__PianoRollUids = {}
__PianoRollUids = {
    VarWatch = EnumNext(),
    SelectTab = EnumNext(),
    FrameList = FromRenderer(dofile(views_path .. "PianoRoll/FrameListGui.lua")),
}

for _, tab in pairs(dofile(views_path .. "PianoRoll/Tabs.lua")) do
    __PianoRollUids[tab.name] = FromRenderer(tab)
end

return __PianoRollUids