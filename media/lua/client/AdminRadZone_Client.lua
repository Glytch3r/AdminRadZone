--client folder
--AdminRadZone_Client.lua
if not isClient() then return end

AdminRadZone = AdminRadZone or {}

function AdminRadZone.init()
	AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
end
Events.OnInitGlobalModData.Add(AdminRadZone.init)

function AdminRadZone.core(module, command, args) 
    if module == "AdminRadZone" then     
        if command == "Sync" and args.data then
            AdminRadZone.save("AdminRadZone", args.data)       
        elseif command == "Msg" then 
            print('AdminRadZone: server msg\n'..tostring(args.msg))
        elseif command == "Fetch" then 
            local result = ""
            for k, v in pairs(data) do
                result = result .. tostring(k) .. ' \n';
                for key, value in pairs(v) do
                    result = result .. "    " .. tostring(key) .. ' : ' .. tostring(value) .. "\n";
                end
            end
            print(result)
        end
    end
end 
Events.OnServerCommand.Add(AdminRadZone.core)

function AdminRadZone.setActive(data)
    if not data or not data.active then
        AdminRadZoneData.active = not AdminRadZoneData.active
    else
        AdminRadZoneData.active = data.active
    end
    
    if AdminRadZoneData.active then
        AdminRadZoneData.cooldown = 0
        AdminRadZone.startClock()
        AdminRadZone.updateMarker()
    else
        AdminRadZone.setXY({x=-1,y=-1})
        AdminRadZone.clockStarted = false
    end
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.demo()
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
    
    local pl = getPlayer() 
    local x, y = -1, -1
    if pl then
        x, y = round(pl:getX()),  round(pl:getY())
    end
    
    if x and y then
        AdminRadZoneData.x = x
        AdminRadZoneData.y = y
    end
    
    AdminRadZoneData.rad = 5
    AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration or 60

    AdminRadZoneData.active = true
    AdminRadZoneData.rounds = 5
    AdminRadZoneData.cooldown = 0
    AdminRadZoneData.shrinkRate = SandboxVars.AdminRadZone.ShrinkRate or 1
    
    AdminRadZone.doTransmit(AdminRadZoneData)
    AdminRadZone.activate(true)
end

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
    AdminRadZoneData.shrinkRate = SandboxVars.AdminRadZone.ShrinkRate or 1
    AdminRadZoneData.active = false

    AdminRadZone.clockStarted = false
    AdminRadZone.doTransmit(AdminRadZoneData)
    --AdminRadZone.updateMarker()

end

function AdminRadZone.setXY(data)
    if not data or not data.x or not data.y  then
        AdminRadZoneData.x = -1
        AdminRadZoneData.y = -1
    else
        AdminRadZoneData.x = data.x
        AdminRadZoneData.y = data.y
    end
    AdminRadZone.updateMarker()
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.setRad(data)
    if not data or not data.rad then
        AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 50
    else
        AdminRadZoneData.rad = data.rad
    end
    AdminRadZone.updateMarker()
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.setduration(data)
    if not data or not data.duration then
        AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration or 50
    else
        AdminRadZoneData.duration = data.duration
    end
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.setRounds(data)
    if not data or not data.rounds then
        AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    else
        AdminRadZoneData.rounds = data.rounds
    end
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.setCooldown(data)
    if not data or not data.cooldown then
        AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.DefaultCooldown or 60
    else
        AdminRadZoneData.cooldown = data.cooldown
    end
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.isCanActive()
    return AdminRadZoneData.x ~= -1 and AdminRadZoneData.y ~= -1 and AdminRadZoneData.rad ~= -1
end

function AdminRadZone.activate(bool)
    AdminRadZoneData.active = bool
    if AdminRadZoneData.active then 
        --AdminRadZoneData.timestamp = getTimestampMs()
        AdminRadZone.startClock()
        AdminRadZone.updateMarker()
    else
        AdminRadZone.clear()
    end
    AdminRadZone.save("AdminRadZoneData", AdminRadZoneData)
    
end

function AdminRadZone.doTransmit(data)
    AdminRadZone.sync(data)
    ModData.transmit("AdminRadZoneData", data)
end

function AdminRadZone.sync(data)
    data = data or AdminRadZoneData
    sendClientCommand(getPlayer(), "AdminRadZone", "Sync", {data=data})
end

function AdminRadZone.save(key, data)
    if key == "AdminRadZoneData" or key == "AdminRadZone" then
        local function StoreData(clientTable, serverTable)
            if not clientTable or not serverTable then return {} end
            for key, value in pairs(serverTable) do
                clientTable[key] = value
            end
            for key, _ in pairs(clientTable) do
                if not serverTable[key] then
                    clientTable[key] = nil
                end
            end
            return clientTable
        end
        AdminRadZoneData = StoreData(AdminRadZoneData, data)
        AdminRadZone.updateMarker()
    end
end

function AdminRadZone.RecieveData(key, data)
    AdminRadZone.save(key, data)
end
Events.OnReceiveGlobalModData.Add(AdminRadZone.RecieveData)
-----------------------            ---------------------------
function AdminRadZone.Fetch()   
    sendClientCommand(getPlayer(), "AdminRadZone", "Fetch", {})
end
