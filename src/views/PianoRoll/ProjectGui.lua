local UID = dofile(views_path .. "PianoRoll/UID.lua")
local Help = dofile(views_path .. "PianoRoll/Help.lua")
local PianoRoll = dofile(views_path .. "PianoRoll/PianoRoll.lua")

local selectionIndex = 0
local createdSheetCount = 0
local controlHeight = 0.75

local function SelectCurrent()
    PianoRollContext.current = PianoRollContext.all[selectionIndex]
    if PianoRollContext.current ~= nil then
        PianoRollContext.current:jumpTo(PianoRollContext.current.previewGT)
    end
end

local function RenderConfirmDeletionPrompt(sheetIndex)
    return function()
        local top = 15 - controlHeight
        local confirmationText = "[Confirm deletion]\n\nAre you sure you want to delete \"" .. PianoRollContext.all[sheetIndex].name .. "\"?\nThis action cannot be undone."

        local theme = Styles.theme()
        local foregroundColor = theme.listbox.text[1]

        BreitbandGraphics.draw_text(
            grid_rect(0, top - 8, 8, 8),
            "center",
            "end",
            {},
            foregroundColor,
            theme.font_size * 1.2 * Drawing.scale,
            theme.font_name,
            confirmationText)

        if ugui.button({
            uid = UID.ConfirmationYes,
            rectangle = grid_rect(4, top, 2, controlHeight),
            text = 'Yes'
        }) then
            table.remove(PianoRollContext.all, sheetIndex)
            SelectCurrent()
            PianoRollDialog = nil
        end
        if ugui.button({
            uid = UID.ConfirmationNo,
            rectangle = grid_rect(2, top, 2, controlHeight),
            text = 'No'
        }) then
            PianoRollDialog = nil
        end
    end
end

local function RenderSheetList()
    local theme = Styles.theme()
    local foregroundColor = theme.listbox.text[1]
    if #PianoRollContext.all == 0 then
        BreitbandGraphics.draw_text(
            grid_rect(0, 0, 8, 16),
            "center",
            "center",
            {},
            foregroundColor,
            theme.font_size * 1.2 * Drawing.scale,
            theme.font_name,
            "No piano roll sheets available.\nCreate one to proceed.")
    end

    local top = 1
    local availablePianoRolls = {}
    for i = 1, #PianoRollContext.all, 1 do
        availablePianoRolls[i] = PianoRollContext.all[i].name
    end
    availablePianoRolls[#availablePianoRolls + 1] = "Add..."

    nextPianoRoll = selectionIndex
    local uid = UID.ProjectSheetBase
    for i = 1, #availablePianoRolls, 1 do
        local y = top + (i - 1) * controlHeight
        if ugui.toggle_button({
            uid = uid,
            rectangle = grid_rect(0, y, 3, controlHeight),
            text = availablePianoRolls[i],
            is_checked = i == nextPianoRoll,
        }) then
            if i == #PianoRollContext.all + 1 then -- add new sheet
                nextPianoRoll = #PianoRollContext.all + 1
                createdSheetCount = createdSheetCount + 1
                PianoRollContext.current = PianoRoll.new("Sheet " .. createdSheetCount)
                PianoRollContext.all[nextPianoRoll] = PianoRollContext.current
            else -- select sheet
                nextPianoRoll = i % #availablePianoRolls
            end
        end
        uid = uid + 1

        -- prevent rendering options for the "add..." button
        if i > #PianoRollContext.all then break end

        local x = 3
        local function drawUtilityButton(text, enabled, width)
            width = width or 0.5
            local result = ugui.button({
                uid = uid,
                rectangle = grid_rect(x, y, width, controlHeight),
                text = text,
                is_enabled = enabled
            })
            uid = uid + 1
            x = x + width
            return result
        end

        if (drawUtilityButton("^", i > 1)) then
            local tmp = PianoRollContext.all[i]
            PianoRollContext.all[i] = PianoRollContext.all[i - 1]
            PianoRollContext.all[i - 1] = tmp
        end

        if (drawUtilityButton("v", i < #PianoRollContext.all)) then
            local tmp = PianoRollContext.all[i]
            PianoRollContext.all[i] = PianoRollContext.all[i + 1]
            PianoRollContext.all[i + 1] = tmp
        end

        if (drawUtilityButton("-")) then
            PianoRollDialog = RenderConfirmDeletionPrompt(i)
        end
    end

    if selectionIndex ~= nextPianoRoll then
        selectionIndex = nextPianoRoll
        SelectCurrent()
    end
end

local function RenderFooter()
    local top = 16 - controlHeight
    if ugui.button(
        {
            uid = UID.ToggleHelp,

            rectangle = grid_rect(0, top, 1.5, controlHeight),
            text = "Help",
        }
    ) then
        PianoRollDialog = Help.Render
    end
end

return {
    name = "Project",
    Render = function(draw)
        RenderSheetList()
        RenderFooter()
    end,
}