-- client/AdminRadZone_Client.lua
if not isClient() then return end

AdminRadZone = AdminRadZone or {}

----------------------- ---------------------------

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
    AdminRadZoneData.remainingTime = AdminRadZoneData.remainingTime or AdminRadZone.getRemainingTime() or 0
    
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

function AdminRadZone.getMarkerColor(alpha, pick)
    alpha = alpha or 1
    pick = pick or (SandboxVars and SandboxVars.AdminRadZone and SandboxVars.AdminRadZone.MarkerColor) or 3
    
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


AdminRadZone.stateColors = {
    ["inactive"] = ColorInfo.new(0.5, 0.5, 0.5, 1), -- gray
    ["active"] = ColorInfo.new(0, 1, 0, 1),          -- green
    ["cooldown"] = ColorInfo.new(1, 1, 0, 1),        -- yellow
    ["pause"] = ColorInfo.new(1, 0.5, 0, 1)          -- orange
}



function AdminRadZone.updateColorProperties(marker)
    marker = marker or AdminRadZone.marker
    if not marker then return end
    local col
    if AdminRadZonePanel.instance ~= nil and AdminRadZoneData and AdminRadZoneData.state then
        col = AdminRadZone.stateColors[AdminRadZoneData.state]
    else
        col = AdminRadZone.getMarkerColor()
    end

    if marker:getR() ~= col.r then marker:setR(col.r) end
    if marker:getG() ~= col.g then marker:setG(col.g) end
    if marker:getB() ~= col.b then marker:setB(col.b) end
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
        --[[      
            local lamp = pl:getCell():addLamppost(IsoLightSource.new(x, y, z, 0, 255, 0, 255))
            AdminRadZone.halt(3, function()
                pl:getCell():removeLamppost(x,y,z)
            end) 
        ]]
            
            AdminRadZone.doFader(x, y, z)
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

function AdminRadZone.getRemainingTime()
    if not AdminRadZoneData then return 0 end

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
AdminRadZone.showStates = {
    ["active"] = true,
    ["pause"] = true,
    ["cooldown"] = true,
}
AdminRadZone.swapImg = {
    ["AdminRadZone_Img2"] = "AdminRadZone_Img1",
    ["AdminRadZone_Img1"] = "AdminRadZone_Img2",
}


function AdminRadZone.isShouldShowMarker()
    if not AdminRadZoneData then return false end
    if AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 then return false end
    
    if AdminRadZonePanel.instance ~= nil then 
        AdminRadZone.markerChoice = "AdminRadZone_Img2"
        return true 
    else
        AdminRadZone.markerChoice = "AdminRadZone_Img1"
    end
    if AdminRadZoneData  then
        return AdminRadZone.showStates[AdminRadZoneData.state] == true 
    end
    return false
end

-----------------------            ---------------------------

AdminRadZone.a = 255
function AdminRadZone.fader(x, y, z, r, g, b)
    local pl = getPlayer() 
    AdminRadZone.a = 255
    local function ticker(t)
        t=t+1

        if t % 8 == 0 then 
            AdminRadZone.a = AdminRadZone.a - 1
            if AdminRadZone.lamp then
                pl:getCell():removeLamppost(x,y,z)
            end

            if AdminRadZone.a <= 0 then        
                AdminRadZone.a = 255
                Events.OnTick.Remove(ticker)
            else
                AdminRadZone.a = AdminRadZone.a - 1
                AdminRadZone.lamp = pl:getCell():addLamppost(IsoLightSource.new(x, y, z, r, g, b, AdminRadZone.a))
            end
        end
    end
    Events.OnTick.Add(ticker)
end

function AdminRadZone.doFader(x, y, z)        
    if AdminRadZone.a == 255 then
        local col = AdminRadZone.getRadColor()
        AdminRadZone.fader(x, y, z, col.r*255, col.g*255, col.b*255)
    end
end
--[[ 

local pl = getPlayer()
local x, y, z = round(pl:getX()),  round(pl:getY()),  pl:getZ() or 0

 AdminRadZone.doFader(x, y, z)    
 ]]
--[[ 


AdminRadZone.a = 255
function AdminRadZone.fader(x, y, z, r, g, b)
    local pl = getPlayer() 
    AdminRadZone.a = 255
    local function ticker(t)
        t=t+1
        AdminRadZone.a = AdminRadZone.a - 1
        if AdminRadZone.lamp then
            pl:getCell():removeLamppost(x,y,z)
        end
        if t % 4 == 0 then 
            if AdminRadZone.a <= 0 then        
                AdminRadZone.a = 255
                Events.OnTick.Remove(ticker)
            else
                AdminRadZone.lamp = pl:getCell():addLamppost(IsoLightSource.new(x, y, z, r, g, b, AdminRadZone.a))
            end
        end
    end
    Events.OnTick.Add(ticker)
end

function AdminRadZone.doFader(x, y, z)   
  
    if AdminRadZone.a == 255 then
        local col = AdminRadZone.getRadColor()
        AdminRadZone.fader(x, y, z, col.r*255, col.g*255, col.b*255)
    end
end ]]
