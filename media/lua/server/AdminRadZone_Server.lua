
--server
if isClient() then return end

AdminRadZone = AdminRadZone or {}
LuaEventManager.AddEvent("OnClockUpdate")

function AdminRadZone.getShrinkRate(rad, rounds)
    if not AdminRadZoneData then return 0 end
    if AdminRadZoneData.state ~= "active" then return 0 end

    rad = rad or AdminRadZoneData.rad
    rounds = rounds or AdminRadZoneData.rounds

    if not rad or not rounds or rounds <= 0 then return 0 end

    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    if roundDuration <= 0 then return 0 end

    local totalRemainingTime = rounds * roundDuration
    if AdminRadZoneData.duration and AdminRadZoneData.duration > 0 then
        totalRemainingTime = totalRemainingTime - AdminRadZoneData.duration
    end
    if totalRemainingTime <= 0 then return rad end

    return rad / totalRemainingTime
end

function AdminRadZone.getTotalTime()
    if not AdminRadZoneData then return 0 end
    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    local cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    local rounds = AdminRadZoneData.rounds or 0
    
    local activeTime = rounds * roundDuration
    local cooldownTime = math.max(0, rounds - 1) * cooldown

    return activeTime + cooldownTime
end

function AdminRadZone.getRemainingTime()
    if not AdminRadZoneData then return 0 end
    if AdminRadZoneData.state == "inactive" or AdminRadZoneData.state == "pause" then
        return 0
    end

    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    local cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    local rounds = AdminRadZoneData.rounds or 0
    local duration = AdminRadZoneData.duration or 0
    local remainingTime = 0
    
    if AdminRadZoneData.state == "active" then
        remainingTime = (roundDuration - duration)
        if rounds > 1 then
            remainingTime = remainingTime + ((rounds - 1) * roundDuration)
            remainingTime = remainingTime + ((rounds - 1) * cooldown)
        end
    elseif AdminRadZoneData.state == "cooldown" then
        remainingTime = AdminRadZoneData.cooldown or 0
        if rounds > 0 then
            remainingTime = remainingTime + (rounds * roundDuration)
            if rounds > 1 then
                remainingTime = remainingTime + ((rounds - 1) * cooldown)
            end
        end
    end

    return math.max(0, remainingTime)
end
-----------------------            ---------------------------

function AdminRadZone.clearServer()
    AdminRadZoneData.x = -1
    AdminRadZoneData.y = -1
    AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 4
    AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.run = false
    AdminRadZoneData.state = "inactive"
    AdminRadZoneData.duration = 0
    AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    AdminRadZoneData.totalTime = AdminRadZone.getTotalTime()
    AdminRadZoneData.remainingTime = 0
    ModData.transmit("AdminRadZoneData")
    return AdminRadZoneData
end
function AdminRadZone.initServer()
    AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
    if not AdminRadZoneData.state then
        AdminRadZone.clearServer()
        sendServerCommand("AdminRadZone", "Msg", {msg = "AdminRadZone: SERVER Started"})
    end
end
Events.OnInitGlobalModData.Add(AdminRadZone.initServer)


function AdminRadZone.startServer()    
    if AdminRadZone.serverClockStarted then return end
    AdminRadZone.serverClockStarted = true
    AdminRadZone.prevSec = -1
    
    function AdminRadZone.serverTick()
        if not PZCalendar or not PZCalendar.getInstance() then return end
        local curSec = PZCalendar.getInstance():get(Calendar.SECOND)
        if AdminRadZone.prevSec ~= curSec then
            triggerEvent("OnClockUpdate", curSec)
            AdminRadZone.prevSec = curSec
        end
    end

    Events.OnTick.Add(AdminRadZone.serverTick)
end
Events.OnServerStarted.Add(AdminRadZone.startServer)
-----------------------            ---------------------------

function AdminRadZone.updateData(data)
    for key, value in pairs(data) do
        if key ~= "state" then
            AdminRadZoneData[key] = value
        end
    end
    AdminRadZoneData.totalTime = AdminRadZone.getTotalTime()
    AdminRadZoneData.remainingTime = AdminRadZone.getRemainingTime()
end


function AdminRadZone.doTransmit()
    AdminRadZoneData.totalTime =  AdminRadZone.getTotalTime()
    AdminRadZoneData.remainingTime = AdminRadZone.getRemainingTime()
    ModData.transmit("AdminRadZoneData")
end

function AdminRadZone.clientSync(module, command, player, args)
    if module ~= "AdminRadZone" then return end
    if command == "RequestSync" then
        AdminRadZoneData.totalTime = AdminRadZone.getTotalTime()
        AdminRadZoneData.remainingTime = AdminRadZone.getRemainingTime()
        sendServerCommand(player, "AdminRadZone", "Sync", {data = AdminRadZoneData})
    elseif command == "Run" and args.data then
        AdminRadZone.updateData(args.data)
        if AdminRadZoneData.state == 'cooldown' then
            AdminRadZoneData.cooldown = 0
            if AdminRadZoneData.run == true then
                AdminRadZoneData.state = 'active'    
            end
        else
            AdminRadZoneData.run = true    
            AdminRadZoneData.state = 'active'    
        end
        
        sendServerCommand(player, "AdminRadZone", "Msg", {msg = "AdminRadZone: SERVER UPDATED"})
    elseif command == "Update" or  command == "Sync" and args.data then
        AdminRadZone.updateData(args.data)
        sendServerCommand(player, "AdminRadZone", "Msg", {msg = "AdminRadZone: SERVER UPDATED"})
    elseif command == "Fetch" then
        AdminRadZoneData.totalTime = AdminRadZone.getTotalTime()
        AdminRadZoneData.remainingTime = AdminRadZone.getRemainingTime()
        sendServerCommand(player, "AdminRadZone", "Fetch", {data = AdminRadZoneData})
    elseif command == "Clear" then
       
        AdminRadZone.clearServer()
    elseif command == "isRunning" then
        local msg = "AdminRadZone Server isRunning: "..tostring(AdminRadZone.serverClockStarted)
        sendServerCommand(player, "AdminRadZone", "Msg", {msg = msg})
    end
