--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- Each field resolves to a symbol (or list of alternate names) + offset
-- `section` is the object file whose .bss start is used when no symbol is named (e.g. JP)
local MAP_FIELDS = {
    camera_fov = { symbol = 'sFOVState', offset = 0x4 },
    camera_angle = { symbol = 'gLakituState', offset = 0x7C },
    camera_transition_type = { symbol = 'gWarpTransition', offset = 0x1 },
    camera_transition_progress = { symbol = 'sTransitionColorFadeCount', offset = 0x0 },
    camera_flags = { symbol = 'gCameraMovementFlags', offset = 0x1 },
    camera_x = { symbol = 'gLakituState', offset = 0xC },
    camera_y = { symbol = 'gLakituState', offset = 0x10 },
    camera_z = { symbol = 'gLakituState', offset = 0x14 },
    camera_yaw = { symbol = 'gLakituState', offset = 0x4E },
    camera_pitch = { symbol = 'gLakituState', offset = 0x4C },
    holp_x = { symbol = 'gBodyStates', offset = 0x18 },
    holp_y = { symbol = 'gBodyStates', offset = 0x1C },
    holp_z = { symbol = 'gBodyStates', offset = 0x20 },
    timestop_enabled = { symbol = 'gTimeStopState', offset = 0x3 },
    play_mode = { symbol = 'sCurrPlayMode', offset = 0x0 },
    mario_facing_yaw = { symbol = 'gMarioStates', offset = 0x2E },
    mario_intended_yaw = { symbol = 'gMarioStates', offset = 0x24 },
    mario_h_speed = { symbol = 'gMarioStates', offset = 0x54 },
    mario_v_speed = { symbol = 'gMarioStates', offset = 0x4C },
    mario_x_sliding_speed = { symbol = 'gMarioStates', offset = 0x58 },
    mario_z_sliding_speed = { symbol = 'gMarioStates', offset = 0x5C },
    mario_x = { symbol = 'gMarioStates', offset = 0x3C },
    mario_y = { symbol = 'gMarioStates', offset = 0x40 },
    mario_z = { symbol = 'gMarioStates', offset = 0x44 },
    mario_pitch = { symbol = 'gMarioStates', offset = 0x2C },
    mario_yaw_vel = { symbol = 'gMarioStates', offset = 0x34 },
    mario_pitch_vel = { symbol = 'gMarioStates', offset = 0x32 },
    mario_object_pointer = { symbol = 'gMarioStates', offset = 0x88 },
    mario_object_effective = { symbol = 'gMarioObject', offset = 0x0 },
    mario_action = { symbol = 'gMarioStates', offset = 0xC },
    mario_action_arg = { symbol = 'gMarioStates', offset = 0x1C },
    mario_f_speed = { symbol = 'gMarioStates', offset = 0x54 },
    mario_buffered = { symbol = { '_osContCmdBuf', '__osContPifRam' }, section = 'osContStartReadData.o', offset = 0x4 },
    mario_held_buttons = { symbol = 'gControllerPads', offset = 0x0 },
    mario_pressed_buttons = { symbol = 'gControllers', offset = 0x13 },
    global_timer = { symbol = 'gGlobalTimer', offset = 0x0 },
    rng_value = { symbol = 'gRandomSeed16', section = 'behavior_script.o', offset = 0x0 },
    mario_hat_state = { symbol = 'gMarioStates', offset = 0x7 },
    game_vblank_queue = { symbol = 'gGameVblankQueue', offset = 0x0 },
    floor_address = { symbol = 'gMarioStates', offset = 0x68 },
    floor_yaw = { symbol = 'gMarioStates', offset = 0x74 },
    area_address = { symbol = 'gMarioStates', offset = 0x90 },
    s_segment_table_offset = { symbol = 'sSegmentTable', offset = 0x0 },
}

---Builds an `Addresses` entry from the text of a GNU ld .map file.
---@return table|nil, string|nil, table|nil # The entry, an error message, and fields grouped by any symbols that weren't found
local function parse_map_file(path, text)
    local symbols = {}
    local sections = {}
    for line in text:gmatch('[^\r\n]+') do
        local addr, name = line:match('^%s+0x(%x+)%s+([%a_][%w_]*)%s*$')
        if addr and not symbols[name] then
            symbols[name] = tonumber(addr, 16)
        end
        local bss_addr, file = line:match('^%s*%.bss%s+0x(%x+)%s+0x%x+%s+.-([^/\\()]+%.o)%)?%s*$')
        if bss_addr and not sections[file] then
            sections[file] = tonumber(bss_addr, 16)
        end
    end

    local file_name = path:match('([^/\\]+)$'):gsub('%.map$', '')
    local entry = {
        name = function() return file_name end,
        map_path = path,
        mario_animation = 0x38,
        mario_gfx_angle = 0xD6,
        floor_normal_offset = 0x1C,
        area_terrain_type_offset = 0x2,
        -- No ROM signature can be derived from a map, so autodetect never picks this entry
        pattern = 0,
        pattern_value = -1,
    }

    if not next(symbols) then
        return nil, 'No symbols found in ' .. file_name .. ', is it a linker .map file?'
    end

    -- Fields whose symbol isn't found point at 0, which reads harmlessly like a null object pointer does
    local missing = {}
    for field, spec in pairs(MAP_FIELDS) do
        local names = type(spec.symbol) == 'table' and spec.symbol or { spec.symbol }
        local base = lualinq.first(lualinq.select(names, function(n) return symbols[n] end), function(a) return a end)
            or (spec.section and sections[spec.section])
        if base then
            entry[field] = base + spec.offset
        else
            entry[field] = 0
            local key = table.concat(names, ' / ')
            missing[key] = missing[key] or {}
            table.insert(missing[key], field)
        end
    end
    return entry, nil, missing
