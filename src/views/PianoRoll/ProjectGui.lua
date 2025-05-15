local name = "Project"

local UID = dofile(views_path .. "PianoRoll/UID.lua")[name]
local Project = dofile(views_path .. "PianoRoll/Project.lua")
local persistence = dofile(lib_path .. "persistence.lua")

local function AllocateUids(EnumNext)
    return {
        NewProject = EnumNext(),
        OpenProject = EnumNext(),
        SaveProject = EnumNext(),
        PurgeProject = EnumNext(),
        DisableProjectSheets = EnumNext(),
        ProjectSheetBase = EnumNext(1024), -- TODO: allocate an exact amount, assuming a scroll bar for too many sheets in one project
        HelpNext = EnumNext(),
        HelpBack = EnumNext(),
        AddSheet = EnumNext(),
        ConfirmationYes = EnumNext(),
        ConfirmationNo = EnumNext(),
    }
end

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
            text = Locales.str("YES"),
        }) then
            onConfirmed()
            PianoRollDialog = nil
        end
        if ugui.button({
            uid = UID.ConfirmationNo,
            rectangle = grid_rect(2, top, 2, controlHeight),
            text = Locales.str("NO"),
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
            Locales.str("PIANO_ROLL_PROJECT_NO_SHEETS_AVAILABLE")
        )
    end

    local top = 1
    draw:small_text(grid_rect(0, top, 8, controlHeight), "left", PianoRollProject.projectLocation)
    if ugui.button({
        uid = UID.NewProject,
        rectangle = grid_rect(0, top + 1, 1.5, controlHeight),
        text = Locales.str("PIANO_ROLL_PROJECT_NEW"),
        tooltip = Locales.str("PIANO_ROLL_PROJECT_NEW_TOOL_TIP"),
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
        text = Locales.str("PIANO_ROLL_PROJECT_OPEN"),
        tooltip = Locales.str("PIANO_ROLL_PROJECT_OPEN_TOOL_TIP"),
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
        text = Locales.str("PIANO_ROLL_PROJECT_SAVE"),
        tooltip = Locales.str("PIANO_ROLL_PROJECT_SAVE_TOOL_TIP"),
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
        text = Locales.str("PIANO_ROLL_PROJECT_PURGE"),
        tooltip = Locales.str("PIANO_ROLL_PROJECT_PURGE_TOOL_TIP"),
        is_enabled = PianoRollProject.projectLocation ~= nil,
    }) then
        PianoRollDialog = RenderConfirmPurgeDialog
    end

    local availableSheets = {}
    for i = 1, #PianoRollProject.meta.sheets, 1 do
        availableSheets[i] = PianoRollProject.meta.sheets[i].name
    end
    availableSheets[#availableSheets + 1] = Locales.str("PIANO_ROLL_PROJECT_ADD_SHEET")

    top = 3
    if #availableSheets > 1 then
        if (ugui.toggle_button({
            uid = UID.DisableProjectSheets,
            rectangle = grid_rect(0, top, 3, controlHeight),
            text = Locales.str("PIANO_ROLL_PROJECT_DISABLE"),
            tooltip = Locales.str("PIANO_ROLL_PROJECT_DISABLE_TOOL_TIP"),
            is_checked = PianoRollProject.disabled
        })) then
            PianoRollProject.disabled = true
        end
        top = top + controlHeight
    end

    local uid = UID.ProjectSheetBase
    for i = 1, #availableSheets, 1 do
        local y = top + (i - 1) * controlHeight
        if ugui.toggle_button({
            uid = uid,
            rectangle = grid_rect(0, y, 3, controlHeight),
            text = availableSheets[i],
            is_checked = not PianoRollProject.disabled and i == PianoRollProject.meta.selectionIndex,
        }) then
            if i == #PianoRollProject.meta.sheets + 1 then -- add new sheet
                PianoRollProject:AddSheet()
                PianoRollProject:Select(#PianoRollProject.meta.sheets)
            elseif PianoRollProject.disabled or i ~= PianoRollProject.meta.selectionIndex then -- select sheet
                PianoRollProject:Select(i)
            end
        end
        uid = uid + 1

        -- prevent rendering options for the "add..." button
        if i > #PianoRollProject.meta.sheets then break end

        local x = 3
        local function drawUtilityButton(text, tooltip, enabled, width)
            width = width or 0.5
            local result = ugui.button({
                uid = uid,
                rectangle = grid_rect(x, y, width, controlHeight),
                text = text,
                tooltip = tooltip,
                is_enabled = enabled,
            })
            uid = uid + 1
            x = x + width
            return result
        end

        if (drawUtilityButton("^", Locales.str("PIANO_ROLL_PROJECT_MOVE_SHEET_UP_TOOL_TIP"), i > 1)) then
            PianoRollProject:MoveSheet(i, -1)
        end

        if (drawUtilityButton("v", Locales.str("PIANO_ROLL_PROJECT_MOVE_SHEET_DOWN_TOOL_TIP"), i < #PianoRollProject.meta.sheets)) then
            PianoRollProject:MoveSheet(i, 1)
        end

        if (drawUtilityButton("-", Locales.str("PIANO_ROLL_PROJECT_DELETE_SHEET_TOOL_TIP"))) then
            PianoRollDialog = RenderConfirmDeletionPrompt(i)
        end

        if (drawUtilityButton(".st", Locales.str("PIANO_ROLL_PROJECT_REBASE_SHEET_TOOL_TIP"), true, 0.75)) then
            PianoRollProject:Rebase(i)
        end

        if (drawUtilityButton(".prs", Locales.str("PIANO_ROLL_PROJECT_REPLACE_INPUTS_TOOL_TIP"), true, 0.75)) then
            local path = iohelper.filediag("*.prs", 0)
            if string.len(path) > 0 then
                PianoRollProject.all[PianoRollProject.meta.sheets[i].name]:load(path, false)
            end
        end

        if (drawUtilityButton(">", Locales.str("PIANO_ROLL_PROJECT_PLAY_WITHOUT_ST_TOOL_TIP"))) then
            PianoRollProject:Select(i, false)
        end
        ::continue::
    end
end

return {
    name = name,
    Render = RenderSheetList,
    AllocateUids = AllocateUids,
    HelpKey = "PROJECT_GUI",
}