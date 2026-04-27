--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('Visualizer', function(enum_next)
    return {
    }
end)

return {
    name = function() return Locales.str('VISUALIZER_TAB_NAME') end,
    draw = function()
        local text_color = Drawing.foreground_color()

        local function draw_button(pressed, active_color, text, shape, origin_x, origin_y, x, y, w, h, textoffset_x,
                                   textoffset_y, font)
            local rect = {
                x = origin_x + x * Drawing.scale,
                y = origin_y + y * Drawing.scale,
                width = w * Drawing.scale,
                height = h * Drawing.scale
            }

            local bg_color = Drawing.BACKGROUND_COLOUR

            if shape == "ellipse" then
                if pressed then
                    bg_color = active_color
                    BreitbandGraphics.fill_ellipse(rect, active_color)
                end
                BreitbandGraphics.draw_ellipse(rect, Drawing.TEXT_COLOR, 1)
            elseif shape == "rect" then
                if pressed then
                    bg_color = active_color
                    BreitbandGraphics.fill_rectangle(rect, active_color)
                end
                BreitbandGraphics.draw_rectangle(rect, Drawing.TEXT_COLOR, 1)
            end

            if textoffset_x == nil then textoffset_x = 6 end
            if textoffset_y == nil then textoffset_y = 8 end

            BreitbandGraphics.draw_text2({
                text = text,
                rectangle = rect,
                font_name = font,
                font_size = Drawing.MEDIUM_FONT_SIZE,
                color = text_color,
            })

            return rect
        end


        local theme = Styles.theme()
    end,
}
