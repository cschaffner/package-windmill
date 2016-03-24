local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}
local gray = resource.create_colored_texture(0.28,0.28,0.28,1) -- gray
--local gray = resource.create_colored_texture(0.898,0.529,0,1) -- gray

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
    local font_size = 40
    local team_width = 380
    local score_width = 70
    local x_games = 150
    local x_standings = 1100
    local rank_width = 60

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, "Open Div", 80, 1,1,1,1))
    a.add(anims.moving_font(t, E, 500, y+10, open_data.round_name .. "  " .. open_data.start_time, 60, 1,1,1,1))
    y = y + 90
    local y_top = y
    t = t + 0.03


    for idx = 1, #open_data.games do
        local game = open_data.games[idx]

        if (idx % 2 == 1) then
            a.add(anims.moving_bar(t, E, gray, x_games, y, x_games+2*(team_width+score_width), y+font_size,1))
        end
        a.add(anims.my_moving_font(t, E, x_games, y, "flag:" .. game.team_1_country .. " " .. game.team_1 , font_size, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_games+team_width, y, string.format("%2.0f", game.team_1_score), font_size, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_games+team_width+score_width, y, "-", font_size, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_games+team_width+score_width+20, y, string.format("%2.0f", game.team_2_score) , font_size, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, x_games+team_width+2*score_width+20, y, game.team_2 .. " flag:" .. game.team_1_country, font_size, 1,1,1,1))
        y = y + font_size + 5
        t = t + 0.03

        if y > HEIGHT - 100 then
            break
        end
    end

    y = y_top
    local nr_teams = #open_data.standings
    for idx = 1, #open_data.standings do
        local standing = open_data.standings[idx]
<<<<<<< HEAD
        local scroll_time = t + 8 + (nr_teams-idx)*0.09
        print("" .. idx .. standing.ranking .. standing.team_name)

        if (idx % 2 == 1) then
            a.add(anims.scrolling_bar(t, scroll_time, E, gray, x_standings, y, x_standings+rank_width+team_width+font_size*3, y+font_size,1))
        end

        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings, y, string.format("%2.0f", standing.ranking) , font_size, 1,1,1,1))
        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings+rank_width, y, standing.team_name , font_size, 1,1,1,1))
        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings+rank_width+team_width, y, string.format("%6.2f", standing.swiss_score), font_size, 1,1,1,1))
=======
--        print("" .. standing.ranking .. standing.team_name)
--
----        a.add(anims.moving_image(t, E, icons['gvb-icon'], 10, y, 140, y+60, 0.9))
        a.add(anims.my_scrolling_font(t, E, x_standings, y, string.format("%2.0f", standing.ranking) , font_size, 1,1,1,1))
        a.add(anims.my_scrolling_font(t, E, x_standings+rank_width, y, standing.team_name , font_size, 1,1,1,1))
        a.add(anims.my_scrolling_font(t, E, x_standings+rank_width+team_width, y, string.format("%5.2f", standing.swiss_score), font_size, 1,1,1,1))
>>>>>>> 0f968b4... standings
----        a.add(anims.my_moving_font(t, E, 150+team_width+score_width, y, "-", font_size, 1,1,1,1))
----        a.add(anims.my_moving_font(t, E, 150+team_width+score_width+20, y, "" .. game.team_2_score , font_size, 1,1,1,1))
----        a.add(anims.my_moving_font(t, E, 150+team_width+2*score_width+20, y, game.team_2 .. " flag:" .. game.team_1_country, font_size, 1,1,1,1))
        y = y + font_size + 5
        t = t + 0.03
--
--        if y > HEIGHT - 100 then
--            break
--        end
    end

--    a.add(anims.moving_image(S+1, E, icons['gvb-icon'], 1000, 400, 1000+300, 400+300, 1))

    fn.wait_t(0)
    Scroller.hide(E)
    Sidebar.hide(E)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
