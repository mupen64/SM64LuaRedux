--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('Visualizer', function(enum_next)
    return {
        Joystick = enum_next(),
        JoystickX = enum_next(),
        JoystickY = enum_next(),
        Labels = enum_next(100),
    }
end)

local EMPHASIZED <const> = {
    yaw_facing = true,
    h_spd = true,
    v_spd = true,
    action = true,
}

local ENTRY_GAP <const> = 6

local SEPARATOR_ALPHA <const> = 0.1

local MIN_FONT_FACTOR <const> = 0.5

return {
    name = function() return Locales.str('VISUALIZER_TAB_NAME') end,
    draw = function()
        local text_color = Drawing.foreground_color()
        local background_color = Styles.theme().background_color

        local FONT_SMALL <const> = ugui.standard_styler.params.font_size * 1.2
        local FONT_BIG <const> = ugui.standard_styler.params.font_size * 1.5

        local function draw_button(pressed, active_color, text, shape, origin_x, origin_y, x, y, w, h, font)
            local rect = {
                x = origin_x + x * Drawing.scale,
                y = origin_y + y * Drawing.scale,
                width = w * Drawing.scale,
                height = h * Drawing.scale,
            }

            local bg_color = background_color

            if shape == 'ellipse' then
                if pressed then
                    bg_color = active_color
                    BreitbandGraphics.fill_ellipse(rect, active_color)
                end
                BreitbandGraphics.draw_ellipse(rect, text_color, 1)
            elseif shape == 'rect' then
                if pressed then
                    bg_color = active_color
                    BreitbandGraphics.fill_rectangle(rect, active_color)
                end
                BreitbandGraphics.draw_rectangle(rect, text_color, 1)
            end

            BreitbandGraphics.draw_text2({
                text = text,
                rectangle = rect,
                font_name = font or ugui.standard_styler.params.monospace_font_name,
                font_size = FONT_BIG,
                color = Drawing.foreground_color_for(bg_color),
            })

            return rect
        end

        local stick_x = Engine.stick_for_input_x(Settings.tas)
        local stick_y = Engine.stick_for_input_y(Settings.tas)

        ugui.joystick({
            uid = UID.Joystick,
            rectangle = grid_rect(2, 0, 4, 4),
            position = {
                x = stick_x,
                y = -stick_y,
            },
        })

        local function place_stick_label(uid, rectangle, text)
            ugui.label({
                uid = uid,
                rectangle = rectangle,
                text = text,
                color = text_color,
                font_size = FONT_SMALL,
                font_name = ugui.standard_styler.params.monospace_font_name,
                align_x = BreitbandGraphics.alignment.start,
            })
        end

        place_stick_label(UID.JoystickX, grid_rect(6, 1.25, 2, 0.75), 'X ' .. MoreMaths.round(stick_x, 0))
        place_stick_label(UID.JoystickY, grid_rect(6, 2, 2, 0.75), 'Y ' .. MoreMaths.round(stick_y, 0))

        local rc = grid_rect(1.25, 4, 4, 4)
        local x = rc.x
        local y = rc.y
        draw_button(Joypad.input.A, '#3366CC', 'A', 'ellipse', x, y, 82, 60, 29, 29)
        draw_button(Joypad.input.B, '#009245', 'B', 'ellipse', x, y, 63, 31, 29, 29)
        draw_button(Joypad.input.start, '#EE1C24', 'S', 'ellipse', x, y, 31, 60, 29, 29)
        draw_button(Joypad.input.R, '#DDDDDD', 'R', 'rect', x, y, 98, 0, 72, 21)
        draw_button(Joypad.input.L, '#DDDDDD', 'L', 'rect', x, y, 9, 0, 72, 21)
        draw_button(Joypad.input.Z, '#DDDDDD', 'Z', 'rect', x, y, 0, 30, 21, 59)
        draw_button(Joypad.input.Cleft, '#FFFF00', '3', 'ellipse', x, y, 116, 47, 21, 21, 'Marlett')
        draw_button(Joypad.input.Cright, '#FFFF00', '4', 'ellipse', x, y, 155, 47, 21, 21, 'Marlett')
        draw_button(Joypad.input.Cup, '#FFFF00', '5', 'ellipse', x, y, 135, 28, 21, 21, 'Marlett')
        draw_button(Joypad.input.Cdown, '#FFFF00', '6', 'ellipse', x, y, 135, 68, 21, 21, 'Marlett')

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
                    height = 0,
                },
                text = label,
                color = text_color,
                font_size = size,
                font_name = ugui.standard_styler.params.monospace_font_name,
                align_x = BreitbandGraphics.alignment.start,
            })

            ugui.label({
                uid = uid + 1,
                rectangle = {
                    x = rc2.x,
                    y = y,
                    width = available_width,
                    height = 0,
                },
                text = value,
                color = text_color,
                font_size = size,
                font_name = ugui.standard_styler.params.monospace_font_name,
                align_x = BreitbandGraphics.alignment['end'],
            })
            y = y + size + ENTRY_GAP
            return uid + 2
        end

        local SEPARATOR_HEIGHT <const> = 8 * Drawing.scale

        ---@param prev_center number The `y` the previous entry was centered on.
        ---@param prev_line_height number The previous entry's rendered line height.
        ---@param next_line_height number The upcoming entry's rendered line height.
        local function place_separator(prev_center, prev_line_height, next_line_height)
            local separator_color = BreitbandGraphics.color_to_float(text_color)
            separator_color.a = SEPARATOR_ALPHA

            local next_center = y + SEPARATOR_HEIGHT
            local gap_top = prev_center + prev_line_height / 2
            local gap_bottom = next_center - next_line_height / 2

            local line_y = math.floor((gap_top + gap_bottom) / 2) + 0.5
            BreitbandGraphics.draw_line(
                { x = math.floor(rc2.x), y = line_y },
                { x = math.floor(rc2.x + available_width), y = line_y },
                separator_color, 1)

            y = next_center
        end

        local sample = emu.samplecount()
        local active = sample ~= 4294967295

        ---@type { label: string, value: string, emphasized: boolean }[]
        local entries = {
            {
                label = active and 'Frame' or 'No movie playing',
                value = active and tostring(sample) or '',
                emphasized = false,
            },
        }

        for _, variable in ipairs(Settings.variables) do
            local entry = variable.visible and VarWatch.var_funcs[variable.identifier]()

            if entry and entry.label then
                entries[#entries + 1] = {
                    label = entry.label,
                    value = entry.value,
                    emphasized = EMPHASIZED[variable.identifier] or false,
                }
            end
        end

        local font_height = 0
        local fixed_height = 0
        for _, entry in ipairs(entries) do
            if entry.emphasized then
                fixed_height = fixed_height + SEPARATOR_HEIGHT
            end
            font_height = font_height + (entry.emphasized and FONT_BIG or FONT_SMALL)
            fixed_height = fixed_height + ENTRY_GAP
        end

        local bottom = Settings.navbar_visible and grid_rect(0, 16, 0, 0).y or Drawing.size.height
        local available_height = bottom - rc2.y - ENTRY_GAP

        local factor = 1
        if font_height + fixed_height > available_height then
            factor = math.max(MIN_FONT_FACTOR, (available_height - fixed_height) / font_height)
        end

        local small_size = FONT_SMALL * factor
        local big_size = FONT_BIG * factor

        local monospace_font <const> = ugui.standard_styler.params.monospace_font_name
        local small_line_height <const> = BreitbandGraphics.get_text_size('0', small_size, monospace_font).height
        local big_line_height <const> = BreitbandGraphics.get_text_size('0', big_size, monospace_font).height

        local prev_center = y
        local prev_line_height = 0

        local current_uid = UID.Labels
        for _, entry in ipairs(entries) do
            local size = entry.emphasized and big_size or small_size
            local line_height = entry.emphasized and big_line_height or small_line_height

            if entry.emphasized then
                place_separator(prev_center, prev_line_height, line_height)
            end

            prev_center = y
            prev_line_height = line_height

            current_uid = place_entry(current_uid, entry.label, entry.value, size)
        end
    end,
}
