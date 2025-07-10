--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Ghost = {
	frames = {},
	is_recording = false
}

local frame = 0

GLOBAL_TIMER_ADDRESS = 0x8032D5D4
MARIO_OBJ_ADDRESS = 0x80361158

OBJ_POSITION_OFFSET = 0x20
OBJ_ANIMATION_OFFSET = 0x38
OBJ_ANIMATION_TIMER_OFFSET = 0x40

OBJ_PITCH_OFFSET = 0x1A
OBJ_YAW_OFFSET = 0x1C
OBJ_ROLL_OFFSET = 0x1E

recordingBaseFrame = nil
lastGlobalTimer = nil

function Ghost.update()
	if not Ghost.is_recording then
		return
	end

	if frame == 0 then
		print("Recording ghost...")
		frame = frame + 1
	end

	local marioObjRef = memory.readdword(MARIO_OBJ_ADDRESS)
	local _globalTimer = memory.readdword(GLOBAL_TIMER_ADDRESS)
	if recordingBaseFrame == nil then
		recordingBaseFrame = _globalTimer
	end
	if lastGlobalTimer == nil or lastGlobalTimer < _globalTimer then
		lastGlobalTimer = _globalTimer
		table.insert(Ghost.frames,
			{
				globalTimer = (_globalTimer - 1),

				pitch = memory.readword(marioObjRef + OBJ_PITCH_OFFSET),
				yaw = memory.readword(marioObjRef + OBJ_YAW_OFFSET),
				roll = memory.readword(marioObjRef + OBJ_ROLL_OFFSET),

				positionX = memory.readdword(marioObjRef + OBJ_POSITION_OFFSET),
				positionY = memory.readdword(marioObjRef + OBJ_POSITION_OFFSET + 4),
				positionZ = memory.readdword(marioObjRef + OBJ_POSITION_OFFSET + 8),

				animationIndex = memory.readword(marioObjRef + OBJ_ANIMATION_OFFSET),
				animationTimer = memory.readword(marioObjRef + OBJ_ANIMATION_TIMER_OFFSET) - 1
			})
	end
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

function Ghost.write_file()
	if recordingBaseFrame == nil then
		return
	end
	local file = io.open(Settings.ghost_path, "wb")
	writebytes32(file, recordingBaseFrame)
	writebytes32(file, #Ghost.frames)
	for _, value in pairs(Ghost.frames) do
		writebytes32(file, (value.globalTimer - recordingBaseFrame))
		writebytes32(file, value.positionX)
		writebytes32(file, value.positionY)
		writebytes32(file, value.positionZ)
		writebytes16(file, value.animationIndex)
		writebytes16(file, value.animationTimer)
		writebytes32(file, value.pitch)
		writebytes32(file, value.yaw)
		writebytes32(file, value.roll)
	end
	file:close()
	print("Ghost written to: " .. Settings.ghost_path)
	frame = 0
end

function Ghost.toggle_recording()
	Ghost.is_recording = not Ghost.is_recording

	if Ghost.is_recording then
		frame = 0
		Ghost.is_recording = true
		return
	end

	Ghost.write_file()
end
