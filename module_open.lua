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
    local y = 20
    local a = utils.Animations()

    local S = 0.0
    local E = duration

    local now = Time.unixtime()

    local t = S
    local team_width = 400
    local score_width = 70
    local x_games = 150
    local x_standings = 1000

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, "Open Division", 80, 1,1,1,1))
    a.add(anims.moving_font(t, E, 600, y+10, open_data.round_name .. "  " .. open_data.start_time, 60, 1,1,1,1))
    y = y + 90
    local y_top = y
    t = t + 0.03

    for idx = 1, #open_data.games do
        local game = open_data.games[idx]

--        a.add(anims.moving_image(t, E, icons['gvb-icon'], 10, y, 140, y+60, 0.9))
        a.add(anims.my_moving_font(t, E, x_games, y, "flag:" .. game.team_1_country .. " " .. game.team_1 , 40, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_games+team_width, y, "" .. game.team_1_score, 40, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_games+team_width+score_width, y, "-", 40, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_games+team_width+score_width+20, y, "" .. game.team_2_score , 40, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_games+team_width+2*score_width+20, y, game.team_2 .. " flag:" .. game.team_1_country, 40, 1,1,1,1))
        y = y + 45
        t = t + 0.03

        if y > HEIGHT - 100 then
            break
        end
    end

    y = y_top
    for idx = 1, #open_data.standings do
        local standing = open_data.standings[idx]

--        a.add(anims.moving_image(t, E, icons['gvb-icon'], 10, y, 140, y+60, 0.9))
        a.add(anims.my_moving_font(t, E, x_standings, y, standing.ranking , 40, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_standings, y, standing.team_name , 40, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_standings+team_width, y, "" .. standing.swiss_score, 40, 1,1,1,1))
--        a.add(anims.my_moving_font(t, E, 150+team_width+score_width, y, "-", 40, 1,1,1,1))
--        a.add(anims.my_moving_font(t, E, 150+team_width+score_width+20, y, "" .. game.team_2_score , 40, 1,1,1,1))
--        a.add(anims.my_moving_font(t, E, 150+team_width+2*score_width+20, y, game.team_2 .. " flag:" .. game.team_1_country, 40, 1,1,1,1))
        y = y + 45
        t = t + 0.03

        if y > HEIGHT - 100 then
            break
        end
    end



--    a.add(anims.moving_image(S+1, E, icons['gvb-icon'], 1000, 400, 1000+300, 400+300, 1))

    fn.wait_t(0)
    Scroller.hide(E-2)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
