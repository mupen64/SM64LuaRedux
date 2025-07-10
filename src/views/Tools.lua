--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local RNG_ROW = 1
local LOOKAHEAD_ROW = 3
local DUMPING_ROW = 5
local GHOST_ROW = 7
local EXPERIMENTS_ROW = 9

return {
    name = Locales.str("TOOLS_TAB_NAME"),
    draw = function()
        local theme = Styles.theme()
        local foreground_color = BreitbandGraphics.invert_color(theme.background_color)

        BreitbandGraphics.draw_text(
            grid_rect(0, RNG_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            Locales.str("TOOLS_RNG"))

        Settings.override_rng = ugui.toggle_button({
            uid = 55,
            rectangle = grid_rect(0, RNG_ROW, 2, 1),
            text = Locales.str("TOOLS_RNG_LOCK"),
            is_checked = Settings.override_rng,
        })
        Settings.override_rng_use_index = ugui.toggle_button({
            uid = 60,
            is_enabled = Settings.override_rng,
            rectangle = grid_rect(6, RNG_ROW, 2, 1),
            text = Locales.str("TOOLS_RNG_USE_INDEX"),
            is_checked = Settings.override_rng_use_index,
        })
        Settings.override_rng_value = math.floor(ugui.spinner({
            uid = 65,
            is_enabled = Settings.override_rng,
            rectangle = grid_rect(2, RNG_ROW, 4, 1),
            value = Settings.override_rng_value,
            minimum_value = math.mininteger,
            maximum_value = math.maxinteger
        }))

        BreitbandGraphics.draw_text(
            grid_rect(0, LOOKAHEAD_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            Locales.str("TOOLS_LOOKAHEAD"))
        local lookahead = ugui.toggle_button({
            uid = 20,
            rectangle = grid_rect(0, LOOKAHEAD_ROW, 3, 1),
            text = Locales.str("TOOLS_LOOKAHEAD_ENABLE"),
            is_checked = Settings.lookahead
        })
        if not Settings.lookahead and lookahead then
            Lookahead.start()
        end
        Settings.lookahead = lookahead

        Settings.lookahead_length = math.abs(ugui.numberbox({
            uid = 25,
            rectangle = grid_rect(3, LOOKAHEAD_ROW, 2, 1),
            value = Settings.lookahead_length,
            places = 1,
        }))

        BreitbandGraphics.draw_text(
            grid_rect(0, DUMPING_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            Locales.str("TOOLS_DUMPING"))

        local previous_dump_enabled = Settings.dump_enabled
        local now_dump_enabled = ugui.toggle_button({
            uid = 50,
            rectangle = grid_rect(0, DUMPING_ROW, 4, 1),
            text = Settings.dump_enabled and Locales.str("GENERIC_STOP") or Locales.str("GENERIC_START"),
            is_checked = previous_dump_enabled
        })

        if now_dump_enabled and not previous_dump_enabled then
            Dumping.start()
        end

        if not now_dump_enabled and previous_dump_enabled then
            Dumping.stop()
        end


        BreitbandGraphics.draw_text(
            grid_rect(0, GHOST_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            Locales.str("TOOLS_GHOST"))

        if ugui.button({
                uid = 100,
                rectangle = grid_rect(0, GHOST_ROW, 4, 1),
                text = Ghost.is_recording and Locales.str("TOOLS_GHOST_STOP") or Locales.str("TOOLS_GHOST_START"),
            }) then
            Ghost.toggle_recording()
        end

        BreitbandGraphics.draw_text(
            grid_rect(0, EXPERIMENTS_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = not theme.cleartype },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            Locales.str("TOOLS_EXPERIMENTS"))

        Settings.worldviz_enabled = ugui.toggle_button({
            uid = 30,
            rectangle = grid_rect(0, EXPERIMENTS_ROW + 2, 4, 1),
            text = Locales.str("TOOLS_WORLD_VISUALIZER"),
            is_checked = Settings.worldviz_enabled
        })
        Settings.auto_firsties = ugui.toggle_button({
            uid = 35,
            rectangle = grid_rect(3, EXPERIMENTS_ROW + 1, 3, 1),
            text = Locales.str("TOOLS_AUTO_FIRSTIES"),
            is_checked = Settings.auto_firsties
        })
        Settings.mini_visualizer = ugui.toggle_button({
            uid = 36,
            rectangle = grid_rect(0, EXPERIMENTS_ROW + 1, 3, 1),
            text = Locales.str("TOOLS_MINI_OVERLAY"),
            is_checked = Settings.mini_visualizer
        })
        local previous_track_moved_distance = Settings.track_moved_distance
        Settings.track_moved_distance = ugui.toggle_button({
            uid = 40,
            rectangle = grid_rect(0, EXPERIMENTS_ROW, 3, 1),
            text = Locales.str("TOOLS_MOVED_DIST"),
            is_checked = Settings.track_moved_distance
        })
        if Settings.track_moved_distance and not previous_track_moved_distance then
            Settings.moved_distance_axis.x = Memory.current.mario_x
            Settings.moved_distance_axis.y = Memory.current.mario_y
            Settings.moved_distance_axis.z = Memory.current.mario_z
        end
        if not Settings.track_moved_distance and previous_track_moved_distance then
            Settings.moved_distance = Engine.get_distance_moved()
        end
        Settings.moved_distance_x = ugui.toggle_button({
            uid = 45,
            rectangle = grid_rect(3, EXPERIMENTS_ROW, 1, 1),
            text = 'X',
            is_checked = Settings.moved_distance_x
        })
        Settings.moved_distance_y = ugui.toggle_button({
            uid = 99,
            rectangle = grid_rect(4, EXPERIMENTS_ROW, 1, 1),
            text = 'Y',
            is_checked = Settings.moved_distance_y
        })
        Settings.moved_distance_z = ugui.toggle_button({
            uid = 101,
            rectangle = grid_rect(5, EXPERIMENTS_ROW, 1, 1),
            text = 'Z',
            is_checked = Settings.moved_distance_z
        })
    end
}
