--client folder
--AdminRadZone_Marker.lua
AdminRadZone = AdminRadZone or {}
LuaEventManager.AddEvent("OnClockUpdate")


function AdminRadZone.isPaused()
    return AdminRadZoneData.cooldown > 0
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



function AdminRadZone.updateMarker()
    if AdminRadZone.shouldInit() then
        AdminRadZone = AdminRadZone.initData()
    end
    if not AdminRadZoneData.active or AdminRadZoneData.rad < 0 or AdminRadZoneData.rounds == -1 then
        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
        return
    end

    if not AdminRadZone.marker then
        local sq = getCell():getOrCreateGridSquare(AdminRadZoneData.x, AdminRadZoneData.y, 0)
        if sq then
            local col = AdminRadZone.getMarkerColor(1)
            AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
            "AdminRadZone_Border", "circle_only_highlight", sq,
            col.r, col.g, col.b, true, AdminRadZoneData.rad)
            AdminRadZone.shiftColor(AdminRadZone.marker)     
        end
    end
 
    if AdminRadZone.marker then
        AdminRadZone.shiftColor(AdminRadZone.marker)        
        AdminRadZone.marker:setSize(AdminRadZoneData.rad)    
        if AdminRadZoneData.x ~= -1 and AdminRadZoneData.y ~= -1 then 
            AdminRadZone.marker:setPos(AdminRadZoneData.x, AdminRadZoneData.y, 0)
        end
    end
end


function AdminRadZone.getShrinkRate(rad, rounds)
    if rounds <= 0 then return 0 end
    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    if roundDuration <= 0 then return 0 end   
    return rad / roundDuration
end
-----------------------            ---------------------------

-----------------------            ---------------------------
function AdminRadZone.OnClockUpdate(curSec)
    if not AdminRadZoneData then return end

    if not AdminRadZoneData.active then
        AdminRadZone.updateMarker()
        return
    end

    if AdminRadZone.isRadZonePaused() then
        AdminRadZone.updateMarker()
        return
    end

    if AdminRadZoneData.cooldown > 0 and AdminRadZoneData.duration == 0 then
        AdminRadZoneData.cooldown = AdminRadZoneData.cooldown - 1

        if AdminRadZoneData.cooldown <= 0 and AdminRadZoneData.rounds > 0 then
            AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration
            AdminRadZoneData.cooldown = 0
        end

        AdminRadZone.updateMarker()
        return
    end

    if AdminRadZoneData.duration > 0 and AdminRadZoneData.cooldown == 0 then
        AdminRadZoneData.duration = AdminRadZoneData.duration - 1

        AdminRadZoneData.shrinkRate = AdminRadZone.getShrinkRate(AdminRadZoneData.rad, AdminRadZoneData.rounds)
        AdminRadZoneData.rad = AdminRadZoneData.rad - AdminRadZoneData.shrinkRate
        if AdminRadZoneData.rad < 0 then AdminRadZoneData.rad = 0 end

        if AdminRadZoneData.rad == 0 then
            AdminRadZoneData.duration = 0
        end

        if AdminRadZoneData.duration <= 0 then
            AdminRadZoneData.rounds = AdminRadZoneData.rounds - 1
            if AdminRadZoneData.rounds <= 0 or AdminRadZoneData.rad == 0 then
                AdminRadZone.clear()
                return
            end
            AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown
        end

        AdminRadZone.updateMarker()
        return
    end

    AdminRadZone.updateMarker()
end

Events.OnClockUpdate.Add(AdminRadZone.OnClockUpdate)
