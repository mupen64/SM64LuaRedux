--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Benchmark = {}
local values = {}
local start = os.clock()

Benchmark.section_start = function()
    start = os.clock()
end

Benchmark.section_stop = function()
    values[#values + 1] = (os.clock() - start) * 1000
end

emu.atstop(function()
    local sum = 0
    for i = 1, #values, 1 do
        sum = sum + values[i]
    end

    print('Average time across ' .. #values .. ' runs: ' .. sum / #values .. 'ms')
end)
