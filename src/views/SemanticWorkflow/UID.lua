__SemanticWorkflowUids = nil or __SemanticWorkflowUids
if __SemanticWorkflowUids then return __SemanticWorkflowUids end

local enumerator = 1000
local function enum_next(count)
    local current = enumerator
    enumerator = enumerator + (count or 1)
    return current
end

---Allocates uids for a Gui type
---@param gui Gui The concrete subtype of Gui to allocate uids for
---@return table lookup The lookup table for that specific Gui's allocated uids
local function from_gui(gui)
    local table = {}
    for k, v in pairs(gui.allocate_uids(enum_next)) do
        table[k] = v
    end
    return table
end

__SemanticWorkflowUids = {}
__SemanticWorkflowUids = {
    VarWatch = enum_next(),
    SelectTab = enum_next(3 + 1), -- TODO: consider the number of required tabs... carefully!
    ToggleHelp = enum_next(),
    HelpNext = enum_next(),
    HelpBack = enum_next(),
    FrameList = from_gui(dofile(views_path .. "SemanticWorkflow/Definitions/FrameListGui.lua")),
}

for _, tab in pairs(dofile(views_path .. "SemanticWorkflow/Tabs.lua")) do
    __SemanticWorkflowUids[tab.name] = from_gui(tab)
end

return __SemanticWorkflowUids