--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- Mario action types
local AIR_HIT_WALL = 0x000008A7
local BACKWARDS_AIR_KB = 0x010208B0
local SOFT_BONK = 0x010208B6
local HOLDING_POLE = 0x08100340
local CLIMBING_POLE = 0x00100343
local WALKING = 0x04000440
local DECELERATING = 0x0400044A
local LAVA_BOOST = 0x010208B7
local LAVA_BOOST_LAND = 0x08000239
local LONG_JUMP = 0x03000888
local LONG_JUMP_LAND = 0x00000479
local FREEFALL_LAND_STOP = 0x0C000232
local CROUCH_SLIDE = 0x04808459
local HOLD_WALKING = 0x00000442
local TURNING_AROUND = 0x00000443
local BRAKING = 0x04000445 
local HOLD_BUTT_SLIDE = 0x00840454
local BUTT_SLIDE = 0x00840452
local TRIPLE_JUMP = 0x01000882
local FLYING_TRIPLE_JUMP = 0x03000894
local SPECIAL_TRIPLE_JUMP = 0x030008AF
local BACKFLIP_LAND = 0x0400047A
local BACKFLIP_LAND_STOP = 0x0800022F
local WALL_KICK = 0x03000886
local SIDEFLIP = 0x01000887
local FREEFALL = 0x0100088C
local DIVE_SLIDE = 0x00880456

-- MARIO action >= 0x04000470, <= 0x04000473
local JUMP_LAND = 0x04000470 
local FREEFALL_LAND = 0x04000471 
local DOUBLE_JUMP_LAND = 0x04000472 
local SIDE_FLIP_LAND = 0x04000473 

-- MARIO action >= 0x00000474, <= 0x00000477
local HOLD_JUMP_LAND = 0x00000474 
local HOLD_FREEFALL_LAND = 0x00000475 
local QUICKSAND_JUMP_LAND = 0x00000476 
local HOLD_QUICKSAND_JUMP_LAND = 0x00000477

-- MARIO action >= 0x0C008220, <= 0x0C008223
local CROUCHING = 0x0C008220
local START_CROUCHING = 0x0C008221 
local STOP_CROUCHING = 0x0C008222 
local START_CRAWLING = 0x0C008223

-- action masks
local ACT_FLAG_AIR = 0x800
local ACT_FLAG_SWIMMING = 0x2000

-- Surface types
local SURFACE_SLOW = 0x09
local SURFACE_VERY_SLIPPERY = 0x13
local SURFACE_SLIPPERY = 0x14 
local SURFACE_NOT_SLIPPERY = 0x15 
local SURFACE_NOISE_SLIPPERY = 0x2A 
local SURFACE_ICE = 0x2E 
local SURFACE_HARD_SLIPPERY = 0x35 
local SURFACE_HARD_VERY_SLIPPERY = 0x36 
local SURFACE_HARD_NOT_SLIPPERY = 0x37 
local SURFACE_NOISE_VERY_SLIPPERY_73 = 0x73 
local SURFACE_NOISE_VERY_SLIPPERY_74 = 0x74 
local SURFACE_NOISE_VERY_SLIPPERY = 0x75 
local SURFACE_NO_CAM_COL_VERY_SLIPPERY = 0x78 
local SURFACE_NO_CAM_COL_SLIPPERY = 0x79 
local SURFACE_SWITCH = 0x7A 

-- Surface slipperieness types
local SURFACE_CLASS_DEFAULT = 0x0
local SURFACE_CLASS_VERY_SLIPPERY = 0x13
local SURFACE_CLASS_SLIPPERY = 0x14
local SURFACE_CLASS_NOT_SLIPPERY = 0x15


Engine = {}

MovementModes = {
	disabled = 1,
	manual = 2,
	match_yaw = 3,
	reverse_yaw = 4,
	match_angle = 5,
}

function Engine.stick_for_input_x(state)
	return state.movement_mode == MovementModes.manual and state.manual_joystick_x or Joypad.input.X or 0
end

function Engine.stick_for_input_y(state)
	return state.movement_mode == MovementModes.manual and state.manual_joystick_y or Joypad.input.Y or 0
end

