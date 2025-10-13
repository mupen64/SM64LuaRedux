--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Engine = {}

MovementModes = {
	disabled = 1,
	manual = 2,
	match_yaw = 3,
	reverse_angle = 4,
	match_angle = 5,
}

function Engine.stick_for_input_x(state)
	return state.movement_mode == MovementModes.manual and state.manual_joystick_x or Joypad.input.X or 0
end

function Engine.stick_for_input_y(state)
	return state.movement_mode == MovementModes.manual and state.manual_joystick_y or Joypad.input.Y or 0
end

function Engine.get_effective_angle(angle)
	-- NOTE: previous input lua snaps angle to multiple 16 by default, incurring a precision loss
	if Settings.truncate_effective_angle then
		return angle - (angle % 16)
	end
	return angle
end

function Engine.getDyaw(angle)
	if Settings.tas.strain_left and Settings.tas.strain_right == false then
		return corrected_facing_yaw + angle
	elseif Settings.tas.strain_left == false and Settings.tas.strain_right then
		return corrected_facing_yaw - angle
	elseif Settings.tas.strain_left == false and Settings.tas.strain_right == false then
		return corrected_facing_yaw + angle * (math.pow(-1, Memory.current.mario_global_timer % 2))
	else
		return angle
	end
end

function Engine.getDyawsign()
	if Settings.tas.strain_left and Settings.tas.strain_right == false then
		return 1
	elseif Settings.tas.strain_left == false and Settings.tas.strain_right then
		return -1
	elseif Settings.tas.strain_left == false and Settings.tas.strain_right == false then
		return math.pow(-1, Memory.current.mario_global_timer % 2)
	else
		return 0
	end
end

ENABLE_REVERSE_ANGLE_ON_WALLKICK = true
actionflag = 0
speedsign = 0
targetspeed = 0.0
function Engine.getgoal(targetspd) -- getting angle for target speed
	if (targetspd > 0) then
		return math.floor(math.acos((targetspd + 0.35 - Memory.current.mario_f_speed) / 1.5) * 32768 / math.pi)
	end
	return math.floor(math.acos((targetspd - 0.35 - Memory.current.mario_f_speed) / 1.5) * 32768 / math.pi)
end

function Engine.getArctanAngle(r, d, n, s, goal)
	-- r is ratio, d is displacement (offset), n is number of frames and  s is starting frame
	s = s - 1
	if (s < Memory.current.mario_global_timer and s > Memory.current.mario_global_timer - n - 1) then
		yaw = 0
		if (Memory.current.mario_action == 0x000008A7 or Memory.current.mario_action == 0x010208B6 or Memory.current.mario_action == 0x010208B0 or Memory.current.mario_action == 0x08100340 or Memory.current.mario_action == 0x00100343 and ENABLE_REVERSE_ANGLE_ON_WALLKICK) then
			yaw = 32768
		end
		if Settings.tas.movement_mode == MovementModes.match_angle then
			yaw = (corrected_facing_yaw + yaw) % 65536
			if (math.abs(yaw - goal) > 16384 and math.abs(yaw - goal) <= 49152) then
				r = -math.abs(math.tan(math.pi / 2 -
					(Engine.get_effective_angle(yaw) - goal) * math.pi / 32768))
			else
				r = math.abs(math.tan(math.pi / 2 -
					(Engine.get_effective_angle(yaw) - goal) * math.pi / 32768))
			end
		end
		if (Settings.tas.reverse_arc == false) then
			dyaw = math.floor((math.pi / 2 - math.atan(0.15 * (r * math.max(1, (n + 1 - Memory.current.mario_global_timer + s)) + d / math.min(1, n + 1 - Memory.current.mario_global_timer + s)))) *
				32768 / math.pi)
			if (Settings.tas.movement_mode == MovementModes.match_angle) then
				if ((yaw - goal + 32768) % 65536 - 32768 > 0) then
					return yaw - dyaw
				end
				return yaw + dyaw
			end
			return (Engine.getDyaw(dyaw) + yaw) % 65536
		end
		dyaw = math.floor((math.pi / 2 - math.atan(0.15 * (r * math.max(1, (Memory.current.mario_global_timer - s)) + d / math.min(1, Memory.current.mario_global_timer - s)))) *
			32768 / math.pi)
		if (Settings.tas.movement_mode == MovementModes.match_angle) then
			if ((yaw - goal + 32768) % 65536 - 32768 > 0) then
				return yaw - dyaw
			end
			return yaw + dyaw
		end
		return (Engine.getDyaw(dyaw) + yaw) % 65536
	end
	return goal
