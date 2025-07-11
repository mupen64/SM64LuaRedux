--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local PRESETS_PATH <const> = 'presets.json'

local function create_default_preset()
    return ugui.internal.deep_clone(Settings)
end

local default_preset = create_default_preset()

Presets = {
    persistent = {
        current_index = 1,
        presets = {},
    },
}

print('Creating default presets...')

for i = 1, 6, 1 do
    Presets.persistent.presets[i] = create_default_preset()
end

function Presets.get_default_preset()
    return ugui.internal.deep_clone(default_preset)
end

function Presets.apply(i)
    -- HACK: The TASState isn't currently serialized properly.
    -- Here, the TASState contents are injected into the presets and are also restored when loading.
    for key, value in pairs(TASState) do
        Settings['tasstate_' .. key] = value
    end

    Presets.persistent.current_index = ugui.internal.clamp(i, 1, #Presets.persistent.presets)
    Settings = Presets.persistent.presets[Presets.persistent.current_index]
    Styles.update_style()

    -- HACK: See above
    if Settings.persist_tas_state then
        for key, value in pairs(TASState) do
            TASState[key] = Settings['tasstate_' .. key] == nil and NewTASState()[key] or Settings['tasstate_' .. key]
        end
    end
end

function Presets.reset(i)
    Presets.persistent.presets[i] = ugui.internal.deep_clone(default_preset)
end

function Presets.save()
    print('Saving preset...')
    Presets.apply(Presets.persistent.current_index)

    local encoded = json.encode(Presets.persistent)

    local file = io.open(PRESETS_PATH, 'w')
    if not file then
        print('Failed to save preset.')
        return
    end
    file:write(encoded)
    io.close(file)
end

function Presets.restore()
    print('Restoring presets...')

    local file = io.open(PRESETS_PATH, 'r')
    if not file then
        return
    end
    local encoded = file:read('a')
    io.close(file)

    local deserialized = json.decode(encoded)

    deserialized = deep_merge(Presets.persistent, deserialized)

    Presets.persistent = deserialized

    -- Purge all hotkeys which dont have a corresponding hotkey_funcs entry
    for _, preset in pairs(Presets.persistent.presets) do
        local hotkeys = ugui.internal.deep_clone(preset.hotkeys)
        for i, hotkey in pairs(hotkeys) do
            if not Hotkeys.exists(hotkey.identifier) then
                print(string.format("Hotkey %s doesn't exist anymore, purging it.", hotkey.identifier))
                table.remove(preset.hotkeys, i)
            end
        end
    end
end