-- turn a raw joystick value into a value that the game uses for computations
local function normalize_joystick_coordinate(n)
	if n < -128 then
		n = -128
	elseif n > 127 then
		n = 127
	elseif math.abs(n) < 8 then
		return 0
	end
	if n > 0 then
		return n - 6
	end
	return n + 6
end

-- return the normalized joystick x, y, and magnitude based on raw joystick inputs
-- Note: most (but not all!) calculations in game use m->intendedMag = (mag * mag / 64) / 2
-- Note 2: since this is called frequently, having a local version is important for performance
local function normalize_joystick(x, y)
	x = normalize_joystick_coordinate(x)
	y = normalize_joystick_coordinate(y)
	local mag = math.sqrt(x*x + y*y)
	if mag > 64 then
		return x * 64 / mag, y * 64 / mag, 64
	end
	return x, y, mag
end

Engine.normalize_joystick = normalize_joystick

--- Gets the magnitude of the joystick input, accounting for the deadzone.
--- @param x int
--- @param y int
--- @return number
function Engine.get_magnitude_for_stick(x, y)
	local mag = 0
	x, y, mag = normalize_joystick(x, y)
	return mag
end

function Engine.get_effective_angle(angle)
	-- NOTE: previous input lua snaps angle to multiple 16 by default, incurring a precision loss
	if Settings.truncate_effective_angle then
		return angle - (angle % 16)
	end
	return angle
end

local corrected_facing_yaw = 0

local function get_dyaw(angle)
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

local function get_dyaw_sign()
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

local ENABLE_REVERSE_YAW_ON_WALLKICK = true

function get_goal_angle(targetspd)
	if (targetspd > 0) then
		return math.floor(math.acos((targetspd + 0.35 - Memory.current.mario_f_speed) / 1.5) * 32768 / math.pi)
	end
	return math.floor(math.acos((targetspd - 0.35 - Memory.current.mario_f_speed) / 1.5) * 32768 / math.pi)
end

--- Returns the target angle to hold on the current frame to achieve arctan straining.
--- @param r number # the preference ratio of forwards over sideways movement along the goal angle.
---		To maximize distance along the target angle, use r=1.
---		To maximize sideways distance use |r|<1, for forwards distance use |r|>1.
---		For backwards distance use r<0.
---		This is automatically determined when Match Angle is on.
--- @param d number # the preference ratio of maximizing speed over distance
---		To maximize for distance only, use d=0.
---		To maximize for speed only, use d>>0.
--- @param n int # the total number of frames to arctan strain for
--- @param s int # the frame to start the arctan strain segment on
--- @param goal int # the overall target angle
--- @param inverse_strain boolean # whether to invert the straining. i.e.
--- @param movement_mode MovementMode # if MovementModes.match_angle is given, then
---		r is automatically determined based on the goal angle and
---		the returned angle is adjusted accordingly
function Engine.get_arctan_angle(r, d, n, s, goal, inverse_strain, movement_mode)
	local t = Memory.current.mario_global_timer - s + 1 -- current frame within strain
	if (t <= 0 or n < t) then
		return goal -- outside of frame range
	end

	local yaw = 0
	if (Memory.current.mario_action == AIR_HIT_WALL or
		Memory.current.mario_action == SOFT_BONK or
		Memory.current.mario_action == BACKWARDS_AIR_KB or
		Memory.current.mario_action == HOLDING_POLE or
		Memory.current.mario_action == CLIMBING_POLE and ENABLE_REVERSE_YAW_ON_WALLKICK) then
		yaw = 32768
	end

	if movement_mode == MovementModes.match_angle then
		-- Automatically pick: r = cot(yaw - goal)
		yaw = (corrected_facing_yaw + yaw) % 65536
		r = math.abs(math.tan(math.pi / 2 - (Engine.get_effective_angle(yaw) - goal) * math.pi / 32768))
		if (math.abs(yaw - goal) > 16384 and math.abs(yaw - goal) <= 49152) then
			r = -r
		end
		-- show the user the automatic choice without changing their choice
		Settings.tas.atan_readonly_r = r
	else
		Settings.tas.atan_readonly_r = nil
	end

	local dyaw
	if (Settings.tas.reverse_arc) then
		dyaw = Strain.arccot(r, d, t + 1)
	else
		dyaw = Strain.arccot(r, d, n - t)
	end

	if (movement_mode == MovementModes.match_angle) then
		if ((yaw - goal + 32768) % 65536 - 32768 > 0) then
			return yaw - dyaw
		end
		return yaw + dyaw
	end
	return (get_dyaw(dyaw) + yaw) % 65536
