---@class Selection
---@field public frames SelectionFrame[] A sparse set of selected frames for a given sheet
__clsSelection = {}

---@class SelectionFrame
---@field public sectionIndex integer The 1-based section index in the respective sheet
---@field public frameIndex integer The 1-based frame index in this seletion's section
__clsSelectionFrame = {}