local M = {}

function M.game_string(game)
    local out = ''
    if game.team_1_score then
        if game.is_final then
            out = game.field .. ": " .. "flag:" .. game.team_1_country .. game.team_1 .. " " .. game.team_1_score .. " - "
            out = out .. game.team_2_score .. " " .. game.team_2 .. "flag:" .. game.team_2_country
        else
            out = "flag:" .. game.team_1_country .. game.team_1 .. " " .. game.team_1_score .. "* - "
            out = out .. game.team_2_score .. "* " .. game.team_2 .. "flag:" .. game.team_2_country
        end
    else
        out = game.field .. ": " .. "flag:" .. game.team_1_country .. game.team_1 .. " vs "
        out = out .. game.team_2 .. "flag:" .. game.team_2_country
    end
    return out
end


function M.flag_write(font, x, y, text, size, r, g, b, a)
    local index = 0
    local width = 0
    local flag_start
    local flag_end
    local country
--    return size+font:write(x, y, text, size, r, g, b, a)
    while true do
        flag_start, flag_end = string.find(text, "flag:", index)
        if flag_start == nil then
--            print(string.sub(text, index))
            width = width + font:write(x + width, y, string.sub(text, index), size, r, g, b, a)
            return width
        else
            if flag_start > 1 then
--                print(string.sub(text, index, flag_start-1))
                width = width + font:write(x + width, y, string.sub(text, index, flag_start-1), size, r, g, b, a)
            end
            country = string.sub(text, flag_end+1, flag_end+2)
            countries['flag_' .. country]:draw(x+width, y, x+width+size, y+size, a)
--            if country=="at" then
--                res.flag_at:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="be" then
--                res.flag_be:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="by" then
--                res.flag_by:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="ca" then
--                res.flag_ca:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="cc" then
--                res.flag_cc:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="ch" then
--                res.flag_ch:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="co" then
--                res.flag_co:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="cz" then
--                res.flag_cz:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="de" then
--                res.flag_de:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="dk" then
--                res.flag_dk:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="ee" then
--                res.flag_ee:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="es" then
--                res.flag_es:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="fr" then
--                res.flag_fr:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="gb" then
--                res.flag_gb:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="hu" then
--                res.flag_hu:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="ie" then
--                res.flag_ie:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="il" then
--                res.flag_il:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="it" then
--                res.flag_it:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="no" then
--                res.flag_no:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="nr" then
--                res.flag_nr:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="pl" then
--                res.flag_pl:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="pt" then
--                res.flag_pt:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="ru" then
--                res.flag_ru:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="se" then
--                res.flag_se:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="sk" then
--                res.flag_sk:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="tr" then
--                res.flag_tr:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="ua" then
--                res.flag_ua:draw(x+width, y, x+width+size, y+size, a)
--            elseif country=="us" then
--                res.flag_us:draw(x+width, y, x+width+size, y+size, a)
--            end
            width = width + size
            index = flag_end + 3
        end
    end
end

function M.Animations()
    local anims = {}

    local function add(anim)
        anims[#anims+1] = anim
    end

    local function draw(t)
        for idx = 1, #anims do
            gl.pushMatrix()
            anims[idx](t)
            gl.popMatrix()
        end
    end

    return {
        add = add;
        draw = draw;
    }
end

function M.wrap(str, limit, indent, indent1)
    limit = limit or 72
    local here = 1
    local wrapped = str:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)
        if fi-here > limit then
            here = st
            return "\n"..word
        end
    end)
    local splitted = {}
    for token in string.gmatch(wrapped, "[^\n]+") do
        splitted[#splitted + 1] = token
    end
    return splitted
end

function M.cycled(items, offset)
    offset = offset % #items + 1
    return items[offset], offset
end

function M.make_smooth(timeline)
    assert(#timeline >= 1)

    local function find_span(t)
        local lo, hi = 1, #timeline
        while lo <= hi do
            local mid = math.floor((lo+hi)/2)
            if timeline[mid].t > t then
                hi = mid - 1
            else
                lo = mid + 1
            end
        end
        return math.max(1, lo-1)
    end

    local function get_value(t)
        local t1 = find_span(t)
        local t0 = math.max(1, t1-1)
        local t2 = math.min(#timeline, t1+1)
        local t3 = math.min(#timeline, t1+2)

        local p0 = timeline[t0]
        local p1 = timeline[t1]
        local p2 = timeline[t2]
        local p3 = timeline[t3]

        local v0 = p0.val
        local v1 = p1.val
        local v2 = p2.val
        local v3 = p3.val

        local progress = 0.0
        if p1.t ~= p2.t then
            progress = math.min(1, math.max(0, 1.0 / (p2.t - p1.t) * (t - p1.t)))
        end

        if p1.ease == "linear" then 
            return (v1 * (1-progress) + (v2 * progress)) 
        elseif p1.ease == "step" then
            return v1
        elseif p1.ease == "inout" then
            return -(v2-v1) * progress*(progress-2) + v1
        else
            local d1 = p2.t - p1.t
            local d0 = p1.t - p0.t

            local bias = 0.5
            local tension = 0.8
            local mu = progress
            local mu2 = mu * mu
            local mu3 = mu2 * mu
            local m0 = (v1-v0)*(1+bias)*(1-tension)/2 + (v2-v1)*(1-bias)*(1-tension)/2
            local m1 = (v2-v1)*(1+bias)*(1-tension)/2 + (v3-v2)*(1-bias)*(1-tension)/2

            m0 = m0 * (2*d1)/(d0+d1)
            m1 = m1 * (2*d0)/(d0+d1)
            local a0 =  2*mu3 - 3*mu2 + 1
            local a1 =    mu3 - 2*mu2 + mu
            local a2 =    mu3 -   mu2
            local a3 = -2*mu3 + 3*mu2
            return a0*v1+a1*m0+a2*m1+a3*v2
        end
    end

    return get_value
end

function M.easeInOut(t, b, c)
    c = c - b
    return -c * math.cos(t * (math.pi/2)) + c + b;
end

return M
