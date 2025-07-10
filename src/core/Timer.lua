--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Timer = {}

local transitionTimes = {}
transitionTimes[0] = 2
transitionTimes[8] = 2
transitionTimes[10] = 2
transitionTimes[16] = 2
transitionTimes[18] = 2
local VIs = 0
local PredictedVIs = 0
local State = 0
local StartVI = 0
local curVI = 0
local frames = 0

local function timerAutoDetect()
    if ((State == 1) and ((Memory.current.mario_object_effective == 0) or (curVI < StartVI))) then -- Reset timer on star select, or if state before start time is loaded
        Timer.reset()
    end
    if ((State ~= 1) and (Memory.current.camera_transition_progress ~= nil) and (Memory.current.mario_object_effective ~= 0) and (transitionTimes[Memory.current.camera_transition_type] == Memory.current.camera_transition_progress) and (Memory.current.mario_action ~= 0x1300)) then -- Start timer on fade in
        Timer.start()
    end
    if ((Memory.current.mario_animation == 179) or (Memory.current.mario_animation == 205)) then -- Stop timer on star dance
        if (State == 1) then                                                                     -- Stop timer on star dance
            if (PredictedVIs ~= curVI) then                                                      -- fix mismatched time if there was lag as the time stops
                VIs = curVI - StartVI
            end
            if ((Memory.current.mario_action_arg & 1) == 1) then -- Special state if a non-exit star is collected
                State = 3
            else
                Timer.stop()
            end
        end
    elseif (State == 3) then -- Reactivate timer after dance
        State = 1
    end
end

Timer.get_frame_text = function()
    local decimals = ((VIs % 60) * 1000 // 60 + 5) // 10 % 100
    if (VIs < 3600) then
        return string.format('%02d.%02d', VIs // 60, decimals)
    elseif (VIs < 216000) then
        return string.format('%02d:%02d.%02d', VIs // 3600, (VIs % 3600) // 60, decimals)
    else
        return string.format('%d:%02d:%02d.%02d', VIs // 216000, (VIs % 216000) // 3600, (VIs % 3600) // 60, decimals)
    end
end

Timer.get_frames = function()
    return frames
end

Timer.update = function()
    curVI = emu.framecount()
    if (State == 1) then
        if (curVI <= StartVI) then
            VIs = 0
            frames = 0
        else
            PredictedVIs = curVI + 2 -- assume it will increment by 2, fix it on the next frame if there's lag
            VIs = PredictedVIs - StartVI
            frames = frames + 1
        end
    end
    if Settings.timer_auto then
        timerAutoDetect()
    end
end

Timer.reset = function()
    State = 0
    VIs = 0
end
Timer.start = function()
    State = 1
    VIs = 2
    StartVI = curVI
end
Timer.stop = function()
    State = 2
end
