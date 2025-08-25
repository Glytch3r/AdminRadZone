--server/AdminRadZone_Server.lua
if isClient() then return end

AdminRadZone = AdminRadZone or {}
LuaEventManager.AddEvent("OnClockUpdate")
AdminRadZone.prevState = nil

function AdminRadZone.getShrinkRate(rad, rounds)
    if AdminRadZoneData.state == "inactive" or AdminRadZoneData.state == "pause" or AdminRadZoneData.state == "cooldown" then 
        return 0 
    end 
    rad = rad or AdminRadZoneData.rad
    rounds = rounds or AdminRadZoneData.rounds
    if rounds <= 0 then return 0 end
    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    if roundDuration <= 0 then return 0 end   
    return rad / roundDuration
end

function AdminRadZone.initServer()
    AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
    if not AdminRadZoneData.state then
        AdminRadZone.clearServer()
    end

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
Events.OnInitGlobalModData.Add(AdminRadZone.initServer)


function AdminRadZone.clearServer()
    AdminRadZoneData.x = -1
    AdminRadZoneData.y = -1
    AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 4
    AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.state = "inactive"
    AdminRadZoneData.duration = 0
    AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    ModData.transmit("AdminRadZoneData")
    return AdminRadZoneData
end

function AdminRadZone.OnServerClockUpdate(curSec)
    if not  AdminRadZoneData.run then return end 
    if AdminRadZone.prevState ~= AdminRadZoneData.state then
        ModData.transmit("AdminRadZoneData")
    end

    if AdminRadZoneData.state == "inactive" or AdminRadZoneData.state == "pause" then
        return
    end

    if AdminRadZoneData.state == "cooldown" then
        AdminRadZoneData.cooldown = math.max(0, AdminRadZoneData.cooldown - 1)
        if AdminRadZoneData.cooldown <= 0 then
            AdminRadZoneData.state = "active"
        end
        ModData.transmit("AdminRadZoneData")
        return
    end

    if AdminRadZoneData.state == "active" then
        local shrinkRate = AdminRadZone.getShrinkRate(AdminRadZoneData.rad, AdminRadZoneData.rounds)
        AdminRadZoneData.rad = math.max(0, AdminRadZoneData.rad - shrinkRate)
        if AdminRadZoneData.rad <= 0 then 
            AdminRadZoneData.state = "inactive"
        else
            AdminRadZoneData.duration = AdminRadZoneData.duration + 1
            if AdminRadZoneData.duration % (SandboxVars.AdminRadZone.RoundDuration or 60) == 0 then
                AdminRadZoneData.duration = 0
                AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
                AdminRadZoneData.state = "cooldown"
                AdminRadZoneData.rounds = math.max(0, AdminRadZoneData.rounds - 1)
            end
        end
        ModData.transmit("AdminRadZoneData")
    end

    if (AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 or AdminRadZoneData.rad <= 0 or AdminRadZoneData.rounds <= 0)
    and AdminRadZoneData.state ~= "inactive" then
        AdminRadZoneData.state = "inactive"
        ModData.transmit("AdminRadZoneData")
    end
end
Events.OnClockUpdate.Add(AdminRadZone.OnServerClockUpdate)

function AdminRadZone.activateServer(x, y, radius, rounds)
    AdminRadZoneData.x = x or AdminRadZoneData.x
    AdminRadZoneData.y = y or AdminRadZoneData.y
    AdminRadZoneData.rad = radius or AdminRadZoneData.rad
    AdminRadZoneData.rounds = rounds or AdminRadZoneData.rounds
    AdminRadZoneData.state = "active"
    AdminRadZoneData.duration = 0
    ModData.transmit("AdminRadZoneData")
end


function AdminRadZone.save(key, data)
    if (key == "AdminRadZoneData" or key == "AdminRadZone") and data then
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

function AdminRadZone.clientSync(module, command, player, args)
    if module ~= "AdminRadZone" then return end
    print("Server: Received command " .. command .. " from " .. tostring(player))

    if command == "RequestSync" then
        sendServerCommand(player, "AdminRadZone", "Sync", {data = AdminRadZoneData})
    elseif command == "Sync" and args.data then

        AdminRadZone.save("AdminRadZoneData", args.data)
        ModData.transmit("AdminRadZoneData")
        sendServerCommand(player, "AdminRadZone", "Msg", {msg = "Data synced"})
    elseif command == "Fetch" then
        sendServerCommand(player, "AdminRadZone", "Fetch", {data = AdminRadZoneData})
    elseif command == "Run"  then
        AdminRadZoneData.run = true
        AdminRadZone.save("AdminRadZoneData", args.data)
        ModData.transmit("AdminRadZoneData")
    elseif command == "Pause" then
        AdminRadZoneData.state = "pause"
        ModData.transmit("AdminRadZoneData")
        sendServerCommand(player, "AdminRadZone", "Pause", {data = AdminRadZoneData})
    elseif command == "Clear" then
        AdminRadZoneData.run = false
        AdminRadZone.clearServer()
        ModData.transmit("AdminRadZoneData")

        --sendServerCommand(player, "AdminRadZone", "Clear", {data = AdminRadZoneData})
    end
end
Events.OnClientCommand.Add(AdminRadZone.clientSync)
