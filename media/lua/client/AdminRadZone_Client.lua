-- client/AdminRadZone_Client.lua
if not isClient() then return end

AdminRadZone = AdminRadZone or {}


-----------------------            ---------------------------
function AdminRadZone.clear()
    AdminRadZoneData.x = -1
    AdminRadZoneData.y = -1
    AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 4
    AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.state = "inactive"
    AdminRadZoneData.duration = 0
    AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
    
    if AdminRadZone.tempMarker then
        AdminRadZone.tempMarker:remove()
        AdminRadZone.tempMarker = nil
    end
    
    AdminRadZone.clearZone()
    print("Client: AdminRadZone cleared")
end

function AdminRadZone.updateMarker()
    AdminRadZone.updateClientMarker()
end

function AdminRadZone.doRun(data)
    
    if AdminRadZone.tempMarker then
        AdminRadZone.tempMarker:remove()
        AdminRadZone.tempMarker = nil
    end
    AdminRadZone.Run() 
end

function AdminRadZone.doTransmit(data)
    sendServerCommand("AdminRadZone", "Sync", {data = data or AdminRadZoneData})
end

function AdminRadZone.isAdm(player)
    return player and (player:getAccessLevel() == "admin" or player:getAccessLevel() == "moderator")
end

-----------------------            ---------------------------
function AdminRadZone.initData()
    AdminRadZoneData.pause = AdminRadZoneData.pause or false
    AdminRadZoneData.cooldown = AdminRadZoneData.cooldown or SandboxVars.AdminRadZone.Cooldown or 60
    AdminRadZoneData.duration = AdminRadZoneData.duration or 0
    AdminRadZoneData.state = AdminRadZoneData.state or "inactive"
    AdminRadZoneData.rounds   = AdminRadZoneData.rounds   or SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.rad      = AdminRadZoneData.rad      or  SandboxVars.AdminRadZone.DefaultRadius or 4    
    AdminRadZoneData.x        = AdminRadZoneData.x        or -1
    AdminRadZoneData.y        = AdminRadZoneData.y        or -1
    return AdminRadZoneData
end

-----------------------            ---------------------------
function AdminRadZone.Fetch()   
    sendClientCommand(getPlayer(), "AdminRadZone", "Fetch", {})
end

function AdminRadZone.doFetch(data)
    local result = ""
    for k, v in pairs(data) do
        result = result .. tostring(k) .. ' \n';
        for key, value in pairs(v) do
            result = result .. "    " .. tostring(key) .. ' : ' .. tostring(value) .. "\n";
        end
    end
    Clipboard.setClipboard(result)
    print(result)
    local pl = getPlayer()
    if pl then 
        pl:Say(tostring("clipboard updated")) 
    end
end

-----------------------            ---------------------------
function AdminRadZone.initClient()
    AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
    AdminRadZone.initData()
    
    if isClient() then
        sendServerCommand("AdminRadZone", "RequestSync", {})
    end
    
    print("Client: AdminRadZone initialized")
end

Events.OnInitGlobalModData.Add(AdminRadZone.initClient)

function AdminRadZone.onCreatePlayer()
    if isClient() then
        sendServerCommand("AdminRadZone", "RequestSync", {})
    end
end

Events.OnCreatePlayer.Add(AdminRadZone.onCreatePlayer)

function AdminRadZone.updateClientMarker()
    if not AdminRadZoneData then return end
    
    if AdminRadZone.isIncomplete() or AdminRadZoneData.state == "inactive" then
        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
        return
    end
    
    if not AdminRadZone.marker and AdminRadZoneData.x ~= -1 and AdminRadZoneData.y ~= -1 then
        local sq = getCell():getOrCreateGridSquare(AdminRadZoneData.x, AdminRadZoneData.y, 0)
        if sq then
            local col = AdminRadZone.getMarkerColor(1)
            AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
                "AdminRadZone_Border", "circle_only_highlight", sq,
                col.r, col.g, col.b, true, AdminRadZoneData.rad)
        end
    end
    if AdminRadZone.marker then
        AdminRadZone.shiftColor(AdminRadZone.marker)
        if AdminRadZoneData.rad ~= AdminRadZone.marker:getSize() then
            AdminRadZone.marker:setSize(AdminRadZoneData.rad)
        end
        if round(AdminRadZone.marker:getX()) ~= round(AdminRadZoneData.x) or round(AdminRadZone.marker:getY()) ~= round(AdminRadZoneData.y) then
            AdminRadZone.marker:setPos(AdminRadZoneData.x, AdminRadZoneData.y, 0)
        end
    end
