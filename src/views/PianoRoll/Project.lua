---@class Project
---@field public current PianoRoll|nil The currently selected and active piano roll.
---@field public all table
---@field public maxDisplayedFrames integer The maximum number of frames to display at once.
---@field public copyEntireState boolean If true, the entire TASState of the active edited frame is copied to all selected. If false, only the changes made will be copied instead.
local __clsProject = {}

function __clsProject.new()
    return {

        current = nil,
        all = {},
        maxDisplayedFrames = 15,
        copyEntireState = true,

        AssertedCurrent = __clsProject.AssertedCurrent,
    }
end

---Retrieves the current piano roll, raising error when it is nil
---@return PianoRoll current The current PianoRoll, never nil
function __clsProject:AssertedCurrent()
    if self.current == nil then
        error("Expected PianoRollContext.current to not be nil.", 2)
    end
    return self.current
end

return {
    new = __clsProject.new,
}