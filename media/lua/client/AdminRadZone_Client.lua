-- client/AdminRadZone_Client.lua
if not isClient() then return end

AdminRadZone = AdminRadZone or {}


-----------------------            ---------------------------
function AdminRadZone.clear()
    local data
    data.x = -1
    data.y = -1
    data.rad = SandboxVars.AdminRadZone.DefaultRadius or 4
    data.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    data.state = "inactive"
    data.duration = 0
    data.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    data.run = false
    
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
    
    if AdminRadZone.tempMarker then
        AdminRadZone.tempMarker:remove()
        AdminRadZone.tempMarker = nil
    end

    if AdminRadZone.SickMarker then
        AdminRadZone.SickMarker:remove()
        AdminRadZone.SickMarker = nil
    end
    if isClient() then
        sendServerCommand("AdminRadZone", "Clear", {data = data})
    end

    AdminRadZone.doTransmit(data)

end

function AdminRadZone.doRun(data)
    
    if AdminRadZone.tempMarker then
        AdminRadZone.tempMarker:remove()
        AdminRadZone.tempMarker = nil
    end
    AdminRadZone.Run() 
end


function AdminRadZone.isAdm(pl)
    return pl and (pl:getAccessLevel() == "admin" or pl:getAccessLevel() == "moderator")
end

-----------------------            ---------------------------

function AdminRadZone.initData()
    AdminRadZoneData.pause = AdminRadZoneData.pause or false
    AdminRadZoneData.cooldown = AdminRadZoneData.cooldown or SandboxVars.AdminRadZone.Cooldown or 60
    AdminRadZoneData.duration = AdminRadZoneData.duration or SandboxVars.AdminRadZone.RoundDuration or 60
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
    if ModData.exists('AdminRadZoneData') then
        ModData.remove('AdminRadZoneData')
    end
    AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
end
Events.OnInitGlobalModData.Add(AdminRadZone.initClient)

function AdminRadZone.onCreatePlayer()    
    if not AdminRadZoneData then AdminRadZone.initClient() end
    if AdminRadZone.isShouldShowMarker() then
        
    end
end
Events.OnCreatePlayer.Add(AdminRadZone.onCreatePlayer)

-----------------------            ---------------------------

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
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
    AdminRadZone.doTransmit(AdminRadZoneData)
end

function AdminRadZone.onModDataReceive(key, data)
    if key == "AdminRadZoneData" then
        AdminRadZone.save(key, data)
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

function AdminRadZone.core(module, command, args)
    if module ~= "AdminRadZone" and module ~= "AdminRadZoneData" then return end
    local pl = getPlayer()
    if command == "Sync" and args.data then
        for key, value in pairs(args.data) do
            AdminRadZoneData[key] = value
        end
        AdminRadZone.updateClientMarker()
    elseif command == "Run" and args.data then
        for key, value in pairs(args.data) do
            AdminRadZoneData[key] = value
        end
        AdminRadZone.updateClientMarker()
    elseif command == "Pause" and args.data then
        for key, value in pairs(args.data) do
            AdminRadZoneData[key] = value
        end
        AdminRadZone.updateClientMarker()
    elseif command == "Clear" and args.data then
        for key, value in pairs(args.data) do
            AdminRadZoneData[key] = value
        end
        AdminRadZone.updateClientMarker()
    elseif command == "Msg" and args.msg then
        print('AdminRadZone Server:\n' .. tostring(args.msg))
    elseif command == "Fetch" and args.data then
        for key, value in pairs(args.data) do
            AdminRadZoneData[key] = value
        end
        AdminRadZone.updateClientMarker()
    end
end

Events.OnServerCommand.Add(AdminRadZone.core)

function AdminRadZone.isShouldShowMarker()
    if AdminRadZoneData.state == nil then return false end
    if AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 then return false end
    local tab = {
        ["active"] = true,
        ["pause"] = true,
        ["cooldown"] = true,
    }
    return tab[AdminRadZoneData.state]
end
-----------------------            ---------------------------


function AdminRadZone.updateClientMarker()
    local data = AdminRadZoneData
    if not data or not data.state then return end
    
    if AdminRadZone.isShouldShowMarker() then
        if not AdminRadZone.marker then
            local sq = getCell():getOrCreateGridSquare(data.x, data.y, 0)
            if sq then
                local col = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
                if col and data.rad then
                    AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
                        "AdminRadZone_Border",
                        "circle_only_highlight",
                        sq,
                        col.r, col.g, col.b,
                        true,
                        data.rad
                    )
                end
            end
        else
            AdminRadZone.marker:setSize(data.rad)
            AdminRadZone.marker:setPos(data.x, data.y, 0)
        end
    else
       if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
    end

    if AdminRadZone.marker then
 
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.updateClientMarker)
