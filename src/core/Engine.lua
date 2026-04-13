--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

-- Mario action codes. These match the values used in the SM64 game engine.
-- Used to detect what Mario is currently doing so the TAS engine can choose
-- the right goal angle / speed target.
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
local HOLD_WALKING = 0x00000442 -- Replace 0x04000442 with this?
local TURNING_AROUND = 0x00000443 -- Replace 0x04000443 with this?
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

-- Jump landing actions form a contiguous range, so we can range-check them.
-- MARIO action >= 0x04000470, <= 0x04000473
local JUMP_LAND = 0x04000470
local FREEFALL_LAND = 0x04000471
local DOUBLE_JUMP_LAND = 0x04000472
local SIDE_FLIP_LAND = 0x04000473

-- Hold/quicksand landing actions, also contiguous.
-- MARIO action >= 0x00000474, <= 0x00000477
local HOLD_JUMP_LAND = 0x00000474
local HOLD_FREEFALL_LAND = 0x00000475
local QUICKSAND_JUMP_LAND = 0x00000476
local HOLD_QUICKSAND_JUMP_LAND = 0x00000477

-- Crouching actions, contiguous range.
-- MARIO action >= 0x0C008220, <= 0x0C008223
local CROUCHING = 0x0C008220
local START_CROUCHING = 0x0C008221
local STOP_CROUCHING = 0x0C008222
local START_CRAWLING = 0x0C008223 


Engine = {}

