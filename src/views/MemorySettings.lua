--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local UID = UIDProvider.allocate_once('MemorySettings', function(enum_next)
    return {
        LoadMapFile = enum_next(),
        Region = enum_next(2),
        AutoDetect = enum_next(),
        DetectOnStart = enum_next(),
    }
end)

return {
    name = Locales.str('SETTINGS_MEMORY_TAB_NAME'),
    draw = function()
        if ugui.button({
                uid = UID.LoadMapFile,
                rectangle = grid_rect(0, 0, 4, 1),
                text = Locales.str('SETTINGS_MEMORY_FILE_SELECT'),
                is_enabled = false,
            }) then
            local path = iohelper.filediag('*.map', 0)
            if string.len(path) > 0 then
                local file = io.open(path, 'r')
                local text = file:read('a')
                io.close(file)
                -- TODO: Implement
            end
        end

        Settings.address_source_index = ugui.combobox({
            uid = UID.Region,
            rectangle = grid_rect(4, 0, 4, 1),
            items = lualinq.select_key(Addresses, 'name'),
            selected_index = Settings.address_source_index,
            tooltip = 'The current game region',
        })

        if ugui.button({
                uid = UID.AutoDetect,
                rectangle = grid_rect(0, 1, 4, 1),
                text = Locales.str('SETTINGS_MEMORY_DETECT_NOW'),
                tooltip = 'Autodetects the game region based on the currently running game',
            }) then
            Settings.address_source_index = Memory.find_matching_address_source_index()
        end

        Settings.autodetect_address = ugui.toggle_button({
            uid = UID.DetectOnStart,
            rectangle = grid_rect(4, 1, 4, 1),
            text = Locales.str('SETTINGS_MEMORY_DETECT_ON_START'),
            is_checked = Settings.autodetect_address,
            tooltip = 'Autodetects the game region when starting the script',
        })
    end,
}
