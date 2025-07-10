--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Joypad = {
	input = {
		
	}
}

function Joypad.update()
	Joypad.input = joypad.get(Settings.controller_index)
end

function Joypad.send()
	joypad.set(Settings.controller_index, Joypad.input)
end