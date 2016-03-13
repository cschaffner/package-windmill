local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}

local icons = util.auto_loader({}, function(fname)
    return fname:sub(1,4) == "gvb-"
end)

local departures = {}

local unwatch = util.file_watch("gvb.json", function(raw)
    departures = json.decode(raw)
end)

function M.unload()
    unwatch()
end

function M.can_schedule()
    return #departures > 0
end

function M.prepare(options)
    return options.duration or 10
end

function M.run(duration, _, fn)
    local y = 200
    local a = utils.Animations()

    local S = 0.0
    local E = duration

    local now = Time.unixtime()
    print('now is '.. now)

    local t = S

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, "Taking the bus to town?", 100, 1,1,1,1))
    y = y + 110
--    t = t + 0.03

    a.add(anims.moving_font(t, E, 150, y, "Take the 10-minute walk to Bus stop Aalbertsestraat", 45, 1,1,1,1))
    y = y + 60
    t = t + 0.03



    for idx = 1, #departures do
        local dep = departures[idx]
        if dep.date > now then
            local time = dep.nice_date

            local remaining = math.floor((dep.date - now) / 60)
            local append = ""

            if remaining < 0 then
                time = "gone"
                if dep.next_date then
                    append = string.format("next in %d min", math.floor((dep.next_date - now)/60))
                end
            elseif remaining < 2 then
                time = "now"
                if dep.next_date then
                    append = string.format("next in %d min", math.floor((dep.next_date - now)/60))
                end
            else
                time = time .. " (in " .. remaining .. "min)"
                if dep.next_nice_date then
                    append = "again " .. dep.next_nice_date
                end
            end

--            if #dep.platform > 0 then
--                if #append > 0 then
--                    append = append .. " / " .. dep.platform
--                else
--                    append = dep.platform
--                end
--            end


--            if remaining < 3 then
            a.add(anims.moving_image(t, E, icons['gvb-bus'], 10, y, 140, y+60, 0.9))
            a.add(anims.moving_font(t, E, 130, y, dep.line , 60, 1,1,1,1))
            a.add(anims.moving_font(t, E, 200, y, time , 45, 1,1,1,1))
            y = y + 45
            a.add(anims.moving_font(t, E, 200, y, dep.stop .. " -> " .. dep.direction, 60, 1,1,1,1))
            y = y + 100
--            else
--                a.add(anims.moving_image(t, E, icons['gvb-bus'], 10, y, 140, y+45, 0.9))
--                a.add(anims.moving_font(t, E, 150, y, time, 45, 1,1,1,1))
--                a.add(anims.moving_font(t, E, 300, y, dep.stop .. " -> " .. dep.direction, 30, 1,1,1,1))
--                y = y + 30
--                a.add(anims.moving_font(t, E, 300, y, append , 25, 1,1,1,1))
--                y = y + 30
--            end
            t = t + 0.03
            if y > HEIGHT - 200  or idx > 3 then
                break
            end
        end
    end

    a.add(anims.moving_image(S+1, E, icons['gvb-icon'], 1300, 400, 1300+200, 400+200, 1))

    fn.wait_t(0)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
