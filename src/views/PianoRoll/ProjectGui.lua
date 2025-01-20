local Project = dofile(views_path .. "PianoRoll/Project.lua")
local UID = dofile(views_path .. "PianoRoll/UID.lua")
local Help = dofile(views_path .. "PianoRoll/Help.lua")
local persistence = dofile(lib_path .. "persistence.lua")

local controlHeight = 0.75

local function CreateConfirmDialog(prompt, onConfirmed)
    return function()
        local top = 15 - controlHeight

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
            prompt)

        if ugui.button({
            uid = UID.ConfirmationYes,
            rectangle = grid_rect(4, top, 2, controlHeight),
            text = 'Yes'
        }) then
            onConfirmed()
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

local function RenderConfirmDeletionPrompt(sheetIndex)
    return CreateConfirmDialog(
        "[Confirm deletion]\n\nAre you sure you want to delete \"" .. PianoRollProject.meta.sheets[sheetIndex].name .. "\"?\nThis action cannot be undone.",
        function() PianoRollProject:RemoveSheet(sheetIndex) end
    )
end

local RenderConfirmPurgeDialog = CreateConfirmDialog(
    "[Confirm project purge]\n\n"
    .."Are you sure you want to purge unused sheets from the project directory?\n"
    .."Unrelated files (not ending with .prs or .prs.savestate) will not be touched.\n"
    .."This action cannot be undone.",
    function()
        local ignoredFiles = {}
        local projectFolder = PianoRollProject:ProjectFolder()
        for _, sheetMeta in ipairs(PianoRollProject.meta.sheets) do
            ignoredFiles[sheetMeta.name .. ".prs"] = true
            ignoredFiles[sheetMeta.name .. ".prs.savestate"] = true
        end
        for file in io.popen("dir \"" .. projectFolder .. "\" /b"):lines() do
            if ignoredFiles[file] == nil and (file:match("(.)prs$") ~= nil or file:match("(.)prs(.)savestate$") ~= nil) then
                assert(os.remove(projectFolder .. file))
                print("removed " .. file)
            end
        end
    end
)

local function RenderSheetList(draw)
    local theme = Styles.theme()
    local foregroundColor = theme.listbox.text[1]
    if #PianoRollProject.meta.sheets == 0 then
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
    draw:small_text(grid_rect(0, top, 8, controlHeight), "left", PianoRollProject.projectLocation)
    if ugui.button({
        uid = UID.NewProject,
        rectangle = grid_rect(0, top + 1, 1.5, controlHeight),
        text = "New"
    }) then
        local path = iohelper.filediag("*.prp", 1)
        if string.len(path) > 0 then
            PianoRollProject = Project.new()
            PianoRollProject.projectLocation = path
            PianoRollProject:AddSheet()
            persistence.store(path, PianoRollProject.meta)
        end
    end
    if ugui.button({
        uid = UID.OpenProject,
        rectangle = grid_rect(1.5, top + 1, 1.5, controlHeight),
        text = "Open"
    }) then
        local path = iohelper.filediag("*.prp", 0)
        if string.len(path) > 0 then
            PianoRollProject = Project.new()
            PianoRollProject.projectLocation = path
            PianoRollProject:Load(persistence.load(path))
        end
    end
    if ugui.button({
        uid = UID.SaveProject,
        rectangle = grid_rect(3, top + 1, 1.5, controlHeight),
        text = "Save"
    }) then
        if PianoRollProject.projectLocation == nil then
            local path = iohelper.filediag("*.prp", 0)
            if string.len(path) == 0 then
                goto skipSave
            end
            PianoRollProject.projectLocation = path
            persistence.store(path, PianoRollProject.meta)
        end
        persistence.store(PianoRollProject.projectLocation, PianoRollProject.meta)
        local projectFolder = PianoRollProject:ProjectFolder()
        for _, sheetMeta in ipairs(PianoRollProject.meta.sheets) do
            PianoRollProject.all[sheetMeta.name]:save(projectFolder .. sheetMeta.name .. ".prs")
        end
    end
    ::skipSave::

    if ugui.button({
        uid = UID.PurgeProject,
        rectangle = grid_rect(4.5, top + 1, 1.5, controlHeight),
        text = "Purge",
        is_enabled = PianoRollProject.projectLocation ~= nil,
    }) then
        PianoRollDialog = RenderConfirmPurgeDialog
    end

    top = 3
    local availablePianoRolls = {}
    for i = 1, #PianoRollProject.meta.sheets, 1 do
        availablePianoRolls[i] = PianoRollProject.meta.sheets[i].name
    end
    availablePianoRolls[#availablePianoRolls + 1] = "Add..."

    local uid = UID.ProjectSheetBase
    for i = 1, #availablePianoRolls, 1 do
        local y = top + (i - 1) * controlHeight
        if ugui.toggle_button({
            uid = uid,
            rectangle = grid_rect(0, y, 3, controlHeight),
            text = availablePianoRolls[i],
            is_checked = i == PianoRollProject.meta.selectionIndex,
        }) then
            if i == #PianoRollProject.meta.sheets + 1 then -- add new sheet
                PianoRollProject:AddSheet()
                PianoRollProject:Select(#PianoRollProject.meta.sheets)
            elseif i ~= PianoRollProject.meta.selectionIndex then -- select sheet
                PianoRollProject:Select(i)
            end
        end
        uid = uid + 1

        -- prevent rendering options for the "add..." button
        if i > #PianoRollProject.meta.sheets then break end

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
            PianoRollProject:MoveSheet(i, -1)
        end

        if (drawUtilityButton("v", i < #PianoRollProject.meta.sheets)) then
            PianoRollProject:MoveSheet(i, 1)
        end

        if (drawUtilityButton("-")) then
            PianoRollDialog = RenderConfirmDeletionPrompt(i)
        end

        if (drawUtilityButton(".st", true, 0.75)) then
            local path = iohelper.filediag("*.st;*.savestate", 0)
            if string.len(path) > 0 then
                PianoRollProject:Rebase(i, path)
            end
        end

        if (drawUtilityButton(".prs", true, 0.75)) then
            local path = iohelper.filediag("*.prs", 0)
            if string.len(path) > 0 then
                PianoRollProject.all[PianoRollProject.meta.sheets[i].name]:load(path, false)
            end
        end

        if (drawUtilityButton(">")) then
            PianoRollProject:Select(i, false)
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