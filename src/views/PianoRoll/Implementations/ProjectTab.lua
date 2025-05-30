---@type ProjectTab
---@diagnostic disable-next-line: assign-type-mismatch
local __impl = __impl

__impl.name = "Project"
__impl.help_key = "PROJECT_TAB"

local Project = dofile(views_path .. "PianoRoll/Definitions/Project.lua")
local persistence = dofile(lib_path .. "persistence.lua")

local UID <const> = dofile(views_path .. "PianoRoll/UID.lua")[__impl.name]

function __impl.allocate_uids(EnumNext)
    return {
        NewProject = EnumNext(),
        OpenProject = EnumNext(),
        SaveProject = EnumNext(),
        PurgeProject = EnumNext(),
        DisableProjectSheets = EnumNext(),
        ProjectSheetBase = EnumNext(1024), -- TODO: allocate an exact amount, assuming a scroll bar for too many sheets in one project
        AddSheet = EnumNext(),
        ConfirmationYes = EnumNext(),
        ConfirmationNo = EnumNext(),
    }
end

local control_height = 0.75

local function create_confirm_dialog(prompt, on_confirmed)
    return function()
        local top = 15 - control_height

        local theme = Styles.theme()
        local foreground_color = theme.listbox.text[1]

        BreitbandGraphics.draw_text(
            grid_rect(0, top - 8, 8, 8),
            "center",
            "end",
            {},
            foreground_color,
            theme.font_size * 1.2 * Drawing.scale,
            theme.font_name,
            prompt)

        if ugui.button({
            uid = UID.ConfirmationYes,
            rectangle = grid_rect(4, top, 2, control_height),
            text = Locales.str("YES"),
        }) then
            on_confirmed()
            PianoRollDialog = nil
        end
        if ugui.button({
            uid = UID.ConfirmationNo,
            rectangle = grid_rect(2, top, 2, control_height),
            text = Locales.str("NO"),
        }) then
            PianoRollDialog = nil
        end
    end
end

local function render_confirm_deletion_prompt(sheet_index)
    return create_confirm_dialog(
        "[Confirm deletion]\n\nAre you sure you want to delete \"" .. PianoRollProject.meta.sheets[sheet_index].name .. "\"?\nThis action cannot be undone.",
        function() PianoRollProject:remove_sheet(sheet_index) end
    )
end

local RenderConfirmPurgeDialog = create_confirm_dialog(
    "[Confirm project purge]\n\n"
    .."Are you sure you want to purge unused sheets from the project directory?\n"
    .."Unrelated files (not ending with .prs or .prs.savestate) will not be touched.\n"
    .."This action cannot be undone.",
    function()
        local ignored_files = {}
        local project_folder = PianoRollProject:project_folder()
        for _, sheet_meta in ipairs(PianoRollProject.meta.sheets) do
            ignored_files[sheet_meta.name .. ".prs"] = true
            ignored_files[sheet_meta.name .. ".prs.savestate"] = true
        end
        for file in io.popen("dir \"" .. project_folder .. "\" /b"):lines() do
            if ignored_files[file] == nil and (file:match("(.)prs$") ~= nil or file:match("(.)prs(.)savestate$") ~= nil) then
                assert(os.remove(project_folder .. file))
                print("removed " .. file)
            end
        end
    end
)

