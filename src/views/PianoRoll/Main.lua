local UID = dofile(views_path .. "PianoRoll/UID.lua")
local Project = dofile(views_path .. "PianoRoll/Project.lua")

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

function RecordPianoRollInput(input)
    for k,v in pairs(TASState) do
        input[k] = v
    end
    input.joy = {}
    CloneInto(input.joy, joypad.get(1))

    if TASState.movement_mode == MovementModes.disabled or movie.get_readonly() then
        input.movement_mode = MovementModes.manual
        input.manual_joystick_x = Joypad.input.X
        input.manual_joystick_y = Joypad.input.Y
    end
    input.preview_joystick_x = input.manual_joystick_x
    input.preview_joystick_y = input.manual_joystick_y
end

local Tabs = {
    dofile(views_path .. "PianoRoll/ProjectGui.lua"),
    dofile(views_path .. "PianoRoll/JoystickGui.lua"),
};

local SelectedTabIndex = 1

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
---@return table|nil override A table that can be assigned to TASState, additionally holding a field 'joy' that can be passed to joypad.set(...).
function CurrentPianoRollOverride()
    local currentSheet = PianoRollProject:Current()
    if (currentSheet == nil) then return nil end
    local globalTimer = memory.readdword(Addresses[Settings.address_source_index].global_timer)
    local numFrames = currentSheet:numFrames()
    if currentSheet ~= nil and currentSheet.startGT + numFrames <= globalTimer then
        local input = {}
        RecordPianoRollInput(input)
        repeat
            currentSheet.previewIndex = numFrames
            currentSheet.editingIndex = numFrames
            currentSheet.frames[numFrames] = input
            numFrames = numFrames + 1
        until currentSheet.startGT + numFrames > globalTimer -- TODO: this may cause issues with overflowing global timer - a sturdier method is needed
    end

    return currentSheet.frames[globalTimer - currentSheet.startGT]
end

local function DrawFactory(theme)
    return {
        foregroundColor = BreitbandGraphics.invert_color(theme.background_color),
        backgroundColor = theme.background_color,
        fontSize = theme.font_size * Drawing.scale * 0.75,
        style = { aliased = not theme.cleartype },

        text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text(rect, horizontal_alignment, "center", self.style, self.foregroundColor, self.fontSize, "Consolas", text)
        end,

        small_text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text(rect, horizontal_alignment, "center", self.style, self.foregroundColor, self.fontSize * 0.75, "Consolas", text)
        end
    }
end

return {
    name = "Piano Roll",
    draw = function()

        -- if we're showing any dialog, stop rendering anything else
        if PianoRollDialog ~= nil then
            PianoRollDialog()
            return
        end

        local draw = DrawFactory(Styles.theme())

        SelectedTabIndex = ugui.carrousel_button({
            uid = UID.SelectTab,

            rectangle = grid_rect(0, 0, 8, 1),
            items = lualinq.select(Tabs, function(e) return e.name end),
            selected_index = SelectedTabIndex
        })

        -- show only the project page if no piano rolls exist
        if PianoRollProject:Current() == nil then SelectedTabIndex = 1 end
        Tabs[SelectedTabIndex].Render(draw)

        -- hack to make the listbox transparent
        Memory.update()
        VarWatch_update()
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