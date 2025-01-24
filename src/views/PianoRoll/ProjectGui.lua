local Project = dofile(views_path .. "PianoRoll/Project.lua")
local UID = dofile(views_path .. "PianoRoll/UID.lua")
local Help = dofile(views_path .. "PianoRoll/Help.lua")
local persistence = dofile(lib_path .. "persistence.lua")

local controlHeight = 0.75

local function RenderConfirmDeletionPrompt(sheetIndex)
    return function()
        local top = 15 - controlHeight
        local confirmationText = "[Confirm deletion]\n\nAre you sure you want to delete \"" .. PianoRollContext.meta.sheets[sheetIndex].name .. "\"?\nThis action cannot be undone."

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
            PianoRollContext:RemoveSheet(sheetIndex)
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

local function RenderSheetList(draw)
    local theme = Styles.theme()
    local foregroundColor = theme.listbox.text[1]
    if #PianoRollContext.meta.sheets == 0 then
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
    draw:small_text(grid_rect(0, top, 8, controlHeight), "left", PianoRollContext.projectLocation)
    if ugui.button({
        uid = UID.NewProject,
        rectangle = grid_rect(0, top + 1, 1.5, controlHeight),
        text = "New"
    }) then
        local path = iohelper.filediag("*.prp", 1)
        if string.len(path) > 0 then
            PianoRollContext = Project.new()
            PianoRollContext.projectLocation = path
            PianoRollContext:AddSheet()
            persistence.store(path, PianoRollContext.meta)
        end
    end
    if ugui.button({
        uid = UID.OpenProject,
        rectangle = grid_rect(1.5, top + 1, 1.5, controlHeight),
        text = "Open"
    }) then
        local path = iohelper.filediag("*.prp", 0)
        if string.len(path) > 0 then
            PianoRollContext = Project.new()
            PianoRollContext.projectLocation = path
            PianoRollContext:Load(persistence.load(path))
        end
    end
    if ugui.button({
        uid = UID.SaveProject,
        rectangle = grid_rect(3, top + 1, 1.5, controlHeight),
        text = "Save"
    }) then
        if PianoRollContext.projectLocation == nil then
            local path = iohelper.filediag("*.prp", 0)
            if string.len(path) == 0 then
                goto skipSave
            end
            PianoRollContext.projectLocation = path
            persistence.store(path, PianoRollContext.meta)
        end
        persistence.store(PianoRollContext.projectLocation, PianoRollContext.meta)
        local projectFolder = PianoRollContext:ProjectFolder()
        for _, sheetMeta in ipairs(PianoRollContext.meta.sheets) do
            PianoRollContext.all[sheetMeta.name]:save(projectFolder .. sheetMeta.name .. ".prs")
        end
    end
    ::skipSave::

    top = 3
    local availablePianoRolls = {}
    for i = 1, #PianoRollContext.meta.sheets, 1 do
        availablePianoRolls[i] = PianoRollContext.meta.sheets[i].name
    end
    availablePianoRolls[#availablePianoRolls + 1] = "Add..."

    local uid = UID.ProjectSheetBase
    for i = 1, #availablePianoRolls, 1 do
        local y = top + (i - 1) * controlHeight
        if ugui.toggle_button({
            uid = uid,
            rectangle = grid_rect(0, y, 3, controlHeight),
            text = availablePianoRolls[i],
            is_checked = i == PianoRollContext.meta.selectionIndex,
        }) then
            if i == #PianoRollContext.meta.sheets + 1 then -- add new sheet
                PianoRollContext:AddSheet()
                PianoRollContext:Select(#PianoRollContext.meta.sheets)
            elseif i ~= PianoRollContext.meta.selectionIndex then -- select sheet
                PianoRollContext:Select(i)
            end
        end
        uid = uid + 1

        -- prevent rendering options for the "add..." button
        if i > #PianoRollContext.meta.sheets then break end

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
            PianoRollContext:MoveSheet(i, -1)
        end

        if (drawUtilityButton("v", i < #PianoRollContext.meta.sheets)) then
            PianoRollContext:MoveSheet(i, 1)
        end

        if (drawUtilityButton("-")) then
            PianoRollDialog = RenderConfirmDeletionPrompt(i)
        end
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
        RenderSheetList(draw)
        RenderFooter()
    end,
}