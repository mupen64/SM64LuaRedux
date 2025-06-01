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
local SelectedTabIndex = 1

local function draw_factory(theme)
    return {
        foreground_color = BreitbandGraphics.invert_color(theme.background_color),
        background_color = theme.background_color,
        font_size = theme.font_size * Drawing.scale * 0.75,
        style = { aliased = theme.pixelated_text },

        text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text(rect, horizontal_alignment, "center", self.style, self.foreground_color, self.font_size, "Consolas", text)
        end,

        small_text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text(rect, horizontal_alignment, "center", self.style, self.foreground_color, self.font_size * 0.75, "Consolas", text)
        end
    }
end

emu.atupdatescreen(function()
    -- prevent reentrant calls caused by GUI actions while the game is running
    local current_sheet = SemanticWorkflowProject:current()
    if current_sheet ~= nil and not current_sheet._busy then
        current_sheet:update()
    end
end)

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

        SelectedTabIndex = ugui.carrousel_button({
            uid = UID.SelectTab,
            rectangle = grid_rect(0, 0, 7, 1),
            items = lualinq.select(Tabs, function(e) return e.name end),
            selected_index = SelectedTabIndex
        })

        if ugui.button(
            {
                uid = UID.ToggleHelp,
                rectangle = grid_rect(7, 0, 1, 1),
                text = "?",
                tooltip = Locales.str("SEMANTIC_WORKFLOW_HELP_SHOW_TOOL_TIP"),
                is_enabled = Tabs[SelectedTabIndex].help_key ~= nil,
            }
        ) then
            SemanticWorkflowDialog = Help.GetDialog(Tabs[SelectedTabIndex].help_key)
        end

        -- show only the project page if no semantic workflows exist
        if SemanticWorkflowProject:current() == nil then SelectedTabIndex = 1 end
        Tabs[SelectedTabIndex].render(draw)

        -- hack to make the listbox transparent
        Memory.update()
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