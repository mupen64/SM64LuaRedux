local UID = dofile(views_path .. "PianoRoll/UID.lua")

return {
    Render = function(key)
        local page = 1
        local help = Locales.raw()["PIANO_ROLL_HELP_EXPLANATIONS"][key];
        local pages = help.PAGES
        local title = help.HEADING
        return function()
            local theme = Styles.theme()
            local foregroundColor = theme.listbox_item.text[1]

            local controlHeight = 0.75
            local top = 16 - controlHeight
            local buttonPosition = grid_rect(7, 0, 1, 1)
            if ugui.button(
                {
                    uid = UID.ToggleHelp,

                    rectangle = buttonPosition,
                    text = "[icon:crossmark]", -- TODO: make this icon work
                }
            ) then
                PianoRollDialog = nil
            end

            BreitbandGraphics.draw_text(grid_rect(0, 0.1, 8, 1), "start", "start", {}, foregroundColor, theme.font_size * 1.2 * Drawing.scale, theme.font_name, title)
            BreitbandGraphics.draw_text(
                grid_rect(0, 0.666, 8, 1), #
                "start",
                "start",
                {},
                foregroundColor,
                theme.font_size * 2 * Drawing.scale,
                theme.font_name,
                pages[page]["HEADING"]
            )
            BreitbandGraphics.draw_text(
                grid_rect(0, 1.8, 8, 1),
                "start",
                "start",
                {},
                foregroundColor,
                theme.font_size * Drawing.scale,
                theme.font_name,
                pages[page]["TEXT"]
            )

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
                    is_enabled = page < #pages
                }
            ) then
                page = page + 1
            end
        end
    end,
}