---utility functions---

function CloneInto(destination, source)
    local changes = {}
    for k, v in pairs(source) do
        if v ~= destination[k] then changes[k] = v end
        any_changes = any_changes or v ~= destination[k]
        destination[k] = v
    end
    return changes
end

---implementation details---

local UID <const> = dofile(views_path .. "SemanticWorkflow/UID.lua")
local Project = dofile(views_path .. "SemanticWorkflow/Definitions/Project.lua")
local Help = dofile(views_path .. "SemanticWorkflow/Help.lua")

---@type Project
SemanticWorkflowProject = Project.new()
SemanticWorkflowDialog = nil

local ugui_icon_draw = ugui.standard_styler.draw_icon

ugui.standard_styler.draw_icon = function(rectangle, color, visual_state, key)
    if key == "door_opening" then
        rectangle = {x = rectangle.x - rectangle.width * 0.5, y = rectangle.y - rectangle.height * 0.5, width = rectangle.width * 2, height = rectangle.height * 2}
        BreitbandGraphics.draw_image(rectangle, nil, views_path .. "SemanticWorkflow/Resources/door_opening.png", color, "linear")
    else
        ugui_icon_draw(rectangle, color, visual_state, key)
    end
end

local Tabs = dofile(views_path .. "SemanticWorkflow/Tabs.lua")
local selected_tab_index = 1

local function draw_factory(theme)
    return {
        foreground_color = BreitbandGraphics.invert_color(theme.background_color),
        background_color = theme.background_color,
        font_size = theme.font_size * Drawing.scale * 0.75,

        text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text2({
                rectangle = rect,
                text = text,
                align_x = horizontal_alignment,
                align_y = BreitbandGraphics.alignment.center,
                aliased = theme.pixelated_text,
                color = self.foreground_color,
                font_size = self.font_size,
                font_name = "Consolas",
            })
        end,

        small_text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text2({
                rectangle = rect,
                text = text,
                align_x = horizontal_alignment,
                align_y = BreitbandGraphics.alignment.center,
                aliased = theme.pixelated_text,
                color = self.foreground_color,
                font_size = self.font_size * 0.75,
                font_name = "Consolas",
            })
        end
    }
end

---public API---

---Retrieves a TASState as determined by the currently active semantic workflow for the current frame identified by the current global timer value.
---
---If the current semantic workflow does not define what to do for this frame, or there is no current semantic workflow, nil is returned instead.
---
---@return SectionInputs|nil override The inputs to apply for the current frame.
function CurrentSemanticWorkflowOverride()
    local current_sheet = SemanticWorkflowProject:current()
    return current_sheet and not SemanticWorkflowProject.disabled and current_sheet:evaluate_frame() or nil
end

return {
    name = Locales.str("SEMANTIC_WORKFLOW_TAB_NAME"),
    draw = function()

        -- if we're showing any dialog, stop rendering anything else
        if SemanticWorkflowDialog ~= nil then
            SemanticWorkflowDialog()
            return
        end

        local draw = draw_factory(Styles.theme())

        -- TODO: redesign which tabs to show when and how
        --       (particularly, 'Preferences' has no reason to be hidden when no project is loaded)
        local project_loaded = SemanticWorkflowProject:current() ~= nil
        if not project_loaded then
            -- show only the project page if no project was loaded
            selected_tab_index = 1
        end
        -- TODO: consider respecting valid bounding 'rectangle' result from this control
        selected_tab_index = ugui.tabcontrol({
            uid = UID.SelectTab,
            rectangle = grid_rect(0, 0, 7, 1),
            items = project_loaded and lualinq.select(Tabs, function(e) return e.name end) or { Tabs[1].name },
            selected_index = selected_tab_index,
        }).selected_index

        if ugui.button(
            {
                uid = UID.ToggleHelp,
                rectangle = grid_rect(7, 0, 1, 1),
                text = "?",
                tooltip = Locales.str("SEMANTIC_WORKFLOW_HELP_SHOW_TOOL_TIP"),
                is_enabled = Tabs[selected_tab_index].help_key ~= nil,
            }
        ) then
            SemanticWorkflowDialog = Help.GetDialog(Tabs[selected_tab_index].help_key)
        end

        Tabs[selected_tab_index].render(draw)

        -- hack to make the listbox transparent
        local previous_alpha = BreitbandGraphics.colors.white.a
        BreitbandGraphics.colors.white.a = 110
        ugui.listbox({
            uid = UID.VarWatch,
            rectangle = grid_rect(-6, 10, 6, 7),
            selected_index = nil,
            items = VarWatch.processed_values,
        })
        BreitbandGraphics.colors.white.a = previous_alpha
    end,
}