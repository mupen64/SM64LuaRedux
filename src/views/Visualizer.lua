--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('Visualizer', function(enum_next)
    return {
        Joystick = enum_next(),
        Labels = enum_next(100),
    }
end)

return {
    name = function() return Locales.str('VISUALIZER_TAB_NAME') end,
    draw = function()
        local text_color = Drawing.foreground_color()

        local FONT_SMALL <const> = ugui.standard_styler.params.font_size * 1.2
        local FONT_BIG <const> = ugui.standard_styler.params.font_size * 1.5
        local function draw_button(pressed, active_color, text, shape, origin_x, origin_y, x, y, w, h, textoffset_x,
                                   textoffset_y, font)
            local rect = {
                x = origin_x + x * Drawing.scale,
                y = origin_y + y * Drawing.scale,
                width = w * Drawing.scale,
                height = h * Drawing.scale
            }

            if shape == "ellipse" then
                if pressed then
                    bg_color = active_color
                    BreitbandGraphics.fill_ellipse(rect, active_color)
                end
                BreitbandGraphics.draw_ellipse(rect, text_color, 1)
            elseif shape == "rect" then
                if pressed then
                    bg_color = active_color
                    BreitbandGraphics.fill_rectangle(rect, active_color)
                end
                BreitbandGraphics.draw_rectangle(rect, text_color, 1)
            end

            if textoffset_x == nil then textoffset_x = 6 end
            if textoffset_y == nil then textoffset_y = 8 end

            BreitbandGraphics.draw_text2({
                text = text,
                rectangle = rect,
                font_name = font or ugui.standard_styler.params.monospace_font_name,
                font_size = FONT_BIG,
                color = text_color,
            })

            return rect
        end


        local theme = Styles.theme()
        local joystick_position = {
            x = Engine.stick_for_input_x(Settings.tas),
            y = -Engine.stick_for_input_y(Settings
                .tas)
        }

        ugui.joystick({
            uid = UID.Joystick,
            rectangle = grid_rect(2, 0, 4, 4),
            position = joystick_position
        })

        local rc = grid_rect(1.25, 4, 4, 4)
        local x = rc.x
        local y = rc.y
        draw_button(Joypad.input.A, "#3366CC", "A", "ellipse", x, y, 82, 60, 29, 29, nil, nil)
        draw_button(Joypad.input.B, "#009245", "B", "ellipse", x, y, 63, 31, 29, 29, nil, nil)
        draw_button(Joypad.input.start, "#EE1C24", "S", "ellipse", x, y, 31, 60, 29, 29, nil, nil)
        draw_button(Joypad.input.R, "#DDDDDD", "R", "rect", x, y, 98, 0, 72, 21, nil, nil)
        draw_button(Joypad.input.L, "#DDDDDD", "L", "rect", x, y, 9, 0, 72, 21, nil, nil)
        draw_button(Joypad.input.Z, "#DDDDDD", "Z", "rect", x, y, 0, 30, 21, 59, nil, nil)
        draw_button(Joypad.input.Cleft, "#FFFF00", "3", "ellipse", x, y, 116, 47, 21, 21, 8, 7, "Marlett")
        draw_button(Joypad.input.Cright, "#FFFF00", "4", "ellipse", x, y, 155, 47, 21, 21, 9, 7, "Marlett")
        draw_button(Joypad.input.Cup, "#FFFF00", "5", "ellipse", x, y, 135, 28, 21, 21, 8, 8, "Marlett")
        draw_button(Joypad.input.Cdown, "#FFFF00", "6", "ellipse", x, y, 135, 68, 21, 21, 8, 8, "Marlett")

        local rc2 = grid_rect(0.1, 7, 0, 0)
        local available_width = (Drawing.size.width - Drawing.initial_size.width) -
            (rc2.x - Drawing.initial_size.width) * 2

        y = rc2.y

        local function place_entry(uid, label, value, size)
            ugui.label({
                uid = uid,
                rectangle = {
                    x = rc2.x,
                    y = y,
                    width = available_width,
                    height = 0
                },
                text = label,
                color = text_color,
                font_size = size,
                font_name = ugui.standard_styler.params.monospace_font_name,
                align_x = BreitbandGraphics.alignment.start
            })

            ugui.label({
                uid = uid + 1,
                rectangle = {
                    x = rc2.x,
                    y = y,
                    width = available_width,
                    height = 0
                },
                text = value,
                color = text_color,
                font_size = size,
                font_name = ugui.standard_styler.params.monospace_font_name,
                align_x = BreitbandGraphics.alignment['end']
            })
            y = y + size + 4
            return uid + 2
        end

        local function place_separator(uid)
            local size = 8
            ugui.label({
                uid = uid,
                rectangle = {
                    x = rc2.x,
                    y = y,
                    width = available_width,
                    height = 0
                },
                text = string.rep('—', 50),
                color = text_color,
                font_size = size,
                font_name = ugui.standard_styler.params.monospace_font_name,
                align_x = BreitbandGraphics.alignment['end']
            })
            y = y + size * 2
            return uid + 1
        end

        local current_uid = UID.Labels

        local sample = emu.samplecount()
        local active = sample ~= 4294967295
        current_uid = place_entry(current_uid, active and "Frame" or "No movie playing",
            active and emu.samplecount() or "", FONT_SMALL)

        current_uid = place_separator(current_uid)

        for _, value in pairs(Settings.variables) do
            local entry = VarWatch.var_funcs[value.identifier]()

            if not value.visible or not entry.label then
                goto continue
            end


            local size = FONT_SMALL

            local locale = Locales.raw()
            local big = { locale.VARWATCH_FACING_YAW_LABEL, locale.VARWATCH_H_SPEED_LABEL, locale.VARWATCH_Y_SPEED_LABEL,
                locale.VARWATCH_ACTION_LABEL }

            for _, v in ipairs(big) do
                if entry.label == v then
                    size = FONT_BIG
                    break
                end
            end

            local separator_after = { locale.VARWATCH_INTENDED_YAW_LABEL, locale.VARWATCH_SPD_EFFICIENCY_LABEL, locale
                .VARWATCH_POS_Z_LABEL }

            current_uid = place_entry(current_uid, entry.label, entry.value, size)

            for _, v in ipairs(separator_after) do
                if entry.label == v then
                    current_uid = place_separator(current_uid)
                    break
                end
            end

            ::continue::
        end
    end,
}
