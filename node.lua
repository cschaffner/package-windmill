local scale = 1.0 -- downscale. 1.0 is fullHD, 2 is half of fullHD

gl.setup(1920 / scale, 1080 / scale)
WIDTH = WIDTH * scale
HEIGHT = HEIGHT * scale

node.set_flag "slow_gc"
util.init_hosted()

local function ERROR(...)
    print("ERROR: ", ...)
end

util.loaders.pkm = resource.load_image

-- available resources. global, so they can be used from modules
res = util.resource_loader({
    "font.ttf";
    "bottle.png";
    "house1.png";
    "house2.png";
    "tower.png";
    "flag_at.png";
    "flag_be.png";
    "flag_by.png";
    "flag_ca.png";
    "flag_cc.png";
    "flag_ch.png";
    "flag_co.png";
    "flag_cz.png";
    "flag_de.png";
    "flag_dk.png";
    "flag_ee.png";
    "flag_es.png";
    "flag_fi.png";
    "flag_fr.png";
    "flag_gb.png";
    "flag_hu.png";
    "flag_ie.png";
    "flag_il.png";
    "flag_io.png";
    "flag_ir.png";
    "flag_is.png";
    "flag_it.png";
    "flag_no.png";
    "flag_nr.png";
    "flag_pl.png";
    "flag_pt.png";
    "flag_ru.png";
    "flag_se.png";
    "flag_sk.png";
    "flag_tr.png";
    "flag_ua.png";
    "flag_us.png";
}, {})

local json = require "json"
local utils = require "utils"
local raw = sys.get_ext "raw_video"

local white = resource.create_colored_texture(1,1,1,1)
local black = resource.create_colored_texture(0,0,0,1)
local open_col = resource.create_colored_texture(0.898,0.529,0,1)  --yelloish
local women_col = resource.create_colored_texture(0.647,0,0.471,1) --dark pink
local mixed_col = resource.create_colored_texture(0.843,0.20,0,1)  --reddish

local loop = resource.load_video{
    file = "loop.mp4";
    looped = true;
}

local function highlight_a(a)
    return 0.94, 0.57, 0.14, a
end

pp(CONFIG)

local white_transparent = resource.create_shader[[
    uniform sampler2D Texture;
    varying vec2 TexCoord;
    uniform vec4 Color;

    void main() {
        vec4 col = texture2D(Texture, TexCoord).rgba;
        if (col.r + col.g + col.b > 2.9) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, 0.0);
        } else {
            gl_FragColor = col;
        }
    }
]]

-----------------------------------------------------------------------------------------------

Time = (function()
    local base_t = os.time() - sys.now()
    local midnight

    local function unixtime()
        -- return sys.now() + base_t + 86400*3
        return sys.now() + base_t
    end

    local function walltime()
        if not midnight then
            return 0, 0
        else
            local time = (midnight + sys.now()) % 86400
            return math.floor(time/3600), math.floor(time % 3600 / 60)
        end
    end

    util.data_mapper{
        ["clock/unix"] = function(time)
            -- print("new time: ", time)
            base_t = tonumber(time) - sys.now()
        end;
        ["clock/midnight"] = function(since_midnight)
            -- print("new midnight: ", since_midnight)
            midnight = tonumber(since_midnight) - sys.now()
        end;
    }

    return {
        unixtime = unixtime;
        walltime = walltime;
    }
end)()

Fadeout = (function()
    local current_alpha = 1
    local fade_til = 0

    local function alpha()
        return current_alpha
    end

    local function fade(t)
        fade_til = sys.now() + t
    end

    local function tick()
        local target_alpha = sys.now() > fade_til and 1 or 0

        if current_alpha < target_alpha then
            current_alpha = current_alpha + 0.01
        elseif current_alpha > target_alpha then
            current_alpha = current_alpha - 0.01
        end
    end

    return {
        alpha = alpha;
        tick = tick;
        fade = fade;
    }
end)()

