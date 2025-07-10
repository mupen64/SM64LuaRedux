--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

HOTKEY_MODE_ONESHOT = 0
HOTKEY_MODE_REPEAT = 1

NOTIFICATION_STYLE_BUBBLE = 1
NOTIFICATION_STYLE_CONSOLE = 2

Settings = {
    swimming_button = "A",
    controller_index = 1,
    override_rng = false,
    override_rng_use_index = false,
    override_rng_value = 0,
    show_effective_angles = true,
    ghost_path = folder .. "recording.ghost",
    grid_size = 35,
    grid_gap = 2,
    track_moved_distance = false,
    moved_distance_x = true,
    moved_distance_y = true,
    moved_distance_z = true,
    moved_distance = 0,
    moved_distance_axis = {
        x = 0,
        y = 0,
        z = 0
    },
    atan_exp = 0,
    lookahead = false,
    lookahead_length = 1,
    format_decimal_points = 4,
    format_angles_degrees = false,
    worldviz_enabled = false,
    truncate_effective_angle = false,
    active_style_index = 2,
    locale_index = 1,
    tab_index = 1,
    navbar_visible = true,
    settings_tab_index = 1,
    autodetect_address = true,
    auto_firsties = false,
    mini_visualizer = false,
    repaint_throttle = 2,
    -- Writes memory values, input data, and frame indicies to a buffer each frame
    dump_enabled = false,
    dump_start_frame = 0,
    dump_movie_start_frame = 0,
    notification_style = NOTIFICATION_STYLE_BUBBLE,
    hotkeys_enabled = true,
    hotkeys_assigning = false,
    hotkeys_selected_index = 1,
    hotkeys_allow_with_active_control = true,
    spd_efficiency_fraction = false,
    persist_tas_state = true,
    timer_auto = true,
    semantic_workflow = {
        edit_entire_state = true,
        fast_foward = true,
        default_section_timeout = 60,
    },
    variables = {
        {
            identifier = "yaw_facing",
            visible = true
        },
        {
            identifier = "yaw_intended",
            visible = true,
        },
        {
            identifier = "h_spd",
            visible = true,
        },
        {
            identifier = "v_spd",
            visible = true,
        },
        {
            identifier = "spd_efficiency",
            visible = true,
        },
        {
            identifier = "position_x",
            visible = true,
        },
        {
            identifier = "position_y",
            visible = true,
        },
        {
            identifier = "position_z",
            visible = true,
        },
        {
            identifier = "pitch",
            visible = true,
        },
        {
            identifier = "yaw_vel",
            visible = false,
        },
        {
            identifier = "pitch_vel",
            visible = false,
        },
        {
            identifier = "xz_movement",
            visible = true,
        },
        {
            identifier = "action",
            visible = true,
        },
        {
            identifier = "rng",
            visible = true,
        },
        {
            identifier = "global_timer",
            visible = false,
        },
        {
            identifier = "moved_dist",
            visible = true
        },
        {
            identifier = "atan_basic",
            visible = true,
        },
        {
            identifier = "atan_start_frame",
            visible = true
        },
    },
    hotkeys = {
        {
            identifier = "movement_mode_disabled",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "control",
                "1",
            },
        },
        {
            identifier = "movement_mode_match_yaw",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "control",
                "2",
            },
        },
        {
            identifier = "movement_mode_reverse_angle",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "control",
                "3",
            },
        },
        {
            identifier = "movement_mode_match_angle",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "control",
                "4",
            },
        },
        {
            identifier = "preset_down",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "leftbracket",
            },
        },
        {
            identifier = "preset_up",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "rightbracket",
            },
        },
        {
            identifier = "copy_yaw_facing_to_match_angle",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "control",
                "comma",
            },
        },
        {
            identifier = "copy_yaw_intended_to_match_angle",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "control",
                "period",
            },
        },
        {
            identifier = "toggle_auto_firsties",
            mode = HOTKEY_MODE_ONESHOT,
            keys = {
                "control",
                "I",
            },
        },
        {
            identifier = "angle_down",
            mode = HOTKEY_MODE_REPEAT,
            keys = {
            },
        },
        {
            identifier = "angle_up",
            mode = HOTKEY_MODE_REPEAT,
            keys = {
            },
        },
        {
            identifier = "toggle_spdkick",
            keys = {
                "control",
                "K",
            },
        },
        {
            identifier = "toggle_navbar",
            keys = {
                "shift",
                "T",
            },
        },
    },
    address_source_index = 1,
}
