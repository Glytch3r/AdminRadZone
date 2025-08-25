--shared folder
--AdminRadZone_Status.lua

AdminRadZone = AdminRadZone or {}




-----------------------            ---------------------------


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
