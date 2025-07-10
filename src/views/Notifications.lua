--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local notifications = {}

-- For now, we only show one notification at a time, as opacity and slide animations are pretty distracting.

return {
    show = function(text)
        if Settings.notification_style == NOTIFICATION_STYLE_CONSOLE then
            print(text)
            return
        end

        if #notifications > 0 then
            notifications = {}
        end

        notifications[#notifications + 1] = {
            text = text,
            time = os.clock(),
        }
    end,
    draw = function()
        if #notifications == 0 then
            return
        end

        local theme = Styles.theme()
        local foreground_color = BreitbandGraphics.invert_color(theme.background_color)

        local text_scale = 1.25

        for i = 1, #notifications, 1 do
            local notification = notifications[i]

            local size = BreitbandGraphics.get_text_size(notification.text, theme.font_size * Drawing.scale * text_scale,
                theme.font_name)

            local padding = ugui.standard_styler.params.textbox.padding.x

            size.width = size.width + padding
            size.height = size.height + padding

            local x = 10
            local y = ugui.internal.environment.window_size.y - 50

            BreitbandGraphics.fill_rectangle(
                { x = x, y = y, width = size.width, height = size.height },
                theme.background_color)

            BreitbandGraphics.draw_text(
                {
                    x = x,
                    y = y,
                    width = size.width + 1,
                    height = size.height + 1,
                },
                'start',
                'start',
                { aliased = not theme.cleartype },
                foreground_color,
                theme.font_size * Drawing.scale * text_scale,
                theme.font_name,
                notification.text)
        end

        local notifications_copy = ugui.internal.deep_clone(notifications)
        for i = #notifications, 1, -1 do
            local notification = notifications_copy[i]

            if os.clock() - notification.time > 1 then
                table.remove(notifications, i)
            end
        end
    end,
}
