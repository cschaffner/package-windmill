local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}


local red = resource.create_colored_texture(0.9,0.32,0,1)
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

--    local y_rain = HEIGHT-200
--    local x_rain = 50
--    for idx = 1, #rain do
--        local x = x_rain + idx*40
--        local rain_point = rain[idx]
----        a.add(anims.moving_font(t, E, 50, y_rain, rain_point.mm_per_h , font_size, 1,1,1,1))
--        if (idx % 4 == 1) then
--            a.add(anims.rotated_moving_font(t, E, x, y_rain, rain_point.time , font_size, 1,1,1,1))
--        end
--        a.add(anims.moving_bar(S, E, blue, x, y_rain-rain_point.mmh_num*300, x+30, y_rain,1))
--    end

    a.add(anims.moving_font(t, E, 900, 130, "now: " .. weather.Schiphol.temperature .. "°C  " .. weather.Schiphol.precipitationmm .. "mm   " .. weather.Schiphol.winddirection .. weather.Schiphol.windspeedBft, 70, 1,1,1,1))

    local today_x = 900
    local dayspace = 200
    local tom_x = 900 + dayspace
    local aftertom_x = tom_x + dayspace
    local afteraftertom_x = aftertom_x + dayspace
    local dayname_y = 280
    local temp_max_y = 400
    local temp_min_y = 700
    local rainbar_y = 850
    local rainday_y = 880
    local windday_y = 930

--    today's data'
    a.add(anims.moving_font(t, E, today_x, dayname_y, weather.Halfweg.day_names[1], 70, 1,1,1,1))
    a.add(anims.moving_font(t, E, today_x, rainday_y, weather.Halfweg.days[1].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, today_x, windday_y, weather.Halfweg.days[1].winddirection .. weather.Halfweg.days[1].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_bar(S, E, blue, today_x, rainbar_y-weather.Halfweg.days[1].precipitationmm*150/30, today_x+100, rainbar_y,1))

    a.add(anims.moving_font(t, E, tom_x, dayname_y, weather.Halfweg.day_names[2], 70, 1,1,1,1))
    a.add(anims.moving_font(t, E, tom_x, rainday_y, weather.Halfweg.days[2].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, tom_x, windday_y, weather.Halfweg.days[2].winddirection .. weather.Halfweg.days[2].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_bar(S, E, blue, tom_x, rainbar_y-weather.Halfweg.days[2].precipitationmm*150/30, tom_x+100, rainbar_y,1))

    a.add(anims.moving_font(t, E, aftertom_x, dayname_y, weather.Halfweg.day_names[3], 70, 1,1,1,1))
    a.add(anims.moving_font(t, E, aftertom_x, rainday_y, weather.Halfweg.days[3].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, aftertom_x, windday_y, weather.Halfweg.days[3].winddirection .. weather.Halfweg.days[3].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_bar(S, E, blue, aftertom_x, rainbar_y-weather.Halfweg.days[3].precipitationmm*150/30, aftertom_x+100, rainbar_y,1))

    a.add(anims.moving_font(t, E, afteraftertom_x, dayname_y, weather.Halfweg.day_names[4], 70, 1,1,1,1))
    a.add(anims.moving_font(t, E, afteraftertom_x, rainday_y, weather.Halfweg.days[4].precipitationmm .. "mm", 40, 1,1,1,1))
    a.add(anims.moving_font(t, E, afteraftertom_x, windday_y, weather.Halfweg.days[4].winddirection .. weather.Halfweg.days[3].beaufort, 40, 1,1,1,1))
    a.add(anims.moving_bar(S, E, blue, afteraftertom_x, rainbar_y-weather.Halfweg.days[4].precipitationmm*150/30, afteraftertom_x+100, rainbar_y,1))

    local function temp_to_y(temp)
        return temp_min_y - (temp-weather.Halfweg.min_temp) * (temp_min_y-temp_max_y) / (weather.Halfweg.max_temp-weather.Halfweg.min_temp)
    end
--    local current_temp = weather.Schiphol.temperature
    for idx = 1, #weather.Halfweg.hours do
        local hour = weather.Halfweg.hours[idx]
        local cur_x = today_x + idx*12
        a.add(anims.moving_bar(S, E, red, cur_x, temp_to_y(hour.temperature), cur_x+5, temp_to_y(hour.temperature)+5,1))
--        current_temp = hour.temperature
    end

    Sidebar.hide(E)
    fn.wait_t(0)

--
--    xx = 100
--    yy = 700
--    shader:use {
--    margin_h=0.03;
--    margin_v=0.2;
--    }
--    red:draw(xx-20,yy-20,xx+700,yy+70)
--    shader:deactivate()

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
