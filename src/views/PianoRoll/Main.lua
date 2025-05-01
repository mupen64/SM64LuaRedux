local UID = dofile(views_path .. "PianoRoll/UID.lua")
local Project = dofile(views_path .. "PianoRoll/Project.lua")
local Help = dofile(views_path .. "PianoRoll/Help.lua")

---utility functions---

PianoRollProject = Project.new()
PianoRollDialog = nil

function CloneInto(destination, source)
    local changes = {}
    for k, v in pairs(source) do
        if v ~= destination[k] then changes[k] = v end
        anyChanges = anyChanges or v ~= destination[k]
        destination[k] = v
    end
    return changes
end

--implementation details

local uguiIconDraw = ugui.standard_styler.draw_icon

ugui.standard_styler.draw_icon = function(rectangle, color, visual_state, key)
    if key == "door_opening" then
        rectangle = {x = rectangle.x - rectangle.width * 0.5, y = rectangle.y - rectangle.height * 0.5, width = rectangle.width * 2, height = rectangle.height * 2}
        BreitbandGraphics.draw_image(rectangle, nil, views_path .. "PianoRoll/test.png", color, "linear")
    else
        uguiIconDraw(rectangle, color, visual_state, key)
    end
end

local Tabs = dofile(views_path .. "PianoRoll/Tabs.lua")
local SelectedTabIndex = 1

local function DrawFactory(theme)
    return {
        foregroundColor = BreitbandGraphics.invert_color(theme.background_color),
        backgroundColor = theme.background_color,
        fontSize = theme.font_size * Drawing.scale * 0.75,
        style = { aliased = theme.pixelated_text },

        text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text(rect, horizontal_alignment, "center", self.style, self.foregroundColor, self.fontSize, "Consolas", text)
        end,

        small_text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text(rect, horizontal_alignment, "center", self.style, self.foregroundColor, self.fontSize * 0.75, "Consolas", text)
        end
    }
end

emu.atupdatescreen(function()
    -- prevent reentrant calls caused by GUI actions while the game is running
    local currentSheet = PianoRollProject:Current()
    if currentSheet ~= nil and not currentSheet._busy then
        currentSheet:update()
    end
end)

---public API---

---Retrieves a TASState as determined by the currently active piano roll for the current frame identified by the current global timer value.
---
---If the current piano roll does not define what to do for this frame, or there is no current piano roll, nil is returned instead.
---
---@return Section|nil override The section to apply for the current frame.
function CurrentPianoRollOverride()
    local currentSheet = PianoRollProject:Current()
    return currentSheet and not PianoRollProject.disabled and currentSheet:evaluateFrame() or nil
end

return {
    name = Locales.str("PIANO_ROLL_TAB_NAME"),
    draw = function()

        -- if we're showing any dialog, stop rendering anything else
        if PianoRollDialog ~= nil then
            PianoRollDialog()
            return
        end

        local draw = DrawFactory(Styles.theme())

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
                tooltip = Locales.str("PIANO_ROLL_HELP_SHOW"),
                is_enabled = Tabs[SelectedTabIndex].HelpKey ~= nil,
            }
        ) then
            PianoRollDialog = Help.Render(Tabs[SelectedTabIndex].HelpKey)
        end

        -- show only the project page if no piano rolls exist
        if PianoRollProject:Current() == nil then SelectedTabIndex = 1 end
        Tabs[SelectedTabIndex].Render(draw)

        -- hack to make the listbox transparent
        Memory.update()
        local previousAlpha = BreitbandGraphics.colors.white.a
        BreitbandGraphics.colors.white.a = 110
        ugui.listbox({
            uid = UID.VarWatch,
            rectangle = grid_rect(-6, 10, 6, 7),
            selected_index = nil,
            items = VarWatch.processed_values,
        })
        BreitbandGraphics.colors.white.a = previousAlpha
    end,
}