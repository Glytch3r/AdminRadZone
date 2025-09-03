----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------
-- client/AdminRadZone_Client.lua
if not isClient() then return end

AdminRadZone = AdminRadZone or {}

-----------------------            ---------------------------
AdminRadZone.showStates = {
    ["active"] = true,
    ["pause"] = true,
    ["cooldown"] = true,
    ["inactive"] = false,

}
AdminRadZone.swapImg = {
    ["AdminRadZone_Img2"] = "AdminRadZone_Img1",
    ["AdminRadZone_Img1"] = "AdminRadZone_Img2",
}


AdminRadZone.stateColors = {
    ["inactive"] = ColorInfo.new(0.5, 0.5, 0.5, 1), -- gray
    ["active"] = ColorInfo.new(0, 1, 0, 1),          -- green
    ["cooldown"] = ColorInfo.new(1, 1, 0, 1),        -- yellow
    ["pause"] = ColorInfo.new(1, 0.5, 0, 1)          -- orange
}


----------------------- ---------------------------
local test = ColorInfo.new(0.5, 0.5, 0.5, 1)
print(test:getA())
function AdminRadZone.formatTime(seconds)
    if not seconds or seconds < 0 then return "00:00" end
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end


----------------------- ---------------------------
function AdminRadZone.requestSync()
    sendClientCommand("AdminRadZone", "RequestSync", {})
end

function AdminRadZone.updateServer(data)
    data.roundsTotal = tostring(data.rounds)
    data.radTotal = tostring(data.rad)
    sendClientCommand("AdminRadZone", "Update", {data = data})
end

function AdminRadZone.startZone(data)
    data.roundsTotal = tostring(data.rounds)
    data.radTotal = tostring(data.rad)
    data.run = true
    sendClientCommand("AdminRadZone", "Run", {data = data})
end

-----------------------            ---------------------------
function AdminRadZone.fetch()   
    sendClientCommand("AdminRadZone", "Fetch", {})
end

function AdminRadZone.doFetch(data)
    local result = "AdminRadZone Data:\n"
    result = result .. "State: " .. tostring(data.state) .. "\n"
    result = result .. "X: " .. tostring(data.x) .. "\n"
    result = result .. "Y: " .. tostring(data.y) .. "\n"
    result = result .. "Radius: " .. tostring(data.rad) .. "\n"
    result = result .. "Rounds: " .. tostring(data.rounds) .. "\n"
    result = result .. "Duration: " .. tostring(data.duration) .. "\n"
    result = result .. "Cooldown: " .. tostring(data.cooldown) .. "\n"
    result = result .. "Total Time: " .. AdminRadZone.formatTime(data.totalTime) .. "\n"
    result = result .. "Remaining Time: " .. AdminRadZone.formatTime(data.remainingTime) .. "\n"
    result = result .. "Run: " .. tostring(data.run) .. "\n"

    Clipboard.setClipboard(result)
    print(result)
    
    local pl = getPlayer()
    if pl then 
        pl:Say("Clipboard updated with RadZone data")
    end
end
-----------------------            ---------------------------

function AdminRadZone.clear()
    if not AdminRadZoneData then return nil end    
    AdminRadZoneData.cooldown = 0
    AdminRadZoneData.duration = 0
    AdminRadZoneData.state = "inactive"
    AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 4    
    AdminRadZoneData.x = -1
    AdminRadZoneData.y = -1
    AdminRadZoneData.run =  false
    AdminRadZoneData.roundsTotal =  tostring(AdminRadZoneData.rounds)
    AdminRadZoneData.radTotal =  tostring(AdminRadZoneData.rad)


    AdminRadZoneData.totalTime = AdminRadZone.getTotalTime() or 0
    AdminRadZoneData.remainingTime = AdminRadZoneData.remainingTime or 0
    sendClientCommand("AdminRadZone", "Clear", {data = AdminRadZoneData})
    return AdminRadZoneData
end




function AdminRadZone.initClient()
    if ModData.exists('AdminRadZoneData') then
        ModData.remove('AdminRadZoneData')
    end

    if not AdminRadZoneData then 
        AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
    end
    
    AdminRadZoneData.cooldown = AdminRadZoneData.cooldown or SandboxVars.AdminRadZone.Cooldown or 60
    AdminRadZoneData.duration = AdminRadZoneData.duration or 0
    AdminRadZoneData.state = AdminRadZoneData.state or "inactive"
    AdminRadZoneData.rounds = AdminRadZoneData.rounds or SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.rad = AdminRadZoneData.rad or SandboxVars.AdminRadZone.DefaultRadius or 4   

    AdminRadZoneData.roundsTotal =  AdminRadZoneData.roundsTotal or tostring(AdminRadZoneData.rounds)
    AdminRadZoneData.radTotal = AdminRadZoneData.radTotal or  tostring(AdminRadZoneData.rad)

    AdminRadZoneData.x = AdminRadZoneData.x or -1
    AdminRadZoneData.y = AdminRadZoneData.y or -1
    AdminRadZoneData.run = AdminRadZoneData.run or false
    AdminRadZoneData.totalTime = AdminRadZoneData.totalTime or AdminRadZone.getTotalTime() or 0
    AdminRadZoneData.remainingTime = AdminRadZoneData.remainingTime or 0
    
    return AdminRadZoneData
