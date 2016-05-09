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
    return table.getn(teams) > 0
end

function M.prepare(options)
    options.team, team_idx = utils.cycled(teams, team_idx)
    return options.duration or 10, options
end

function M.run(duration, args, fn)
    local text_size = 70
    local text_big = 100
--    local text_w = res.font:width(args.text, text_size)
    local a = utils.Animations()

    local y = 100
    a.add(anims.my_moving_font(S,E, 200, y, args.team.name, text_size, 1,1,1,1))
    y = y + text_size + 20

    y = 600
    a.add(anims.my_moving_font(S,E, 200, y, "Games:", text_big, 1,1,1,1))
    y = y + text_big + 20
    for round, game in pairs(args.team.games) do
--        print(game)
        a.add(anims.my_moving_font(S, E, 200, y, round .. ": " .. game.opponent.name, text_size, 1,1,1,1));
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
