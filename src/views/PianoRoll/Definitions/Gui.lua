---@diagnostic disable:missing-return

---@class Gui
local __clsGui = {}

---Allocates UIDs for specific subtype
---@param enumNext fun(count?: integer): integer A function that will generate a new UID whenever called
---@return table lookup A table from names to UIDs
function __clsGui.allocate_uids(enumNext) end

---Renders a specific Gui subtype
---@param draw any A utility object to streamline draw calls.
function __clsGui.render(draw) end

---@class Tab:Gui
---@field name string The name to display for this tab and the key in the UID table for this tab.
---@field help_key string The key by which to look up the help page text as well as the tab title for this tab.
local __clsTab = {}