function __impl.render(draw)
    local theme = Styles.theme()
    local foreground_color = theme.listbox.text[1]
    if #PianoRollProject.meta.sheets == 0 then
        BreitbandGraphics.draw_text(
            grid_rect(0, 0, 8, 16),
            "center",
            "center",
            {},
            foreground_color,
            theme.font_size * 1.2 * Drawing.scale,
            theme.font_name,
            Locales.str("PIANO_ROLL_PROJECT_NO_SHEETS_AVAILABLE")
        )
    end

    local top = 1
    draw:small_text(grid_rect(0, top, 8, control_height), "left", PianoRollProject.project_location)
    if ugui.button({
        uid = UID.NewProject,
        rectangle = grid_rect(0, top + 1, 1.5, control_height),
        text = Locales.str("PIANO_ROLL_PROJECT_NEW"),
        tooltip = Locales.str("PIANO_ROLL_PROJECT_NEW_TOOL_TIP"),
    }) then
        local path = iohelper.filediag("*.prp", 1)
        if string.len(path) > 0 then
            PianoRollProject = Project.new()
            PianoRollProject.project_location = path
            PianoRollProject:add_sheet()
            persistence.store(path, PianoRollProject.meta)
        end
    end
    if ugui.button({
        uid = UID.OpenProject,
        rectangle = grid_rect(1.5, top + 1, 1.5, control_height),
        text = Locales.str("PIANO_ROLL_PROJECT_OPEN"),
        tooltip = Locales.str("PIANO_ROLL_PROJECT_OPEN_TOOL_TIP"),
    }) then
        local path = iohelper.filediag("*.prp", 0)
        if string.len(path) > 0 then
            PianoRollProject = Project.new()
            PianoRollProject.project_location = path
            PianoRollProject:load(persistence.load(path))
        end
    end
    if ugui.button({
        uid = UID.SaveProject,
        rectangle = grid_rect(3, top + 1, 1.5, control_height),
        text = Locales.str("PIANO_ROLL_PROJECT_SAVE"),
        tooltip = Locales.str("PIANO_ROLL_PROJECT_SAVE_TOOL_TIP"),
    }) then
        if PianoRollProject.project_location == nil then
            local path = iohelper.filediag("*.prp", 0)
            if string.len(path) == 0 then
                goto skipSave
            end
            PianoRollProject.project_location = path
            persistence.store(path, PianoRollProject.meta)
        end
        persistence.store(PianoRollProject.project_location, PianoRollProject.meta)
        local project_folder = PianoRollProject:project_folder()
        for _, sheet_meta in ipairs(PianoRollProject.meta.sheets) do
            PianoRollProject.all[sheet_meta.name]:save(project_folder .. sheet_meta.name .. ".prs")
        end
    end
    ::skipSave::

    if ugui.button({
        uid = UID.PurgeProject,
        rectangle = grid_rect(4.5, top + 1, 1.5, control_height),
        text = Locales.str("PIANO_ROLL_PROJECT_PURGE"),
        tooltip = Locales.str("PIANO_ROLL_PROJECT_PURGE_TOOL_TIP"),
        is_enabled = PianoRollProject.project_location ~= nil,
    }) then
        PianoRollDialog = RenderConfirmPurgeDialog
    end

    local available_sheets = {}
    for i = 1, #PianoRollProject.meta.sheets, 1 do
        available_sheets[i] = PianoRollProject.meta.sheets[i].name
    end
    available_sheets[#available_sheets + 1] = Locales.str("PIANO_ROLL_PROJECT_ADD_SHEET")

    top = 3
    if #available_sheets > 1 then
        if (ugui.toggle_button({
            uid = UID.DisableProjectSheets,
            rectangle = grid_rect(0, top, 3, control_height),
            text = Locales.str("PIANO_ROLL_PROJECT_DISABLE"),
            tooltip = Locales.str("PIANO_ROLL_PROJECT_DISABLE_TOOL_TIP"),
            is_checked = PianoRollProject.disabled
        })) then
            PianoRollProject.disabled = true
        end
        top = top + control_height
    end

    local uid = UID.ProjectSheetBase
    for i = 1, #available_sheets, 1 do
        local y = top + (i - 1) * control_height
        if ugui.toggle_button({
            uid = uid,
            rectangle = grid_rect(0, y, 3, control_height),
            text = available_sheets[i],
            is_checked = not PianoRollProject.disabled and i == PianoRollProject.meta.selection_index,
        }) then
            if i == #PianoRollProject.meta.sheets + 1 then -- add new sheet
                PianoRollProject:add_sheet()
                PianoRollProject:select(#PianoRollProject.meta.sheets)
            elseif PianoRollProject.disabled or i ~= PianoRollProject.meta.selection_index then -- select sheet
                PianoRollProject:select(i)
            end
        end
        uid = uid + 1

        -- prevent rendering options for the "add..." button
        if i > #PianoRollProject.meta.sheets then break end

        local x = 3
        local function draw_utility_button(text, tooltip, enabled, width)
            width = width or 0.5
            local result = ugui.button({
                uid = uid,
                rectangle = grid_rect(x, y, width, control_height),
                text = text,
                tooltip = tooltip,
                is_enabled = enabled,
            })
            uid = uid + 1
            x = x + width
            return result
        end

        if (draw_utility_button("^", Locales.str("PIANO_ROLL_PROJECT_MOVE_SHEET_UP_TOOL_TIP"), i > 1)) then
            PianoRollProject:move_sheet(i, -1)
        end

        if (draw_utility_button("v", Locales.str("PIANO_ROLL_PROJECT_MOVE_SHEET_DOWN_TOOL_TIP"), i < #PianoRollProject.meta.sheets)) then
            PianoRollProject:move_sheet(i, 1)
        end

        if (draw_utility_button("-", Locales.str("PIANO_ROLL_PROJECT_DELETE_SHEET_TOOL_TIP"))) then
            PianoRollDialog = render_confirm_deletion_prompt(i)
        end

        if (draw_utility_button(".st", Locales.str("PIANO_ROLL_PROJECT_REBASE_SHEET_TOOL_TIP"), true, 0.75)) then
            PianoRollProject:rebase(i)
        end

        if (draw_utility_button(".prs", Locales.str("PIANO_ROLL_PROJECT_REPLACE_INPUTS_TOOL_TIP"), true, 0.75)) then
            local path = iohelper.filediag("*.prs", 0)
            if string.len(path) > 0 then
                PianoRollProject.all[PianoRollProject.meta.sheets[i].name]:load(path, false)
            end
        end

        if (draw_utility_button(">", Locales.str("PIANO_ROLL_PROJECT_PLAY_WITHOUT_ST_TOOL_TIP"))) then
            PianoRollProject:select(i, false)
        end
        ::continue::
    end
end