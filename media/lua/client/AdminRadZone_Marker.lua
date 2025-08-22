--client folder
--AdminRadZone_Marker.lua
AdminRadZone = AdminRadZone or {}
LuaEventManager.AddEvent("OnClockUpdate")

function AdminRadZone.isDisabled()
    return AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 
end

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
    AdminRadZoneData = AdminRadZoneData or {}
    AdminRadZoneData.active   = AdminRadZoneData.active   or false
    AdminRadZoneData.cooldown = AdminRadZoneData.cooldown or 0
    AdminRadZoneData.duration = AdminRadZoneData.duration or 0
    AdminRadZoneData.rounds   = AdminRadZoneData.rounds   or 0
    AdminRadZoneData.x        = AdminRadZoneData.x        or -1
    AdminRadZoneData.y        = AdminRadZoneData.y        or -1
    AdminRadZoneData.rad      = AdminRadZoneData.rad      or 0

    if not AdminRadZoneData.active or AdminRadZoneData.rad <= 0 or AdminRadZoneData.rounds == -1 then
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
                col.r, col.g, col.b, true, AdminRadZoneData.rad
            )
        end
    end

    if AdminRadZone.marker then
        AdminRadZone.marker:setSize(AdminRadZoneData.rad)
        if AdminRadZoneData.x ~= -1 and AdminRadZoneData.y ~= -1 then 
            AdminRadZone.marker:setPos(AdminRadZoneData.x, AdminRadZoneData.y, 0)
        end
    end
end

function AdminRadZone.startClock()
    if AdminRadZone.clockStarted then return end
    AdminRadZone.clockStarted = true
    
    local prevSec = -1
    if PZCalendar and PZCalendar.getInstance() then
        prevSec = PZCalendar.getInstance():get(Calendar.SECOND)
    end
    function AdminRadZone.tick()
        if not PZCalendar or not PZCalendar.getInstance() then return end
        local curSec = PZCalendar.getInstance():get(Calendar.SECOND)
        if prevSec ~= curSec then
            triggerEvent("OnClockUpdate", curSec)
            prevSec = curSec
        end
    end
    Events.OnTick.Add(AdminRadZone.tick)
end

function AdminRadZone.getShrinkRate(rad, rounds)
    if rounds <= 0 then return 0 end
    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    if roundDuration <= 0 then return 0 end
   
    return rad / roundDuration
end
-----------------------            ---------------------------
function AdminRadZone.clear()
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
    AdminRadZoneData.x = -1
    AdminRadZoneData.y = -1
    AdminRadZoneData.rad = -1
    AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration or 60
    AdminRadZoneData.active = false
    AdminRadZoneData.rounds = 0
    AdminRadZoneData.cooldown = 0
    --AdminRadZoneData.shrinkRate = SandboxVars.AdminRadZone.ShrinkRate or 1
    AdminRadZoneData.active = false

    AdminRadZone.clockStarted = false
    AdminRadZone.doTransmit(AdminRadZoneData)
    --AdminRadZone.updateMarker()
end

--[[ 
function AdminRadZone.shouldClear()
    return (AdminRadZoneData.x == -1 and AdminRadZoneData.y == -1 and AdminRadZoneData.rad == -1) and AdminRadZone.marker ~= nil
end
 ]]
-----------------------            ---------------------------
function AdminRadZone.OnClockUpdate(curSec)
    local pl = getPlayer(); 
    if not pl then return end 
    if not AdminRadZoneData or not AdminRadZoneData.active then
        AdminRadZone.updateMarker()
        return 
    end
    -- cd
    if AdminRadZoneData.cooldown > 0 and AdminRadZoneData.duration == 0 then
        AdminRadZoneData.cooldown = AdminRadZoneData.cooldown - 1
        pl:setHaloNote('Cooldown: '..tostring(AdminRadZoneData.cooldown),150,250,150,100) 
        
        if AdminRadZoneData.cooldown <= 0 then
            if AdminRadZoneData.rounds > 0 then
                AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration
                AdminRadZoneData.cooldown = 0
            end
        end
        return
    end
    
    -- active
    if AdminRadZoneData.duration > 0 and AdminRadZoneData.cooldown == 0 then
        AdminRadZoneData.duration = AdminRadZoneData.duration - 1
        pl:setHaloNote('Duration: '..tostring(round(AdminRadZoneData.duration)),150,250,150,100) 
        
        AdminRadZoneData.shrinkRate =  AdminRadZone.getShrinkRate(AdminRadZoneData.rad, AdminRadZoneData.rounds)
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

    end
end
Events.OnClockUpdate.Add(AdminRadZone.OnClockUpdate)