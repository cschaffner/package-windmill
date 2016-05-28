local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}


local blue = resource.create_colored_texture(0.12,0.56,1,1)
local weather = {}
local rain = {}
local radar_data = {}
local radar_pics = util.auto_loader({}, function(fname)
    return fname:sub(1,14) == "weather_radar_"
end)

local data_unwatch = util.file_watch("weather_data.json", function(raw)
    weather = json.decode(raw)
end)
local rain_unwatch = util.file_watch("weather_rain.json", function(raw)
    rain = json.decode(raw)
end)
local radar_data_unwatch = util.file_watch("weather_radar.json", function(raw)
    radar_data = json.decode(raw)
end)


function M.unload()
    data_unwatch()
    rain_unwatch()
    radar_data_unwatch()
end

function M.can_schedule()
    return true
end

function M.prepare(options)
    return options.duration or 10
end

function M.run(duration, _, fn)
    local y = 50
    local a = utils.Animations()

    local S = 0.0
    local E = duration

    local now = Time.unixtime()
    print('now is '.. now)

    local t = S

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, "Weather @Windmill", 100, 1,1,1,1))
    y = y + 110
    t = t + 0.03
    local font_size = 40

    a.add(anims.moving_image(t, E, radar_pics['weather_radar_background'], 200, y, 599+200, y+420, 1))
    a.add(function(t)
        idx = math.ceil(t/E*#radar_data)
--        print(idx, radar_data[idx].filename)
        return radar_pics[radar_data[idx].filename]:draw(200, y, 599+200, y+420, 1)
    end)
    --    for idx = 1, #radar_data do
--        local radar = radar_data[idx]
--        print(radar.filename)
--        a.add(radar_pics[radar.filename]:draw(200, y, 1060+200, y+915, 1))
--        a.add(res.font:write(200, y, radar.time, 60, 1,0,0,0.8))
--    end

    local y_rain = HEIGHT-200
    local x_rain = 50
    for idx = 1, #rain do
        local x = x_rain + idx*40
        local rain_point = rain[idx]
--        a.add(anims.moving_font(t, E, 50, y_rain, rain_point.mm_per_h , font_size, 1,1,1,1))
        if (idx % 4 == 1) then
            a.add(anims.rotated_moving_font(t, E, x, y_rain, rain_point.time , font_size, 1,1,1,1))
        end
        a.add(anims.moving_bar(S, E, blue, x, y_rain-rain_point.mmh_num*300, x+30, y_rain,1))
    end

    a.add(anims.moving_font(t, E, 900, 130, "now: " .. weather.Schiphol.temperature .. "°C  " .. weather.Schiphol.precipitationmm .. "mm   " .. weather.Schiphol.winddirection .. weather.Schiphol.windspeedBft, 80, 1,1,1,1))
    a.add(anims.moving_font(t, E, 900, 280, weather.Halfweg.day_names, 80, 1,1,1,1))

--    today's data'
    a.add(anims.moving_font(t, E, 900, 880, weather.Halfweg.days[1].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, 900, 930, weather.Halfweg.days[1].winddirection .. weather.Halfweg.days[1].beaufort, 40, 1,1,1,1))

    a.add(anims.moving_font(t, E, 900, 880, weather.Halfweg.days[1].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, 900, 930, weather.Halfweg.days[1].winddirection .. weather.Halfweg.days[1].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, 1150, 880, weather.Halfweg.days[2].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, 1150, 930, weather.Halfweg.days[2].winddirection .. weather.Halfweg.days[1].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, 1400, 880, weather.Halfweg.days[3].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, 1400, 930, weather.Halfweg.days[3].winddirection .. weather.Halfweg.days[1].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, 1650, 880, weather.Halfweg.days[4].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, 1650, 930, weather.Halfweg.days[4].winddirection .. weather.Halfweg.days[1].beaufort, 40, 1,1,1,1))

    Sidebar.hide(E)
    fn.wait_t(0)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
