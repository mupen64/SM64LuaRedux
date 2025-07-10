--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Memory = {
	current = {},
	previous = {},
}

function Memory.update()
	local address_source = Addresses[Settings.address_source_index]
	Memory.current.camera_fov = memory.readfloat(address_source.camera_fov)
	Memory.current.camera_angle = memory.readword(address_source.camera_angle)
	Memory.current.camera_transition_type = memory.readbyte(address_source.camera_transition_type)
	Memory.current.camera_transition_progress = memory.readbyte(address_source.camera_transition_progress)
	Memory.current.camera_flags = memory.readbyte(address_source.camera_flags)
	Memory.current.camera_x = memory.readfloat(address_source.camera_x)
	Memory.current.camera_y = memory.readfloat(address_source.camera_y)
	Memory.current.camera_z = memory.readfloat(address_source.camera_z)
	Memory.current.camera_yaw = memory.readword(address_source.camera_yaw)
	Memory.current.camera_pitch = memory.readword(address_source.camera_pitch)
	Memory.current.holp_x = memory.readfloat(address_source.holp_x)
	Memory.current.holp_y = memory.readfloat(address_source.holp_y)
	Memory.current.holp_z = memory.readfloat(address_source.holp_z)
	Memory.current.timestop_enabled = memory.readbyte(address_source.timestop_enabled)
	Memory.current.play_mode = memory.readwordsigned(address_source.play_mode)
	Memory.current.mario_facing_yaw = memory.readword(address_source.mario_facing_yaw)
	Memory.current.mario_intended_yaw = memory.readword(address_source.mario_intended_yaw)
	Memory.current.mario_h_speed = MoreMaths.dec_to_float(memory.readdword(address_source.mario_h_speed))
	Memory.current.mario_v_speed = MoreMaths.dec_to_float(memory.readdword(address_source.mario_v_speed))
	Memory.current.mario_x_sliding_speed = MoreMaths.dec_to_float(memory.readdword(address_source.mario_x_sliding_speed))
	Memory.current.mario_z_sliding_speed = MoreMaths.dec_to_float(memory.readdword(address_source.mario_z_sliding_speed))
	Memory.current.mario_x = MoreMaths.dec_to_float(memory.readdword(address_source.mario_x))
	Memory.current.mario_y = MoreMaths.dec_to_float(memory.readdword(address_source.mario_y))
	Memory.current.mario_z = MoreMaths.dec_to_float(memory.readdword(address_source.mario_z))
	Memory.current.mario_pitch = memory.readwordsigned(address_source.mario_pitch)
	Memory.current.mario_yaw_vel = memory.readwordsigned(address_source.mario_yaw_vel)
	Memory.current.mario_pitch_vel = memory.readwordsigned(address_source.mario_yaw_vel)
	Memory.current.mario_object_pointer = memory.readdword(address_source.mario_object_pointer)
	Memory.current.mario_object_effective = memory.readdword(address_source.mario_object_effective)
	Memory.current.mario_action = memory.readdword(address_source.mario_action)
	Memory.current.mario_action_arg = memory.readdword(address_source.mario_action_arg)
	Memory.current.mario_f_speed = memory.readfloat(address_source.mario_f_speed)
	Memory.current.mario_buffered = memory.readbyte(address_source.mario_buffered)
	Memory.current.mario_held_buttons = memory.readbyte(address_source.mario_held_buttons) -- A | B | Z | START | DUP | DDOWN | DLEFT | DRIGHT
	Memory.current.mario_pressed_buttons = memory.readbyte(address_source.mario_pressed_buttons) -- U1 | U2 | L | R | CUP | CDOWN | CLEFT | CRIGHT
	Memory.current.mario_global_timer = memory.readdword(address_source.global_timer)
	Memory.current.rng_value = memory.readword(address_source.rng_value)
	Memory.current.mario_animation = memory.readword(memory.readdword(address_source.mario_object_effective)+address_source.mario_animation)
	Memory.current.mario_gfx_angle = memory.readword(memory.readdword(address_source.mario_object_effective)+address_source.mario_gfx_angle)
	Memory.current.mario_hat_state = memory.readbyte(address_source.mario_hat_state)
end

function Memory.update_previous()
	-- update previous values
	Memory.previous = ugui.internal.deep_clone(Memory.current)
end

function Memory.initialize()
	Memory.update()
	Memory.update_previous()
end

function Memory.find_matching_address_source_index()
	for key, value in pairs(Addresses) do
		if memory.readdword(value.pattern) == value.pattern_value then
			return key
		end
	end
	return 1
end