end
Events.OnInitGlobalModData.Add(AdminRadZone.initClient)

function AdminRadZone.onModDataReceive(key, data)
    if key == "AdminRadZoneData" or  key == "AdminRadZone"  then
        AdminRadZone.save(key, data)    
    end
end
Events.OnReceiveGlobalModData.Add(AdminRadZone.onModDataReceive)


function AdminRadZone.isIncomplete()
    return not AdminRadZoneData or AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1
end



function AdminRadZone.isPanelInit()
    return AdminRadZonePanel and  AdminRadZonePanel.instance and AdminRadZonePanel.instance:getIsVisible()
end
-----------------------            ---------------------------


function AdminRadZone.save(key, data)
    if (key == "AdminRadZoneData" or key == "AdminRadZone") and data then      
        for dataKey, value in pairs(data) do
            AdminRadZoneData[dataKey] = value
        end
        
        for dataKey, _ in pairs(AdminRadZoneData) do
            if data[dataKey] == nil then
                AdminRadZoneData[dataKey] = nil
            end
        end
        
        return AdminRadZoneData
    end
end


-----------------------            ---------------------------
function AdminRadZone.core(module, command, args)
    if module ~= "AdminRadZone" then return end
    
    if command == "Sync" and args.data then
        for key, value in pairs(args.data) do
            AdminRadZoneData[key] = value
        end
    elseif command == "Msg" and args.msg then
        print(tostring(args.msg))
        local pl = getPlayer()
        if pl and AdminRadZone.isAdm(pl) then
            pl:Say(args.msg)
        end
    elseif command == "Warning"  then

        local pl = getPlayer()
        if not pl then return end 

        if SandboxVars.AdminRadZone.ShrinkAlertAudio then
            pl:getEmitter():playSound("AdminRadZone_Warning")         
        end

        local x,y,z = pl:getX(), pl:getY(), pl:getZ()
        if x and y and z then
           if AdminRadZone.lamp then 
                getCell():removeLamppost(AdminRadZone.lamp) 
            end
            local col = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
            local r, g, b = col:getR()*255,  col:getG()*255, col:getB()*255                
            AdminRadZone.lamp =  getCell():addLamppost(IsoLightSource.new(x,y,z, r, g, b, 255))
        end
        AdminRadZone.halt(7.5, function()
            if SandboxVars.AdminRadZone.ShrinkAlertMessage then
                pl:startMuzzleFlash()
                ISChat.instance.servermsgTimer = 5000
                ISChat.instance.servermsg = tostring("Radiation Warning")
            end
        end)
    elseif command == "Run"  then
        local pl = getPlayer()
        if not pl then return end 
        if SandboxVars.AdminRadZone.ShrinkAlertAudio then
            pl:getEmitter():playSound("AdminRadZone_Warning")         
        end
        local x, y, z =   AdminRadZoneData.x ,   AdminRadZoneData.y , pl:getZ()
        if x and y and z then
           if AdminRadZone.lamp then 
                getCell():removeLamppost(AdminRadZone.lamp) 
            end
            local col = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
            local r, g, b = col:getR()*255,  col:getG()*255, col:getB()*255                
            AdminRadZone.lamp =  getCell():addLamppost(IsoLightSource.new(x,y,z, r, g, b, 255))
        end

        AdminRadZone.halt(7.5, function()
            if SandboxVars.AdminRadZone.ShrinkAlertMessage then
                pl:startMuzzleFlash()
                ISChat.instance.servermsgTimer = 5000
                ISChat.instance.servermsg = tostring("Radiation Warning")
            end
        end)
    
    elseif command == "Fetch" and args.data then
        AdminRadZone.doFetch(args.data)
    end
end


Events.OnServerCommand.Add(AdminRadZone.core)


function AdminRadZone.getTotalTime()
    if not AdminRadZoneData then return 0 end
    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    local cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    local rounds = AdminRadZoneData.rounds or 0
    
    local activeTime = rounds * roundDuration
    local cooldownTime = math.max(0, rounds - 1) * cooldown

    return activeTime + cooldownTime
end


-----------------------            ---------------------------

