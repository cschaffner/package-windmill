local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}

local icons = util.auto_loader({}, function(fname)
    return fname:sub(1,4) == "gvb-"
end)

local blue = resource.create_colored_texture(0.12,0.56,1,1)
local weather = {}
local rain = {}
local radar

local data_unwatch = util.file_watch("weather_data.json", function(raw)
    weather = json.decode(raw)
end)
local rain_unwatch = util.file_watch("weather_rain.json", function(raw)
    rain = json.decode(raw)
end)
local radar_unwatch = util.file_watch("weather_radar.gif", function(raw)
    radar = raw
end)

function M.unload()
    data_unwatch()
    rain_unwatch()
--    radar_unwatch()
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
    local y_rain = HEIGHT-200
    local x_rain = 50

    a.add(anims.moving_image(t, E, radar, 1200, 500, 1200+200, 500+200, 1))

    for idx = 1, #rain do
        local x = x_rain + idx*40
        local rain_point = rain[idx]
--        a.add(anims.moving_font(t, E, 50, y_rain, rain_point.mm_per_h , font_size, 1,1,1,1))
        if (idx % 4 == 1) then
            a.add(anims.rotated_moving_font(t, E, x, y_rain, rain_point.time , font_size, 1,1,1,1))
        end
        a.add(anims.moving_bar(S, E, blue, x, y_rain-rain_point.mmh_num*600, x+30, y_rain,1))
    end

    a.add(anims.moving_font(t, E, 150, y, "now: ", 100, 1,1,1,1))
    a.add(anims.moving_font(t, E, 300, y, "temp: " .. weather.today.temperatuurGC, 100, 1,1,1,1))

    fn.wait_t(0)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
