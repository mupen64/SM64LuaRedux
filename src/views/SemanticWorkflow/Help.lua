local UID <const> = dofile(views_path .. "SemanticWorkflow/UID.lua")

return {
    GetDialog = function(key)
        local page = 1
        local help = Locales.raw()["SEMANTIC_WORKFLOW_HELP_EXPLANATIONS"][key];
        local pages = help.PAGES
        local title = help.HEADING
        return function()
            local theme = Styles.theme()
            local foreground_color = theme.listbox_item.text[1]

            local control_height = 0.75
            local top = 16 - control_height
            local button_position = grid_rect(7, 0, 1, 1)
            if ugui.button(
                {
                    uid = UID.ToggleHelp,
                    rectangle = button_position,
                    text = "[icon:door_opening]",
                    tooltip = Locales.str("SEMANTIC_WORKFLOW_HELP_EXIT_TOOL_TIP")
                }
            ) then
                SemanticWorkflowDialog = nil
            end

            BreitbandGraphics.draw_text2({
                rectangle = grid_rect(0, 0.1, 8, 1),
                text = title,
                align_x = BreitbandGraphics.alignment.start,
                align_y = BreitbandGraphics.alignment.start,
                color = foreground_color,
                font_size = theme.font_size * 1.2 * Drawing.scale,
                font_name = theme.font_name,
            })
            BreitbandGraphics.draw_text2({
                rectangle = grid_rect(0, 0.666, 8, 1),
                text = pages[page]["HEADING"],
                align_x = BreitbandGraphics.alignment.start,
                align_y = BreitbandGraphics.alignment.start,
                color = foreground_color,
                font_size = theme.font_size * 2 * Drawing.scale,
                font_name = theme.font_name,
            })
            BreitbandGraphics.draw_text2({
                rectangle = grid_rect(0, 1.8, 8, 1),
                text = pages[page]["TEXT"],
                align_x = BreitbandGraphics.alignment.start,
                align_y = BreitbandGraphics.alignment.start,
                color = foreground_color,
                font_size = theme.font_size * Drawing.scale,
                font_name = theme.font_name,
            })

            if ugui.button(
                {
                    uid = UID.HelpBack,
                    rectangle = grid_rect(5, top, 1.5, control_height),
                    text = Locales.str("SEMANTIC_WORKFLOW_HELP_PREV_PAGE"),
                    is_enabled = page > 1
                }
            ) then
                page = page - 1
            end

            if ugui.button(
                {
                    uid = UID.HelpNext,
                    rectangle = grid_rect(6.5, top, 1.5, control_height),
                    text = Locales.str("SEMANTIC_WORKFLOW_HELP_NEXT_PAGE"),
                    is_enabled = page < #pages
                }
            ) then
                page = page + 1
            end
        end
    end,
}