end

function AdminRadZone.isIncomplete()
    return not AdminRadZoneData or AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1
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




function AdminRadZone.shiftColor(marker)
    if not marker then return end
    local col = AdminRadZone.getMarkerColor(1)
    marker:setColor(col.r, col.g, col.b)
end

function AdminRadZone.Run(x, y, rad, rounds)
    if isClient() then
        sendServerCommand("AdminRadZone", "Run", {
            x = x, 
            y = y, 
            rad = rad, 
            rounds = rounds,
        })
    end
    AdminRadZoneData.x = x
    AdminRadZoneData.y = y
    AdminRadZoneData.rad = rad
    AdminRadZoneData.rounds = rounds
    AdminRadZoneData.state = "active"

    if not AdminRadZone.marker and AdminRadZoneData.x ~= -1 and AdminRadZoneData.y ~= -1 then
        local sq = getCell():getOrCreateGridSquare(AdminRadZoneData.x, AdminRadZoneData.y, 0)
        if sq then
            local col = AdminRadZone.getMarkerColor(1)
            AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
                "AdminRadZone_Border", "circle_only_highlight", sq,
                col.r, col.g, col.b, true, AdminRadZoneData.rad)
        end
    end
    if AdminRadZone.marker then
        AdminRadZone.shiftColor(AdminRadZone.marker)
        if AdminRadZoneData.rad ~= AdminRadZone.marker:getSize() then
            AdminRadZone.marker:setSize(AdminRadZoneData.rad)
        end
        if round(AdminRadZone.marker:getX()) ~= round(AdminRadZoneData.x) or round(AdminRadZone.marker:getY()) ~= round(AdminRadZoneData.y) then
            AdminRadZone.marker:setPos(AdminRadZoneData.x, AdminRadZoneData.y, 0)
        end
    end
end

function AdminRadZone.clearZone()
    AdminRadZoneData.state = "inactive"
    if isClient() then
        sendServerCommand("AdminRadZone", "Clear", {})
    end
    AdminRadZone.doTransmit(AdminRadZoneData)

end

function AdminRadZone.onModDataReceive(key)
    if key == "AdminRadZoneData" then
        print("Client: ModData updated")
        AdminRadZone.updateClientMarker()
    end
end

Events.OnReceiveGlobalModData.Add(AdminRadZone.onModDataReceive)

-----------------------            ---------------------------
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
function AdminRadZone.checkState()
    if AdminRadZoneData.state == "active" then return true end
    if AdminRadZoneData.state == "inactive" then return false end
    return nil
end

function AdminRadZone.core(module, command, args) 
    if module == "AdminRadZone" or module == "AdminRadZoneData" then   
        local pl = getPlayer();   
        if command == "Sync" and args.data then
            for key, value in pairs(args.data) do
                AdminRadZoneData[key] = value
            end
            print("Client: Received sync from server")
            AdminRadZone.updateClientMarker()
        elseif command == "Run" and (args.x or args.y or args.rad or args.rounds) then
            AdminRadZoneData.state = "active" 
            AdminRadZone.Run(args.x, args.y, args.rad, args.rounds)          
        elseif command == "Pause" and args.data then
            AdminRadZoneData.state = "pause" 
            AdminRadZone.save("AdminRadZoneData", args.data)     
        elseif command == "Clear" and args.data then
            AdminRadZoneData.state = "inactive" 
            AdminRadZone.clearZone()
        elseif command == "Msg" and args.msg then 
            print('AdminRadZone Server:\n'..tostring(args.msg))
        elseif command == "Fetch" and args.data then 
           AdminRadZone.doFetch(args.data)
        end
    end
end 

Events.OnServerCommand.Add(AdminRadZone.core)

function AdminRadZone.activate(bool)
    if bool == true then
        AdminRadZoneData.state = "active"
        AdminRadZone.Run()
    else
        AdminRadZoneData.state = "inactive"
        AdminRadZone.clearZone()
    end
end

-----------------------            ---------------------------