end

-- Notifications is created after the views are loaded, so fall back to the console at startup
local function notify(text)
    if Notifications then
        Notifications.show(text)
    else
        print(text)
    end
end

---Parses the map file at `path` and adds it to `Addresses`, replacing any entry previously loaded from the same path.
---Logs details to the console, since notifications are too brief to list every missing symbol.
---@return integer|nil, string|nil, boolean|nil # The entry's index into `Addresses` and whether some values are missing, or nil and an error message
local function add_map_file(path)
    local file, open_err = io.open(path, 'r')
    if not file then
        local err = "Couldn't load map file: " .. tostring(open_err)
        print(err)
        return nil, err
    end
    local text = file:read('a')
    io.close(file)

    local ok, entry, err, missing = pcall(parse_map_file, path, text)
    if not ok or not entry then
        err = "Couldn't load map file: " .. tostring(ok and err or entry)
        print(err)
        return nil, err
    end

    local symbols = {}
    for symbol in pairs(missing) do
        symbols[#symbols + 1] = symbol
    end
    table.sort(symbols)
    if #symbols == 0 then
        print('Loaded map file ' .. path)
    else
        print(string.format("Loaded map file %s, but %d symbol(s) weren't found in it.", path, #symbols))
        print('These values will read as 0 and anything using them may not work:')
        for _, symbol in ipairs(symbols) do
            table.sort(missing[symbol])
            print(string.format('  %s: %s', symbol, table.concat(missing[symbol], ', ')))
        end
    end

    local index = #Addresses + 1
    for i, addr in ipairs(Addresses) do
        if addr.map_path == path then
            index = i
            break
        end
    end
    Addresses[index] = entry
    return index, nil, #symbols > 0
end

---Returns the preset's map file list, migrating the old single-path setting.
local function map_paths()
    if not Settings.address_map_paths then
        Settings.address_map_paths = { Settings.address_map_path }
        Settings.address_map_path = nil
    end
    return Settings.address_map_paths
end

-- rebuild custom map entries in Address from the preset's paths, keeping the selection by path
local function restore_map_files()
    -- Already loaded, e.g. when Presets.save re-applies the current preset
    local loaded_paths = {}
    for _, addr in ipairs(Addresses) do
        loaded_paths[#loaded_paths + 1] = addr.map_path
    end
    if table.concat(loaded_paths, '|') == table.concat(map_paths(), '|') then
        if not Addresses[Settings.address_source_index] then
            Settings.address_source_index = 1
        end
        return
    end

    -- Map entries always follow the built-ins in address_map_paths order, so the saved index maps to a path
    local builtin_count = #lualinq.where(Addresses, function(addr) return not addr.map_path end)
    local selected_path = map_paths()[Settings.address_source_index - builtin_count]

    for i = #Addresses, 1, -1 do
        if Addresses[i].map_path then
            table.remove(Addresses, i)
        end
    end

    -- Map entries are appended in preset order; paths that fail to load are dropped
    local loaded = {}
    for _, path in ipairs(map_paths()) do
        local _, err = add_map_file(path)
        if err then
            -- add_map_file already printed it, so only surface it on screen
            if Notifications then Notifications.show(err) end
        else
            loaded[#loaded + 1] = path
        end
    end
    Settings.address_map_paths = loaded

    if selected_path then
        Settings.address_source_index = 1
        for i, addr in ipairs(Addresses) do
            if addr.map_path == selected_path then
                Settings.address_source_index = i
            end
        end
    elseif not Addresses[Settings.address_source_index] then
        Settings.address_source_index = 1
    end
end

---Prompts for a map file, adds it to the preset's map files and selects it as the active address source.
local function load_map_file_dialog()
    local path = iohelper.filediag('*.map', 0)
    if not path or string.len(path) == 0 then
        return
    end
    local index, err, incomplete = add_map_file(path)
    if not index then
        notify(err .. ' (see console)')
        return
    end
    local paths = map_paths()
    if not lualinq.first(paths, function(p) return p == path end) then
        paths[#paths + 1] = path
    end
    Settings.address_source_index = index
    if incomplete then
        notify('Loaded map file ' .. Addresses[index].name() .. ', but some values may not work (see console)')
    else
        notify('Loaded map file ' .. Addresses[index].name())
    end
end

return {
    restore_map_files = restore_map_files,
    load_map_file_dialog = load_map_file_dialog,
}