-- Movement modes control how the TAS engine computes the goal angle each frame.
--   disabled   : engine does nothing, raw controller input is passed through
--   manual     : user-specified fixed joystick X/Y values are used
--   match_yaw  : goal angle = Mario's current facing yaw (move in the direction Mario faces)
--   reverse_yaw: goal angle = facing yaw + 180° (move opposite to Mario's facing)
--   match_angle: goal angle = arbitrary user-set angle (free direction control)
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

-- Returns the effective joystick magnitude after the game's deadzone is applied.
-- SM64 subtracts 6 from each axis before computing magnitude, and clamps to 0.
-- So inputs with |x| <= 6 and |y| <= 6 contribute nothing to movement.
---@param x number  Raw joystick X (-128..127)
---@param y number  Raw joystick Y (-128..127)
---@return number   Effective magnitude (0 = fully in deadzone)
function Engine.get_magnitude_for_stick(x, y)
	-- SM64 deadzone: |val| <= 7 is zeroed, |val| >= 8 has 6 subtracted.
	-- math.max(0, |x| - 6) would give 1 for x=7, but the game actually zeros it.
	local ex = math.abs(x) >= 8 and math.abs(x) - 6 or 0
	local ey = math.abs(y) >= 8 and math.abs(y) - 6 or 0
	return math.sqrt(ex * ex + ey * ey)
end

-- Returns the angle after optionally truncating to the nearest multiple of 16.
-- The original input.lua snapped angles to multiples of 16 by default, which
-- caused precision loss. This function preserves the full angle unless the
-- setting is explicitly enabled.
function Engine.get_effective_angle(angle)
	-- NOTE: previous input lua snaps angle to multiple 16 by default, incurring a precision loss
	if Settings.truncate_effective_angle then
		return angle - (angle % 16)
	end
	return angle
end

-- Returns the absolute goal angle (in SM64 angle units, 0..65535) from a
-- relative dyaw offset, based on the current strain direction setting:
--   strain_left only  → always add dyaw (turn left)
--   strain_right only → always subtract dyaw (turn right)
--   neither           → alternate each frame: +dyaw on even frames, -dyaw on odd frames
--                       (this is the "oscillating strain" used to gain speed while strafing)
--   both              → return dyaw unchanged (used when movement_mode == match_angle)
function Engine.getDyaw(angle)
	if Settings.tas.strain_left and Settings.tas.strain_right == false then
		return corrected_facing_yaw + angle
	elseif Settings.tas.strain_left == false and Settings.tas.strain_right then
		return corrected_facing_yaw - angle
	elseif Settings.tas.strain_left == false and Settings.tas.strain_right == false then
		-- Alternate sign every frame: even frame = +, odd frame = -
		return corrected_facing_yaw + angle * (math.pow(-1, Memory.current.mario_global_timer % 2))
	else
		return angle
	end
end

-- Returns +1, -1, or 0 depending on the current strain direction.
-- Used to apply a small angle nudge (32 units) to the goal after speed-target
-- selection, so Mario gains speed in the correct direction.
--   strain_left only  → +1
--   strain_right only → -1
--   neither           → alternates each frame (±1)
--   both              → 0 (no nudge, used in match_angle mode)
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

-- These globals are set inside inputsForAngle each frame and consumed at the end.
-- actionflag : 1 if Mario is in a "grounded" action (walk, land, brake, etc.), 0 otherwise
-- speedsign  : +1 for forward speed targets, -1 for reverse, 0 if no target matched
-- targetspeed: the speed value we are currently trying to reach
ENABLE_REVERSE_YAW_ON_WALLKICK = true
actionflag = 0
speedsign = 0
targetspeed = 0.0

-- Returns the dyaw angle offset (in SM64 units) needed to reach targetspd next frame.
-- Based on the SM64 walking speed formula: new_speed = old_speed + 1.5 * cos(dyaw)
-- Rearranged: dyaw = acos((targetspd ± 0.35 - current_speed) / 1.5)
-- The ±0.35 is a tolerance buffer to avoid overshooting the target speed.
function Engine.getgoal(targetspd)
	if (targetspd > 0) then
		return math.floor(math.acos((targetspd + 0.35 - Memory.current.mario_f_speed) / 1.5) * 32768 / math.pi)
	end
	return math.floor(math.acos((targetspd - 0.35 - Memory.current.mario_f_speed) / 1.5) * 32768 / math.pi)
end

-- Computes a goal angle that follows an arctan curve over N frames,
-- smoothly approaching the goal from a large initial offset.
-- Used for the "atan strain" feature: instead of snapping to the goal angle
-- immediately, Mario's input angle sweeps in from far away following an
-- arctan curve. This is useful for speed-gain setups that require a specific
-- angular approach path.
--
-- Parameters:
--   r    : ratio / steepness of the arctan curve (higher = faster approach)
--   d    : displacement added to the curve argument (shifts the curve left/right in time)
--   n    : total number of frames the curve runs over
--   s    : the starting global frame number (1-indexed, adjusted to 0-indexed internally)
--   goal : the target angle to approach (SM64 angle units, 0..65535)
--
-- The arctan formula used:
--   dyaw = (π/2 - atan(0.15 * (r * frames_remaining + d / frames_remaining))) * 32768/π
-- This produces a large dyaw early in the window that shrinks toward 0 as the
-- end of the window approaches, creating a smooth arc.
function Engine.getArctanAngle(r, d, n, s, goal)
	s = s - 1  -- convert from 1-indexed to 0-indexed frame number
	if (s < Memory.current.mario_global_timer and s > Memory.current.mario_global_timer - n - 1) then
		-- Base yaw: normally 0, but flip 180° if Mario is in a wall-bouncing action
		-- so the curve approaches from the correct side after a bounce.
		yaw = 0
		if (Memory.current.mario_action == AIR_HIT_WALL or Memory.current.mario_action == SOFT_BONK or Memory.current.mario_action == BACKWARDS_AIR_KB or Memory.current.mario_action == HOLDING_POLE or Memory.current.mario_action == CLIMBING_POLE and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			yaw = 32768  -- 180° flip
		end
		if Settings.tas.movement_mode == MovementModes.match_angle then
			-- In match_angle mode, derive r automatically from the angle difference
			-- between the current facing yaw and the goal, so the curve steepness
			-- scales with how far Mario needs to turn.
			yaw = (corrected_facing_yaw + yaw) % 65536
			if (math.abs(yaw - goal) > 16384 and math.abs(yaw - goal) <= 49152) then
				-- Goal is on the "far" side (more than 90° away): negate r so the
				-- curve approaches from the correct direction.
				r = -math.abs(math.tan(math.pi / 2 -
					(Engine.get_effective_angle(yaw) - goal) * math.pi / 32768))
			else
				r = math.abs(math.tan(math.pi / 2 -
					(Engine.get_effective_angle(yaw) - goal) * math.pi / 32768))
			end
		end
		if (Settings.tas.reverse_arc == false) then
			-- Forward arc: dyaw shrinks as we get closer to the end of the window
			-- (frames_remaining = n + 1 - current_frame_offset)
			dyaw = math.floor((math.pi / 2 - math.atan(0.15 * (r * math.max(1, (n + 1 - Memory.current.mario_global_timer + s)) + d / math.min(1, n + 1 - Memory.current.mario_global_timer + s)))) *
				32768 / math.pi)
			if (Settings.tas.movement_mode == MovementModes.match_angle) then
				-- In match_angle mode, apply dyaw toward the goal (add or subtract
				-- depending on which side of goal we are on)
				if ((yaw - goal + 32768) % 65536 - 32768 > 0) then
					return yaw - dyaw
				end
				return yaw + dyaw
			end
			return (Engine.getDyaw(dyaw) + yaw) % 65536
		end
		-- Reverse arc: dyaw grows as we move further from the start of the window
		-- (frames_elapsed = current_frame_offset - s)
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
	-- Outside the frame window: just return the goal angle unchanged
	return goal
end

-- Given a goal angle (SM64 units, 0..65535), computes the raw joystick X/Y
-- that will make Mario move toward that angle this frame.
--
-- Steps:
--   1. Determine the corrected facing yaw (accounting for the long-jump camera trick)
--   2. Override goal based on movement mode (match_yaw, reverse_yaw)
--   3. If strain_speed_target is on, pick a goal angle that targets a specific
--      speed value next frame (the "speed target" system)
--   4. Optionally apply the arctan strain curve
--   5. Binary-search the precomputed Angles table for the closest valid joystick
--      input that produces the computed goal angle relative to the camera
--
-- Returns: { angle, X, Y }
Engine.inputsForAngle = function(goal, curr_input)

	-- -------------------------------------------------------------------------
	-- Step 1: Correct facing yaw for the long-jump camera trick.
	-- During a long jump, if Mario is performing the sliding animation and the
	-- camera is in certain modes, the game uses mario_gfx_angle instead of the
	-- normal facing yaw to compute movement direction. We replicate that here.
	-- -------------------------------------------------------------------------
	corrected_facing_yaw = Memory.current.mario_facing_yaw
	if (Memory.current.camera_flags % 4 < 2 and Memory.current.mario_pressed_buttons % 16 > 7 and Memory.current.mario_held_buttons < 128 and curr_input.A and (Memory.current.mario_animation == 127 or Memory.current.mario_animation == 128)) then
		corrected_facing_yaw = Memory.current.mario_gfx_angle
	end

	-- -------------------------------------------------------------------------
	-- Step 2: Override goal based on movement mode.
	-- -------------------------------------------------------------------------

	-- match_yaw: always face the direction Mario is currently facing.
	-- If Mario just hit a wall (air_hit_wall, soft_bonk, etc.) and the wallkick
	-- reverse is enabled, flip 180° so Mario moves away from the wall correctly.
	if (Settings.tas.movement_mode == MovementModes.match_yaw) then
		goal = corrected_facing_yaw
		if ((Memory.current.mario_action == AIR_HIT_WALL or Memory.current.mario_action == SOFT_BONK or Memory.current.mario_action == BACKWARDS_AIR_KB or Memory.current.mario_action == HOLDING_POLE or Memory.current.mario_action == CLIMBING_POLE) and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			goal = (goal + 32768) % 65536
		end
	end

	-- reverse_yaw: always face opposite to Mario's current facing.
	-- Same wallkick flip logic, but reversed: the flip brings us back to the
	-- original facing direction instead of away from it.
	if (Settings.tas.movement_mode == MovementModes.reverse_yaw) then
		goal = (corrected_facing_yaw + 32768) % 65536
		if ((Memory.current.mario_action == AIR_HIT_WALL or Memory.current.mario_action == SOFT_BONK or Memory.current.mario_action == BACKWARDS_AIR_KB or Memory.current.mario_action == HOLDING_POLE or Memory.current.mario_action == CLIMBING_POLE) and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			goal = corrected_facing_yaw
		end
	end

	-- -------------------------------------------------------------------------
	-- Step 3: Speed target system.
	-- When strain_speed_target is enabled, override the goal angle so Mario's
	-- forward speed reaches a specific target value next frame.
	-- "offset" widens the speed windows when strain_always is on, allowing the
	-- speed target to trigger over a broader range of current speeds.
	-- -------------------------------------------------------------------------

	-- offset = 3 when strain_always is on; widens all speed-target windows below
	if (Settings.tas.strain_always) then
		offset = 3
	else
		offset = 0
	end

	if Settings.tas.strain_speed_target then

		-- actionflag = 1 means Mario is in a "grounded" state (walking, landing,
		-- braking, butt-slide, etc.). Used below to distinguish air vs ground cases.
		if Memory.current.mario_action == WALKING
			or Memory.current.mario_action == DECELERATING
			or Memory.current.mario_action == LAVA_BOOST_LAND
			or Memory.current.mario_action == FREEFALL_LAND_STOP
			or Memory.current.mario_action == 0x04000442   -- HOLD_WALKING (uncertain, see constant above)
			or Memory.current.mario_action == 0x04000443   -- TURNING_AROUND (uncertain, see constant above)
			or Memory.current.mario_action == LAVA_BOOST
			or Memory.current.mario_action == BRAKING
			or Memory.current.mario_action == HOLD_BUTT_SLIDE
			or Memory.current.mario_action == BUTT_SLIDE
			or (Memory.current.mario_action >= JUMP_LAND and Memory.current.mario_action <= SIDE_FLIP_LAND)
			or (Memory.current.mario_action >= HOLD_JUMP_LAND and Memory.current.mario_action <= HOLD_QUICKSAND_JUMP_LAND)
		then
			actionflag = 1
		else
			actionflag = 0
		end

		-- ----- Speed target case 1: Crouch-slide / long-jump-land → target speed 48 -----
		-- Condition: speed ~31 (from above), crouch-slide or long-jump-land,
		--            A held, B not held, match_yaw mode.
		-- If speed is already above 32 use a fixed dyaw of 13927 (~24.3°, which is
		-- the angle that produces exactly +0 speed change at speed 32 in the formula),
		-- otherwise compute the angle needed to reach targetspeed next frame.
		if (Memory.current.mario_f_speed > 937 / 30 and Memory.current.mario_f_speed < 31.9 + offset * 3000000
			and (Memory.current.mario_action == CROUCH_SLIDE or Memory.current.mario_action == LONG_JUMP_LAND)
			and Memory.current.mario_held_buttons < 128 and curr_input.A
			and (Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B)
			and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 48 - Memory.current.mario_f_speed / 2
			speedsign = 1
			if (Memory.current.mario_f_speed > 32) then
				goal = Engine.getDyaw(13927)
			else
				goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			end

		-- ----- Speed target case 2: Crouch-slide with strain_always → target speed 32 -----
		-- Only active when offset ~= 0 (i.e. strain_always is on).
		-- B held, A not held, speed 10..34.85, match_yaw mode.
		elseif (Memory.current.mario_f_speed >= 10 and offset ~= 0 and Memory.current.mario_f_speed < 34.85
			and Memory.current.mario_action == CROUCH_SLIDE
			and (Memory.current.mario_held_buttons > 127 or not curr_input.A)
			and Memory.current.mario_held_buttons % 128 < 64 and curr_input.B
			and Settings.tas.movement_mode == MovementModes.match_yaw) then
			speedsign = 1
			targetspeed = 32
			if (Memory.current.mario_f_speed > 32) then
				if (Memory.current.mario_f_speed > 33.85) then targetspeed = targetspeed + 1 end
				goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			else
				goal = Engine.getDyaw(13927)
			end

		-- ----- Speed target case 3: Long-jump-land reverse → target speed -16 -----
		-- Speed is between ~-11.2 and -9.9 (going backwards), reverse_yaw mode.
		elseif (Memory.current.mario_f_speed > -337 / 30 - offset / 1.5 and Memory.current.mario_f_speed < -9.9
			and Memory.current.mario_action == LONG_JUMP_LAND
			and Settings.tas.movement_mode == MovementModes.reverse_yaw) then
			targetspeed = -16 - Memory.current.mario_f_speed / 2
			if (Memory.current.mario_f_speed < -11.9) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))

		-- ----- Speed target case 4: Long jump → target speed 48 -----
		-- Speed is near 47, A held, match_yaw mode.
		elseif (Memory.current.mario_f_speed > 46.85 and Memory.current.mario_f_speed < 47.85 + offset
			and Memory.current.mario_action == LONG_JUMP
			and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 48
			if (Memory.current.mario_f_speed > 49.85) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))

		-- ----- Speed target case 5: General forward → target speed 32 from ~31 -----
		-- Broad case: speed near 31, not a jump/crouch-slide, A held (or dive-slide),
		-- no B (unless dive-slide), match_yaw mode.
		-- Excludes long jump, long jump land, and crouch slide (handled above).
		-- Also applies to double-jump-land with cap if actionflag is 1.
		-- After computing the goal, if Mario is bouncing off a wall, flip 180°.
		elseif (Memory.current.mario_f_speed > 30.85 and Memory.current.mario_f_speed < 31.85 + offset
			and (actionflag == 0 or (Memory.current.mario_action == DOUBLE_JUMP_LAND and Memory.current.mario_hat_state % 16 > 7 and Memory.current.mario_held_buttons < 128 and curr_input.A))
			and Memory.current.mario_action ~= LONG_JUMP
			and Memory.current.mario_action ~= LONG_JUMP_LAND
			and Memory.current.mario_action ~= CROUCH_SLIDE
			and (Memory.current.mario_action ~= DIVE_SLIDE or ((Memory.current.mario_held_buttons < 128 and curr_input.A) or (Memory.current.mario_held_buttons % 128 < 64 and curr_input.B)))
			and ((Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B) or Memory.current.mario_action == DIVE_SLIDE)
			and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 32
			if (Memory.current.mario_f_speed > 33.85) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			if (Memory.current.mario_action == AIR_HIT_WALL or Memory.current.mario_action == SOFT_BONK or Memory.current.mario_action == BACKWARDS_AIR_KB or Memory.current.mario_action == HOLDING_POLE or Memory.current.mario_action == CLIMBING_POLE and ENABLE_REVERSE_YAW_ON_WALLKICK) then
				goal = (goal + 32768) % 65536
			end

		-- ----- Speed target case 6: Air actions with B → target speed 17 from ~16 -----
		-- Triple jump, wall kick, sideflip, freefall, etc. with B held, speed near 16.
		-- Also includes double-jump-land with cap. match_yaw mode.
		elseif (Memory.current.mario_f_speed > 15.85 and Memory.current.mario_f_speed < 16.85 + offset
			and (((Memory.current.mario_action == TRIPLE_JUMP
				or Memory.current.mario_action == SPECIAL_TRIPLE_JUMP
				or Memory.current.mario_action == WALL_KICK
				or Memory.current.mario_action == FLYING_TRIPLE_JUMP
				or Memory.current.mario_action == SIDEFLIP
				or Memory.current.mario_action == FREEFALL)
				or (Memory.current.mario_action == DOUBLE_JUMP_LAND and Memory.current.mario_hat_state % 16 > 7))
				and Memory.current.mario_held_buttons % 128 < 64 and curr_input.B)
			and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 32 - 15  -- = 17
			if (Memory.current.mario_f_speed > 18.85) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))
			if (Memory.current.mario_action == AIR_HIT_WALL or Memory.current.mario_action == SOFT_BONK or Memory.current.mario_action == BACKWARDS_AIR_KB or Memory.current.mario_action == HOLDING_POLE or Memory.current.mario_action == CLIMBING_POLE and ENABLE_REVERSE_YAW_ON_WALLKICK) then
				goal = (goal + 32768) % 65536
			end

		-- ----- Speed target case 7: Crouching / backflip-land reverse → fixed angle -----
		-- Speed within -32..32, crouching or backflip landing, reverse_yaw mode.
		-- Uses a fixed dyaw of 18840 (~103°) which is the angle that maximizes
		-- reverse speed gain in this state.
		elseif (Memory.current.mario_f_speed > -32 and Memory.current.mario_f_speed < 32
			and ((Memory.current.mario_action >= CROUCHING and Memory.current.mario_action <= START_CRAWLING)
				or Memory.current.mario_action == BACKFLIP_LAND
				or Memory.current.mario_action == BACKFLIP_LAND_STOP)
			and Settings.tas.movement_mode == MovementModes.reverse_yaw) then
			speedsign = -1
			goal = Engine.getDyaw(18840)

		-- ----- Speed target case 8: General reverse → target speed -16 from ~-16 -----
		-- Speed near -15, grounded actions without air-B actions, reverse_yaw mode.
		-- Excludes long-jump-land (handled above). Also handles double-jump-land with cap.
		elseif (Memory.current.mario_f_speed > -16.85 - offset and Memory.current.mario_f_speed < -14.85
			and Memory.current.mario_action ~= LONG_JUMP_LAND
			and ((actionflag == 0
					and (Memory.current.mario_action ~= TRIPLE_JUMP
						and Memory.current.mario_action ~= SPECIAL_TRIPLE_JUMP
						and Memory.current.mario_action ~= WALL_KICK
						and Memory.current.mario_action ~= FLYING_TRIPLE_JUMP
						and Memory.current.mario_action ~= SIDEFLIP
						and Memory.current.mario_action ~= FREEFALL
						or Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B))
				or (Memory.current.mario_action == DOUBLE_JUMP_LAND
						and Memory.current.mario_held_buttons < 128 and curr_input.A
						and (Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B)
						and Memory.current.mario_hat_state % 16 > 7))
			and Settings.tas.movement_mode == MovementModes.reverse_yaw) then
			targetspeed = -16
			if (Memory.current.mario_f_speed < -17.85) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))

		-- ----- Speed target case 9: Air actions with B reverse → target speed -31 -----
		-- Same air actions as case 6 but in reverse, speed near -30, reverse_yaw mode.
		elseif (Memory.current.mario_f_speed > -31.85 - offset and Memory.current.mario_f_speed < -29.85
			and Memory.current.mario_action ~= LONG_JUMP_LAND
			and (((Memory.current.mario_action == TRIPLE_JUMP
				or Memory.current.mario_action == SPECIAL_TRIPLE_JUMP
				or Memory.current.mario_action == WALL_KICK
				or Memory.current.mario_action == FLYING_TRIPLE_JUMP
				or Memory.current.mario_action == SIDEFLIP
				or Memory.current.mario_action == FREEFALL)
				or (Memory.current.mario_action == DOUBLE_JUMP_LAND and Memory.current.mario_hat_state % 16 > 7))
				and Memory.current.mario_held_buttons % 128 < 64 and curr_input.B)
			and Settings.tas.movement_mode == MovementModes.reverse_yaw) then
			targetspeed = -16 - 15  -- = -31
			if (Memory.current.mario_f_speed < -32.85) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))

		-- ----- Speed target case 10: Grounded reverse → interpolated target near -20 -----
		-- Speed near -20, grounded actions (actionflag=1 or crouch-slide), A held,
		-- not double-jump-land-with-cap, reverse_yaw mode.
		-- Target speed is interpolated from current speed: -16 + speed/5.
		elseif (Memory.current.mario_f_speed > -21.0625 - offset / 0.8 and Memory.current.mario_f_speed < -18.5625
			and Memory.current.mario_action ~= LONG_JUMP_LAND
			and (Memory.current.mario_action ~= DOUBLE_JUMP_LAND or Memory.current.mario_hat_state % 16 < 8)
			and (actionflag == 1 or Memory.current.mario_action == CROUCH_SLIDE)
			and Memory.current.mario_held_buttons < 128 and curr_input.A
			and Settings.tas.movement_mode == MovementModes.reverse_yaw) then
			targetspeed = -16 + Memory.current.mario_f_speed / 5
			if (Memory.current.mario_f_speed < -22.3125) then targetspeed = targetspeed - 2 end
			speedsign = -1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))

		-- ----- Speed target case 11: Grounded forward → interpolated target near 39 -----
		-- Speed near 39, grounded (actionflag=1), A held, B not held,
		-- not long-jump / long-jump-land / double-jump-land-with-cap, match_yaw mode.
		-- Target speed is interpolated from current speed: 32 + speed/5.
		elseif (Memory.current.mario_f_speed > 38.5625 and Memory.current.mario_f_speed < 39.8125 + offset / 0.8
			and Memory.current.mario_action ~= LONG_JUMP_LAND
			and Memory.current.mario_action ~= LONG_JUMP
			and (Memory.current.mario_action ~= DOUBLE_JUMP_LAND or Memory.current.mario_hat_state % 16 < 8)
			and actionflag == 1
			and Memory.current.mario_held_buttons < 128 and curr_input.A
			and (Memory.current.mario_held_buttons % 128 > 63 or not curr_input.B)
			and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 32 + Memory.current.mario_f_speed / 5
			if (Memory.current.mario_f_speed > 42.3125) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))

		-- ----- Speed target case 12: Double-jump-land without cap + B → interpolated target -----
		-- Speed near 20, double-jump-land, no cap (hat_state < 8), A+B held, match_yaw mode.
		-- Target speed is interpolated: 17 + speed/5.
		elseif (Memory.current.mario_f_speed > 20 and Memory.current.mario_f_speed < 21.0625 + offset / 0.8
			and Memory.current.mario_action == DOUBLE_JUMP_LAND
			and Memory.current.mario_hat_state % 16 < 8
			and Memory.current.mario_held_buttons < 128 and curr_input.A
			and Memory.current.mario_held_buttons % 128 < 64 and curr_input.B
			and Settings.tas.movement_mode == MovementModes.match_yaw) then
			targetspeed = 32 - 15 + Memory.current.mario_f_speed / 5  -- = 17 + speed/5
			if (Memory.current.mario_f_speed > 23.5625) then targetspeed = targetspeed + 1 end
			speedsign = 1
			goal = Engine.getDyaw(Engine.getgoal(targetspeed))

		else
			-- No speed target case matched this frame
			speedsign = 0
		end

		-- Apply a small 32-unit angle nudge in the strain direction.
		-- This shifts the goal angle slightly left or right (alternating each frame
		-- when oscillating) so Mario gains speed while strafing.
		goal = goal + 32 * speedsign * Engine.getDyawsign()
	end

	-- -------------------------------------------------------------------------
	-- Step 4: Optional overrides after speed target selection.
	-- -------------------------------------------------------------------------

	-- In match_angle + dyaw mode, recompute goal through getDyaw so the user-set
	-- angle is offset by the strain direction. Then flip 180° if bouncing off a wall.
	if (Settings.tas.movement_mode == MovementModes.match_angle and Settings.tas.dyaw) then
		goal = Engine.getDyaw(goal)
		if (Memory.current.mario_action == AIR_HIT_WALL or Memory.current.mario_action == SOFT_BONK or Memory.current.mario_action == BACKWARDS_AIR_KB or Memory.current.mario_action == HOLDING_POLE or Memory.current.mario_action == CLIMBING_POLE and ENABLE_REVERSE_YAW_ON_WALLKICK) then
			goal = (goal + 32768) % 65536
		end
	end

	-- Apply the arctan strain curve if enabled. This smoothly sweeps goal from
	-- a large offset toward the target over N frames (see getArctanAngle above).
	--if (Settings.tas.atan_strain and Settings.tas.atan_start < Memory.current.mario_global_timer and Settings.tas.atan_start > Memory.current.mario_global_timer - Settings.tas.atan_n - 1) then
	if (Settings.tas.atan_strain) then
		goal = goal % 65536
		goal = Engine.getArctanAngle(Settings.tas.atan_r, Settings.tas.atan_d, Settings.tas.atan_n, Settings.tas.atan_start, goal)
	end

	-- Uncommented in a previous version; left here for reference.
	-- if(Settings.tas.movement_mode ~= MovementModes.match_angle or Settings.tas.dyaw or Settings.tas.atan_strain) then
	-- 	goal = goal + Memory.current.mario_facing_yaw % 16
	-- end

	-- -------------------------------------------------------------------------
	-- Step 5: Binary search for the closest valid joystick input.
	-- The Angles table (Angles.ANGLE) is a precomputed list of all joystick X/Y
	-- pairs and the in-game angle they produce, sorted by angle offset.
	-- We want the entry whose angle (relative to camera) is closest to goal.
	-- -------------------------------------------------------------------------

	-- Normalise goal into the range [camera_angle, camera_angle + 65536) so the
	-- binary search works on a monotone sequence.
	goal = goal - 65536
	while (Memory.current.camera_angle > goal) do
		goal = goal + 65536
	end

	-- Binary search over Angles.ANGLE[1..Angles.COUNT]
	minang = 1
	maxang = Angles.COUNT
	midang = math.floor((minang + maxang) / 2)
	while (minang <= maxang) do
		if (Angles.ANGLE[midang].angle + Memory.current.camera_angle < goal) then
			minang = midang + 1
		elseif (Angles.ANGLE[midang].angle + Memory.current.camera_angle == goal) then
			-- Exact match: collapse the search window to this entry
			minang = midang
			maxang = midang - 1
		else
			maxang = midang - 1
		end
		midang = math.floor((minang + maxang) / 2)
	end

	-- If minang overflowed past the end, the goal is between the last and first
	-- entry (wraps around). Pick whichever of the two endpoints is closer.
	if minang > Angles.COUNT then
		minang = 1
		if math.abs(Angles.ANGLE[1].angle + Memory.current.camera_angle - (goal - 65536)) > math.abs(Angles.ANGLE[Angles.COUNT].angle + Memory.current.camera_angle - goal) then
			minang = Angles.COUNT
		end
	end

	if Engine.get_magnitude_for_stick(Angles.ANGLE[minang].X, Angles.ANGLE[minang].Y) == 0 then
		for offset = 1, Angles.COUNT do
			local lo = minang - offset
			local hi = minang + offset
			if lo < 1 then lo = lo + Angles.COUNT end
			if hi > Angles.COUNT then hi = hi - Angles.COUNT end
			if Engine.get_magnitude_for_stick(Angles.ANGLE[hi].X, Angles.ANGLE[hi].Y) > 0 then
				minang = hi
				break
			end
			if Engine.get_magnitude_for_stick(Angles.ANGLE[lo].X, Angles.ANGLE[lo].Y) > 0 then
				minang = lo
				break
			end
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

