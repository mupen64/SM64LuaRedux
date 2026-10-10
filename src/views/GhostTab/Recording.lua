--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('GhostRecording', function(enum_next)
    return {
        RecordingStatus = enum_next(ugui.label_uids()),
        RecordMario = enum_next(ugui.toggle_button_uids()),
        ObjectLabel = enum_next(ugui.label_uids()),
        RecordObject = enum_next(ugui.toggle_button_uids()),
        AddressLabel = enum_next(ugui.label_uids()),
        GhostObjectAddress = enum_next(ugui.textbox_uids()),
        RecordObjectByName = enum_next(ugui.toggle_button_uids()),
        ObjectList = enum_next(ugui.listbox_uids()),
        ObjectData = enum_next(ugui.listbox_uids()),
        GhostPath = enum_next(ugui.textbox_uids()),
        BrowseGhostPath = enum_next(ugui.button_uids()),
        RecordGhost = enum_next(ugui.toggle_button_uids()),
    }
end)

local previous_global_timer = nil
local was_recording_timer = 0
local SAVED_DISPLAY_TIME <const> = 300

-- the recorded object's data, read once per game frame rather than on every draw
local object_data_cache = { key = nil, items = nil }

local function object_varwatch_data()
    local mario_obj = Memory.current.mario_object_effective
    local addr = Ghosts.recording_object_address(mario_obj)
    local key = addr .. ':' .. Memory.current.global_timer
    if key ~= object_data_cache.key then
        object_data_cache.key = key
        local data = Ghosts.read_object(addr)
        object_data_cache.items = data and frame_varwatch_data(data)
            or { Locales.str('GHOST_INVALID_OBJECT') }
    end
    return object_data_cache.items
end

-- object list snapshot for the listbox, refreshed at most once per game frame
local select_object_by_name = false
local object_list = { objects = {}, items = {} }

local function shorten_path(text)
    local first = text:find('\\', 1, true)
    local second_last = text:find('\\[^\\]*\\[^\\]*$')
    if first and second_last and first < second_last then
        return text:sub(1, first) .. '...' .. text:sub(second_last)
    end
    return text
end