Scroller = (function()
    local function my_new_running_text(opt)
        local current_idx = 1
        local current_left = 0
        local last = sys.now()

        local generator = opt.generator
        local font = opt.font
        local size = opt.size or 10
        local speed = opt.speed or 10
        local color = opt.color or {1,1,1,1}

        local texts = {}
        return {
            draw = function(self, y)
                local now = sys.now()
                local xoff = current_left
                local idx = 1
                while xoff < WIDTH do
                    if #texts < idx then
                        table.insert(texts, generator.next())
                    end
                    local width = utils.flag_write(font, xoff, y-200, texts[idx] .. "   -   ", size, unpack(color))
                    xoff = xoff + width
                    if xoff < 0 then
                        current_left = xoff
                        table.remove(texts, idx)
                    else
                        idx = idx + 1
                    end
                end
                local delta = now - last
                last = now
                current_left = current_left - delta * speed
            end;
            add = function(self, text)
                generator:add(text)
            end;
        }
    end

--
--
--    local workshops = {}
--    util.file_watch("workshops.json", function(content)
--        print("reloading workshops")
--        workshops = json.decode(content)
--    end)

    local open_games = {}
    util.file_watch("current_games_open.json", function(content)
        print("reloading open games")
        open_games = json.decode(content)
    end)

    local infos = {}
    util.file_watch("scroll.txt", function(content)
        infos = {}
        for line in string.gmatch(content.."\n", "([^\n]*)\n") do
            if #line > 0 then
                infos[#infos+1] = line
            end
        end
    end)

    local function feeder()
        local out = {}
        for idx = 1, #infos do
            out[#out+1] = infos[idx]
        end

        local now = Time.unixtime()
        out[#out+1] = open_games.round_name .. "(" .. open_games.start_time .. "): "
        for idx = 1, #open_games.games do
            local game = open_games.games[idx]
            if game.team_1_score then
                out[#out+1] = game.field .. ": " .. game.team_1 .. " " .. game.team_1_score .. " - " .. game.team_2_score .. " " .. game.team_2
            else
                out[#out+1] = game.field .. ": " .. game.team_1 .. " - " .. game.team_2
            end
        end

--        for idx = 1, #workshops do
--            local workshop = workshops[idx]
--            if workshop.start_unix > now and workshop.start_unix < now + 3 * 3600 then
--                out[#out+1] = workshop.text
--            end
--        end
        return out
    end

    local text = my_new_running_text{
        font = res.font;
        size = 60;
        speed = 180;
        color = {1,1,1,.8};
        generator = util.generator(feeder)
    }

    local visibility = 0
    local target = 0
    local restore = sys.now() + 1

    local function hide(duration)
        target = 0
        restore = sys.now() + duration
    end

    local function draw()
        if visibility > 0.01 then
            open_col:draw(0, HEIGHT-100, WIDTH, HEIGHT, visibility/3)
            text:draw(HEIGHT-100 - visibility * 42)
        end
    end

    local current_speed = 0
    local function tick()
        if sys.now() > restore then
            target = 1
        end
        local current_speed = 0.05
        visibility = visibility * (1-current_speed) + target * (current_speed)
        draw()
    end


    return {
        tick = tick;
        hide = hide;
    }
end)()

Sidebar = (function()
    local sidebar_width = 339
    local visibility = 0
    local target = 0
    local restore = sys.now() + 1

    local function hide(duration)
        target = 0
        restore = sys.now() + duration
    end

    util.data_mapper{
        ["sidebar/hide"] = function(t)
            hide(tonumber(t))
        end;
    }

    local function draw()
        if visibility > 0.01 then
            loop:start()
            local max_rotate = 90
            gl.pushMatrix()
            gl.translate(WIDTH-sidebar_width, 0)
            gl.rotate(max_rotate - visibility * max_rotate, 0, 1, 0) 
            gl.translate(0.5*sidebar_width*(1-visibility), 0, (1-visibility)*400)
            res.bottle:draw(0, 0, sidebar_width, HEIGHT, 1)

            loop:draw(10, 350, 320, 350+80)

            -- res.font:write(125, HEIGHT-45, "info-beamer.com", 40, 0,0,0, visibility)
            gl.popMatrix()
        else
            loop:stop()
        end

        local size = 100
        local hour, min = Time.walltime()
        local time = string.format("%d:%02d", hour, min)
        local w = res.font:width(time, size)
        local sidebar_x = WIDTH - sidebar_width + (sidebar_width-w)/2

        local tower_x = utils.easeInOut(visibility, WIDTH+100, WIDTH-150)
        local tower_y = utils.easeInOut(visibility, 900, 660)
        res.tower:draw(tower_x, tower_y-200, tower_x + 100, tower_y + 145, visibility*2)

        local house_x = utils.easeInOut(visibility, WIDTH+100, WIDTH-320)
        local house_y = utils.easeInOut(visibility, 900, 650)
        res.house2:draw(house_x, house_y, house_x + 280, house_y + 180, visibility*2)

        local clock_x = utils.easeInOut(visibility, WIDTH-260, WIDTH-320)
        local clock_y = utils.easeInOut(visibility, HEIGHT-105, 850)
        res.house1:draw(clock_x, clock_y-100, clock_x + 300, clock_y + 155)
        res.font:write(clock_x + 150 - w/2, clock_y+5, time, 100, highlight_a(1))
    end

    local current_speed = 0
    local function tick()
        if sys.now() > restore then
            target = 1
        end
        local current_speed = 0.05
        visibility = visibility * (1-current_speed) + target * (current_speed)
        draw()
    end

    return {
        tick = tick;
        hide = hide;
    }
end)()

-----------------------------------------------------------------------------------------------

local function ModuleLoader()
    local modules = {}

    local function module_name_from_filename(filename)
        return filename:match "module_(.*)%.lua"
    end

    local function module_unload(module_name)
        if modules[module_name] and modules[module_name].unload then
            modules[module_name].unload()
        end
        modules[module_name] = nil
        node.gc()
    end

    local function module_update(module_name, module)
        module_unload(module_name)
        modules[module_name] = module
        node.gc()
    end

    node.event("content_update", function(filename)
        local module_name = module_name_from_filename(filename)
        if module_name then
            module_update(module_name, assert(loadstring(resource.load_file(filename), "=" .. filename))())
        end
    end)
    node.event("content_delete", function(filename)
        local module_name = module_name_from_filename(filename)
        if module_name then
            module_unload(module_name)
        end
    end)

    return modules
end

local function Scheduler(runner, modules)
    local playlist = {}
    local playlist_offset = 0

    util.file_watch("playlist.json", function(raw)
        playlist = json.decode(raw)
        playlist_offset = 0
    end)

    local next_visual = sys.now() + 1
    local next_wake = sys.now()

    local function enqueue(item)
        local ok, duration, options = pcall(modules[item.module].prepare, item.options or {})
        if not ok then
            print("failed to prepare " .. item.module .. ": " .. duration)
            return
        end

        local visual = {
            starts = next_visual - 1;
            duration = duration;
            module = item.module;
            options = options;
        }

        next_visual = next_visual + duration - 1
        next_wake = next_visual - 3
        print("about to schedule visual ", item.module)
        pp(visual)
        runner.add(visual)
    end

    util.data_mapper{
        ["scheduler/enqueue"] = function(raw)
            enqueue(json.decode(raw))
        end
    }

    local function tick()
        if sys.now() < next_wake then
            return
        end

        local item, can_schedule
        repeat
            item, playlist_offset = utils.cycled(playlist, playlist_offset)
            can_schedule = true
            if item.chance then
                can_schedule = math.random() < item.chance
            end
            if item.hours then
                local hours = {}
                for h in string.gmatch(item.hours, "%S+") do
                    hours[tonumber(h)] = true
                end
                local hour, min = Time.walltime()
                if not hours[hour] then
                    can_schedule = false
                end
            end
            if not modules[item.module] then
                print("module " .. item.module .. " not available")
                can_schedule = false
            elseif not modules[item.module].can_schedule(item.options) then
                print("module " .. item.module .. " cannot be scheduled")
                can_schedule = false
            end
        until can_schedule
        enqueue(item)
    end

    return {
        tick = tick;
    }
end

local function reset_view()
    local fov = math.atan2(HEIGHT, WIDTH*2) * 360 / math.pi
    return gl.perspective(fov, WIDTH/2, HEIGHT/2, -WIDTH,
                               WIDTH/2, HEIGHT/2, 0)
end

local function Runner(modules)
    local visuals = {}

    local function add(visual)
        local co = coroutine.create(modules[visual.module].run)

        local success, is_finished = coroutine.resume(co, visual.duration, visual.options, {
            wait_next_frame = function ()
                return coroutine.yield(false)
            end;
            wait_t = function(t)
                while true do
                    local now = coroutine.yield(false)
                    if now >= t then return now end
                end
            end;
            upto_t = function(t) 
                return function()
                    local now = coroutine.yield(false)
                    if now < t then return now end
                end
            end;
        })

        if not success then
            ERROR(debug.traceback(co, string.format("cannot start visual: %s", is_finished)))
        elseif not is_finished then
            table.insert(visuals, 1, {
                co = co;
                starts = visual.starts;
            })
        end
    end

    local function tick()
        local now = sys.now()
        for idx = #visuals,1,-1 do -- iterate backwards so we can remove finished visuals
            local visual = visuals[idx]
            reset_view()
            local success, is_finished = coroutine.resume(visual.co, now - visual.starts)
            if not success then
                ERROR(debug.traceback(visual.co, string.format("cannot resume visual: %s", is_finished)))
                table.remove(visuals, idx)
            elseif is_finished then
                table.remove(visuals, idx)
            end
        end
    end

    return {
        tick = tick;
        add = add;
    }
end

-----------------------------------------------------------------------------------------------

local modules = ModuleLoader()
local runner = Runner(modules)
local scheduler = Scheduler(runner, modules)

function node.render()
    Fadeout.tick()
    runner.tick()
    reset_view()
    scheduler.tick()
    Scroller.tick()
    Sidebar.tick()
end
