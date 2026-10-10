--
-- Copyright (c) 2026, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

GhostRecordingModes = {
    mario = 1,
    object = 2
}

Ghosts = {
    recording_mode = GhostRecordingModes.mario,
	object_address = 0x80330000,
    auto_apply_hack = false,
    base_offset = 0x8040
}

---@class GhostFrame
---@field global_timer integer
---@field x integer
---@field y integer
---@field z integer
---@field animation_index integer
---@field animation_timer integer
---@field pitch integer
---@field yaw integer
---@field roll integer

---@type GhostFrame[]
local frames = {}
local is_recording = false
local frame = 0
local recording_base_frame = nil
local last_global_timer = nil

local OBJECT_EXTRA_MAGIC <const> = 0x4F424A54
local non_mario_graphics = nil
local animation_switches = { }
local last_recorded_animation = nil

---@class VariableData
---@field type integer # see Ghosts.VARIABLE_TYPES
---@field label string # up to 15 bytes
---@field data any[] # one value per frame

-- variable block: magic, 15 byte label, 1 byte type, then one value of that type per frame
local VARWATCH_EXTRA_MAGIC <const> = 0x12345678
local VARIABLE_FORMATS <const> = {'<I2', '<I4', '<f'}
local VARIABLE_MASKS <const> = {0xFFFF, 0xFFFFFFFF}
Ghosts.VARIABLE_TYPES = {word = 1, int = 2, float = 3}

---@type VariableData[]
local recording_variables = {} -- the registered variables, snapshot when a recording starts
local variable_types = {} -- label to type map, for variables registered with Ghosts.record_variable
local variable_read_funcs = {} -- label to function map, where the function returns the current value

---@class Ghost
---@field filepath string
---@field data GhostFrame[]
---@field global_timer_start integer # the first frame of the data
---@field is_transparent boolean # when true, the ghost will have a vanish cap
---@field hat_color integer[3]
---@field graphics integer # the gfx pointer for an object or 0 for a Mario
---@field enabled boolean # when true, the ghost will be displayed
---@field variables VariableData[] # extra recorded data, each with one value per frame of `data`

-- ghosts loaded in (Lua) memory, in load order. Kept as an array since its order assigns the
-- hack's RAM slots, and pairs() over a table with removed keys can reorder them between frames
---@type Ghost[]
local ghosts = {}

local OBJ_POSITION_OFFSET <const> = 0x20
local OBJ_ANIMATION_ID_OFFSET <const> = 0x38
local OBJ_ANIMATION_OFFSET <const> = 0x3C
local OBJ_ANIMATION_TIMER_OFFSET <const> = 0x40
local OBJ_PITCH_OFFSET <const> = 0x1A
local OBJ_YAW_OFFSET <const> = 0x1C
local OBJ_ROLL_OFFSET <const> = 0x1E

local mario_hat_color = {0xFF, 0x00, 0x00}
local default_color_counter = 1
local DEFAULT_COLORS = {
    {255, 0, 0},
    {255, 127, 0},
    {255, 255, 0},
    {0, 255, 0},
    {0, 255, 255},
    {0, 0, 255},
    {255, 255, 255},
    {51, 51, 51}
}

-- the hack's tables are written for a region starting at 0x80400000 and moved to Ghosts.base_offset
local HACK_FILE_BASE <const> = 0x80400000
local MIN_BASE_OFFSET <const> = 0x8040 -- below this is the game's own memory
local MAX_BASE_OFFSET <const> = 0x806C -- the 15 animation buffers end at base + 0x13C000
local BASE_LUIS <const> = {0x44, 0x78, 0x190, 0x270} -- offsets to write "LUI Ghosts.base_offset" to
local BASE_PLUS_1_LUI <const> = 0xF8 -- offset to write "LUI Ghosts.base_offset + 1" to
local ANIMATION_BUFFER_LUI <const> = 0x50 -- offset to write "LUI Ghosts.base_offset + 0x10" to
local HAT_COLOR_LIGHTS_OFFSET <const> = 0x8300

local pending_base_offset = nil

---@return integer # the RAM address `offset` bytes into the hack's region
local function region(offset)
    return (Ghosts.base_offset << 16) + offset
end

-- jal ghost_loop, written into area_update_objects
local function hook_instruction()
    return 0x0C000000 | ((region(0x8000) & 0x03FFFFFF) >> 2)
end

local function writebytes32(f, x)
	local b4 = string.char(x % 256)
	x = (x - x % 256) / 256
	local b3 = string.char(x % 256)
	x = (x - x % 256) / 256
	local b2 = string.char(x % 256)
	x = (x - x % 256) / 256
	local b1 = string.char(x % 256)
	x = (x - x % 256) / 256
	f:write(b4, b3, b2, b1)
end

local function writebytes16(f, x)
	local b2 = string.char(x % 256)
	x = (x - x % 256) / 256
	local b1 = string.char(x % 256)
	x = (x - x % 256) / 256
	f:write(b2, b1)
end

local function writebytes(address, bytes)
    for i = 1, #bytes, 1 do
        memory.writebyte(address + i - 1, bytes[i])
    end
end

local function read_word(file)
    return string.unpack('<I2', file:read(2))
end

local function read_int(file) -- little endian
    return string.unpack('<I4', file:read(4))
end

local function read_float(file)
    return string.unpack('<f', file:read(4))
end

---@param file file*
---@param variables VariableData[]
local function write_variable_blocks(file, variables)
    for _, variable in ipairs(variables) do
        local format, mask = VARIABLE_FORMATS[variable.type], VARIABLE_MASKS[variable.type]
        local values = {}
        for i, value in ipairs(variable.data) do
            values[i] = string.pack(format, mask and (math.floor(value) & mask) or value)
        end
        file:write(string.pack('<I4c15B', VARWATCH_EXTRA_MAGIC, variable.label:sub(1, 15), variable.type),
            table.concat(values))
    end
end

