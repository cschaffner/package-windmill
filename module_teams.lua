local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}

local team_idx = 0
--local black = resource.create_colored_texture(0,0,0,1)

local teams = {}

local teams_unwatch = util.file_watch("current_teams.json", function(raw)
    teams = json.decode(raw)
end)

function M.unload()
    teams_unwatch()
end

function M.can_schedule(options)
    print("number of teams: " .. #teams)
    return #teams > 0
end

function M.prepare(options)
    options.team, team_idx = utils.cycled(teams, team_idx)
    return options.duration or 10, options
end

function M.run(duration, args, fn)
    local text_size = 40
    local text_big = 50
    local S = 0.0
    local E = duration

--    local text_w = res.font:width(args.text, text_size)
    local a = utils.Animations()

    local y = 100
    a.add(anims.my_moving_font(S,E, 200, y, "flag:".. args.team.country .. " " .. args.team.name, 80, 1,1,1,1))
    y = y + 80 + 20
    if args.team.city ~= "" then
        a.add(anims.my_moving_font(S,E, 200, y, "City:".. args.team.city, text_size, 1,1,1,1))
        y = y + text_size + 10
    end

    y = y + 50
    a.add(anims.my_moving_font(S,E, 200, y, "Games:", text_big, 1,1,1,1))
    y = y + text_big + 20
    for idx = 1, #args.team.games do
        local game = args.team.games[idx]
--        print(game)
        a.add(anims.my_moving_font(S, E, 200, y, "Round " .. game.round_number .. ": " .. string.format("%2.0f", game.own_score) .. " - " .. string.format("%2.0f", game.opponent_score), text_size, 1,1,1,1))
        a.add(anims.my_moving_font(S, E, 500, y, "flag:" .. game.opponent_country .. game.opponent, text_size, 1,1,1,1));
        S = S + 0.1
        y = y + text_size + 20
    end

    fn.wait_t(0)
--    Sidebar.hide(E-1)

    for now in fn.upto_t(E) do
        a.draw(now)
    end
    return true

end

return M
