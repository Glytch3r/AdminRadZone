--shared folder
--AdminRadZone_Status.lua

AdminRadZone = AdminRadZone or {}




-----------------------            ---------------------------


AdminRadZone.PausedColor   = {r=1.0, g=0.85, b=0.2,  a=0.8} -- yellow
AdminRadZone.CooldownColor = {r=0.4, g=0.8,  b=1.0,  a=0.8} -- light blue
AdminRadZone.InactiveColor = {r=0.5, g=0.5,  b=0.5,  a=0.8} -- gray
AdminRadZone.ActiveColor   = {r=0.2, g=0.85, b=0.2,  a=0.8} -- green

function AdminRadZone.getPanelColor(str)
    str = str or  AdminRadZoneData.state
    local tab = {
        [""] = {r=0.2, g=0, b=0, a=0.8},             -- default/fallback
        ["pause"] = {r=1.0, g=0.85, b=0.2,  a=0.8},           -- paused
        ["cooldown"] = {r=0.4, g=0.8,  b=1.0,  a=0.8},         -- cooldown
        ["inactive"] = {r=0.5, g=0.5,  b=0.5,  a=0.8},         -- ready/inactive
        ["active"] = {r=0.2, g=0.85, b=0.2,  a=0.8},           -- active
    }
    return tab[str] or AdminRadZone.InactiveColor
end

function AdminRadZone.getMarkerColor(alpha, pick)
    alpha = alpha or 1
    pick = pick or SandboxVars and SandboxVars.AdminRadZone and SandboxVars.AdminRadZone.MarkerColor or 3
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
-----------------------            ---------------------------

function AdminRadZone.isRadZonePaused()
    return AdminRadZoneData.state == "pause"
end
function AdminRadZone.isRadZoneActive()
    return AdminRadZoneData.state == "active" and AdminRadZone.marker~=nil
end

function AdminRadZone.isRadZoneCooldown()
    return AdminRadZoneData.state == "cooldown"
end

function AdminRadZone.isRadZoneReady()
    return AdminRadZoneData.rounds > 0
           and AdminRadZoneData.x ~= -1 and AdminRadZoneData.y ~= -1
           and AdminRadZoneData.rad > 0
end
function AdminRadZone.isRadZoneInactive()
    return AdminRadZoneData.state == "inactive" and AdminRadZone.marker==nil
end


-----------------------            ---------------------------



-----------------------            ---------------------------


function AdminRadZone.clearData()
    AdminRadZoneData.state = 'inactive'
    AdminRadZoneData.duration = 0
    AdminRadZoneData.cooldown = 0
    AdminRadZoneData.rounds   = 0
    AdminRadZoneData.rad      = 0
    AdminRadZoneData.x        = -1
    AdminRadZoneData.y        = -1
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
end