---Writes the current ghost data to the disk.
---@return boolean # Whether the operation succeeded.
---@nodiscard
local function flush()
	local file = io.open(Settings.ghost_path, 'wb')

	if not file then
		return false
	end

	-- Recording is less than one frame long, so write nothing.
	if recording_base_frame == nil then
		file:close()
		return true
	end

	writebytes32(file, recording_base_frame)
	writebytes32(file, #frames)

	for _, value in pairs(frames) do
		writebytes32(file, (value.global_timer - recording_base_frame))
		writebytes32(file, value.x)
		writebytes32(file, value.y)
		writebytes32(file, value.z)
		writebytes16(file, value.animation_index)
		writebytes16(file, value.animation_timer)
		writebytes32(file, value.pitch)
		writebytes32(file, value.yaw)
		writebytes32(file, value.roll)
	end

	if non_mario_graphics and non_mario_graphics ~= 0 then
		writebytes32(file, OBJECT_EXTRA_MAGIC)
		writebytes32(file, non_mario_graphics)
		local count = 0
		for _ in pairs(animation_switches) do count = count + 1 end
		writebytes32(file, count)
		for k, v in pairs(animation_switches) do
			writebytes32(file, k)
			writebytes32(file, v)
		end
	end

	write_variable_blocks(file, recording_variables)

	file:close()

	return true
end

---Records an extra value with each frame, starting with the next recording.
---@param label string # up to 15 bytes, stored in the file
---@param datatype integer # see Ghosts.VARIABLE_TYPES
---@param read_func function # a function that reads game memory and returns the current value
function Ghosts.record_variable(label, datatype, read_func)
    variable_types[label] = datatype
    variable_read_funcs[label] = read_func
end

---@param label string
function Ghosts.stop_recording_variable(label)
    variable_types[label] = nil
    variable_read_funcs[label] = nil
end

---Appends a frame to the ghost recording if active.
local function update_recording()
	if frame == 0 then
		frame = frame + 1
	end

	local address_source = Addresses[Settings.address_source_index]
	local mario_obj = Ghosts.recording_object_address(memory.readdword(address_source.mario_object_effective))
	local global_timer = memory.readdword(address_source.global_timer)

	if recording_base_frame == nil then
		recording_base_frame = global_timer
	end

	if last_global_timer == nil or last_global_timer < global_timer then
		last_global_timer = global_timer
		frames[#frames + 1] = {
			global_timer = (global_timer - 1),
			pitch = memory.readword(mario_obj + OBJ_PITCH_OFFSET),
			yaw = memory.readword(mario_obj + OBJ_YAW_OFFSET),
			roll = memory.readword(mario_obj + OBJ_ROLL_OFFSET),
			x = memory.readdword(mario_obj + OBJ_POSITION_OFFSET),
			y = memory.readdword(mario_obj + OBJ_POSITION_OFFSET + 4),
			z = memory.readdword(mario_obj + OBJ_POSITION_OFFSET + 8),
			animation_index = memory.readword(mario_obj + OBJ_ANIMATION_ID_OFFSET),
			animation_timer = memory.readword(mario_obj + OBJ_ANIMATION_TIMER_OFFSET) - 1,
		}

		-- keyed like the frame offsets written by flush(), which is how STROOP looks them up
		local animation = memory.readdword(mario_obj + OBJ_ANIMATION_OFFSET)
		if animation ~= last_recorded_animation then
			last_recorded_animation = animation
			animation_switches[math.max(0, global_timer - 1 - recording_base_frame)] = animation
		end

        -- extra variable info
        for _, variable in ipairs(recording_variables) do
            variable.data[#variable.data + 1] = variable_read_funcs[variable.label]() or 0
        end
	end
end

---Stops the ghost recording.
---@return boolean # Whether the operation succeeded.
---@nodiscard
function Ghosts.stop_recording()
	if not is_recording then
		return true
	end

	local result = flush()
	local recorded_frames = #frames

	is_recording = false
	frames = {}
	frame = 0
	recording_base_frame = nil
	last_global_timer = nil

	if result and recorded_frames > 0 and Settings.ghost_recording_auto_load then
		Ghosts.load_ghost_file(Settings.ghost_path)
	end

	return result
end

---Starts a ghost recording.
---@return boolean # Whether the operation succeeded.
---@nodiscard
function Ghosts.start_recording()
	if is_recording then
		local result = Ghosts.stop_recording()
		if not result then
			return false
		end
	end

	is_recording = true
	-- Mario picked from the object list still records as Mario, not as an object with his model
	non_mario_graphics = 0
	local mario_obj = memory.readdword(Addresses[Settings.address_source_index].mario_object_effective)
	if Ghosts.recording_object_address(mario_obj) ~= mario_obj then
		non_mario_graphics = memory.readdword(Ghosts.object_address + 0x14)
	end
	animation_switches = {}
	last_recorded_animation = nil

	-- snapshot so variables (un)registered mid-recording can't misalign values with frames
	recording_variables = {}
	for label, datatype in pairs(variable_types) do
		recording_variables[#recording_variables + 1] = {label = label, type = datatype, data = {}}
	end
	table.sort(recording_variables, function(a, b) return a.label < b.label end)

	return true
end

---@param mario_obj integer # the address of Mario's object
---@return integer # the address of the object to record; Mario when not recording an object or the address is 0
function Ghosts.recording_object_address(mario_obj)
	if Ghosts.recording_mode == GhostRecordingModes.object and Ghosts.object_address ~= 0 then
		return Ghosts.object_address
	end
	return mario_obj
end

---Reads the recordable state of an object.
---@param addr integer
---@return table | nil # nil if the address isn't in RDRAM
function Ghosts.read_object(addr)
	if addr < 0x80000000 or addr >= 0x80800000 then
		return nil
	end
	return {
		position = {
			x = memory.readfloat(addr + OBJ_POSITION_OFFSET),
			y = memory.readfloat(addr + OBJ_POSITION_OFFSET + 4),
			z = memory.readfloat(addr + OBJ_POSITION_OFFSET + 8),
		},
		pitch = memory.readword(addr + OBJ_PITCH_OFFSET),
		yaw = memory.readword(addr + OBJ_YAW_OFFSET),
		roll = memory.readword(addr + OBJ_ROLL_OFFSET),
		animation_index = memory.readword(addr + OBJ_ANIMATION_ID_OFFSET),
		animation_frame = memory.readword(addr + OBJ_ANIMATION_TIMER_OFFSET),
		animation = memory.readdword(addr + OBJ_ANIMATION_OFFSET),
		graphics = memory.readdword(addr + 0x14),
	}
end

---@return boolean # Whether a ghost is being recorded.
---@nodiscard
function Ghosts.is_recording()
	return is_recording
end

---@return boolean # Whether the playback hack is supported on the current ROM
function Ghosts.hack_is_supported()
	local address_source = Addresses[Settings.address_source_index]
    local rom_name = address_source.name()
	return (
        address_source.vanilla_bank_04_offset ~= nil and
        address_source.s_segment_table_offset ~= nil and
        address_source.area_update_objects ~= nil and
        (rom_name == Locales.str('ADDRESS_USA') or
            rom_name == Locales.str('ADDRESS_JAPAN'))
    )
end

---@return boolean # Whether the ghost hack is in RAM
-- Note: this is a guess based on if the first jump instruction is present
function Ghosts.hack_is_applied()
    local address_source = Addresses[Settings.address_source_index]
    return memory.readdword(address_source.area_update_objects) == hook_instruction()
end

-- Source: https://github.com/FramePerfection/STROOP/blob/Development/STROOP/Tabs/GhostTab/ColoredHats.cs
local function enable_colored_hats()
	local address_source = Addresses[Settings.address_source_index]
    local offset = address_source.vanilla_bank_04_offset
    local size = 0x100000 - offset -- Rough estimate, relevant references should be in this range
    local bank_location = memory.readdword(address_source.s_segment_table_offset + 0x10) -- GetInt32

    for addr = bank_location, bank_location + size, 4 do
        local command = memory.readdword(addr) >> 16
        local found_pointer = memory.readdword(addr + 0x14) -- GetUInt32
        -- the original display list pointers, or ones already patched for a previous base offset
        if (command == 0x001B and (found_pointer == 0x40119A0 or
                found_pointer == 0x4011A90 or
                found_pointer == 0x4011B80 or
                found_pointer == 0x4012030)) or
            (command == 0x012A and (found_pointer & 0xFF00FFFF) == 0x80008200) then
            memory.writedword(addr + 0x14, region(0x8200))
            memory.writeword(addr, 0x12A)
        end
    end

    local jump_out_of_head_addr = 0x90580 + bank_location - offset + 0x8
    writebytes(jump_out_of_head_addr, {0xB8, 0, 0, 0, 0, 0, 0, 0})
    local offsetA = 0xF470C - bank_location

    -- Disable low poly Mario by finding the LOD threshold values and replacing them with the maximum distance (0x7fff) as appropriate
    for addr = bank_location, bank_location + size, 4 do
        local value = memory.readdword(addr) -- GetUInt32
        if value == 0x02580640 then
            memory.writedword(addr, 0x02587FFF)
        elseif value == 0x06407FFF then
            memory.writedword(addr, 0x7FFF7FFF)
        end
    end
end

local function clamp(x)
    return math.max(0, math.min(255, x))
end

local function color_to_lights(RGB)
    local R1 = clamp(RGB[1])
    local G1 = clamp(RGB[2])
    local B1 = clamp(RGB[3])
    local R2 = clamp(RGB[1] // 2)
    local G2 = clamp(RGB[2] // 2)
    local B2 = clamp(RGB[3] // 2)
    return {
          R2,   G2,   B2, 0x00,   R2,   G2,   B2, 0x00,
          R1,   G1,   B1, 0x00,   R1,   G1,   B1, 0x00,
        0x28, 0x28, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00,
    }
end

---@param ghost Ghost | nil # if nil is given, it uses Mario's hat color
---@param ghost_index integer # the order of the ghost in RAM (0 for Mario)
local function write_color_to_stream(ghost, ghost_index)
    local color = {204, 204, 204}
    if ghost then
        color = ghost.hat_color
    elseif mario_hat_color then
        color = mario_hat_color
    end
    local lights = color_to_lights(color)
    writebytes(region(HAT_COLOR_LIGHTS_OFFSET) + ghost_index * 0x20, lights)
end

local function read_ghost_frame(file)
    return {
        offset = read_int(file),
        position = {
            x = read_float(file),
            y = read_float(file),
            z = read_float(file)
        },
        animation_index = read_word(file),
        animation_frame = read_word(file),
        pitch = read_int(file),
        yaw = read_int(file),
        roll = read_int(file)
    }
end

---@param filepath string # the path to a .ghost file
---@return Ghost | nil # the newly loaded ghost, or nil if it fails
function Ghosts.load_ghost_file(filepath)
    local file = io.open(filepath, "rb")
	if file == nil then
		return nil
	end

    local ghost = {
        filepath = filepath,
        data = {},
        global_timer_start = 0,
        is_transparent = Settings.ghost_transparent_default or false,
        hat_color = {0, 0, 0},
        graphics = 0,
        enabled = true,
        variables = {},
    }

    -- ensure the file isn't truncated or empty
    local ok = pcall(function()
        ghost.global_timer_start = read_int(file)
        local num_frames = read_int(file)
        for i = 1, num_frames do
            ghost.data[i] = read_ghost_frame(file)
        end
    end)
    if not ok then
        file:close()
        return nil
    end

    -- extended ghost format with optional blocks
    while true do
        local magic = file:read(4)
        if not magic or #magic ~= 4 then
            break
        end
        magic = string.unpack('<I4', magic)

        local block_ok = true
        if magic == OBJECT_EXTRA_MAGIC then
            -- object block: graphics pointer and animation pointers keyed by frame offset
            -- pcall so a truncated block falls back to Mario instead of failing the load
            block_ok = pcall(function()
                local graphics = read_int(file)
                local count = read_int(file)
                local switches, first_key = {}, nil
                for _ = 1, count do
                    local key = read_int(file)
                    local value = read_int(file)
                    switches[key] = value
                    if first_key == nil or key < first_key then first_key = key end
                end
                -- resolve each frame's animation like STROOP: the latest switch, else the earliest one
                local animation = first_key and switches[first_key] or 0
                for _, f in ipairs(ghost.data) do
                    animation = switches[f.offset] or animation
                    f.animation = animation
                end
                ghost.graphics = graphics
            end)
        elseif magic == VARWATCH_EXTRA_MAGIC then
            -- varwatch block: extra data is included per frame
            block_ok = pcall(function()
                local label, datatype = string.unpack('c15B', file:read(16))
                local format = assert(VARIABLE_FORMATS[datatype])
                local size = string.packsize(format)
                local variable = {label = label:gsub('%z+$', ''), type = datatype, data = {}}
                for i = 1, #ghost.data do
                    variable.data[i] = string.unpack(format, file:read(size))
                end
                ghost.variables[#ghost.variables + 1] = variable
            end)
        else
            break -- unknown block
        end
        if not block_ok then
            break -- the rest of the file can't be located after a truncated block
        end
    end

    -- give Mario ghosts a new hat color (rotating default selection)
    if ghost.graphics == 0 then
        ghost.hat_color = DEFAULT_COLORS[default_color_counter + 1]
    	default_color_counter = (default_color_counter + 1) % #DEFAULT_COLORS
    end

	file:close()
	ghosts[#ghosts + 1] = ghost
	return ghost
end

---Writes a loaded ghost to a .ghost file, starting on its current global timer start.
---@param ghost Ghost # the ghost to save. Note: ghost.filepath will be updated
---@param filepath string # location to save the file to
---@return boolean # whether the file was written
function Ghosts.save_ghost_file(ghost, filepath)
    local data = ghost.data
    local file = data and io.open(filepath, 'wb')
    if not file then
        return false
    end
    file:write(string.pack('<I4I4', ghost.global_timer_start, #data))
    for _, f in ipairs(data) do
        file:write(string.pack('<I4fffI2I2I4I4I4', f.offset, f.position.x, f.position.y, f.position.z,
            f.animation_index, f.animation_frame, f.pitch, f.yaw, f.roll))
    end
    -- object block: only the frames where the animation changes are stored
    local graphics = ghost.graphics
    if graphics ~= 0 then
        local switches, last = {}, nil
        for _, f in ipairs(data) do
            if f.animation ~= last then
                switches[#switches + 1] = string.pack('<I4I4', f.offset, f.animation or 0)
                last = f.animation
            end
        end
        file:write(string.pack('<I4I4I4', OBJECT_EXTRA_MAGIC, graphics, #switches), table.concat(switches))
    end
    write_variable_blocks(file, ghost.variables)
    file:close()
    ghost.filepath = filepath
    return true
end

---Clears the ghost from memory (but not from game RAM)
---@param ghost Ghost
function Ghosts.unload_ghost(ghost)
    ghost.data = nil
    for i, loaded in ipairs(ghosts) do
        if loaded == ghost then
            table.remove(ghosts, i)
            return
        end
    end
end

-- ghost_loop's "no ghosts requested" branch (0x80408084) is retargeted from @CLEAN_UP_EARLY to
-- "delete leftover ghosts": the former zeroes the next slot's pointer instead of the freed one,
-- leaving the last ghost's pointer dangling.
local HACKS_US = {
    [0x8027B188] = {
        0x0C, 0x10, 0x20, 0x00
    },
    [0x80408000] = {
        0x27, 0xBD, 0xFF, 0xC0, 0x3C, 0x08, 0x80, 0x36, 0x8D, 0x08, 0x11, 0x58,
        0x10, 0x08, 0x00, 0x73, 0xAF, 0xBF, 0x00, 0x34, 0xAF, 0xB4, 0x00, 0x30,
        0xAF, 0xB3, 0x00, 0x2C, 0xAF, 0xB2, 0x00, 0x28, 0xAF, 0xB1, 0x00, 0x24,
        0xAF, 0xB0, 0x00, 0x20, 0x00, 0x08, 0xA0, 0x25, 0x86, 0x88, 0x00, 0x02,
        0x31, 0x09, 0x00, 0x40, 0x15, 0x20, 0x00, 0x06, 0x35, 0x09, 0x00, 0x40,
        0xA6, 0x89, 0x00, 0x02, 0x10, 0x00, 0x00, 0x60, 0x3C, 0x11, 0x80, 0x40,
        0x10, 0x00, 0x00, 0x5B, 0x36, 0x31, 0x7F, 0xF8, 0x3C, 0x13, 0x80, 0x50,
        0x3C, 0x18, 0x80, 0x37, 0x34, 0x01, 0x00, 0xBD, 0xA7, 0x01, 0x05, 0xA8,
        0x37, 0x01, 0x05, 0xB8, 0xAF, 0x01, 0x05, 0x98, 0x3C, 0x01, 0x80, 0x06,
        0x24, 0x21, 0x40, 0x40, 0xAF, 0x01, 0x05, 0xB8, 0x00, 0x00, 0x80, 0x25,
        0x3C, 0x01, 0x80, 0x40, 0x34, 0x31, 0x7F, 0xF8, 0x80, 0x21, 0x7F, 0xFF,
        0x10, 0x01, 0x00, 0x47, 0x00, 0x00, 0x00, 0x00, 0x8E, 0x28, 0x00, 0x00,
        0x15, 0x00, 0x00, 0x0E, 0x00, 0x00, 0x20, 0x25, 0x26, 0x25, 0xFF, 0x9C,
        0x8E, 0x86, 0x00, 0x14, 0x3C, 0x07, 0x80, 0x38, 0x34, 0xE1, 0x5F, 0xDC,
        0xAF, 0xA1, 0x00, 0x10, 0x34, 0xE1, 0x5F, 0xE4, 0xAF, 0xA1, 0x00, 0x14,
        0x0C, 0x0D, 0xEE, 0x78, 0x34, 0xE7, 0x5F, 0xD0, 0xAE, 0x22, 0x00, 0x00,
        0x8E, 0x84, 0x00, 0x0C, 0x0C, 0x0D, 0xF0, 0x11, 0x00, 0x40, 0x28, 0x25,
        0x8E, 0x32, 0x00, 0x00, 0x82, 0x89, 0x00, 0x18, 0xA2, 0x49, 0x00, 0x18,
        0x8E, 0x89, 0x00, 0x38, 0xAE, 0x49, 0x00, 0x38, 0x3C, 0x01, 0x80, 0x33,
        0x8C, 0x28, 0xD5, 0xD4, 0x31, 0x08, 0x00, 0x7F, 0x00, 0x08, 0x41, 0x40,
        0x00, 0x10, 0x4B, 0x00, 0x01, 0x09, 0x40, 0x21, 0x3C, 0x01, 0x80, 0x41,
        0x01, 0x01, 0x40, 0x21, 0x25, 0x08, 0x9B, 0x00, 0x8D, 0x09, 0x00, 0x00,
        0xAE, 0x49, 0x00, 0x20, 0x8D, 0x09, 0x00, 0x04, 0xAE, 0x49, 0x00, 0x24,
        0x8D, 0x09, 0x00, 0x08, 0xAE, 0x49, 0x00, 0x28, 0x85, 0x09, 0x00, 0x10,
        0xA6, 0x49, 0x00, 0x1A, 0x85, 0x09, 0x00, 0x12, 0xA6, 0x49, 0x00, 0x1C,
        0x85, 0x09, 0x00, 0x14, 0xA6, 0x49, 0x00, 0x1E, 0x8D, 0x09, 0x00, 0x18,
        0x8D, 0x0B, 0x00, 0x0C, 0x15, 0x20, 0x00, 0x0F, 0x85, 0x0A, 0x00, 0x16,
        0x3C, 0x18, 0x80, 0x37, 0xAF, 0x12, 0x05, 0x80, 0xAF, 0x13, 0x05, 0xC0,
        0xA7, 0xAA, 0x00, 0x38, 0x37, 0x04, 0x04, 0xF8, 0xA6, 0x40, 0x00, 0x38,
        0xAF, 0x00, 0x05, 0xBC, 0x0C, 0x09, 0x42, 0x6E, 0x8D, 0x05, 0x00, 0x0C,
        0x87, 0xAA, 0x00, 0x38, 0x8E, 0x89, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00,
        0x10, 0x00, 0x00, 0x02, 0x26, 0x73, 0x40, 0x00, 0xAE, 0x4B, 0x00, 0x3C,
        0xAE, 0x49, 0x00, 0x14, 0xA6, 0x4A, 0x00, 0x40, 0x26, 0x31, 0xFF, 0x98,
        0x26, 0x10, 0x00, 0x01, 0x3C, 0x01, 0x80, 0x40, 0x80, 0x21, 0x7F, 0xFF,
        0x02, 0x01, 0x40, 0x2B, 0x15, 0x00, 0xFF, 0xBB, 0xA2, 0x50, 0x00, 0x60,
        0x8E, 0x32, 0x00, 0x00, 0x12, 0x40, 0x00, 0x06, 0x00, 0x12, 0x20, 0x25,
        0x0C, 0x0D, 0xF0, 0x2F, 0xAE, 0x20, 0x00, 0x00, 0x8E, 0x24, 0x00, 0x00,
        0x14, 0x80, 0xFF, 0xFC, 0x26, 0x31, 0xFF, 0x98, 0x8F, 0xBF, 0x00, 0x34,
        0x8F, 0xB4, 0x00, 0x30, 0x8F, 0xB3, 0x00, 0x2C, 0x8F, 0xB2, 0x00, 0x28,
        0x8F, 0xB1, 0x00, 0x24, 0x8F, 0xB0, 0x00, 0x20, 0x03, 0xE0, 0x00, 0x08,
        0x27, 0xBD, 0x00, 0x40
    },
    [0x80408200] = {
        0x27, 0xBD, 0xFF, 0xC0, 0xAF, 0xBF, 0x00, 0x14, 0x3C, 0x09, 0x04, 0x01,
        0x35, 0x28, 0x19, 0xA0, 0x3C, 0x01, 0x80, 0x36, 0x8C, 0x21, 0x11, 0x58,
        0x3C, 0x18, 0x80, 0x33, 0x8F, 0x18, 0xDF, 0x00, 0x13, 0x01, 0x00, 0x02,
        0x00, 0x00, 0x50, 0x25, 0x83, 0x0A, 0x00, 0x60, 0x35, 0x29, 0x19, 0x78,
        0xAF, 0xA8, 0x00, 0x18, 0xAF, 0xA9, 0x00, 0x1C, 0xAF, 0xAA, 0x00, 0x20,
        0x24, 0x01, 0x00, 0x01, 0x14, 0x24, 0x00, 0x1B, 0x34, 0x04, 0x00, 0x38,
        0x0C, 0x09, 0xE3, 0xCB, 0x00, 0x00, 0x00, 0x00, 0x3C, 0x0C, 0x06, 0x00,
        0xAC, 0x4C, 0x00, 0x10, 0x8F, 0xA1, 0x00, 0x18, 0xAC, 0x41, 0x00, 0x14,
        0x3C, 0x01, 0x03, 0x88, 0x34, 0x21, 0x00, 0x10, 0xAC, 0x41, 0x00, 0x18,
        0xAC, 0x41, 0x00, 0x00, 0x3C, 0x08, 0x80, 0x40, 0x35, 0x08, 0x83, 0x00,
        0x8F, 0xA9, 0x00, 0x20, 0x00, 0x09, 0x49, 0x40, 0x01, 0x28, 0x50, 0x21,
        0xAC, 0x4A, 0x00, 0x1C, 0xAC, 0x4A, 0x00, 0x04, 0x3C, 0x01, 0x03, 0x86,
        0x34, 0x21, 0x00, 0x10, 0xAC, 0x41, 0x00, 0x20, 0xAC, 0x41, 0x00, 0x08,
        0x25, 0x4B, 0x00, 0x08, 0xAC, 0x4B, 0x00, 0x24, 0xAC, 0x4B, 0x00, 0x0C,
        0xAC, 0x4C, 0x00, 0x28, 0x8F, 0xA8, 0x00, 0x1C, 0xAC, 0x48, 0x00, 0x2C,
        0x3C, 0x01, 0xB8, 0x00, 0xAC, 0x41, 0x00, 0x30, 0x8F, 0xBF, 0x00, 0x14,
        0x03, 0xE0, 0x00, 0x08, 0x27, 0xBD, 0x00, 0x40
    },
    [0x80277988] = {
        0x3C, 0x09, 0x80, 0x34, 0x25, 0x2A, 0xB1, 0x70, 0x3C, 0x19, 0x80, 0x33,
        0x8F, 0x39, 0xDF, 0x00, 0x3C, 0x01, 0x80, 0x36, 0x8C, 0x21, 0x11, 0x58,
        0x17, 0x21, 0x00, 0x57, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    },
    [0x8027719C] = {
        0x34, 0x0C, 0x00, 0x01
    },
    [0x802770A4] = {
        0x27, 0xBD, 0xFF, 0xD0, 0xAF, 0xBF, 0x00, 0x14, 0x24, 0x01, 0x00, 0x01,
        0x14, 0x81, 0x00, 0x1A, 0x00, 0x00, 0x10, 0x25, 0x00, 0xA0, 0x20, 0x25,
        0x3C, 0x08, 0x80, 0x34, 0x25, 0x08, 0xB3, 0xB0, 0x8C, 0xB8, 0x00, 0x18,
        0x00, 0x18, 0xC8, 0x80, 0x03, 0x38, 0xC8, 0x21, 0x00, 0x19, 0xC8, 0xC0,
        0x03, 0x28, 0x48, 0x21, 0x3C, 0x08, 0x80, 0x33, 0x8D, 0x08, 0xDF, 0x00,
        0x3C, 0x01, 0x80, 0x36, 0x8C, 0x21, 0x11, 0x58, 0x15, 0x01, 0x00, 0x06,
        0x85, 0x2C, 0x00, 0x08, 0x31, 0x8D, 0x01, 0x00, 0x11, 0xA0, 0x00, 0x07,
        0x34, 0x05, 0x00, 0xFF, 0x10, 0x00, 0x00, 0x05, 0x31, 0x85, 0x00, 0xFF,
        0x81, 0x18, 0x00, 0x61, 0x13, 0x00, 0x00, 0x02, 0x34, 0x05, 0x00, 0xFF,
        0x34, 0x05, 0x00, 0x7F, 0x0C, 0x09, 0xDB, 0xE4, 0x00, 0x00, 0x00, 0x00,
        0x8F, 0xBF, 0x00, 0x14, 0x03, 0xE0, 0x00, 0x08, 0x27, 0xBD, 0x00, 0x30
    },
    [0x802776D8] = {
        0x3C, 0x08, 0x80, 0x33, 0x8D, 0x08, 0xDF, 0x00, 0x3C, 0x01, 0x80, 0x36,
        0x8C, 0x21, 0x11, 0x58, 0x15, 0x01, 0x00, 0x05, 0x3C, 0x19, 0x80, 0x34,
        0x87, 0x2A, 0xB3, 0xB8, 0x00, 0x0A, 0x52, 0x02, 0x10, 0x00, 0x00, 0x03,
        0xA4, 0xAA, 0x00, 0x1E, 0x81, 0x0A, 0x00, 0x61, 0xA4, 0xAA, 0x00, 0x1E,
        0x03, 0xE0, 0x00, 0x08, 0x00, 0x00, 0x10, 0x25
    },
}

local HACKS_JP = {
    [0x8027ABD8] = {
        0x0C, 0x10, 0x20, 0x00
    },
    [0x80408000] = {
        0x27, 0xBD, 0xFF, 0xC0, 0x3C, 0x08, 0x80, 0x36, 0x8D, 0x08, 0xFD, 0xE8,
        0x10, 0x08, 0x00, 0x73, 0xAF, 0xBF, 0x00, 0x34, 0xAF, 0xB4, 0x00, 0x30,
        0xAF, 0xB3, 0x00, 0x2C, 0xAF, 0xB2, 0x00, 0x28, 0xAF, 0xB1, 0x00, 0x24,
        0xAF, 0xB0, 0x00, 0x20, 0x00, 0x08, 0xA0, 0x25, 0x86, 0x88, 0x00, 0x02,
        0x31, 0x09, 0x00, 0x40, 0x15, 0x20, 0x00, 0x06, 0x35, 0x09, 0x00, 0x40,
        0xA6, 0x89, 0x00, 0x02, 0x10, 0x00, 0x00, 0x60, 0x3C, 0x11, 0x80, 0x40,
        0x10, 0x00, 0x00, 0x5B, 0x36, 0x31, 0x7F, 0xF8, 0x3C, 0x13, 0x80, 0x50,
        0x3C, 0x18, 0x80, 0x37, 0x34, 0x01, 0x00, 0xBD, 0xA7, 0x01, 0x05, 0xA8,
        0x37, 0x01, 0x05, 0xB8, 0xAF, 0x01, 0x05, 0x98, 0x3C, 0x01, 0x80, 0x06,
        0x24, 0x21, 0x40, 0x40, 0xAF, 0x01, 0x05, 0xB8, 0x00, 0x00, 0x80, 0x25,
        0x3C, 0x01, 0x80, 0x40, 0x34, 0x31, 0x7F, 0xF8, 0x80, 0x21, 0x7F, 0xFF,
        0x10, 0x01, 0x00, 0x47, 0x00, 0x00, 0x00, 0x00, 0x8E, 0x28, 0x00, 0x00,
        0x15, 0x00, 0x00, 0x0E, 0x00, 0x00, 0x20, 0x25, 0x26, 0x25, 0xFF, 0x9C,
        0x8E, 0x86, 0x00, 0x14, 0x3C, 0x07, 0x80, 0x38, 0x34, 0xE1, 0x5F, 0xDC,
        0xAF, 0xA1, 0x00, 0x10, 0x34, 0xE1, 0x5F, 0xE4, 0xAF, 0xA1, 0x00, 0x14,
        0x0C, 0x0D, 0xEE, 0x78, 0x34, 0xE7, 0x5F, 0xD0, 0xAE, 0x22, 0x00, 0x00,
        0x8E, 0x84, 0x00, 0x0C, 0x0C, 0x0D, 0xF0, 0x11, 0x00, 0x40, 0x28, 0x25,
        0x8E, 0x32, 0x00, 0x00, 0x82, 0x89, 0x00, 0x18, 0xA2, 0x49, 0x00, 0x18,
        0x8E, 0x89, 0x00, 0x38, 0xAE, 0x49, 0x00, 0x38, 0x3C, 0x01, 0x80, 0x33,
        0x8C, 0x28, 0xC6, 0x94, 0x31, 0x08, 0x00, 0x7F, 0x00, 0x08, 0x41, 0x40,
        0x00, 0x10, 0x4B, 0x00, 0x01, 0x09, 0x40, 0x21, 0x3C, 0x01, 0x80, 0x41,
        0x01, 0x01, 0x40, 0x21, 0x25, 0x08, 0x9B, 0x00, 0x8D, 0x09, 0x00, 0x00,
        0xAE, 0x49, 0x00, 0x20, 0x8D, 0x09, 0x00, 0x04, 0xAE, 0x49, 0x00, 0x24,
        0x8D, 0x09, 0x00, 0x08, 0xAE, 0x49, 0x00, 0x28, 0x85, 0x09, 0x00, 0x10,
        0xA6, 0x49, 0x00, 0x1A, 0x85, 0x09, 0x00, 0x12, 0xA6, 0x49, 0x00, 0x1C,
        0x85, 0x09, 0x00, 0x14, 0xA6, 0x49, 0x00, 0x1E, 0x8D, 0x09, 0x00, 0x18,
        0x8D, 0x0B, 0x00, 0x0C, 0x15, 0x20, 0x00, 0x0F, 0x85, 0x0A, 0x00, 0x16,
        0x3C, 0x18, 0x80, 0x37, 0xAF, 0x12, 0x05, 0x80, 0xAF, 0x13, 0x05, 0xC0,
        0xA7, 0xAA, 0x00, 0x38, 0x37, 0x04, 0x04, 0xF8, 0xA6, 0x40, 0x00, 0x38,
        0xAF, 0x00, 0x05, 0xBC, 0x0C, 0x09, 0x41, 0xFA, 0x8D, 0x05, 0x00, 0x0C,
        0x87, 0xAA, 0x00, 0x38, 0x8E, 0x89, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00,
        0x10, 0x00, 0x00, 0x02, 0x26, 0x73, 0x40, 0x00, 0xAE, 0x4B, 0x00, 0x3C,
        0xAE, 0x49, 0x00, 0x14, 0xA6, 0x4A, 0x00, 0x40, 0x26, 0x31, 0xFF, 0x98,
        0x26, 0x10, 0x00, 0x01, 0x3C, 0x01, 0x80, 0x40, 0x80, 0x21, 0x7F, 0xFF,
        0x02, 0x01, 0x40, 0x2B, 0x15, 0x00, 0xFF, 0xBB, 0xA2, 0x50, 0x00, 0x60,
        0x8E, 0x32, 0x00, 0x00, 0x12, 0x40, 0x00, 0x06, 0x00, 0x12, 0x20, 0x25,
        0x0C, 0x0D, 0xF0, 0x2F, 0xAE, 0x20, 0x00, 0x00, 0x8E, 0x24, 0x00, 0x00,
        0x14, 0x80, 0xFF, 0xFC, 0x26, 0x31, 0xFF, 0x98, 0x8F, 0xBF, 0x00, 0x34,
        0x8F, 0xB4, 0x00, 0x30, 0x8F, 0xB3, 0x00, 0x2C, 0x8F, 0xB2, 0x00, 0x28,
        0x8F, 0xB1, 0x00, 0x24, 0x8F, 0xB0, 0x00, 0x20, 0x03, 0xE0, 0x00, 0x08,
        0x27, 0xBD, 0x00, 0x40
    },
    [0x80408200] = {
        0x27, 0xBD, 0xFF, 0xC0, 0xAF, 0xBF, 0x00, 0x14, 0x3C, 0x09, 0x04, 0x01,
        0x35, 0x28, 0x19, 0xA0, 0x3C, 0x01, 0x80, 0x36, 0x8C, 0x21, 0xFD, 0xE8,
        0x3C, 0x18, 0x80, 0x33, 0x8F, 0x18, 0xCF, 0xA0, 0x13, 0x01, 0x00, 0x02,
        0x00, 0x00, 0x50, 0x25, 0x83, 0x0A, 0x00, 0x60, 0x35, 0x29, 0x19, 0x78,
        0xAF, 0xA8, 0x00, 0x18, 0xAF, 0xA9, 0x00, 0x1C, 0xAF, 0xAA, 0x00, 0x20,
        0x24, 0x01, 0x00, 0x01, 0x14, 0x24, 0x00, 0x1B, 0x34, 0x04, 0x00, 0x38,
        0x0C, 0x09, 0xE2, 0x5F, 0x00, 0x00, 0x00, 0x00, 0x3C, 0x0C, 0x06, 0x00,
        0xAC, 0x4C, 0x00, 0x10, 0x8F, 0xA1, 0x00, 0x18, 0xAC, 0x41, 0x00, 0x14,
        0x3C, 0x01, 0x03, 0x88, 0x34, 0x21, 0x00, 0x10, 0xAC, 0x41, 0x00, 0x18,
        0xAC, 0x41, 0x00, 0x00, 0x3C, 0x08, 0x80, 0x40, 0x35, 0x08, 0x83, 0x00,
        0x8F, 0xA9, 0x00, 0x20, 0x00, 0x09, 0x49, 0x40, 0x01, 0x28, 0x50, 0x21,
        0xAC, 0x4A, 0x00, 0x1C, 0xAC, 0x4A, 0x00, 0x04, 0x3C, 0x01, 0x03, 0x86,
        0x34, 0x21, 0x00, 0x10, 0xAC, 0x41, 0x00, 0x20, 0xAC, 0x41, 0x00, 0x08,
        0x25, 0x4B, 0x00, 0x08, 0xAC, 0x4B, 0x00, 0x24, 0xAC, 0x4B, 0x00, 0x0C,
        0xAC, 0x4C, 0x00, 0x28, 0x8F, 0xA8, 0x00, 0x1C, 0xAC, 0x48, 0x00, 0x2C,
        0x3C, 0x01, 0xB8, 0x00, 0xAC, 0x41, 0x00, 0x30, 0x8F, 0xBF, 0x00, 0x14,
        0x03, 0xE0, 0x00, 0x08, 0x27, 0xBD, 0x00, 0x40
    },
    [0x802773D8] = {
        0x3C, 0x09, 0x80, 0x33, 0x35, 0x2A, 0x9E, 0x00, 0x3C, 0x19, 0x80, 0x33,
        0x8F, 0x39, 0xCF, 0xA0, 0x3C, 0x01, 0x80, 0x36, 0x8C, 0x21, 0xFD, 0xE8,
        0x17, 0x21, 0x00, 0x57, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    },
    [0x80276BEC] = {
        0x34, 0x0C, 0x00, 0x01
    },
    [0x80276AF4] = {
        0x27, 0xBD, 0xFF, 0xD0, 0xAF, 0xBF, 0x00, 0x14, 0x24, 0x01, 0x00, 0x01,
        0x14, 0x81, 0x00, 0x1A, 0x00, 0x00, 0x10, 0x25, 0x00, 0xA0, 0x20, 0x25,
        0x3C, 0x08, 0x80, 0x34, 0x25, 0x08, 0xA0, 0x40, 0x8C, 0xB8, 0x00, 0x18,
        0x00, 0x18, 0xC8, 0x80, 0x03, 0x38, 0xC8, 0x21, 0x00, 0x19, 0xC8, 0xC0,
        0x03, 0x28, 0x48, 0x21, 0x3C, 0x08, 0x80, 0x33, 0x8D, 0x08, 0xCF, 0xA0,
        0x3C, 0x01, 0x80, 0x36, 0x8C, 0x21, 0xFD, 0xE8, 0x15, 0x01, 0x00, 0x06,
        0x85, 0x2C, 0x00, 0x08, 0x31, 0x8D, 0x01, 0x00, 0x11, 0xA0, 0x00, 0x07,
        0x34, 0x05, 0x00, 0xFF, 0x10, 0x00, 0x00, 0x05, 0x31, 0x85, 0x00, 0xFF,
        0x81, 0x18, 0x00, 0x61, 0x13, 0x00, 0x00, 0x02, 0x34, 0x05, 0x00, 0xFF,
        0x34, 0x05, 0x00, 0x7F, 0x0C, 0x09, 0xDA, 0x78, 0x00, 0x00, 0x00, 0x00,
        0x8F, 0xBF, 0x00, 0x14, 0x03, 0xE0, 0x00, 0x08, 0x27, 0xBD, 0x00, 0x30
    },
    [0x80277128] = {
        0x3C, 0x08, 0x80, 0x33, 0x8D, 0x08, 0xCF, 0xA0, 0x3C, 0x01, 0x80, 0x36,
        0x8C, 0x21, 0xFD, 0xE8, 0x15, 0x01, 0x00, 0x05, 0x3C, 0x19, 0x80, 0x34,
        0x87, 0x2A, 0xA0, 0x48, 0x00, 0x0A, 0x52, 0x02, 0x10, 0x00, 0x00, 0x03,
        0xA4, 0xAA, 0x00, 0x1E, 0x81, 0x0A, 0x00, 0x61, 0xA4, 0xAA, 0x00, 0x1E,
        0x03, 0xE0, 0x00, 0x08, 0x00, 0x00, 0x10, 0x25
    }
}

---Moves the hack's RAM region (e.g. 0x8060 for 0x80600000). While the hack is in RAM the move is
---deferred until its ghosts are freed, otherwise they'd be orphaned in the scene graph.
---@param base integer
---@return boolean # whether the offset was valid
function Ghosts.set_base_offset(base)
    if base < MIN_BASE_OFFSET or base > MAX_BASE_OFFSET then
        return false
    end
    if base == Ghosts.base_offset or not Ghosts.hack_is_applied() then
        Ghosts.base_offset = base
        pending_base_offset = nil
    else
        pending_base_offset = base -- Ghosts.update finishes the move
    end
    return true
end

---@return integer | nil # the base offset the hack is moving to once its ghosts are freed
function Ghosts.get_pending_base_offset()
    return pending_base_offset
end

--[[
    Body state hooks: Mario's geo callbacks read gBodyStates[0] for every node drawn with his
    model, so ghosts copied the real Mario's kick/punch scaling, torso tilt and head rotation.
    Each hook jumps to a wrapper that applies neutral values when the node being drawn is a
    ghost (GraphNodeObjects inlined at region 0x7000-0x7FFF), else runs the original.
]]

local BODY_HOOKS_OFFSET <const> = 0x8800 -- free space between the hat lights and the frame buffers
local BODY_HOOK_STRIDE <const> = 0x50
local NOP <const> = 0x00000000
local NEUTRAL_SCALE <const> = {0x3C0C3F80, 0xAD6C0018, NOP} -- scaleNode->scale = 1.0f
local NEUTRAL_ROTATION <const> = {0xA5600018, 0xA560001A, 0xA560001C} -- rotNode->rotation = {0, 0, 0}

-- addresses from STROOP's MappingUS.map / MappingJP.map
local BODY_HOOKS_US <const> = {
    cur_graph_node_object = 0x8032DF00,
    {addr = 0x80277294, neutral = NEUTRAL_ROTATION}, -- geo_mario_tilt_torso
    {addr = 0x802773A4, neutral = NEUTRAL_ROTATION}, -- geo_mario_head_rotation
    {addr = 0x802775CC, neutral = NEUTRAL_SCALE},    -- geo_mario_hand_foot_scaler
}
local BODY_HOOKS_JP <const> = {
    cur_graph_node_object = 0x8032CFA0,
    {addr = 0x80276CE4, neutral = NEUTRAL_ROTATION}, -- geo_mario_tilt_torso
    {addr = 0x80276DF4, neutral = NEUTRAL_ROTATION}, -- geo_mario_head_rotation
    {addr = 0x8027701C, neutral = NEUTRAL_SCALE},    -- geo_mario_hand_foot_scaler
}

local function j_to(target)
    return 0x08000000 | ((target & 0x0FFFFFFF) >> 2)
end

-- true for branches/jumps, which can't be relocated into the wrapper
local function is_branch(op)
    local opcode, funct = op >> 26, op & 0x3F
    return (opcode >= 1 and opcode <= 7) or (opcode >= 20 and opcode <= 23)
        or (opcode == 0 and (funct == 8 or funct == 9))
        or (opcode == 17 and ((op >> 21) & 0x1F) == 8)
end

---@return integer, integer | nil # the hooked function's original first two instructions, or nil if its code is unexpected
local function original_instructions(addr)
    local first, second = memory.readdword(addr), memory.readdword(addr + 4)
    if first >> 26 == 2 then
        -- already hooked, possibly for an older base offset: recover what that wrapper displaced
        local wrapper = (addr & 0xF0000000) | ((first & 0x03FFFFFF) << 2)
        if memory.readdword(wrapper + 0x44) == j_to(addr + 8) then
            return memory.readdword(wrapper + 0x3C), memory.readdword(wrapper + 0x40)
        end
        return nil
    end
    -- the previous function ends right before, and the moved instructions aren't branches
    if memory.readdword(addr - 8) ~= 0x03E00008 or is_branch(first) or is_branch(second) then
        return nil
    end
    return first, second
end

local function apply_body_state_hooks(hooks)
    local node_hi, node_lo = (hooks.cur_graph_node_object + 0x8000) >> 16, hooks.cur_graph_node_object & 0xFFFF
    for i, hook in ipairs(hooks) do
        local wrapper = region(BODY_HOOKS_OFFSET) + (i - 1) * BODY_HOOK_STRIDE
        local first, second = original_instructions(hook.addr)
        if not first then
            print(string.format("Ghost: unexpected code at 0x%X, skipping body state hook", hook.addr))
        else
            local code = {
                0x3C080000 | node_hi,        -- lui t0, hi(gCurGraphNodeObject)
                0x8D080000 | node_lo,        -- lw t0, lo(gCurGraphNodeObject)(t0)
                0x3C090000 | Ghosts.base_offset, -- lui t1, base
                0x35297000, -- ori t1, t1, 0x7000
                0x01094023, -- subu t0, t0, t1
                0x2D081000, -- sltiu t0, t0, 0x1000   ; ghost node?
                0x11000008, -- beq t0, zero, original
                0x240A0001, -- addiu t2, zero, GEO_CONTEXT_RENDER
                0x148A0006, -- bne a0, t2, original
                0x8CAB0008, -- lw t3, 0x8(a1)         ; node->next
                hook.neutral[1], hook.neutral[2], hook.neutral[3],
                0x03E00008, -- jr ra
                0x00001025, -- or v0, zero, zero      ; return NULL
                first, second, -- original: the displaced instructions, then resume
                j_to(hook.addr + 8),
                NOP,
            }
            for k, op in ipairs(code) do
                memory.writedword(wrapper + (k - 1) * 4, op)
            end
            memory.writedword(hook.addr + 4, NOP)
            memory.writedword(hook.addr, j_to(wrapper))
        end
    end
end

---Write the playback ghost hack to RAM.
-- Details: https://github.com/FramePerfection/STROOP/tree/Development/HackSources/Ghosts
function Ghosts.apply_hack()
	local rom_name = Addresses[Settings.address_source_index].name()
	local HACKS, BODY_HOOKS = HACKS_US, BODY_HOOKS_US -- default to US hack
	if rom_name == Locales.str('ADDRESS_JAPAN') then
		HACKS, BODY_HOOKS = HACKS_JP, BODY_HOOKS_JP
	end

    local hook_addr = Addresses[Settings.address_source_index].area_update_objects
    for addr, hck in pairs(HACKS) do
        if addr >= HACK_FILE_BASE and addr < HACK_FILE_BASE + 0x10000 then
            writebytes(region(addr - HACK_FILE_BASE), hck)
        elseif addr ~= hook_addr then
            writebytes(addr, hck)
        end
    end

    -- point the moved code at its new region
    for _, offset in ipairs(BASE_LUIS) do
        memory.writeword(region(offset) + 2, Ghosts.base_offset)
    end
    memory.writeword(region(BASE_PLUS_1_LUI) + 2, Ghosts.base_offset + 1)
    memory.writeword(region(ANIMATION_BUFFER_LUI) + 2, Ghosts.base_offset + 0x10)

    -- clear some memory to prevent nonsensical data causing a game crash
    -- on the first ghost loop iteration
    for addr = region(0x7000), region(0x7FFC), 4 do
        memory.writedword(addr, 0)
    end

    -- signature: this hack originates from Lua
    memory.writebyte(region(0x7FFE), 0x42)

    memory.writedword(hook_addr, hook_instruction())

    enable_colored_hats()
    apply_body_state_hooks(BODY_HOOKS)

    memory.recompilenextall()
end

-- write 1 frame of ghost playback data to RAM
local function write_ghost_frame(offset, ghost, ghostidx, graphics)
    if ghost == nil then return end
    ghostidx = ghostidx - 1
    local addr = region(0x9B00) + ghostidx * 0x1000 + offset * 0x20
    local animation = graphics ~= 0 and (ghost.animation or 0) or ghost.animation_index
    memory.writefloat(addr + 0x00, ghost.position.x)
    memory.writefloat(addr + 0x04, ghost.position.y)
    memory.writefloat(addr + 0x08, ghost.position.z)
    memory.writedword(addr + 0x0C, animation)
    memory.writeword(addr + 0x10, ghost.pitch)
    memory.writeword(addr + 0x12, ghost.yaw)
    memory.writeword(addr + 0x14, ghost.roll)
    memory.writeword(addr + 0x16, ghost.animation_frame)
    memory.writedword(addr + 0x18, graphics) -- model pointer (0 = Mario)
end

-- clamp the index to within the ghost data's frame range
-- and return data at that index
---@param ghostdata GhostFrame[]
---@param index integer
local function last_valid_ghost_frame(ghostdata, index)
	if index <= 0 then
		if ghostdata[0] ~= nil then
            return ghostdata[0]
        end
        return ghostdata[1]
    elseif 0 < index and index < #ghostdata then
        return ghostdata[index]
    end
    return ghostdata[#ghostdata]
end

-- update the number of ghosts the hack should load
local function update_ghost_count(n)
	-- ghost_loop.asm only frees one slot per frame. Match that behaviour here
	-- to avoid dangling pointer bugs.
	local last_n = memory.readbyte(region(0x7FFF))
	if n < last_n - 1 then
		n = last_n - 1
	end
    memory.writebyte(region(0x7FFF), n)
end

local function update_ghost_playback()
    write_color_to_stream(nil, 0) -- write Mario's hat colour
	local address_source = Addresses[Settings.address_source_index]
	local global_timer = memory.readdword(address_source.global_timer)
    local n = 0
	for _, ghost in ipairs(ghosts) do
        if ghost.enabled and #ghost.data > 0 then
            n = n + 1
            for tm = 0, 0x7F do
                local offset = (tm + global_timer) & 0x7F
                local i = global_timer + tm - ghost.global_timer_start + 1
                write_ghost_frame(offset, last_valid_ghost_frame(ghost.data, i + 1), n, ghost.graphics)
            end
            write_color_to_stream(ghost, n)
            local obj = memory.readdword(region(0x7FF8) - 0x68 * (n - 1))
			if obj ~= 0 then
            	memory.writebyte(obj + 0x61, ghost.is_transparent and 1 or 0)
			end
        end
	end
	update_ghost_count(n)
end

---Updates playback and recording.
function Ghosts.update()
	if is_recording then
		update_recording()
	end
    local hack_applied = Ghosts.hack_is_applied()
    if Ghosts.auto_apply_hack and not hack_applied then
        Ghosts.apply_hack()
        hack_applied = true
    end
    if hack_applied and pending_base_offset then
        -- moving: shrink to 0 ghosts (freed one per frame), then reapply at the new base
        update_ghost_count(0)
        if memory.readbyte(region(0x7FFF)) == 0 and memory.readdword(region(0x7FF8)) == 0 then
            Ghosts.base_offset = pending_base_offset
            pending_base_offset = nil
            Ghosts.apply_hack()
        end
    elseif hack_applied then
        -- updating will always write Mario's hat to memory, so
        -- gate it behind a check to see if the RAM is hacked
        update_ghost_playback()
    end
end

---Safely set the hat color for a given ghost (clamps RGB values).
---@param ghost Ghost | nil # nil is given, this sets Mario's hat color
---@param RGB integer[3] # the RGB color
function Ghosts.set_color(ghost, RGB)
    local color = {
		clamp(RGB[1]), clamp(RGB[2]), clamp(RGB[3])
	}
    if ghost then
	    ghost.hat_color = color
    else
        mario_hat_color = color
    end
end

---@param ghost Ghost | nil # if nil is given, return Mario's hat color
---@return integer[3]
function Ghosts.get_color(ghost)
	return ghost and ghost.hat_color or mario_hat_color
end

---Return the ghost's data on the given frame. If global_timer is before the
---ghost's start, it will return the first frame of data. Similarly, if
---global_timer is after the end of the ghost's data, it will return the final
---frame of data.
---@param ghost Ghost
---@param global_timer integer
---@return GhostFrame | nil # returns nil for invalid ghosts
function Ghosts.get_ghost_data(ghost, global_timer)
    if not ghost or not ghost.data then
        return nil
    end
    local i = global_timer - ghost.global_timer_start + 1
    return last_valid_ghost_frame(ghost.data, i + 1)
end

---Returns the ghost's extra recorded values on the given frame, clamped like Ghosts.get_ghost_data.
---@param ghost Ghost
---@param global_timer integer
---@return {label: string, type: integer, value: any}[]
function Ghosts.get_ghost_variables(ghost, global_timer)
    local values = {}
    if not ghost or not ghost.data or #ghost.data == 0 then
        return values
    end
    local i = math.max(1, math.min(#ghost.data, global_timer - ghost.global_timer_start + 2))
    for _, variable in ipairs(ghost.variables) do
        values[#values + 1] = {label = variable.label, type = variable.type, value = variable.data[i]}
    end
    return values
end

---Returns a contiguous array of the currently loaded ghosts.
---@return Ghost[]
function Ghosts.list_ghosts()
    return table.move(ghosts, 1, #ghosts, 1, {})
end
