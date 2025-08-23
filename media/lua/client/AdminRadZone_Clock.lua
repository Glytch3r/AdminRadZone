--[[ -- client
--AdminRadZone_Clock.lua

AdminRadZone = AdminRadZone or {}
LuaEventManager.AddEvent("OnClockUpdate")

-----------------------            ---------------------------

function AdminRadZone.init()
    AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
end
Events.OnInitGlobalModData.Add(AdminRadZone.init)

function AdminRadZone.start()
    AdminRadZone.startClock()
end
Events.OnCreatePlayer.Add(AdminRadZone.start)



function AdminRadZone.save(key, data)
    if key == "AdminRadZoneData" or key == "AdminRadZone" and data then      
        for key, value in pairs(data) do
            AdminRadZoneData[key] = value
        end
        for key, _ in pairs(AdminRadZoneData) do
            if not data[key] then
                AdminRadZoneData[key] = nil
            end
        end
        return AdminRadZoneData
    end
end

function AdminRadZone.Send()   
    sendClientCommand(getPlayer(), "AdminRadZone", "Sync", {data = AdminRadZoneData})
end



function AdminRadZone.isIncomplete()
    return AdminRadZone.x == -1 or AdminRadZone.y == -1
end



function AdminRadZone.startClock()
    if AdminRadZone.clockStarted then return end
    AdminRadZone.clockStarted = true
    AdminRadZone.prevSec = -1
    
    function AdminRadZone.tick()
        if not PZCalendar or not PZCalendar.getInstance() then return end
        local curSec = PZCalendar.getInstance():get(Calendar.SECOND)
        if AdminRadZone.prevSec ~= curSec then
            triggerEvent("OnClockUpdate", curSec)
            AdminRadZone.prevSec = curSec
        end
    end

    Events.OnTick.Add(AdminRadZone.tick)
end


function AdminRadZone.clear()
    AdminRadZoneData.x = -1
    AdminRadZoneData.y = -1
    AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 4
    AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.state = "inactive"
    AdminRadZoneData.duration = 0
    AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    --AdminRadZoneData.shrinkRate = SandboxVars.AdminRadZone.ShrinkRate or 1
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
    if isClient() then
        print( "Client: AdminRadZone.clear()")
    end
    return AdminRadZoneData
end

function AdminRadZone.OnClockUpdate(curSec)
     if not AdminRadZoneData.state == 'pause' then
        if AdminRadZoneData.state == 'cooldown' then
            AdminRadZoneData.cooldown =  math.max(0, AdminRadZoneData.cooldown - 1)
            if AdminRadZoneData.cooldown <= 0 then
                AdminRadZoneData.state = "active"
            end
        elseif AdminRadZoneData.state == "active" then
            AdminRadZoneData.rad =  math.max(0, AdminRadZoneData.rad - 1)
            if AdminRadZoneData.rad < 0 then 
                AdminRadZoneData.state = 'inactive'
            end   
            AdminRadZoneData.duration = AdminRadZoneData.duration + 1
            if AdminRadZoneData.duration %  SandboxVars.AdminRadZone.RoundDuration == 0 then
                AdminRadZoneData.duration = 0
                AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown
                AdminRadZoneData.state = 'cooldown'
            end
        end 
    end
    if AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 or AdminRadZoneData.rad <= 0 or AdminRadZoneData.rounds <= 0 then
        AdminRadZoneData.state = 'inactive'
    end
    if AdminRadZone.isIncomplete() or AdminRadZoneData.state == "inactive"  then
        if AdminRadZone.marker then
            AdminRadZoneData.state = "inactive"    
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
    
    if AdminRadZoneData.state == "cooldown" or  AdminRadZoneData.state == "pause" then
        return 
    end
   
    
    if AdminRadZoneData.state == "active" then
        if AdminRadZone.marker then
            AdminRadZone.shiftColor(AdminRadZone.marker)        
            AdminRadZone.marker:setSize(AdminRadZoneData.rad)    
            if not AdminRadZone.isIncomplete()  then
                AdminRadZone.marker:setPos(AdminRadZoneData.x, AdminRadZoneData.y, 0)
            end
        end
    end
end
Events.OnClockUpdate.Add(AdminRadZone.OnClockUpdate)

-----------------------            ---------------------------
 ]]