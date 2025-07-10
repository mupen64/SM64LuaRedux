--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

WorldVisualizer = {}

-- original by madghostek, adapted to redux model

local camera_depth = 0
local camera_yaw = 0
local camera_pitch = 0

gObjlist = 0x8033D488
objsize = 0x260

--gets all active slots and returns vec3 array of positions
local function get_objects()
    local objects = {}
    local i = 0
    while true do
        if memory.readdword(gObjlist + i * objsize) == 0 then break end

        objects[#objects + 1] = {
            x = memory.readfloat(gObjlist + 0xA0 + i * objsize),
            y = memory.readfloat(gObjlist + 0xA4 + i * objsize),
            z = memory.readfloat(gObjlist + 0xA8 + i * objsize),
            ptr = gObjlist + i * objsize,
        }
        i = i + 1
    end
    return objects
end


local function project(vec3)
    local p = ugui.internal.deep_clone(vec3)

    --cam to origin, move point relatively
    p.x = p.x - Memory.current.camera_x
    p.y = p.y - Memory.current.camera_y
    p.z = p.z - Memory.current.camera_z

    --rotate point based on cam yaw
    local t = p.x * math.cos(math.rad(camera_yaw)) - p.z * math.sin(math.rad(camera_yaw))
    p.z = p.x * math.sin(math.rad(camera_yaw)) + p.z * math.cos(math.rad(camera_yaw))
    p.x = t

    --now on cam pitch
    t = p.z * math.cos(math.rad(360 - camera_pitch)) -
        p.y * math.sin(math.rad(360 - camera_pitch))
    p.y = p.z * math.sin(math.rad(360 - camera_pitch)) +
        p.y * math.cos(math.rad(360 - camera_pitch))
    p.z = t
    p.x = -p.x * camera_depth / p.z --apparently x is reversed too
    p.y = -p.y * camera_depth / p.z

    --move to center of screen
    p.x = p.x + Drawing.initial_size.width / 2
    p.y = p.y + Drawing.initial_size.height / 2
    p.z = p.z

    return p
end

local function is_inside_frustum(vec)
    return vec.z > 50 and vec.z < 5000
end

local function draw_moved_dist()
    if not Settings.track_moved_distance then
        return
    end
    
    local start_x = Settings.moved_distance_axis.x
    local start_y = Settings.moved_distance_axis.y
    local start_z = Settings.moved_distance_axis.z
    local end_x = Settings.moved_distance_axis.x
    local end_y = Settings.moved_distance_axis.y
    local end_z = Settings.moved_distance_axis.z
    if Settings.moved_distance_x then
        end_x = Memory.current.mario_x
    end
    if Settings.moved_distance_y then
        end_y = Memory.current.mario_y
    end
    if Settings.moved_distance_z then
        end_z = Memory.current.mario_z
    end
    local p1 = project({
        x = start_x,
        y = start_y,
        z = start_z,
    })
    local p2 = project({
        x = end_x,
        y = end_y,
        z = end_z,
    })

    local offset = 30000 / p1.z
    local rect = {
        x = math.floor(p1.x - offset / 2),
        y = math.floor(p1.y - offset / 2),
        width = math.floor(offset),
        height = math.floor(offset),
    }
    if is_inside_frustum(p1) and is_inside_frustum(p2) then
        BreitbandGraphics.fill_ellipse(rect, { r = 255, g = 0, b = 0, a = 128 })
        BreitbandGraphics.draw_line(p1, p2, BreitbandGraphics.colors.blue, 4)
    end
end

WorldVisualizer.draw = function()
    if not Settings.worldviz_enabled then
        return
    end

    camera_depth = (Drawing.initial_size.height - 29) / (2 * math.tan(math.rad(Memory.current.camera_fov / 2)))
    camera_yaw = Memory.current.camera_yaw / 182.04
    camera_pitch = Memory.current.camera_pitch / 182.04

    local objects = get_objects()

    for _, o in pairs(objects) do
        local p = project(o);

        if not is_inside_frustum(p) then
            goto continue
        end

        local offset = 30000 / p.z

        local rect = {
            x = math.floor(p.x - offset / 2),
            y = math.floor(p.y - offset / 2),
            width = math.floor(offset),
            height = math.floor(offset),
        }

        BreitbandGraphics.draw_rectangle(rect, o.color or BreitbandGraphics.colors.red, 1)

        ::continue::
    end

    draw_moved_dist()
end