end

Engine.inputsForAngle = function(goal, curr_input)
	corrected_facing_yaw = Memory.current.mario_facing_yaw
	if (Memory.current.camera_flags % 4 < 2 and Memory.current.mario_pressed_buttons % 16 > 7 and Memory.current.mario_held_buttons < 128 and curr_input.A and (Memory.current.mario_animation == 127 or Memory.current.mario_animation == 128)) then
		corrected_facing_yaw = Memory.current.mario_gfx_angle
	end
	if (Settings.tas.movement_mode == MovementModes.match_yaw) then
		goal = corrected_facing_yaw
		if ((Memory.current.mario_action == 0x000008A7 or Memory.current.mario_action == 0x010208B6 or Memory.current.mario_action == 0x010208B0 or Memory.current.mario_action == 0x08100340 or Memory.current.mario_action == 0x00100343) and ENABLE_REVERSE_ANGLE_ON_WALLKICK) then
			goal = (goal + 32768) % 65536
		end
	end
	if (Settings.tas.movement_mode == MovementModes.reverse_angle) then
		goal = (corrected_facing_yaw + 32768) % 65536
		if ((Memory.current.mario_action == 0x000008A7 or Memory.current.mario_action == 0x010208B6 or Memory.current.mario_action == 0x010208B0 or Memory.current.mario_action == 0x08100340 or Memory.current.mario_action == 0x00100343) and ENABLE_REVERSE_ANGLE_ON_WALLKICK) then
			goal = corrected_facing_yaw
		end
	end

	if (Settings.tas.strain_always) then
		offset = 3
	else
		offset = 0
	end

	if Settings.tas.strain_speed_target then
		if Memory.current.mario_action == 0x04000440 or Memory.current.mario_action == 0x0400044A or Memory.current.mario_action == 0x08000239 or Memory.current.mario_action == 0x0C000232 or Memory.current.mario_action == 0x04000442 or Memory.current.mario_action == 0x04000443 or Memory.current.mario_action == 0x010208B7 or Memory.current.mario_action == 0x04000445 or Memory.current.mario_action == 0x00840454 or Memory.current.mario_action == 0x00840452 or (Memory.current.mario_action > 0x0400046F and Memory.current.mario_action < 0x04000474) or (Memory.current.mario_action > 0x00000473 and Memory.current.mario_action < 0x00000478) then
			actionflag = 1
		else
			actionflag = 0
		end
		if (Memory.current.mario_f_speed > 937 / 30 and Memory.current.mario_f_speed < 31.9 + offset * 3000000 and (Memory.current.mario_action == 0x04808459 or Memory.current.mario_action == 0x00000479) and Memory.current.mario_held_buttons < 128 and curr_input.A and (Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B) and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 48 - Memory.current.mario_f_speed / 2
			speedsign = 1
			if (Memory.current.mario_f_speed > 32) then
				goal = Engine.getDyaw(13927)
			else
				goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			end
		elseif (Memory.current.mario_f_speed >= 10 and offset ~= 0 and Memory.current.mario_f_speed < 34.85 and Memory.current.mario_action == 0x04808459 and (Memory.current.mario_held_buttons > 127 or not curr_input.A) and Memory.current.mario_held_buttons % 128 < 64 and curr_input.B and Settings.tas.movement_mode == MovementModes.match_yaw) then
			speedsign = 1
			targetspeed = 32
			if (Memory.current.mario_f_speed > 32) then
				if (Memory.current.mario_f_speed > 33.85) then targetspeed = targetspeed + 1 end
				goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			else
				goal = Engine.getDyaw(13927)
			end
		elseif (Memory.current.mario_f_speed > -337 / 30 - offset / 1.5 and Memory.current.mario_f_speed < -9.9 and Memory.current.mario_action == 0x00000479 and Settings.tas.movement_mode == MovementModes.reverse_angle) then
			targetspeed = -16 - Memory.current.mario_f_speed / 2
			if (Memory.current.mario_f_speed < -11.9) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.current.mario_f_speed > 46.85 and Memory.current.mario_f_speed < 47.85 + offset and Memory.current.mario_action == 0x03000888 and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 48
			if (Memory.current.mario_f_speed > 49.85) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.current.mario_f_speed > 30.85 and Memory.current.mario_f_speed < 31.85 + offset and (actionflag == 0 or (Memory.current.mario_action == 0x04000472 and Memory.current.mario_hat_state % 16 > 7 and Memory.current.mario_held_buttons < 128 and curr_input.A)) and Memory.current.mario_action ~= 0x03000888 and Memory.current.mario_action ~= 0x00000479 and Memory.current.mario_action ~= 0x04808459 and (Memory.current.mario_action ~= 0x00880456 or ((Memory.current.mario_held_buttons < 128 and curr_input.A) or (Memory.current.mario_held_buttons % 128 < 64 and curr_input.B))) and ((Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B) or Memory.current.mario_action == 0x00880456) and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 32
			if (Memory.current.mario_f_speed > 33.85) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			if (Memory.current.mario_action == 0x000008A7 or Memory.current.mario_action == 0x010208B6 or Memory.current.mario_action == 0x010208B0 or Memory.current.mario_action == 0x08100340 or Memory.current.mario_action == 0x00100343 and ENABLE_REVERSE_ANGLE_ON_WALLKICK) then
				goal = (goal + 32768) % 65536
			end
		elseif (Memory.current.mario_f_speed > 15.85 and Memory.current.mario_f_speed < 16.85 + offset and (((Memory.current.mario_action == 0x01000882 or Memory.current.mario_action == 0x030008AF or Memory.current.mario_action == 0x03000886 or Memory.current.mario_action == 0x03000894 or Memory.current.mario_action == 0x01000887 or Memory.current.mario_action == 0x0100088C) or (Memory.current.mario_action == 0x04000472 and Memory.current.mario_hat_state % 16 > 7)) and Memory.current.mario_held_buttons % 128 < 64 and curr_input.B) and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 32 - 15
			if (Memory.current.mario_f_speed > 18.85) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			if (Memory.current.mario_action == 0x000008A7 or Memory.current.mario_action == 0x010208B6 or Memory.current.mario_action == 0x010208B0 or Memory.current.mario_action == 0x08100340 or Memory.current.mario_action == 0x00100343 and ENABLE_REVERSE_ANGLE_ON_WALLKICK) then
				goal = (goal + 32768) % 65536
			end
		elseif (Memory.current.mario_f_speed > -32 and Memory.current.mario_f_speed < 32 and ((Memory.current.mario_action >= 0x0C008220 and Memory.current.mario_action < 0x0C008224) or Memory.current.mario_action == 0x0400047A or Memory.current.mario_action == 0x0800022F) and Settings.tas.movement_mode == MovementModes.reverse_angle) then
			speedsign = -1
			goal = Engine.getDyaw(18840)
		elseif (Memory.current.mario_f_speed > -16.85 - offset and Memory.current.mario_f_speed < -14.85 and Memory.current.mario_action ~= 0x00000479 and ((actionflag == 0 and (Memory.current.mario_action ~= 0x01000882 and Memory.current.mario_action ~= 0x030008AF and Memory.current.mario_action ~= 0x03000886 and Memory.current.mario_action ~= 0x03000894 and Memory.current.mario_action ~= 0x01000887 and Memory.current.mario_action ~= 0x0100088C or Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B)) or (Memory.current.mario_action == 0x04000472 and Memory.current.mario_held_buttons < 128 and curr_input.A and (Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B) and Memory.current.mario_hat_state % 16 > 7)) and Settings.tas.movement_mode == MovementModes.reverse_angle) then
			targetspeed = -16
			if (Memory.current.mario_f_speed < -17.85) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.current.mario_f_speed > -31.85 - offset and Memory.current.mario_f_speed < -29.85 and Memory.current.mario_action ~= 0x00000479 and (((Memory.current.mario_action == 0x01000882 or Memory.current.mario_action == 0x030008AF or Memory.current.mario_action == 0x03000886 or Memory.current.mario_action == 0x03000894 or Memory.current.mario_action == 0x01000887 or Memory.current.mario_action == 0x0100088C) or (Memory.current.mario_action == 0x04000472 and Memory.current.mario_hat_state % 16 > 7)) and Memory.current.mario_held_buttons % 128 < 64 and curr_input.B) and Settings.tas.movement_mode == MovementModes.reverse_angle) then
			targetspeed = -16 - 15
			if (Memory.current.mario_f_speed < -32.85) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.current.mario_f_speed > -21.0625 - offset / 0.8 and Memory.current.mario_f_speed < -18.5625 and Memory.current.mario_action ~= 0x00000479 and (Memory.current.mario_action ~= 0x04000472 or Memory.current.mario_hat_state % 16 < 8) and (actionflag == 1 or Memory.current.mario_action == 0x04808459) and Memory.current.mario_held_buttons < 128 and curr_input.A and Settings.tas.movement_mode == MovementModes.reverse_angle) then
			targetspeed = -16 + Memory.current.mario_f_speed / 5
			if (Memory.current.mario_f_speed < -22.3125) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.current.mario_f_speed > 38.5625 and Memory.current.mario_f_speed < 39.8125 + offset / 0.8 and Memory.current.mario_action ~= 0x00000479 and Memory.current.mario_action ~= 0x03000888 and (Memory.current.mario_action ~= 0x04000472 or Memory.current.mario_hat_state % 16 < 8) and actionflag == 1 and Memory.current.mario_held_buttons < 128 and curr_input.A and (Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B) and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 32 + Memory.current.mario_f_speed / 5
			if (Memory.current.mario_f_speed > 42.3125) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		elseif (Memory.current.mario_f_speed > 20 and Memory.current.mario_f_speed < 21.0625 + offset / 0.8 and Memory.current.mario_action == 0x04000472 and Memory.current.mario_hat_state % 16 < 8 and Memory.current.mario_held_buttons < 128 and curr_input.A and Memory.current.mario_held_buttons % 128 < 64 and curr_input.B and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 32 - 15 + Memory.current.mario_f_speed / 5
			if (Memory.current.mario_f_speed > 23.5625) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
		else
			speedsign = 0
		end
		goal = goal + 32 * speedsign * Engine.getDyawsign()
	end
	if (Settings.tas.movement_mode == MovementModes.match_angle and Settings.tas.dyaw) then
		goal = Engine.getDyaw(goal)
		if (Memory.current.mario_action == 0x000008A7 or Memory.current.mario_action == 0x010208B6 or Memory.current.mario_action == 0x010208B0 or Memory.current.mario_action == 0x08100340 or Memory.current.mario_action == 0x00100343 and ENABLE_REVERSE_ANGLE_ON_WALLKICK) then
			goal = (goal + 32768) % 65536
		end
	end
	--if (Settings.tas.atan_strain and Settings.tas.atan_start < Memory.current.mario_global_timer and Settings.tas.atan_start > Memory.current.mario_global_timer - Settings.tas.atan_n - 1) then
	if (Settings.tas.atan_strain) then
		goal = goal % 65536
		goal = Engine.getArctanAngle(Settings.tas.atan_r, Settings.tas.atan_d, Settings.tas.atan_n, Settings.tas.atan_start, goal)
	end
	-- if(Settings.tas.movement_mode ~= MovementModes.match_angle or Settings.tas.dyaw or Settings.tas.atan_strain) then
	-- goal = goal + Memory.current.mario_facing_yaw % 16
	-- end
	goal = goal - 65536
	while (Memory.current.camera_angle > goal) do
		goal = goal + 65536
	end
	-- Set up binary search
	minang = 1
	maxang = Angles.COUNT
	midang = math.floor((minang + maxang) / 2)
	-- Binary search
	while (minang <= maxang) do
		if (Angles.ANGLE[midang].angle + Memory.current.camera_angle < goal) then
			minang = midang + 1
		elseif (Angles.ANGLE[midang].angle + Memory.current.camera_angle == goal) then
			minang = midang
			maxang = midang - 1
		else
			maxang = midang - 1
		end
		midang = math.floor((minang + maxang) / 2)
	end
	-- If binary search fails, optimal angle is between Angles.Count and 1. Checks which one is closer.
	if minang > Angles.COUNT then
		minang = 1
		if math.abs(Angles.ANGLE[1].angle + Memory.current.camera_angle - (goal - 65536)) > math.abs(Angles.ANGLE[Angles.COUNT].angle + Memory.current.camera_angle - goal) then
			minang = Angles.COUNT
		end
	end
	return {
		angle = (Angles.ANGLE[minang].angle + Memory.current.camera_angle) % 65536,
		X = Angles.ANGLE[minang].X,
		Y = Angles.ANGLE[minang].Y,
	}
end

function Engine.GetQFs(Mariospeed)
	-- print(math.sqrt(math.abs(math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.previous.mario_x))) - math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.current.mario_x)))) ^ 2 + math.abs(math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.previous.mario_z))) - math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.current.mario_z)))) ^ 2))
	-- return math.floor(4 * (math.sqrt(math.abs(math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.previous.mario_x))) - math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.current.mario_x)))) ^ 2 + math.abs(math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.previous.mario_z))) - math.abs(MoreMaths.hexToFloat(string.format("%x", Memory.current.mario_z)))) ^ 2)) / math.abs(Mariospeed))
