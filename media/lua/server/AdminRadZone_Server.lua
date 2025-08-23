-- server/AdminRadZone_Server.lua
if isClient() then return end

AdminRadZone = AdminRadZone or {}

LuaEventManager.AddEvent("OnClockUpdate")

-----------------------            ---------------------------
function AdminRadZone.initServer()
    AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
    
    if not AdminRadZoneData.x then
        AdminRadZone.clearServer()
    end
    
    print("Server: AdminRadZone initialized")
end

Events.OnInitGlobalModData.Add(AdminRadZone.initServer)

function AdminRadZone.startServerClock()
    if AdminRadZone.serverClockStarted then return end
    AdminRadZone.serverClockStarted = true
    AdminRadZone.prevSec = -1
    
    function AdminRadZone.serverTick()
        if not PZCalendar or not PZCalendar.getInstance() then return end
        local curSec = PZCalendar.getInstance():get(Calendar.SECOND)
        if AdminRadZone.prevSec ~= curSec then
            triggerEvent("OnClockUpdate", curSec)
            AdminRadZone.OnServerClockUpdate(curSec)
            AdminRadZone.prevSec = curSec
        end
    end
    Events.OnTick.Add(AdminRadZone.serverTick)
    print("Server: Clock started")
end

Events.OnServerStarted.Add(AdminRadZone.startServerClock)

function AdminRadZone.clearServer()
    AdminRadZoneData.x = -1
    AdminRadZoneData.y = -1
    AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 4
    AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.state = "inactive"
    AdminRadZoneData.duration = 0
    AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    
    AdminRadZone.syncToAllClients()
    return AdminRadZoneData
end

function AdminRadZone.OnServerClockUpdate(curSec)
    if AdminRadZoneData.state ~= 'pause' then 
        if AdminRadZoneData.state == 'cooldown' then
            AdminRadZoneData.cooldown = math.max(0, AdminRadZoneData.cooldown - 1)
            if AdminRadZoneData.cooldown <= 0 then
                AdminRadZoneData.state = "active"
                AdminRadZone.syncToAllClients()
            else
                AdminRadZone.syncToAllClients()
            end
        elseif AdminRadZoneData.state == "active" then
            AdminRadZoneData.rad = math.max(0, AdminRadZoneData.rad - 1)
            if AdminRadZoneData.rad <= 0 then 
                AdminRadZoneData.state = 'inactive'
                AdminRadZone.syncToAllClients()
            else
                AdminRadZoneData.duration = AdminRadZoneData.duration + 1
                if AdminRadZoneData.duration % (SandboxVars.AdminRadZone.RoundDuration or 60) == 0 then
                    AdminRadZoneData.duration = 0
                    AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
                    AdminRadZoneData.state = 'cooldown'
                    AdminRadZoneData.rounds = math.max(0, AdminRadZoneData.rounds - 1)
              
                    AdminRadZone.syncToAllClients()
                else   
                    AdminRadZone.syncToAllClients()
                end
            end
        end 
    end
    
    if AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 or AdminRadZoneData.rad <= 0 or AdminRadZoneData.rounds <= 0 then
        if AdminRadZoneData.state ~= 'inactive' then
            AdminRadZoneData.state = 'inactive'
           
            AdminRadZone.syncToAllClients()
        end
    end
end


function AdminRadZone.activateServer(x, y, radius, rounds)
    AdminRadZoneData.x = x or AdminRadZoneData.x
    AdminRadZoneData.y = y or AdminRadZoneData.y
    AdminRadZoneData.rad = radius or AdminRadZoneData.rad
    AdminRadZoneData.rounds = rounds or AdminRadZoneData.rounds
    AdminRadZoneData.state = "active"
    AdminRadZoneData.duration = 0
    
    AdminRadZone.syncToAllClients()
end

function AdminRadZone.syncToAllClients()
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
    if module == "AdminRadZone" then 
        print("Server: Received command " .. command .. " from " .. tostring(player))
        
        if command == "RequestSync" then
            sendServerCommand(player, "AdminRadZone", "Sync", {data = AdminRadZoneData})
            print("Server: Synced data to client")
            
        elseif command == "Sync" and args.data then
            AdminRadZone.save("AdminRadZoneData", args.data)
            AdminRadZone.syncToAllClients()
            sendServerCommand(player, "AdminRadZone", "Msg", {msg = "Data synced"})        
            
        elseif command == "Fetch" then
            AdminRadZone.syncToAllClients()
            sendServerCommand(player, "AdminRadZone", "Fetch", {data = AdminRadZoneData})
            
        elseif command == "Run" then
            if args and args.x and args.rad and args.rounds then
                AdminRadZoneData.state = "active"
                AdminRadZone.activateServer(args.x, args.y, args.rad, args.rounds)
                sendServerCommand(player, "AdminRadZone", "Run", {data = AdminRadZoneData})
            end
            
        elseif command == "Pause" then
            AdminRadZoneData.state = "pause"
            AdminRadZone.syncToAllClients()
            sendServerCommand(player, "AdminRadZone", "Pause", {data = AdminRadZoneData})
            print("Server: Zone paused")
            
        elseif command == "Clear" then       
            AdminRadZone.clearServer()
            sendServerCommand(player, "AdminRadZone", "Clear", {data = AdminRadZoneData})
            
        end
    end
end

Events.OnClientCommand.Add(AdminRadZone.clientSync)


-----------------------            ---------------------------