local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}

--local icons = util.auto_loader({}, function(fname)
--    return fname:sub(1,4) == "gvb-"
--end)

local open_data = {}

local unwatch = util.file_watch("current_games_open.json", function(raw)
    open_data = json.decode(raw)
end)

function M.unload()
    unwatch()
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

    local t = S

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, "Open Division", 100, 1,1,1,1))
    y = y + 100
    t = t + 0.03

    a.add(anims.moving_font(t, E, 150, y, open_data.round_name .. open_data.start_time, 80, 1,1,1,1))
    y = y + 100
    t = t + 0.03


    for idx = 1, #open_data.games do
        local game = open_data.games[idx]

--        a.add(anims.moving_image(t, E, icons['gvb-icon'], 10, y, 140, y+60, 0.9))
        a.add(anims.my_moving_font(t, E, 150, y, utils.game_string(game) , 60, 1,1,1,1))
        y = y + 60
        t = t + 0.03

        if y > HEIGHT - 100 then
            break
        end
    end

--    a.add(anims.moving_image(S+1, E, icons['gvb-icon'], 1000, 400, 1000+300, 400+300, 1))

    fn.wait_t(0)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
