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
local mixed_data = {}
local women_data = {}

local open_unwatch = util.file_watch("current_games_open.json", function(raw)
    open_data = json.decode(raw)
end)
local mixed_unwatch = util.file_watch("current_games_mixed.json", function(raw)
    mixed_data = json.decode(raw)
end)
local women_unwatch = util.file_watch("current_games_women.json", function(raw)
    women_data = json.decode(raw)
end)

function M.unload()
    open_unwatch()
    mixed_unwatch()
    women_unwatch()
end

function M.can_schedule()
    return true
end

function M.prepare(options)
    return options.duration or 10, options
--        {
--        division = options.division,
--        font_size = options.font_size,
--        y_lift = options.y_lift,
--        top_title = options.top_title,
--        line_break_fraction_games = options.line_break_fraction_games,
--        line_break_fraction_standings = options.line_break_fraction_standings,
--    }
end

function M.run(duration, args, fn)
    local game_data
    if args.division == 'open' then
        game_data = open_data
    elseif args.division == 'mixed' then
        game_data = mixed_data
    elseif args.division == 'women' then
        game_data = women_data
    end

    local y = 20
    local a = utils.Animations()

    local S = 0.0
    local E = duration

    local now = Time.unixtime()

    local t = S
    local font_size = args.font_size
    local field_nr_width = 80
    local team_width = 300
    local score_width = 60
    local x_games = 150
    local x_standings = 1100
    local rank_width = 60
    local y_lift = args.y_lift -- for scrolling the standings

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, args.top_title, 80, 1,1,1,1))
    a.add(anims.moving_font(t, E, 400, y, game_data.round_name .. "  " .. game_data.start_time, 80, 1,1,1,1))
    y = y + 130
    local y_top = y
    t = t + 0.03


    for idx = 1, #game_data.games do
        local game = game_data.games[idx]

        if (idx % 2 == 1) then
            a.add(anims.moving_bar(t, E, gray, x_games, y, x_games+field_nr_width+2*(team_width+score_width)+20, y+font_size,1))
        end
        curx = x_games
        a.add(anims.my_moving_font(t, E, x_games, y, string.format("%2.0f", game.field_nr) , font_size, 1,1,1,1))
        curx = curx + field_nr_width
        a.add(anims.my_moving_font(t, E, curx, y, "flag:" .. game.team_1_country .. " " .. game.team_1 , font_size, 1,1,1,1))
        curx = curx + team_width
        a.add(anims.my_moving_font(t, E, curx, y, string.format("%2.0f", game.team_1_score), font_size, 1,1,1,1))
        curx = curx + score_width
        if game.is_final then
            a.add(anims.my_moving_font(t, E, curx, y, "-", font_size, 1,1,1,1))
        else
            a.add(anims.my_moving_font(t, E, curx-10, y, "*-", font_size, 1,1,1,1))
        end
        curx = curx + 20
        a.add(anims.my_moving_font(t, E, curx, y, string.format("%2.0f", game.team_2_score) , font_size, 1,1,1,1))
        curx = curx + score_width
        a.add(anims.my_moving_font(t, E, curx, y, game.team_2 .. " flag:" .. game.team_2_country, font_size, 1,1,1,1))
        y = y + font_size + math.floor(font_size/args.line_break_fraction_games)
        t = t + 0.03

        if y > HEIGHT - 100 then
            break
        end
    end

    y = y_top - 150
    local nr_teams = #game_data.standings
    for idx = 1, #game_data.standings do
        local standing = game_data.standings[idx]
        local scroll_time = t + 8 + (nr_teams-idx)*0.09
        print("" .. idx .. standing.ranking .. standing.team_name)

        if (idx % 2 == 1) then
            a.add(anims.scrolling_bar(t, scroll_time, E, gray, x_standings, y, x_standings+rank_width+team_width+font_size*3, y+font_size, y_lift, 1))
        end

        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings, y, y_lift, string.format("%2.0f", standing.ranking) , font_size, 1,1,1,1))
        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings+rank_width, y, y_lift, standing.team_name , font_size, 1,1,1,1))
        a.add(anims.my_scrolling_font(t, scroll_time, E, x_standings+rank_width+team_width, y, y_lift, string.format("%6.2f", standing.swiss_score), font_size, 1,1,1,1))
----        a.add(anims.my_moving_font(t, E, 150+team_width+score_width, y, "-", font_size, 1,1,1,1))
----        a.add(anims.my_moving_font(t, E, 150+team_width+score_width+20, y, "" .. game.team_2_score , font_size, 1,1,1,1))
----        a.add(anims.my_moving_font(t, E, 150+team_width+2*score_width+20, y, game.team_2 .. " flag:" .. game.team_1_country, font_size, 1,1,1,1))
        y = y + font_size + math.floor(font_size/args.line_break_fraction_standings)
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
