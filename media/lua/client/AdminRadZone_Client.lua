--client folder
--AdminRadZone_Client.lua
if not isClient() then return end

AdminRadZone = AdminRadZone or {}

function AdminRadZone.init()
	AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
    return AdminRadZoneData
end
Events.OnInitGlobalModData.Add(AdminRadZone.init)

function AdminRadZone.shouldInit()
    return not AdminRadZoneData or 
    AdminRadZoneData.active  == nil or
    AdminRadZoneData.cooldown  == nil or
    AdminRadZoneData.duration  == nil or
    AdminRadZoneData.rounds    == nil or
    AdminRadZoneData.rad       == nil or
    AdminRadZoneData.x         == nil or
    AdminRadZoneData.y         == nil 
end

function AdminRadZone.initData()
    AdminRadZoneData = AdminRadZone.init() or {}
    AdminRadZoneData.active   = AdminRadZoneData.active   or false
    AdminRadZoneData.pause = AdminRadZoneData.pause or false
    
    AdminRadZoneData.cooldown = AdminRadZoneData.cooldown or SandboxVars.AdminRadZone.Cooldown or 60
    AdminRadZoneData.duration = AdminRadZoneData.duration or SandboxVars.AdminRadZone.RoundDuration or 60

    
    AdminRadZoneData.rounds   = AdminRadZoneData.rounds   or SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.rad      = AdminRadZoneData.rad      or  SandboxVars.AdminRadZone.DefaultRadius or 50    
    AdminRadZoneData.x        = AdminRadZoneData.x        or -1
    AdminRadZoneData.y        = AdminRadZoneData.y        or -1
    return AdminRadZoneData
end

function AdminRadZone.core(module, command, args) 
    if module == "AdminRadZone" then     
        if command == "Sync" and args.data then
            AdminRadZone.save("AdminRadZoneData", args.data)       
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


function AdminRadZone.activate(bool)
    if AdminRadZone.shouldInit() then
        AdminRadZone = AdminRadZone.initData()
    end
    AdminRadZoneData.active = bool
    if AdminRadZoneData.active then 
        AdminRadZone.startClock()
    else
        AdminRadZone.clear()
    end
    AdminRadZone.save("AdminRadZoneData", AdminRadZoneData)
    return AdminRadZoneData.active
end
-----------------------            ---------------------------
function AdminRadZone.doTransmit(data)
    data = data or AdminRadZoneData
    sendClientCommand(getPlayer(), "AdminRadZone", "Sync", {data=data})
    ModData.transmit("AdminRadZoneData", data)
end

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
        if AdminRadZone.shouldInit() then
            AdminRadZoneData = AdminRadZone.initData()
        end
        AdminRadZone.updateMarker()
        return AdminRadZoneData
    end
end

function AdminRadZone.RecieveData(key, data)
    if key == "AdminRadZoneData" or key == "AdminRadZone" then
        AdminRadZone.save(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(AdminRadZone.RecieveData)
-----------------------            ---------------------------
function AdminRadZone.Fetch()   
    sendClientCommand(getPlayer(), "AdminRadZone", "Fetch", {})
end
-----------------------            ---------------------------
--[[ function AdminRadZone.setActive(data)
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
    --AdminRadZone.doTransmit(data)
end
 ]]