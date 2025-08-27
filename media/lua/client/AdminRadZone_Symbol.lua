

AdminRadZone = AdminRadZone or {}

function AdminRadZone.addSym()
    local data = AdminRadZoneData
    if data.state == "active" then
        local col =  AdminRadZone.panelColors[data.state]
        local pl = getPlayer()
        local x, y = data.x , data.y

        rad = rad or 5
        local symAPI = ISWorldMap_instance.mapAPI:getSymbolsAPI()
        if not AdminRadZoneSym then
            AdminRadZoneSym = symAPI:addTexture("Circle", x, y)
        end
        if AdminRadZoneSym then
            AdminRadZoneSym:setAnchor(0.5, 0.5)
            local run = data.run or false
            if run  then
                local r,g,b = col.r or 1, col.g or 0, col.b or 0
                AdminRadZoneSym:setRGBA(r,g,b, 1)
                data.rad = data.rad or SandboxVars.AdminRadZone.DefaultRadius or 4
                AdminRadZoneSym:setScale(data.rad)
            end
        end
    end    
end

-----------------------            ---------------------------


 function AdminRadZone.isOutOfBound(pl)
    pl = pl or getPlayer()

    if not pl then return false end

    if not AdminRadZoneData then return false end
    if not AdminRadZoneData.state then return false end
    
    if AdminRadZoneData.state == 'inactive' then return false end

    if  AdminRadZoneData.x == -1 or  AdminRadZoneData.y == -1 then return false end
    

    local centerX, centerY, rad = AdminRadZoneData.x, AdminRadZoneData.y, AdminRadZoneData.rad
    local sq = pl:getCurrentSquare()
    if not sq or not centerX or not centerY or not rad then return false end

    local dx = sq:getX() - centerX
    local dy = sq:getY() - centerY
    local distSq = dx * dx + dy * dy

    return distSq > (rad * rad)
end

function AdminRadZone.doRadNvg(pl)
    pl = pl or getPlayer()
    if not pl then return end
    pl:setWearingNightVisionGoggles(true)
    pl:startMuzzleFlash()
    pl:getEmitter():playSound("AdminRadZone_Warn"..tostring(ZombRand(1,3)))
    
    AdminRadZone.halt(0.2, function()
        pl:setWearingNightVisionGoggles(false)
    end)
end





function AdminRadZone.halt(seconds, callback)
    local start = getTimestampMs()
    local duration = seconds * 1000
    local function tick()
        if getTimestampMs() - start >= duration then
            Events.OnTick.Remove(tick)
            if callback then callback() end
        end
    end
    Events.OnTick.Add(tick)
end

function AdminRadZone.doRadSpr()
    local pl = getPlayer()
    if not pl then return end
    local sq = pl:getCurrentSquare()
    if not sq then return end
    pl:getEmitter():playSound("AdminRadZone_Warn"..tostring(ZombRand(1,3)))
    
    local sprName = "d_plants_1_2"..tostring(ZombRand(4, 8))
    local sprName2 = "d_plants_1_"..tostring(ZombRand(61, 64))
    local sprName3 = "d_plants_1_"..tostring(ZombRand(57, 60))

    local obj = IsoObject.new(getCell(), sq, sprName, false, {})
    sq:AddTileObject(obj)
    local col = AdminRadZone.getRadColor(5)

    if col then
        obj:setHighlightColor(col.r, col.g,col.b, 1)
        obj:setHighlighted(true, true)
        obj:setBlink(true)
    end
    AdminRadZone.halt(0.5, function() obj:setSprite(sprName2) end)
    AdminRadZone.halt(1, function() obj:setSprite(sprName3) end)
    AdminRadZone.halt(1.5, function() AdminRadZone.doSledge(obj) end)
end

function AdminRadZone.doSledge(obj)
    if isClient() then
        sledgeDestroy(obj)
    else
        local sq = obj:getSquare()
        if sq then
            sq:RemoveTileObject(obj);
            sq:getSpecialObjects():remove(obj);
            sq:getObjects():remove(obj);
            sq:transmitRemoveItemFromSquare(obj)
        end
    end
end

function AdminRadZone.doRadSpr()
    local pl = getPlayer()
    if not pl then return end 
    local sq = pl:getCurrentSquare() 
    if not sq then return end
    
    local sprName = "d_plants_1_2"..tostring(ZombRand(4, 8))
    local sprName2 = "d_plants_1_"..tostring(ZombRand(61, 64))
    local sprName3 = "d_plants_1_"..tostring(ZombRand(57, 60))

    print(sprName)
    local obj = IsoObject.new(getCell(), sq  , sprName, false, {})
    sq:AddTileObject(obj);

    local col = AdminRadZone.getRadColor(5)
    obj:setHighlightColor(col);
    obj:setHighlighted(true, false);
--[[     obj:setOutlineHighlightCol( col.r or 1, col.g or 0, col.b or,  1);
    obj:setOutlineThickness(1); ]]
    obj:setOutlineHighlight(true);
    obj:setBlink(true);
    obj:setOutlineHlBlink(true);
    AdminRadZone.pauseForSeconds(0.5, function() 
         obj:setSprite(sprName2)
    end)
    AdminRadZone.pauseForSeconds(1, function() 
         obj:setSprite(sprName3)
    end)
    AdminRadZone.pauseForSeconds(1.5, function() 
         AdminRadZone.doSledge(obj)
    end)
end

