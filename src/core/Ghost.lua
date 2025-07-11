--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Ghost = {}

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

local GLOBAL_TIMER_ADDRESS <const> = 0x8032D5D4
local MARIO_OBJ_ADDRESS <const> = 0x80361158
local OBJ_POSITION_OFFSET <const> = 0x20
local OBJ_ANIMATION_OFFSET <const> = 0x38
local OBJ_ANIMATION_TIMER_OFFSET <const> = 0x40
local OBJ_PITCH_OFFSET <const> = 0x1A
local OBJ_YAW_OFFSET <const> = 0x1C
local OBJ_ROLL_OFFSET <const> = 0x1E

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

	file:close()

	return true
end

---Appends a frame to the ghost recording if active.
function Ghost.update()
	if not is_recording then
		return
	end

	if frame == 0 then
		print('Recording ghost...')
		frame = frame + 1
	end

	local mario_obj = memory.readdword(MARIO_OBJ_ADDRESS)
	local global_timer = memory.readdword(GLOBAL_TIMER_ADDRESS)

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
			animation_index = memory.readword(mario_obj + OBJ_ANIMATION_OFFSET),
			animation_timer = memory.readword(mario_obj + OBJ_ANIMATION_TIMER_OFFSET) - 1,
		}
	end
end

---Stops the ghost recording.
---@return boolean # Whether the operation succeeded.
---@nodiscard
function Ghost.stop_recording()
	if not is_recording then
		return true
	end

	local result = flush()

	is_recording = false
	frames = {}
	frame = 0
	recording_base_frame = nil
	last_global_timer = nil

	return result
end

---Starts a ghost recording.
---@return boolean # Whether the operation succeeded.
---@nodiscard
function Ghost.start_recording()
	if is_recording then
		local result = Ghost.stop_recording()
		if not result then
			return false
		end
	end

	is_recording = true

	return true
end

---@return boolean # Whether a ghost is being recorded.
---@nodiscard
function Ghost.recording()
	return is_recording
end
