local json = require "json"
local utils = require "utils"
local anims = require "anims"

local M = {}
local gray = resource.create_colored_texture(0.28,0.28,0.28,1) -- gray
--local gray = resource.create_colored_texture(0.898,0.529,0,1) -- gray

--local icons = util.auto_loader({}, function(fname)
--    return fname:sub(1,4) == "gvb-"
--end)

local background = resource.load_image("brackets_scaled.png")

local open_data = {}

local unwatch = util.file_watch("current_brackets_open.json", function(raw)
    open_brackets = json.decode(raw)
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
    local font_size_small = 30
    local team_width = 380
    local score_width = 70
    local x_games = 150
    local x_standings = 1100
    local rank_width = 60
    local y_split_teams = 100

    -- HEADER
    a.add(anims.moving_font(t, E, 150, y, "Open Division Bracket", 80, 1,1,1,1))
    y = y + 90
    local y_top = y
    t = t + 0.03

    a.add(anims.moving_image(t, E, background, 0, y, 1920, y+909, 1))


    local pos = {}
--    name     = team_1  ,  team_2 (relative to team_1),  start_time / field (relative to team_1)
    pos["QF0"] = {39, 43, 0, 85, 40, 40}
    pos["QF1"] = {39, 218, pos["QF0"][3], pos["QF0"][4], pos["QF0"][5], pos["QF0"][6]}
    pos["QF2"] = {1614, pos["QF0"][2], pos["QF0"][3], pos["QF0"][4], pos["QF0"][5], pos["QF0"][6]}
    pos["QF3"] = {1614, pos["QF1"][2], pos["QF0"][3], pos["QF0"][4], pos["QF0"][5], pos["QF0"][6]}
    pos["SF0"] = {600, 150, 0, 300, 100, 150}
    pos["SF1"] = {900, 150, 0, 300, 100, 150}
    pos["SF2"] = {600, 100, 0, 100, 100, 50}
    pos["SF3"] = {900, 100, 0, 100, 100, 50}
    pos["Fin12"] = {800, 200, 200, 0, -100, 50}
    pos["Fin34"] = {800, 400, 200, 0, -100, 50}
    pos["Fin56"] = {800, 600, 200, 0, -100, 50}
    pos["Fin78"] = {800, 800, 200, 0, -100, 50}



    for idx = 1, #open_brackets do
        local game = open_brackets[idx]
        co = pos[game.name]
        a.add(anims.my_moving_font(t, E, co[1], y+co[2], "flag:" .. game.team_1_country .. " " .. game.team_1 , font_size, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, co[1]+team_width, y+co[2], string.format("%2.0f", game.team_1_score), font_size, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, co[1]+co[3], y+co[2]+co[4], "flag:" .. game.team_2_country .. " " .. game.team_1 , font_size, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, co[1]+co[3]+team_width, y+co[2]+co[4], string.format("%2.0f", game.team_2_score), font_size, 1,1,1,1))
        a.add(anims.my_moving_font(t, E, co[1]+co[5], y+co[2]+co[6], game.start_time .. " " .. game.field, font_size_small, 1,1,1,1))
        t = t + 0.03
    end

    fn.wait_t(0)
    Scroller.hide(E)
    Sidebar.hide(E)

    for now in fn.upto_t(E) do
        a.draw(now)
    end

    return true
end

return M
