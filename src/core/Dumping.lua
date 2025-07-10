--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Dumping = {
    data = {}
}

Dumping.start = function()
    Settings.dump_enabled = true
    Settings.dump_start_frame = emu.inputcount()
    Settings.dump_movie_start_frame = movie.get_seek_completion()[1]
    Dumping.data = {}
    print("Dumping started")
end

Dumping.stop = function()
    Settings.dump_enabled = false

    local path = "dump.json"
    local serialized = json.encode(Dumping.data)
    local file = io.open(path, "w")
    file:write(serialized)
    io.close(file)

    print(string.format("Dumped %d frames to %s", #Dumping.data, path))
end

Dumping.update = function()
    if not Settings.dump_enabled then
        return
    end

    if ((Memory.current.timestop_enabled ~= 0) or (Memory.current.play_mode ~= 0)) then
        print("Skipping non-input frame while dumping")
        return
    end

    local movie_path = nil

    pcall(function ()
        movie_path = movie.get_filename()
    end)

    Dumping.data[#Dumping.data + 1] = {
        frame = #Dumping.data,
        movie_path = movie_path,
        sample = movie.get_seek_completion()[1],
        movie_start_sample = Settings.dump_movie_start_frame,
        input = ugui.internal.deep_clone(Joypad.input),
        memory = ugui.internal.deep_clone(Memory.current),
        varwatch = ugui.internal.deep_clone(VarWatch.processed_values),
    }
end