return {
    name = function() return Locales.str('GHOST_RECORDING_TAB_NAME') end,
    draw = function()
        local theme = Styles.theme()
        local foreground_color = Drawing.foreground_color()

        local status = Locales.str('GHOST_STATUS_IDLE')
        if Ghosts.is_recording() then
            status = Locales.str('GHOST_STATUS_RECORDING')
            was_recording_timer = SAVED_DISPLAY_TIME
        elseif was_recording_timer > 0 then
            status = Locales.str('GHOST_STATUS_SAVED')
            if previous_global_timer ~= Memory.current.global_timer then
                previous_global_timer = Memory.current.global_timer
                was_recording_timer = was_recording_timer - 1
            end
        end
        ugui.label({
            uid = UID.RecordingStatus,
            rectangle = grid_rect(0, 1, 2.5, 1),
            text = status,
            color = foreground_color,
            font_size = theme.font_size * 1.25,
            font_name = theme.font_name,
            align_x = ugui.alignment['start'],
            align_y = ugui.alignment.center,
        })

        -- toggle_button returns the checked state rather than a click, so act only when it flips
        local record = ugui.toggle_button({
            uid = UID.RecordGhost,
            rectangle = grid_rect(0.1, 1.85, 7.8, 1),
            text = Ghosts.is_recording() and Locales.str('GHOST_STOP') or Locales.str('GHOST_START'),
            tooltip = Locales.str('GHOST_RECORD_TOOLTIP'),
            is_checked = Ghosts.is_recording()
        })
        if record ~= Ghosts.is_recording() then
            if Ghosts.is_recording() then
                local result = Ghosts.stop_recording()
                if not result then
                    print(Locales.str('GHOST_STOP_RECORDING_FAILED'))
                end
            else
                local result = Ghosts.start_recording()
                if not result then
                    print(Locales.str('GHOST_START_RECORDING_FAILED'))
                end
            end
        end

        local path = Settings.ghost_path
        local is_focused = ugui.internal.keyboard_captured_control == UID.GhostPath
        if not is_focused then
            path = shorten_path(Settings.ghost_path)
        end
        path = ugui.textbox({
            uid = UID.GhostPath,
            rectangle = grid_rect(0.1, 2.85, 6.9, 0.8),
            text = path,
            tooltip = Locales.str('GHOST_PATH_TOOLTIP')
        })
        if is_focused then
            Settings.ghost_path = path
        end

        if ugui.button({
                uid = UID.BrowseGhostPath,
                rectangle = grid_rect(7.1, 2.85, 0.8, 0.8),
                text = "...",
                tooltip = Locales.str('GHOST_BROWSE_TOOLTIP'),
            }) then
            local path = iohelper.filediag("*.ghost", 1)
            if string.len(path) > 0 then
                Settings.ghost_path = path
            end
        end

        ugui.label({
            uid = UID.ObjectLabel,
            rectangle = grid_rect(0, 3.8, 2.5, 1),
            text = Locales.str('GHOST_OBJECT_LABEL'),
            color = foreground_color,
            font_size = theme.font_size * 1.25,
            font_name = theme.font_name,
            align_x = ugui.alignment['start'],
            align_y = ugui.alignment.center,
        })

        if ugui.toggle_button({
                uid = UID.RecordMario,
                rectangle = grid_rect(0.1, 4.6, 1.5, 1),
                text = Locales.str('GHOST_RECORD_MARIO'),
                tooltip = Locales.str('GHOST_RECORD_MARIO_TOOLTIP'),
                is_enabled = not Ghosts.is_recording(),
                is_checked = Ghosts.recording_mode == GhostRecordingModes.mario
            }) then
            Ghosts.recording_mode = GhostRecordingModes.mario
        end

        if ugui.toggle_button({
                uid = UID.RecordObject,
                rectangle = grid_rect(1.6, 4.6, 3.4, 1),
                text = Locales.str('GHOST_RECORD_OBJECT'),
                tooltip = Locales.str('GHOST_RECORD_OBJECT_TOOLTIP'),
                is_enabled = not Ghosts.is_recording(),
                is_checked = Ghosts.recording_mode == GhostRecordingModes.object and not select_object_by_name
            }) then
            Ghosts.recording_mode = GhostRecordingModes.object
            select_object_by_name = false
        end

        ugui.label({
            uid = UID.AddressLabel,
            rectangle = grid_rect(0.1, 5.6, 2, 1),
            text = Locales.str('GHOST_ADDRESS_LABEL'),
            color = foreground_color,
            font_size = theme.font_size * 1.25,
            font_name = theme.font_name,
            align_x = ugui.alignment['start'],
            align_y = ugui.alignment.center,
        })

        local new_obj_addr = tonumber(ugui.textbox({
            uid = UID.GhostObjectAddress,
            rectangle = grid_rect(2, 5.7, 3, 0.9),
            text = string.format("0x%X", Ghosts.object_address),
            tooltip = Locales.str('GHOST_OBJECT_ADDRESS_TOOLTIP'),
            styler_mixin = {
                font_size = theme.font_size * 1.25,
            },
            is_enabled = (Ghosts.recording_mode == GhostRecordingModes.object and
                not select_object_by_name and not Ghosts.is_recording())
        }):gsub("[^%x]", ""), 16)
        if new_obj_addr and new_obj_addr ~= Ghosts.object_address then
            Ghosts.object_address = new_obj_addr
        end

        if ugui.toggle_button({
                uid = UID.RecordObjectByName,
                rectangle = grid_rect(5, 4.6, 2.9, 1),
                text = Locales.str('GHOST_RECORD_OBJECT_BY_NAME'),
                tooltip = Locales.str('GHOST_RECORD_OBJECT_BY_NAME_TOOLTIP'),
                is_enabled = not Ghosts.is_recording(),
                is_checked = Ghosts.recording_mode == GhostRecordingModes.object and select_object_by_name
            }) then
            Ghosts.recording_mode = GhostRecordingModes.object
            select_object_by_name = true
        end

        local by_name_enabled = (Ghosts.recording_mode == GhostRecordingModes.object and
                select_object_by_name and not Ghosts.is_recording())
        -- Memory.update() flags the list as stale once per game frame, so this doesn't rescan on every draw.
        -- Also fill it once up front so Mario is listed before "Object by name" is picked
        if (by_name_enabled or #object_list.objects == 0) and Memory.objects_need_updating() then
            Memory.update_objects()
            object_list.objects = Memory.objects
            object_list.items = {}
            for i, obj in ipairs(object_list.objects) do
                object_list.items[i] = string.format('%s (0x%X)', obj.name, obj.address)
            end
        end
        local selected_object_index = nil
        for i, obj in ipairs(object_list.objects) do
            if Ghosts.recording_mode == GhostRecordingModes.mario then
                if obj.name == 'Mario' then
                    selected_object_index = i
                    break
                end
            elseif obj.address == Ghosts.object_address then
                selected_object_index = i
                break
            end
        end
        -- selection is tracked by address, so the list reordering between frames doesn't move it
        local new_object_index = ugui.listbox({
            uid = UID.ObjectList,
            rectangle = grid_rect(0, 6.6, 8, 5.3),
            items = object_list.items,
            selected_index = selected_object_index,
            tooltip = Locales.str('GHOST_OBJECT_LIST_TOOLTIP'),
            is_enabled = by_name_enabled,
        })
        if new_object_index and new_object_index ~= selected_object_index and object_list.objects[new_object_index] then
            Ghosts.object_address = object_list.objects[new_object_index].address
        end

        -- data of the object that would be recorded
        ugui.listbox({
            uid = UID.ObjectData,
            rectangle = grid_rect(0, 12, 8, 4),
            selected_index = nil,
            items = object_varwatch_data(),
        })
    end
}