-- Adjusts the joystick X/Y in `result` so that the effective magnitude
-- (after SM64's deadzone) equals goal_mag, while keeping the movement angle
-- as close as possible to the angle already in result.X/Y.
--
-- `use_high_mag`: when true, prefer inputs with higher magnitude even if the
-- angle match is slightly worse (useful for setups where speed matters more
-- than direction precision).
--
-- Overview of the algorithm:
--   1. Analytically solve for the ideal (x0, y0) that satisfies both
--      get_magnitude_for_stick(x0, y0) == goal_mag  AND
--      atan2(y0, x0) == atan2(start_y, start_x).
--   2. Search a ±32 neighbourhood around (x0, y0) for the integer input that
--      maximises cos(actual_angle - goal_angle), i.e. most aligned to goal.
--      Track separately the best result that is outside the deadzone.
--   3. Prefer the best non-deadzone result over any deadzone result.
--   4. If the chosen input still has a component in the deadzone (zeroed out
--      by the game), try boundary values (±8) to find a better option.
--
-- NOTE / BUG AREA:
--   The game's deadzone zeros a component when |val| <= 6.
--   The `effectiveAngle` helper below (and the zeroed_x/zeroed_y checks) use
--   |val| < 8 as the deadzone boundary instead. This inconsistency means
--   inputs with |val| == 7 are treated as deadzone by this code but NOT by
--   the game, and inputs with |val| == 7 that happen to be the best option
--   may be incorrectly discarded or handled. This is likely related to the
--   .99 strain → .00 bug (issue #36).
Engine.scaleInputsForMagnitude = function(result, goal_mag, use_high_mag)
	-- Full-magnitude inputs: no adjustment needed
	if goal_mag >= 127 then return end

	local start_x, start_y = result.X, result.Y
	local current_mag = Engine.get_magnitude_for_stick(start_x, start_y)

	-- -------------------------------------------------------------------------
	-- Step 1: Analytically compute the starting point (x0, y0) for the search.
	-- We want: get_magnitude_for_stick(x0, y0) == goal_mag
	--          AND the angle of (x0, y0) matches (start_x, start_y).
	--
	-- Special cases: if one axis is 0, the other carries the full magnitude.
	-- General case: solve the system analytically (WolframAlpha link below).
	-- -------------------------------------------------------------------------
	local x0, y0 = 0, 0
	if start_x == 0 then
		-- Only Y axis active: magnitude = max(0, |y| - 6), so |y| = goal_mag + 6
		y0 = goal_mag + 6
	elseif start_y == 0 then
		-- Only X axis active: magnitude = max(0, |x| - 6), so |x| = goal_mag + 6
		x0 = goal_mag + 6
	else
		-- General case: solve for x0, y0 such that
		--   sqrt((x0-6)^2 + (y0-6)^2) = goal_mag   AND   atan2(y0,x0) = atan2(start_y,start_x)
		-- Solution: https://www.wolframalpha.com/input/?i=solve+%7Bsqrt%28%28x0-6%29%C2%B2+%2B+%28y0-6%29%5E2%29+%3D+k%3B+atan2%28y%2Cx%29+%3D+atan2%28y0%2Cx0%29+%7D+for+x0+and+y0
		local k = goal_mag
		local x, y = math.abs(start_x), math.abs(start_y)
		local x2, y2 = x * x, y * y
		-- "crazy" is the discriminant term from the quadratic solution
		local crazy = math.sqrt((4 * (k ^ 2 - 72) * y2) / (x2 + y2) + (y2 * (-12 * x - 12 * y) ^ 2) / (x2 + y2) ^ 2)
		x0 = math.floor(math.abs(x * crazy / (2 * y) + (6 * x2) / (x2 + y2) + (6 * x * y) / (x2 + y2)))
		y0 = math.floor(math.abs(0.5 * crazy + (6 * y2) / (x2 + y2) + (6 * x * y) / (x2 + y2)))
	end

	-- Restore the sign of each axis to match the original direction
	if start_x < 0 then x0 = -x0 end
	if start_y < 0 then y0 = -y0 end

	-- Guard against NaN (can happen if goal_mag is very small and start values
	-- produce a negative discriminant in the general case above)
	if x0 ~= x0 then x0 = 0 end
	if y0 ~= y0 then y0 = 0 end

	-- -------------------------------------------------------------------------
	-- Step 2: Neighbourhood search ±32 around (x0, y0).
	-- Score each candidate by cos(candidate_angle - goal_angle):
	--   = 1.0  → perfect angle match
	--   = 0.0  → 90° off
	--   = -1.0 → opposite direction
	-- Separately track the best candidate that is outside the game's deadzone
	-- (effectiveAngle uses |val| < 8 as the deadzone threshold here).
	-- -------------------------------------------------------------------------
	local closest_x, closest_y = x0, y0
	local err = -1
	local best_nonzero_err = -math.huge
	local best_nonzero_x, best_nonzero_y = nil, nil
	local goal_angle = effectiveAngle(start_x, start_y)

	for i = -32, 32 do
		for j = -32, 32 do
			local x, y = clamp(-127, x0 + i, 127), clamp(-127, y0 + j, 127)
			local mag = Engine.get_magnitude_for_stick(x, y)
			-- Only consider inputs that don't exceed the target magnitude
			if (mag <= goal_mag) and (mag * mag >= err) then
				local angle = effectiveAngle(x, y)
				local this_err = math.cos(angle - goal_angle)
				if (use_high_mag) then this_err = this_err * mag * mag end
				if this_err > err then
					err = this_err
					closest_x, closest_y = x, y
				end
				-- Track best non-deadzone result separately.
				-- NOTE: uses |val| >= 8, but game deadzone is |val| <= 6.
				--       Values with |val| == 7 are counted as "non-zero" here
				--       but ARE outside the game deadzone, so this is actually
				--       slightly conservative (safe), not a bug in this check.
				if (math.abs(x) >= 8 or math.abs(y) >= 8) and this_err > best_nonzero_err then
					best_nonzero_err = this_err
					best_nonzero_x, best_nonzero_y = x, y
				end
			end
		end
	end

	-- Always prefer a non-deadzone result over a deadzone one
	if best_nonzero_x ~= nil then
		closest_x, closest_y = best_nonzero_x, best_nonzero_y
	end

	closest_x = clamp(-127, closest_x, 127)
	closest_y = clamp(-127, closest_y, 127)

	-- -------------------------------------------------------------------------
	-- Step 3: Zero out any component that falls in the Lua-side deadzone threshold.
	-- NOTE: uses |val| < 8. Game uses |val| <= 6. See bug note at top of function.
	-- -------------------------------------------------------------------------
	local zeroed_x = math.abs(closest_x) < 8
	local zeroed_y = math.abs(closest_y) < 8
	if zeroed_x then closest_x = 0 end
	if zeroed_y then closest_y = 0 end

	-- -------------------------------------------------------------------------
	-- Step 4: If a component was zeroed, try boundary values ±8 to recover a
	-- better angle without exceeding goal_mag.
	-- This handles the case where the ideal point has one axis in the deadzone:
	-- instead of accepting (0, y) we try (±8, y) which has a small but nonzero
	-- X contribution and may produce a better angle match.
	-- -------------------------------------------------------------------------
	if zeroed_x or zeroed_y then
		local best_err = math.cos(effectiveAngle(closest_x, closest_y) - goal_angle)
		if use_high_mag then
			best_err = best_err * Engine.get_magnitude_for_stick(closest_x, closest_y) ^ 2
		end
		local candidates = {}
		if zeroed_x then
			table.insert(candidates, { -8, closest_y })
			table.insert(candidates, {  8, closest_y })
		end
		if zeroed_y then
			table.insert(candidates, { closest_x, -8 })
			table.insert(candidates, { closest_x,  8 })
		end
		if zeroed_x and zeroed_y then
			-- Both axes in deadzone: try all four corners of the inner boundary
			table.insert(candidates, { -8, -8 })
			table.insert(candidates, { -8,  8 })
			table.insert(candidates, {  8, -8 })
			table.insert(candidates, {  8,  8 })
		end
		for _, c in ipairs(candidates) do
			local x = clamp(-127, c[1], 127)
			local y = clamp(-127, c[2], 127)
			local mag = Engine.get_magnitude_for_stick(x, y)
			if mag <= goal_mag then
				local e = math.cos(effectiveAngle(x, y) - goal_angle)
				if use_high_mag then e = e * mag * mag end
				if e > best_err then
					best_err = e
					closest_x, closest_y = x, y
				end
			end
		end
	end

	result.X, result.Y = closest_x, closest_y
end