end

Strain = {
	arccot = function(r, d, t) -- expects t > 0
		angle = math.atan(0.15 * (r * t + d)) 
		angle = angle / math.pi * 32768
		return math.floor(16384 - angle)
	end
}

--- Returns the target angle to hold based on Mario's current action and hspeed,
--- or returns nil if you cannot strain towards a drag threshold. This considers
--- many different specific cases, and will return nil if your speed is too high.
--- @param action # Mario's action
--- @param v # Mario's forward speed
--- @param current_input # the controller inputs pressed on this frame
--- @param movement_mode # the intention will change the resulting angle
Engine.get_point99_trick_goal_angle = function(action, v, current_input, movement_mode)
	local goal = nil
	local speedsign = 0
	local targetspeed = 0.0

	-- used to determine if straining is attaible. i.e. if Mario is moving too fast,
	-- don't bother trying to strain to the particular drag threshold
	local offset = 0
	if (Settings.tas.strain_always) then
		offset = 3
	end

	local A_HELD = Memory.current.mario_held_buttons > 127
	local A_PRESSED = not A_HELD and current_input.A
	local B_HELD = Memory.current.mario_held_buttons % 128 > 63
	local B_PRESSED = not B_HELD and current_input.B
	local HAS_WINGCAP = Memory.current.mario_hat_state % 16 > 7

	local REFLECT_ACTION = (action == AIR_HIT_WALL or
			action == SOFT_BONK or
			action == BACKWARDS_AIR_KB or
			action == HOLDING_POLE or
			action == CLIMBING_POLE)
	
	-- grounded (or lava boost)
	local GROUNDED_ACTION = (action == WALKING or
			action == DECELERATING or
			action == LAVA_BOOST_LAND or
			action == FREEFALL_LAND_STOP or
			action == HOLD_WALKING or
			action == TURNING_AROUND or
			action == LAVA_BOOST or
			action == BRAKING or
			action == HOLD_BUTT_SLIDE or
			action == BUTT_SLIDE or
			(JUMP_LAND <= action and action <= SIDE_FLIP_LAND) or
			(HOLD_JUMP_LAND <= action and action <= HOLD_QUICKSAND_JUMP_LAND))

	-- starting a long jump
	if (v > 937 / 30 and v < 31.9 + offset * 3000000 and
			(action == CROUCH_SLIDE or action == LONG_JUMP_LAND) and
			A_PRESSED and (B_HELD or not current_input.B) and
			movement_mode == MovementModes.match_yaw) then
		speedsign = 1
		targetspeed = 48 - v / 2
		if (v > 32) then
			targetspeed = 48
			goal = get_dyaw(13927)
		else
			goal = get_dyaw(get_goal_angle(targetspeed))
		end

	-- starting a slide kick
	elseif (v >= 10 and offset ~= 0 and v < 34.85 and
			action == CROUCH_SLIDE and
			(A_HELD or not current_input.A) and B_PRESSED and
			movement_mode == MovementModes.match_yaw) then
		speedsign = 1
		targetspeed = 32
		if (v > 32) then
			if (v > 33.85) then targetspeed = targetspeed + 1 end
			goal = get_dyaw(get_goal_angle(targetspeed))
		else
			goal = get_dyaw(13927)
		end

	-- long jump land (backwards)
	elseif (v > -337 / 30 - offset / 1.5 and v < -9.9 and
			action == LONG_JUMP_LAND and
			movement_mode == MovementModes.reverse_yaw) then
		speedsign = -1
		targetspeed = -16 - v / 2
		if (v < -11.9) then targetspeed = targetspeed - 2 end
		goal = get_dyaw(get_goal_angle(targetspeed))

	-- long jump (in the air)
	elseif (v > 46.85 and v < 47.85 + offset and
			action == LONG_JUMP and
			movement_mode == MovementModes.match_yaw) then
		speedsign = 1
		targetspeed = 48
		if (v > 49.85) then targetspeed = targetspeed + 1 end
		goal = get_dyaw(get_goal_angle(targetspeed))

	-- air movement
	elseif (v > 30.85 and v < 31.85 + offset and
			(not GROUNDED_ACTION or (action == DOUBLE_JUMP_LAND and HAS_WINGCAP and A_PRESSED)) and
			action ~= LONG_JUMP and
			action ~= LONG_JUMP_LAND and
			action ~= CROUCH_SLIDE and
			(action ~= DIVE_SLIDE or ((A_PRESSED) or (B_PRESSED))) and
			((B_HELD or not current_input.B) or action == DIVE_SLIDE) and
			movement_mode == MovementModes.match_yaw) then
		speedsign = 1
		targetspeed = 32
		if (v > 33.85) then targetspeed = targetspeed + 1 end
		goal = get_dyaw(get_goal_angle(targetspeed))
		if (REFLECT_ACTION and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			goal = (goal + 32768) % 65536
		end

	-- air dive
	elseif (v > 15.85 and v < 16.85 + offset and
			(((action == TRIPLE_JUMP or
			action == SPECIAL_TRIPLE_JUMP or
			action == WALL_KICK or
			action == FLYING_TRIPLE_JUMP or
			action == SIDEFLIP or
			action == FREEFALL) or
			(action == DOUBLE_JUMP_LAND and HAS_WINGCAP)) and B_PRESSED) and
			movement_mode == MovementModes.match_yaw) then
		speedsign = 1
		targetspeed = 32 - 15
		if (v > 18.85) then targetspeed = targetspeed + 1 end
		goal = get_dyaw(get_goal_angle(targetspeed))
		if (REFLECT_ACTION and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			goal = (goal + 32768) % 65536
		end

	-- crouching/backflip land (backwards)
	elseif (v > -32 and v < 32 and
			((action >= CROUCHING and action <= START_CRAWLING) or
			action == BACKFLIP_LAND or
			action == BACKFLIP_LAND_STOP) and
			movement_mode == MovementModes.reverse_yaw) then
		speedsign = -1
		goal = get_dyaw(18840)

	-- wingcap triple jump (backwards)
	elseif (v > -16.85 - offset and v < -14.85 and
			action ~= LONG_JUMP_LAND and
			((not GROUNDED_ACTION and
			(action ~= TRIPLE_JUMP and
			action ~= SPECIAL_TRIPLE_JUMP and
			action ~= WALL_KICK and
			action ~= FLYING_TRIPLE_JUMP and
			action ~= SIDEFLIP and
			action ~= FREEFALL or
			B_HELD or not current_input.B)) or
			(action == DOUBLE_JUMP_LAND and A_PRESSED and (B_HELD or not current_input.B) and HAS_WINGCAP)) and
			movement_mode == MovementModes.reverse_yaw) then
		speedsign = -1
		targetspeed = -16
		if (v < -17.85) then targetspeed = targetspeed - 2 end
		goal = get_dyaw(get_goal_angle(targetspeed))

	-- air dive (backwards)
	elseif (v > -31.85 - offset and v < -29.85 and
			action ~= LONG_JUMP_LAND and
			(((action == TRIPLE_JUMP or
			action == SPECIAL_TRIPLE_JUMP or
			action == WALL_KICK or
			action == FLYING_TRIPLE_JUMP or
			action == SIDEFLIP or
			action == FREEFALL) or
			(action == DOUBLE_JUMP_LAND and
			HAS_WINGCAP)) and
			B_PRESSED) and
			movement_mode == MovementModes.reverse_yaw) then
		speedsign = -1
		targetspeed = -16 - 15
		if (v < -32.85) then targetspeed = targetspeed - 2 end
		goal = get_dyaw(get_goal_angle(targetspeed))

	-- single jump (backwards)
	elseif (v > -21.0625 - offset / 0.8 and v < -18.5625 and
			action ~= LONG_JUMP_LAND and
			(action ~= DOUBLE_JUMP_LAND or not HAS_WINGCAP) and
			(GROUNDED_ACTION or action == CROUCH_SLIDE) and
			A_PRESSED and
			movement_mode == MovementModes.reverse_yaw) then
		speedsign = -1
		targetspeed = -16 + v / 5
		if (v < -22.3125) then targetspeed = targetspeed - 2 end
		goal = get_dyaw(get_goal_angle(targetspeed))

	-- single jump
	elseif (v > 38.5625 and v < 39.8125 + offset / 0.8 and
			action ~= LONG_JUMP_LAND and
			action ~= LONG_JUMP and
			(action ~= DOUBLE_JUMP_LAND or not HAS_WINGCAP) and
			GROUNDED_ACTION and
			A_PRESSED and (B_HELD or not current_input.B) and
			movement_mode == MovementModes.match_yaw) then
		speedsign = 1
		targetspeed = 32 + v / 5
		if (v > 42.3125) then targetspeed = targetspeed + 1 end
		goal = get_dyaw(get_goal_angle(targetspeed))

	-- triple jump dive
	elseif (v > 20 and v < 21.0625 + offset / 0.8 and
			action == DOUBLE_JUMP_LAND and
			not HAS_WINGCAP and A_PRESSED and B_PRESSED and
			movement_mode == MovementModes.match_yaw) then
		speedsign = 1
		targetspeed = 32 - 15 + v / 5
		if (v > 23.5625) then targetspeed = targetspeed + 1 end
		goal = get_dyaw(get_goal_angle(targetspeed))
	end

	if goal == nil then
		return nil
	end

	-- given controller inputs, compute updated air speed and return the
	-- newly computed speed and whether it is under the target or not
	local verify_speed_under_threshold = function(x, y, mag)
		local intended_mag = mag * mag / 4096
		local indendedYaw = Angles.atan2s(-y, x) + Memory.current.camera_angle
		local new_v = v - 0.35
		if v < 0 then
			new_v = v + 0.35
		end
		new_v = new_v + 1.5 * intended_mag * Angles.coss(indendedYaw - Memory.current.mario_facing_yaw)
		local valid = new_v <= targetspeed
		if targetspeed < 0 then
			valid = new_v >= targetspeed
		end
		return new_v, valid
	end

	return goal + 32 * speedsign * get_dyaw_sign(), verify_speed_under_threshold
end

--- Bruteforce search in a neighbourhood for better inputs.
--- @param x0 int # initial joystick x coordinate to search around
--- @param y0 int # initial joystick y coordinate to search around
--- @param metric function(x, y, mag) # a scoring function to determine
---		which input to choose. Higher is better. Inputs with a score of
---		nil will be excluded.
local function find_best_joystick(x0, y0, metric)
	local best_x, best_y = x0, y0
	local best_score = nil
	local x, y, mag

	-- choice of search range is arbitrary but seems to work consistently
	for i = -32, 32 do
		for j = -32, 32 do
			x, y, mag = normalize_joystick(x0 + i, y0 + j)
			local score = metric(x, y, mag)
			if score ~= nil and (best_score == nil or score > best_score) then
				best_score = score
				best_x, best_y = x0 + i, y0 + j
			end
		end
	end

	-- normalize again in case it picks something in the deadzone
	if math.abs(best_x) < 8 then
		best_x = 0
	end
	if math.abs(best_y) < 8 then
		best_y = 0
	end

	return best_x, best_y
end

--- Return the joystick coordinates to hold based on a target angle
--- @param goal # the target angle
--- @param current_input # the controller inputs pressed on this frame
--- @param movement_mode # the intention of the goal angle
Engine.inputs_for_angle = function(goal, current_input, movement_mode)
	corrected_facing_yaw = Memory.current.mario_facing_yaw

	-- far camera + C up was pressed + A is pressed this frame + side stepping
	if (Memory.current.camera_flags % 4 < 2 and
			Memory.current.mario_pressed_buttons % 16 > 7 and
			Memory.current.mario_held_buttons < 128 and current_input.A and
			(Memory.current.mario_animation == 127 or Memory.current.mario_animation == 128)) then
		corrected_facing_yaw = Memory.current.mario_gfx_angle
	end

	local action = Memory.current.mario_action
	local REFLECT_ACTION = (action == AIR_HIT_WALL or
			action == SOFT_BONK or
			action == BACKWARDS_AIR_KB or
			action == HOLDING_POLE or
			action == CLIMBING_POLE)

	if (movement_mode == MovementModes.match_yaw) then
		goal = corrected_facing_yaw
		if (REFLECT_ACTION and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			goal = (goal + 32768) % 65536
		end
	end
	if (movement_mode == MovementModes.reverse_yaw) then
		goal = (corrected_facing_yaw + 32768) % 65536
		if (REFLECT_ACTION and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			goal = corrected_facing_yaw
		end
	end

	local verify_xx99 = nil
	if Settings.tas.strain_speed_target then
		local xx99_goal
		xx99_goal, verify_xx99 = Engine.get_point99_trick_goal_angle(
			action,
			Memory.current.mario_f_speed,
			current_input,
			movement_mode
		)
		if xx99_goal ~= nil then
			goal = xx99_goal
		end
	end

	if (movement_mode == MovementModes.match_angle and Settings.tas.dyaw) then
		goal = get_dyaw(goal)
		if (REFLECT_ACTION and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			goal = (goal + 32768) % 65536
		end
	end

	if (Settings.tas.atan_strain) then
		goal = Engine.get_arctan_angle(
			Settings.tas.atan_r,
			Settings.tas.atan_d,
			Settings.tas.atan_n,
			Settings.tas.atan_start,
			goal % 65536,
			Settings.tas.reverse_arc,
			movement_mode
		)
	end

	goal = goal - 65536
	while (Memory.current.camera_angle > goal) do
		goal = goal + 65536
	end

	-- Binary search to determine the input that gives closest achievable angle.
	-- Note: this does not consider hex angle units: sometimes it might be preferable
	-- 		 to achieve goal+15 rather than goal-1.
	minang = 1
	maxang = Angles.COUNT
	midang = math.floor((minang + maxang) / 2)
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
		local first_angle_dist = math.abs(Angles.ANGLE[1].angle + Memory.current.camera_angle - (goal - 65536))
		local last_angle_dist = math.abs(Angles.ANGLE[Angles.COUNT].angle + Memory.current.camera_angle - goal)
		if first_angle_dist > last_angle_dist then
			minang = Angles.COUNT
		end
	end
	local result = {
		angle = (Angles.ANGLE[minang].angle + Memory.current.camera_angle) % 65536,
		X = Angles.ANGLE[minang].X,
		Y = Angles.ANGLE[minang].Y,
	}

	if verify_xx99 ~= nil then
		local x, y, mag, new_v, valid
		x, y, mag = normalize_joystick(result.X, result.Y)
		new_v, valid = verify_xx99(x, y, mag)
		if not valid then
			local drag = -1
			if movement_mode == MovementModes.reverse_yaw then
				drag = 2
			end
			local metric = function(x, y, mag)
				local new_v, valid
				new_v, valid = verify_xx99(x, y, mag)
				if valid then
					return new_v
				end
				return new_v + drag
			end
			result.X, result.Y = find_best_joystick(result.X, result.Y, metric, true)
		end
	end

	return result
end

function Engine.get_speed_efficiency()
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

function Engine.get_h_sliding_speed()
	return math.sqrt((Memory.current.mario_x_sliding_speed ^ 2) + (Memory.current.mario_z_sliding_speed ^ 2))
end

-- Returns the slipperiness class of Mario's floor.
local function mario_get_floor_class(floor_type)
    local floor_class = SURFACE_CLASS_DEFAULT

    -- slide terrain type defaults to slide slipperiness
    if ((Memory.current.area_terrain_type & 7) == 6) then
        floor_class = SURFACE_CLASS_VERY_SLIPPERY
	end

    if (Memory.current.floor_address ~= 0) then
		if (floor_type == SURFACE_NOT_SLIPPERY or
				floor_type == SURFACE_HARD_NOT_SLIPPERY or
				floor_type == SURFACE_SWITCH) then
			floor_class = SURFACE_CLASS_NOT_SLIPPERY
		elseif (floor_type == SURFACE_SLIPPERY or
				floor_type == SURFACE_NOISE_SLIPPERY or
				floor_type == SURFACE_HARD_SLIPPERY or
				floor_type == SURFACE_NO_CAM_COL_SLIPPERY) then
			floor_class = SURFACE_CLASS_SLIPPERY
		elseif (floor_type == SURFACE_VERY_SLIPPERY or
				floor_type == SURFACE_ICE or
				floor_type == SURFACE_HARD_VERY_SLIPPERY or
				floor_type == SURFACE_NOISE_VERY_SLIPPERY_73 or
				floor_type == SURFACE_NOISE_VERY_SLIPPERY_74 or
				floor_type == SURFACE_NOISE_VERY_SLIPPERY or
				floor_type == SURFACE_NO_CAM_COL_VERY_SLIPPERY) then
			floor_class = SURFACE_CLASS_VERY_SLIPPERY
		end
    end

    return floor_class
end

local function mario_floor_is_slope(floor_type, norm_y)
	-- check if terrain is a slide
    if ((Memory.current.area_terrain_type & 7) == 6 and norm_y < 0.9998477) then
        return true
	end

	local floor_class = mario_get_floor_class(floor_type)
	if floor_class == SURFACE_VERY_SLIPPERY then
		return norm_y <= 0.9961947
	elseif floor_class == SURFACE_SLIPPERY then
		return norm_y <= 0.9848077
	elseif floor_class == SURFACE_NOT_SLIPPERY then
		return norm_y <= 0.9396926
	end

    return norm_y <= 0.9659258
end

local function approach(current, target, increment, decrement)
	if current < target then
		if current + increment > target then
			return target
		end
		return current + increment
	end
	if current - decrement < target then
		return target
	end
	return current - decrement
end

-- Returns Mario's updated hspd
local function apply_slope_accel(floor_type, floor_norm, hspd, updated_yaw)
    if (not mario_floor_is_slope(floor_type, floor_norm.y)) then
		return hspd
	end
	
    local steepness = math.sqrt(floor_norm.x * floor_norm.x + floor_norm.z * floor_norm.z)
	local slope_class = mario_get_floor_class(floor_type)
	local floor_dyaw = (Memory.current.floor_yaw - updated_yaw) % 65536
	if floor_dyaw >= 32768 then floor_dyaw = floor_dyaw - 65536 end -- s16 cast
	local sign = (floor_dyaw > -0x4000 and floor_dyaw < 0x4000) and 1 or -1

	if slope_class == SURFACE_CLASS_VERY_SLIPPERY then
		return hspd + sign * 5.3 * steepness
	elseif slope_class == SURFACE_CLASS_SLIPPERY then
		return hspd + sign * 2.7 * steepness
	elseif slope_class == SURFACE_CLASS_NOT_SLIPPERY then
		return hspd
	end
	return hspd + sign * 1.7 * steepness
end

-- returns Mario's updated speed.
local function update_walk_speed(floor_type, floor_norm, hspd, intended_mag, intended_yaw)
	local maxTargetSpeed = 32
	if floor_type == SURFACE_SLOW then maxTargetSpeed = 24 end
	local target_speed = intended_mag
	if maxTargetSpeed < intended_mag then
		target_speed = maxTargetSpeed
	end
	--if quicksandDepth > 10 then target_speed = target_speed * 6.25 / quicksandDepth end
	local new_hspd = hspd
	if (hspd <= 0.0) then
		new_hspd = hspd + 1.1
	elseif (hspd <= target_speed) then
		new_hspd = hspd + 1.1 - hspd / 43
	elseif (floor_norm.y >= 0.95) then
		new_hspd = hspd - 1
	end
	if new_hspd > 48 then
		new_hspd = 48
	end
	local updated_yaw = intended_yaw - approach(intended_yaw - Memory.current.mario_facing_yaw, 0, 0x800, 0x800)
	return apply_slope_accel(floor_type, floor_norm, new_hspd, updated_yaw)
end

--- Modifies input.X and input.Y to have a similar angle, but a smaller magnitude.
--- This aims to match the angle as close as it can.
--- @param input table # joystick inputs {X: int, Y: int}
--- @param goal_mag int # the maximum allowed magnitude for the choice of inputs
--- @param maximize_airspeed boolean # when true, it choses inputs based on the air speed
---		equations instead of based on how close the angle is to the original input
--- @param dustless_walk boolean # when true, it excludes inputs that will cause dust particles
Engine.scale_inputs_to_magnitude = function(input, goal_mag, maximize_airspeed, dustless_walk)
	-- all inputs above a magnitude of 64 are scaled down to 64 anyways
	if goal_mag >= 64 then return end

	local start_x, start_y = input.X, input.Y
	local x0, y0 = 0, 0
	if start_x == 0 then
		y0 = goal_mag + 6
	elseif start_y == 0 then
		x0 = goal_mag + 6
	else
		-- solve for x0, y0 with the same angle as start_x, start_y and new magnitude goal_mag
		-- https://www.wolframalpha.com/input/?i=solve+%7Bsqrt%28%28x0-6%29%C2%B2+%2B+%28y0-6%29%5E2%29+%3D+k%3B+atan2%28y%2Cx%29+%3D+atan2%28y0%2Cx0%29+%7D+for+x0+and+y0
		local k = goal_mag
		local x, y = math.abs(start_x), math.abs(start_y)
		local x2, y2 = x * x, y * y
		local crazy = math.sqrt((4 * (k ^ 2 - 72) * y2) / (x2 + y2) + (y2 * (-12 * x - 12 * y) ^ 2) / (x2 + y2) ^ 2)
		x0 = math.floor(math.abs(x * crazy / (2 * y) + (6 * x2) / (x2 + y2) + (6 * x * y) / (x2 + y2)))
		y0 = math.floor(math.abs(0.5 * crazy + (6 * y2) / (x2 + y2) + (6 * x * y) / (x2 + y2)))
	end
	-- ensure correct quadrant
	if start_x < 0 then x0 = -x0 end
	if start_y < 0 then y0 = -y0 end
	-- NaN guard
	if x0 ~= x0 then x0 = 0 end
	if y0 ~= y0 then y0 = 0 end

	local x, y, mag, metric
	x, y, mag = normalize_joystick(start_x, start_y)
	local goal_angle = math.atan2(-y, x)

	if maximize_airspeed then
		-- air movement hspd update without constant factors
		metric = function(x, y, mag)
			if mag > goal_mag then return nil end
			local indendedYaw = Angles.atan2s(-y, x) + Memory.current.camera_angle
			return mag * mag * Angles.coss(indendedYaw - Memory.current.mario_facing_yaw)
		end
	elseif dustless_walk then
		local mario_yaw = Memory.current.mario_facing_yaw
		local camera_yaw = Memory.current.camera_angle
		local action = Memory.current.mario_action
		local floor_norm = {
			x = Memory.current.floor_normal_x,
			y = Memory.current.floor_normal_y,
			z = Memory.current.floor_normal_z,
		}
		local v0 = Memory.current.mario_f_speed

		-- disallow inputs that kickup dust particles.
		-- score based on the magnitude and how close it is to the goal angle
		metric = function(x, y, mag)
			local intended_mag = mag * mag / 128
			local intended_yaw = mario_yaw
			if intended_mag > 0 then
				intended_yaw = Angles.atan2s(-y, x) + camera_yaw
			end
			if action == HOLD_WALKING then
				intended_mag = intended_mag * 0.4
			end
			local hspd = update_walk_speed(floor_type, floor_norm, v0, intended_mag, intended_yaw)
			if action == HOLD_WALKING then
				if 0.4 * intended_mag > hspd + 10 then
					return nil
				end
			elseif intended_mag > hspd + 16 then
				return nil
			end
			return math.cos(math.atan2(-y, x) - goal_angle) * 1e4 + intended_mag
		end

		-- if a full mag input doesn't spawn dust then don't search for other inputs
		x, y, mag = normalize_joystick(input.X, input.Y)
		if metric(x, y, mag) ~= nil then
			return
		end
	else -- match closest angle
		metric = function(x, y, mag)
			if mag > goal_mag then return nil end
			local angle = math.atan2(-y, x)
			return math.cos(angle - goal_angle)
		end
	end
	
	input.X, input.Y = find_best_joystick(x0, y0, metric)
end

--- Modifies input.X and input.Y to have a similar angle, but a smaller magnitude,
--- such that dust particles are not spawned while walking.
Engine.scale_inputs_for_dustless_walk = function(input)
	if (Memory.current.mario_action & (ACT_FLAG_AIR | ACT_FLAG_SWIMMING)) > 0 then
		Settings.tas.goal_mag = 64
		return -- not on the ground
	end
	Engine.scale_inputs_to_magnitude(input, 63, false, true)
	local x, y, mag
	x, y, mag = normalize_joystick(input.X, input.Y)
	Settings.tas.goal_mag = math.ceil(mag)
end