end

---Toggles between the appropriate values required for performing speedkicks.
function Engine.toggle_speedkick()
	if Settings.tas.goal_mag ~= 48 then
		Settings.tas.goal_mag = 48
	else
		Settings.tas.goal_mag = 127
	end
	Settings.tas.high_magnitude = true
end

function Engine.GetSpeedEfficiency()
	local div = math.abs(math.sqrt(
		Memory.current.mario_x_sliding_speed ^ 2 +
		Memory.current.mario_z_sliding_speed ^ 2)
	)

	if div == 0 then
		return 0
	end

	return Engine.get_xz_distance_moved_since_last_frame() / div
end

function Engine.get_xz_distance_moved_since_last_frame()
	return math.sqrt((Memory.previous.mario_x - Memory.current.mario_x) ^
		2 + (Memory.previous.mario_z - Memory.current.mario_z) ^ 2)
end

function Engine.get_distance_moved()
	local x = (Settings.moved_distance_axis.x - Memory.current.mario_x) ^ 2
	local y = (Settings.moved_distance_axis.y - Memory.current.mario_y) ^ 2
	local z = (Settings.moved_distance_axis.z - Memory.current.mario_z) ^ 2

	local sum = 0
	if Settings.moved_distance_x then
		sum = sum + x
	end
	if Settings.moved_distance_y then
		sum = sum + y
	end
	if Settings.moved_distance_z then
		sum = sum + z
	end

	return math.sqrt(sum)
