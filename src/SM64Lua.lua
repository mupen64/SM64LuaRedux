--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

folder = debug.getinfo(1).source:sub(2):match('(.*\\)')
styles_path = folder .. 'res\\styles\\'
locales_path = folder .. 'res\\lang\\'
views_path = folder .. 'views\\'
core_path = folder .. 'core\\'
lib_path = folder .. 'lib\\'
processors_path = folder .. 'processors\\'

---@module 'BreitbandGraphics'
BreitbandGraphics = dofile(lib_path .. 'breitbandgraphics.lua')

---@module 'mupen-lua-ugui'
ugui = dofile(lib_path .. 'mupen-lua-ugui.lua')

---@module 'mupen-lua-ugui-ext'
ugui_ext = dofile(lib_path .. 'mupen-lua-ugui-ext.lua')

---@module 'linq'
lualinq = dofile(lib_path .. 'linq.lua')

json = dofile(lib_path .. 'json.lua')
dofile(styles_path .. 'base_style.lua')
dofile(core_path .. 'Helpers.lua')
dofile(core_path .. 'Settings.lua')
dofile(core_path .. 'Formatter.lua')
dofile(core_path .. 'Drawing.lua')
dofile(core_path .. 'Memory.lua')
dofile(core_path .. 'RNG.lua')
dofile(core_path .. 'Joypad.lua')
dofile(core_path .. 'Angles.lua')
dofile(core_path .. 'Engine.lua')
dofile(core_path .. 'MoreMaths.lua')
dofile(core_path .. 'WorldVisualizer.lua')
dofile(core_path .. 'MiniVisualizer.lua')
dofile(core_path .. 'Timer.lua')
dofile(core_path .. 'Ghost.lua')
dofile(core_path .. 'VarWatch.lua')
dofile(core_path .. 'Styles.lua')
dofile(core_path .. 'Locales.lua')
dofile(core_path .. 'Presets.lua')
dofile(core_path .. 'Dumping.lua')
dofile(core_path .. 'Actions.lua')
Addresses = dofile(core_path .. 'Addresses.lua')

apply_math_shim()

Memory.initialize()
Joypad.update()
Drawing.size_up()
Presets.restore()
Presets.apply(Presets.persistent.current_index)
Actions.register_all()

local views = {
    dofile(views_path .. 'TAS.lua'),
    dofile(views_path .. 'SemanticWorkflow/Main.lua'),
    dofile(views_path .. 'Settings.lua'),
    dofile(views_path .. 'Tools.lua'),
    dofile(views_path .. 'Timer.lua'),
}

local semantic_workflow = dofile(processors_path .. 'SemanticWorkflow.lua')
local processors = {
    semantic_workflow.transform,
    dofile(processors_path .. 'Walk.lua'),
    dofile(processors_path .. 'Swimming.lua'),
    dofile(processors_path .. 'Wallkicker.lua'),
    dofile(processors_path .. 'Framewalk.lua'),
    semantic_workflow.readback,
}

Notifications = dofile(views_path .. 'Notifications.lua')

ugui_environment = {}
local mouse_wheel = 0

-- Amount of updatescreen invocations, used for throttling repaints during ff
local paints = 0

-- Whether the current paint cycle is being skipped
paint_skipped = false

-- Flag keeping track of whether atinput has fired for one time
local first_input = true

local reset_preset_menu_open = false
local last_rmb_down_position = { x = 0, y = 0 }
local keys = input.get()
local last_keys = input.get()

local function at_input()
    -- TODO: Move this to Memory.lua
    if first_input then
        if Settings.autodetect_address then
            Settings.address_source_index = Memory.find_matching_address_source_index()
        end
        first_input = false
    end

    if Settings.override_rng then
        local address_source = Addresses[Settings.address_source_index]

        if Settings.override_rng_use_index then
            memory.writeword(address_source.rng_value, RNG.get_value(Settings.override_rng_value))
        else
            memory.writeword(address_source.rng_value, Settings.override_rng_value)
        end
    end

    Memory.update_previous()
    Joypad.update()

    -- frame stage 2: let domain code loose on everything, then perform transformations or inspections (e.g.: swimming, rng override, ghost)
    -- TODO: make this into a priority callback system?
    Timer.update()

    for i = 1, #processors, 1 do
        Joypad.input = processors[i].process(Joypad.input)
    end

    Joypad.send()
    Ghost.update()
    Dumping.update()
end

local function at_vi()
    Memory.update()
end

