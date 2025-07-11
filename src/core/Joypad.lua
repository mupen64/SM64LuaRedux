--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Joypad = {
	---@type JoypadInputs
	input = {},
}

---Updates the Joypad input state.
function Joypad.update()
	Joypad.input = joypad.get(Settings.controller_index)
end

---Sends the current Joypad input state to the emulator.
function Joypad.send()
	joypad.set(Settings.controller_index, Joypad.input)
end
