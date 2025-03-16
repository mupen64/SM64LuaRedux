local name = "Timeline"

local UID = dofile(views_path .. "PianoRoll/UID.lua")[name]
local FrameListGui = dofile(views_path .. "PianoRoll/FrameListGui.lua")
local Section = dofile(views_path .. "PianoRoll/Sheet.lua")

local MAX_ACTION_GUESSES = 5

local endActionSearchText = nil

local function AllocateUids(EnumNext)
    return {
        InsertSection = EnumNext(),
        DeleteSection = EnumNext(),
        EndAction = EnumNext(),
        AvailableActions = EnumNext(MAX_ACTION_GUESSES),
        Timeout = EnumNext(),
    }
end

local function ControlsForSelected(draw)
    local smallControlHeight = 0.5
    local largeControlHeight = 0.75
    local top = 10.5
    local sheet = PianoRollProject:AssertedCurrent()

    local anyChanges = false

    if ugui.button({
        uid = UID.InsertSection,
        rectangle = grid_rect(0, top, 1.5, largeControlHeight),
        text = "Insert",
    }) then
        local newSection = Section.new("idle", 150)
        if #sheet.sections == 0 then
            sheet.sections = { newSection }
        else
            table.insert(sheet.sections, sheet.editingIndex + 1, newSection)
        end
        anyChanges = true
    end

    if ugui.button({
        uid = UID.DeleteSection,
        rectangle = grid_rect(1.5, top, 1.5, largeControlHeight),
        text = "Delete"
    }) then
        local startIndex = sheet.selection.startIndex
        local endIndex = sheet.selection.endIndex
        for _ = startIndex, endIndex, 1 do
            table.remove(sheet.sections, startIndex)
        end
    end

    top = top + 1
    local section = sheet.sections[sheet.editingIndex]
    if endActionSearchText == nil then
        -- end action "dropdown" is not visible
        if ugui.button({
            uid = UID.EndAction,
            rectangle = grid_rect(0.5, top, 2, largeControlHeight),
            text = section.endAction
        }) then
            endActionSearchText = ""
        end

        local oldTimeout = section.timeout
        section.timeout = ugui.numberbox({
            uid = UID.Timeout,
            rectangle = grid_rect(0.5, top + largeControlHeight, 2, largeControlHeight),
            value = section.timeout,
            places = 4,
        })
        anyChanges = anyChanges or oldTimeout ~= section.timeout
    else
        -- end action "dropdown" is visible
        endActionSearchText = ugui.textbox({
            uid = UID.EndAction,
            rectangle = grid_rect(0.5, top, 2, largeControlHeight),
            text = endActionSearchText,
        }):lower()
        local i = 0
        local matchPattern = "^" .. endActionSearchText
        for _, actionName in pairs(Locales.raw().ACTIONS) do
            if actionName:find(matchPattern) ~= nil then
                if ugui.button({
                    uid = UID.AvailableActions + i,
                    rectangle = grid_rect(0.5, top + largeControlHeight + i * smallControlHeight, 4, smallControlHeight),
                    text = actionName
                }) then
                    endActionSearchText = nil
                    section.endAction = actionName
                    anyChanges = true
                end

                i = i + 1
                if (i > MAX_ACTION_GUESSES) then break end
            end
        end
    end

    if anyChanges then
        sheet:runToPreview()
    end
end


local function DrawFrameContent(draw, rect, frameNumber)
    local currentSheet = PianoRollProject:AssertedCurrent()
    local previewAction = currentSheet.sections[frameNumber].endAction
    draw:text(rect, "left", "until '" .. previewAction .. "'")
end

return {
    name = name,
    Render = function(draw)
        ControlsForSelected()
        FrameListGui.Render(draw, DrawFrameContent)
    end,
    AllocateUids = AllocateUids,
}