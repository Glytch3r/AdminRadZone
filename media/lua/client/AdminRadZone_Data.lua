----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

AdminRadZone = AdminRadZone or {}

function AdminRadZone.floor(n) 
    return math.floor(n + 0.5) 
end

function AdminRadZone.isDisabled()
    local x, y, rad, pause = AdminRadZone.toStringData(str)
    if x == -1 or y == -1 or rad == 0 then return true end
    local pick = SandboxVars.AdminRadZone.MarkerColor or 3
    return pick == 11
end
function AdminRadZone.isPaused()
    local x, y, rad, pause = AdminRadZone.toStringData(str)
    return  pause and pause == 1 
end

function AdminRadZone.getMarkerColor(alpha)
    alpha = alpha or 1
    local pick = SandboxVars.AdminRadZone.MarkerColor or 3
    local function getcolor(index, alpha)
        index = index or SandboxVars.AdminRadZone.MarkerColor or 3
        local colors = {
            ColorInfo.new(0.5, 0.5, 0.5, alpha),  --1 gray
            ColorInfo.new(1, 0, 0, alpha),        --2 red
            ColorInfo.new(1, 0.5, 0, alpha),      --3 orange
            ColorInfo.new(1, 1, 0, alpha),        --4 yellow
            ColorInfo.new(0, 1, 0, alpha),        --5 green
            ColorInfo.new(0, 0, 1, alpha),        --6 blue
            ColorInfo.new(0.5, 0, 0.5, alpha),    --7 purple
            ColorInfo.new(0, 0, 0, alpha),        --8 black
            ColorInfo.new(1, 1, 1, alpha),        --9 white
            ColorInfo.new(1, 0.75, 0.8, alpha),   --10 pink
            ColorInfo.new(0, 0, 0, 0),            --11 disabled
        }
        return colors[index] or nil 
    end
    return getcolor(pick, alpha)
end
function AdminRadZone.toStringData(str)
    str = str or SandboxVars.AdminRadZone.DataString
    if not str then return nil end
    local x, y, rad, pause = str:match("^(%-?%d+):(%-?%d+):(%-?%d+):?(%d*)$")
    if not x then return nil end
    return tonumber(x), tonumber(y), tonumber(rad), tonumber(pause) or 1
end
-- local x, y, rad, pause = AdminRadZone.toStringData(str)

function AdminRadZone.toDataString(x, y, rad, pause)
    if not x or not y then return nil end
    rad = rad or (SandboxVars.AdminRadZone.DefaultRadius or 50)
    pause = pause or 1
    return string.format("%d:%d:%d:%d", x, y, rad, pause)
end
-- local str = AdminRadZone.toDataString(x, y, rad, pause)
