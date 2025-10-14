--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local PRESETS_PATH <const> = 'presets.json'
local DEFAULT_PRESET <const> = ugui.internal.deep_clone(Settings)

Presets = {
    persistent = {
        current_index = 1,
        presets = {},
    },
}

Presets.persistent.presets[1] = ugui.internal.deep_clone(DEFAULT_PRESET)

---Applies the preset at the specified index.
---@param i integer
function Presets.apply(i)
    Presets.persistent.current_index = ugui.internal.clamp(i, 1, #Presets.persistent.presets)
    Settings = Presets.persistent.presets[Presets.persistent.current_index]
    Styles.update_style()
end

---Deletes and resets all presets, leaving only a default preset.
function Presets.delete_all()
    Presets.persistent.presets = { ugui.internal.deep_clone(DEFAULT_PRESET) }
    Presets.apply(Presets.persistent.current_index)
    print(Presets.persistent.current_index)
end

---Resets the preset at the specified index, applying it if it's the current one.
---@param i integer
function Presets.reset(i)
    Presets.persistent.presets[i] = ugui.internal.deep_clone(DEFAULT_PRESET)

    if Presets.persistent.current_index == i then
        Presets.apply(Presets.persistent.current_index)
    end
end

---Saves presets to disk.
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

---Loads presets from disk.
function Presets.load()
    print('Loading presets...')
    local file = io.open(PRESETS_PATH, 'r')
    if not file then
        return
    end
    local encoded = file:read('a')
    io.close(file)

    local deserialized = json.decode(encoded)

    deserialized = deep_merge(Presets.persistent, deserialized)

    Presets.persistent = deserialized
end

---Sets the preset index.
---@param i integer
function Presets.change_index(i)
    i = math.max(1, i)

    if #Presets.persistent.presets < i then
        Presets.persistent.presets[i] = ugui.internal.deep_clone(DEFAULT_PRESET)
    end

    Presets.persistent.current_index = i

    Presets.apply(i)
end
