local name = "Timeline"

local UID = dofile(views_path .. "PianoRoll/UID.lua")[name]
local FrameListGui = dofile(views_path .. "PianoRoll/FrameListGui.lua")

local function AllocateUids(EnumNext)
    return {

    }
end

return {
    name = name,
    Render = function(draw)
        FrameListGui.Render(draw, function() end)
    end,
    AllocateUids = AllocateUids,
}