end

function Engine.GetHSlidingSpeed()
	return math.sqrt((Memory.current.mario_x_sliding_speed ^ 2) + (Memory.current.mario_z_sliding_speed ^ 2))
end

local function magnitude(x, y)
	return math.sqrt(math.max(0, math.abs(x) - 6) ^ 2 + math.max(0, math.abs(y) - 6) ^ 2)
end

local function clamp(min, n, max)
	if n < min then return min end
	if n > max then return max end
	return n
end
local function effectiveAngle(x, y)
	if math.abs(x) < 8 then
		x = 0
	elseif x > 0 then
		x = x - 6
	else
		x = x + 6
	end
	if math.abs(y) < 8 then
		y = 0
	elseif y > 0 then
		y = y - 6
	else
		y = y + 6
	end
	return math.atan2(-y, x)
end

Engine.scaleInputsForMagnitude = function(result, goal_mag, use_high_mag)
	if goal_mag >= 127 then return end

	local start_x, start_y = result.X, result.Y
	local current_mag = magnitude(start_x, start_y)
	local ideal_x, ideal_y = start_x * goal_mag / current_mag, start_y * goal_mag / current_mag
	--print(magnitude(ideal_x, ideal_y))
	--print(goal_mag)

	--local x0, y0 = math.floor(ideal_x), math.floor(ideal_y)
	--local x0, y0 = 0, 0

	local x0, y0 = 0, 0
	if start_x == 0 then
		y0 = goal_mag + 6
	elseif start_y == 0 then
		x0 = goal_mag + 6
	else
		-- https://www.wolframalpha.com/input/?i=solve+%7Bsqrt%28%28x0-6%29%C2%B2+%2B+%28y0-6%29%5E2%29+%3D+k%3B+atan2%28y%2Cx%29+%3D+atan2%28y0%2Cx0%29+%7D+for+x0+and+y0
		local k = goal_mag
		local x, y = math.abs(start_x), math.abs(start_y)
		local x2, y2 = x * x, y * y
		local crazy = math.sqrt((4 * (k ^ 2 - 72) * y2) / (x2 + y2) + (y2 * (-12 * x - 12 * y) ^ 2) / (x2 + y2) ^ 2)
		--print(crazy)
		x0 = math.floor(math.abs(x * crazy / (2 * y) + (6 * x2) / (x2 + y2) + (6 * x * y) / (x2 + y2)))
		y0 = math.floor(math.abs(0.5 * crazy + (6 * y2) / (x2 + y2) + (6 * x * y) / (x2 + y2)))
	end
	if start_x < 0 then
		x0 = -x0
	end
	if start_y < 0 then
		y0 = -y0
	end
	if x0 ~= x0 then x0 = 0 end -- NaN?
	if y0 ~= y0 then y0 = 0 end

	-- search neighbourhood for input with greatest component in goal direction
	local closest_x, closest_y = x0, y0
	local err = -1
	local goal_angle = effectiveAngle(start_x, start_y)
	for i = -32, 32 do
		for j = -32, 32 do
			local x, y = clamp(-127, x0 + i, 127), clamp(-127, y0 + j, 127)
			--print(string.format("%d,%d", x, y))
			local mag = magnitude(x, y)
			if (mag <= goal_mag) and (mag * mag >= err) then
				local angle = effectiveAngle(x, y)
				--print(string.format("%d:%d: %f (%f)", x,y,angle,goal_angle))
				--local this_err = math.cos(angle - goal_angle)*mag
				local this_err = math.cos(angle - goal_angle)
				if (use_high_mag) then this_err = this_err * mag * mag end
				--print(string.format("%d,%d: %f, %d; %f, %f; %f, %s", x, y, mag, goal_mag, angle, goal_angle, this_err, tostring(err)))
				if this_err > err then
					err = this_err
					closest_x, closest_y = x, y
				end
			end
		end
	end

	closest_x = clamp(-127, closest_x, 127)
	closest_y = clamp(-127, closest_y, 127)
	if math.abs(closest_x) < 8 then closest_x = 0 end
	if math.abs(closest_y) < 8 then closest_y = 0 end

	result.X, result.Y = closest_x, closest_y
end
