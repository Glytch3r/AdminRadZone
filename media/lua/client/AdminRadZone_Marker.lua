----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------
--client\AdminRadZone_Marker.lua
AdminRadZone = AdminRadZone or {}

function AdminRadZone.getMarkerColor(alpha, pick)
    alpha = alpha or 1
    pick = pick or (SandboxVars and SandboxVars.AdminRadZone and SandboxVars.AdminRadZone.MarkerColor) or 3
    
    local colors = {
        ColorInfo.new(0.5, 0.5, 0.5, alpha),  -- gray
        ColorInfo.new(1, 0, 0, alpha),        -- red
        ColorInfo.new(1, 0.5, 0, alpha),      -- orange
        ColorInfo.new(1, 1, 0, alpha),        -- yellow
        ColorInfo.new(0, 1, 0, alpha),        -- green
        ColorInfo.new(0, 0, 1, alpha),        -- blue
        ColorInfo.new(0.5, 0, 0.5, alpha),    -- purple
        ColorInfo.new(0, 0, 0, alpha),        -- black
        ColorInfo.new(1, 1, 1, alpha),        -- white
        ColorInfo.new(1, 0.75, 0.8, alpha),   -- pink
    }
    
    return colors[pick] or colors[3]
end

function AdminRadZone.getColorProperties()
    local col
    if AdminRadZone.isPanelInit() then
        col = getCore():getMpTextColor()
        AdminRadZone.shouldPick = "AdminRadZone_Img2"

    else
        col = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
        AdminRadZone.shouldPick = "AdminRadZone_Img1"

    end
    return col
end

-----------------------            ---------------------------
function AdminRadZone.isShouldShowMarker()
    if not AdminRadZoneData then return false end
    if AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 then return false end
    
    if AdminRadZone.isPanelInit() then 
       -- AdminRadZone.markerChoice = "AdminRadZone_Img1"
        return true 
    else
       -- AdminRadZone.markerChoice = "AdminRadZone_Img2"
        
        return true 

    end
    if AdminRadZoneData  then
        return AdminRadZone.showStates[AdminRadZoneData.state] == true 
    end
    return false
end
-----------------------            ---------------------------