end
Events.OnClientCommand.Add(AdminRadZone.clientSync)

function AdminRadZone.isOnHold()
    local data = AdminRadZoneData
    if not data then return true end
    local state = data.state
    if not state then return true end
    return state == 'pause' or state == 'inactive' 
end

function AdminRadZone.OnServerClockUpdate(curSec)
    if not AdminRadZoneData.run then return end
    if AdminRadZoneData.state == "pause" or AdminRadZoneData.state == "inactive" then
        return 
    end
    if AdminRadZoneData.state == "cooldown" then
        AdminRadZoneData.cooldown = math.max(0, AdminRadZoneData.cooldown - 1)
        if AdminRadZoneData.cooldown <= 0 then
            AdminRadZoneData.state = "active"


            sendServerCommand(player, "AdminRadZone", "Msg", {msg = "AdminRadZone: SERVER UPDATED"})


        end
        AdminRadZone.doTransmit()
        return  
    end
    if AdminRadZoneData.state == "active" then
        local shrinkRate = AdminRadZone.getShrinkRate(AdminRadZoneData.rad, AdminRadZoneData.rounds)
        AdminRadZoneData.rad = math.max(0, AdminRadZoneData.rad - shrinkRate)
        
        if AdminRadZoneData.rad <= 0 then 
            if SandboxVars.AdminRadZone.DeactivateRadZero then
                AdminRadZoneData.run = false
                AdminRadZoneData.state = "inactive"        
            else
                AdminRadZoneData.state = "pause"
            end
        else
            AdminRadZoneData.duration = AdminRadZoneData.duration + 1
            if AdminRadZoneData.duration % (SandboxVars.AdminRadZone.RoundDuration or 60) == 0 then
                AdminRadZoneData.duration = 0
                AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
                AdminRadZoneData.state = "cooldown"
                AdminRadZoneData.rounds = math.max(0, AdminRadZoneData.rounds - 1)
                if AdminRadZoneData.rounds <= 0 then
                    AdminRadZoneData.state = "pause"
                end
            end
        end
   
    
        AdminRadZone.doTransmit()
    end
    
    if (AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1)
    and AdminRadZoneData.state ~= "inactive" then
        AdminRadZoneData.state = "inactive"
        AdminRadZone.doTransmit()
    end
end
Events.OnClockUpdate.Add(AdminRadZone.OnServerClockUpdate)


function AdminRadZone.OnReceiveGlobalModData(key, data)
    if key == "AdminRadZoneData" or  key == "AdminRadZone"  then
        AdminRadZone.updateData(data)  
        --AdminRadZone.doTransmit()
    end
  
end
Events.OnReceiveGlobalModData.Add(AdminRadZone.OnReceiveGlobalModData)

--[[ 

function AdminRadZone.OnServerClockUpdate(curSec)
    local AdminRadZoneData = AdminRadZoneData
    if not AdminRadZoneData then return end
    local state = AdminRadZoneData.state
    if not state then return end
    if state == 'pause' or state == 'inactive' then
        return
    end
    if state == 'active' then 
        if AdminRadZoneData.duration < SandboxVars.AdminRadZone.RoundDuration then
            AdminRadZoneData.duration = AdminRadZoneData.duration + 1
            AdminRadZoneData.shrinkRate = AdminRadZoneData.getShrinkRate(AdminRadZoneData.rad, AdminRadZoneData.duration) 
            AdminRadZoneData.rad = AdminRadZoneData.rad - AdminRadZoneData.shrinkRate
            if AdminRadZoneData.rad < 0 then AdminRadZoneData.rad = 0 end
            if AdminRadZoneData.rad == 0 then
                AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration
            end
        end
        if AdminRadZoneData.duration >= SandboxVars.AdminRadZone.RoundDuration then
            AdminRadZoneData.rounds = AdminRadZoneData.rounds - 1
            if AdminRadZoneData.rounds <= 0 then
                AdminRadZoneData.state = 'pause'
                return
            end
            AdminRadZoneData.state = 'cooldown'
            AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown
        end
    elseif state == 'cooldown' then
        if AdminRadZoneData.cooldown > 0 then
            AdminRadZoneData.cooldown = AdminRadZoneData.cooldown - 1
        end
        if AdminRadZoneData.cooldown <= 0 then
            AdminRadZoneData.state = 'active'
            AdminRadZoneData.duration = 0
        end
    end
    AdminRadZoneData.totalTime = AdminRadZone.getTotalTime()
    AdminRadZoneData.remainingTime = AdminRadZone.getRemainingTime()
    ModData.transmit("AdminRadZoneData")
end
Events.OnClockUpdate.Add(AdminRadZone.OnServerClockUpdate) ]]