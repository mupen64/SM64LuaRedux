local UID = dofile(views_path .. "PianoRoll/UID.lua")

local page = 1

local title = "Piano Roll Help"

local headers = {
    "About",
    "Getting started",
    "Editing values",
    "Managing sheets",
    "Caveats",
}

local explanations = {
-- About
[[
This page lets you play back a sequence of TAS inputs starting from a specific "base frame" with immediate effect.

The purpose of this is to quickly iterate over the effects of small changes "in the past" in order to more efficiently iterate over different implementations of the same strategy.

Click "next" to learn more about how to use this tool.
]],

-- Getting started
[[
Press the [+] Button in the bottom right corner to create a new "Piano Roll" sheet.
This new sheet will be starting at the current frame, identified by the game's global timer value.
Frame advance a couple times and optionally make some inputs with TASinput as usual to get some frames to mess with.
(You will likely be using this page exclusively from there on anyways.)

Click the "Frame" column to select a frame to preview.
Whenever you make any change to any inputs (e.g. change any button inputs), the game is going to be replayed to the preview frame (highlighted in red) from the start of the sheet with the new inputs.

You can select a range of joystick inputs to edit by leftclicking and dragging over the mini-joysticks in the desired range.
Then use the joystick controls at the bottom to decide how those frames should be treated.
]],

-- Editing values
[[
The frame highlighted in green is the "active" frame.
Its values will be displayed, and when you make any changes, its values will copied to the selected range.

If the 'Copy entire state' toggle is off, only the changes made to the active frame will be copied to the selected range.

When the active frame and the preview frame are the same, the highlight will become a yellow-ish green.
]],

-- Managing sheets
[[
You can add as many piano roll sheets as you want.
Note the textbox in the top right that allows you to assign them names.
Click the [-] button to delete a sheet. You will be prompted for confirmation to prevent accidental deletions.

You can also save and load piano roll sheets.
When saving a piano roll sheet, a savestate with the same name as the piano roll sheet file will be created, and the sheet will be executed from that savestate.
This allows you to share piano roll sheets in a similar way to .m64 movies.

You can always cycle to "Off" to disable Piano Rolls entirely.
]]
}

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
                text = "Exit",
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
                text = "back",
                is_enabled = page > 1
            }
        ) then
            page = page - 1
        end

        if ugui.button(
            {
                uid = UID.Project.HelpNext,

                rectangle = grid_rect(6.5, top, 1.5, controlHeight),
                text = "next",
                is_enabled = page < #explanations
            }
        ) then
            page = page + 1
        end
    end,
}