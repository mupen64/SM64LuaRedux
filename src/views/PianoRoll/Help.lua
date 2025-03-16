local UID = dofile(views_path .. "PianoRoll/UID.lua")

local page = 1

local title = Locales.str("PIANO_ROLL_HELP_HEADER_TITLE")

local headers = {
    Locales.str("PIANO_ROLL_HELP_HEADER_ABOUT"),
    Locales.str("PIANO_ROLL_HELP_HEADER_BEGIN"),
    Locales.str("PIANO_ROLL_HELP_HEADER_EDIT"),
    Locales.str("PIANO_ROLL_HELP_HEADER_MANAGE"),
    Locales.str("PIANO_ROLL_HELP_HEADER_CAVEATS"),
}

local explanations = Locales.str("PIANO_ROLL_HELP_EXPLANATIONS")

return {
    Render = function()
        local theme = Styles.theme()
        local foregroundColor = theme.listbox_item.text[1]

        local controlHeight = 0.75
        local top = 16 - controlHeight
        local buttonPosition = grid_rect(0, top, 1.5, controlHeight)
        if ugui.button(
            {
                uid = UID.Project.ToggleHelp,

                rectangle = buttonPosition,
                text = shown and Locales.str("PIANO_ROLL_HELP_EXIT") or Locales.str("PIANO_ROLL_HELP_SHOW"),
            }
        ) then
            PianoRollDialog = nil
        end

        BreitbandGraphics.draw_text(grid_rect(0, 0.1, 8, 1), "start", "start", {}, foregroundColor, theme.font_size * 1.2 * Drawing.scale, theme.font_name, title)
        BreitbandGraphics.draw_text(grid_rect(0, 0.666, 8, 1), "start", "start", {}, foregroundColor, theme.font_size * 2 * Drawing.scale, theme.font_name, headers[page])
        BreitbandGraphics.draw_text(grid_rect(0, 1.8, 8, 1), "start", "start", {}, foregroundColor, theme.font_size * Drawing.scale, theme.font_name, explanations[page])

        if ugui.button(
            {
                uid = UID.Project.HelpBack,

                rectangle = grid_rect(5, top, 1.5, controlHeight),
                text = Locales.str("PIANO_ROLL_HELP_PREV_PAGE"),
                is_enabled = page > 1
            }
        ) then
            page = page - 1
        end

        if ugui.button(
            {
                uid = UID.Project.HelpNext,

                rectangle = grid_rect(6.5, top, 1.5, controlHeight),
                text = Locales.str("PIANO_ROLL_HELP_NEXT_PAGE"),
                is_enabled = page < #explanations
            }
        ) then
            page = page + 1
        end
    end,
}