local function draw_navbar()
    if not Settings.navbar_visible then
        return
    end
    Settings.tab_index = ugui.carrousel_button({
        uid = -5000,
        rectangle = grid_rect(0, 16, 5.5, 1),
        is_enabled = not Settings.hotkeys_assigning,
        items = lualinq.select_key(views, 'name'),
        selected_index = Settings.tab_index,
    })

    local preset_picker_rect = grid_rect(5.5, 16, 2.5, 1)
    local preset_index = Presets.persistent.current_index

    if reset_preset_menu_open then
        local result = ugui.menu({
            uid = -5010,
            rectangle = ugui.internal.deep_clone(last_rmb_down_position),
            items = {
                {
                    text = Locales.str('GENERIC_RESET'),
                    callback = function()
                        action.invoke(ACTION_RESET_PRESET)
                    end,
                },
                {
                    text = Locales.str('PRESET_CONTEXT_MENU_PERSIST_TAS_STATE'),
                    checked = Settings.persist_tas_state,
                    callback = function()
                        action.invoke(ACTION_TOGGLE_REMEMBER_TAS_STATE)
                    end,
                },
            },
        })

        if result.dismissed then
            reset_preset_menu_open = false
        else
            if result.item then
                result.item.callback()
                reset_preset_menu_open = false
            end
        end
    end

    if (keys.rightclick and not last_keys.rightclick)
        and BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, preset_picker_rect)
        and not Settings.hotkeys_assigning then
        reset_preset_menu_open = true
    end

    preset_index = ugui.carrousel_button({
        uid = -5005,
        rectangle = preset_picker_rect,
        is_enabled = not Settings.hotkeys_assigning,
        items = lualinq.select(Presets.persistent.presets, function(_, i)
            return Locales.str('PRESET') .. i
        end),
        selected_index = preset_index,
    })

    if preset_index > Presets.persistent.current_index then
        action.invoke(ACTION_SET_PRESET_UP)
    elseif preset_index < Presets.persistent.current_index then
        action.invoke(ACTION_SET_PRESET_DOWN)
    end
end

local function atdrawd2d()
    paints = paints + 1
    paint_skipped = (paints % Settings.repaint_throttle) ~= 0 and emu.get_ff and emu.get_ff()

    -- Throttle repaints in ff
    if paint_skipped then
        return
    end

    if d2d and d2d.clear then
        d2d.clear(0, 0, 0, 0)
    end

    last_keys = ugui.internal.deep_clone(keys)
    keys = input.get()

    if keys.rightclick and not last_keys.rightclick then
        last_rmb_down_position = {
            x = keys.xmouse,
            y = keys.ymouse,
        }
    end

    VarWatch_update()

    local focused = emu.ismainwindowinforeground()

    ugui_environment = {
        mouse_position = {
            x = keys.xmouse,
            y = keys.ymouse,
        },
        wheel = mouse_wheel,
        is_primary_down = keys.leftclick and focused,
        held_keys = keys,
        window_size = {
            x = Drawing.size.width,
            y = Drawing.size.height - 23,
        },
    }
    ugui.begin_frame(ugui_environment)

    mouse_wheel = 0

    WorldVisualizer.draw()
    MiniVisualizer.draw()
    Notifications.draw()

    BreitbandGraphics.fill_rectangle({
        x = Drawing.initial_size.width,
        y = 0,
        width = Drawing.size.width - Drawing.initial_size.width,
        height = Drawing.size.height,
    }, Styles.theme().background_color)

    if not Settings.navbar_visible then
        local one_cell_height = grid_rect(0, 0, 0, 1.25).height
        Drawing.push_offset(0, one_cell_height / 2)
    end
    views[Settings.tab_index].draw()
    Drawing.pop_offset()

    draw_navbar()

    ugui.end_frame()
end

local function at_loadstate()
    -- Previous state is now messed up, since it's not the actual previous frame but some other game state
    -- What do we do at this point, leave it like this and let the engine calculate wrong diffs, or copy current state to previous one?
    Memory.update_previous()
    Memory.update()
end

emu.atloadstate(at_loadstate)
emu.atinput(at_input)
emu.atvi(at_vi)
emu.atdrawd2d(atdrawd2d)
emu.atstop(function()
    Presets.save()
    Drawing.size_down()
    BreitbandGraphics.free()
    ugui_ext.free()
end)
emu.atwindowmessage(function(hwnd, msg_id, wparam, lparam)
    if msg_id == 522 then                         -- WM_MOUSEWHEEL
        -- high word (most significant 16 bits) is scroll rotation in multiples of WHEEL_DELTA (120)
        local scroll = math.floor(wparam / 65536) --(wparam & 0xFFFF0000) >> 16
        if scroll == 120 then
            mouse_wheel = 1
        elseif scroll == 65416 then -- 65536 - 120
            mouse_wheel = -1
        end
    end
end)
