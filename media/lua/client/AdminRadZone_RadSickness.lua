--client folder
--AdminRadZone_RadSickness.lua
if not isClient() then return end
LuaEventManager.AddEvent("OnClockUpdate")

AdminRadZone = AdminRadZone or {}


local ticks = 0
function AdminRadZone.RadiationMarker()
    ticks = ticks + 1
    local pl = getPlayer(); if not pl then return end 
    if ticks % 2 ~= 0 then return end

    local isShow = SandboxVars.AdminRadZone.PlayerRadiationMarker
    if isShow == nil then isShow = true end  

    if isShow and AdminRadZone.isOutOfBound(pl) then 
        if not AdminRadZone.SickMarker then
            local sq = pl:getCurrentSquare() 
            if sq then
                local col = AdminRadZone.getMarkerColor(0.8)
                AdminRadZone.SickMarker = getWorldMarkers():addGridSquareMarker(
                    "AdminRadZone_Highlight", "", sq,
                    col.r, col.g, col.b, true, 0.8
                )   
            end
        else
            local x, y, z = round(pl:getX()), round(pl:getY()), pl:getZ() or 0
            AdminRadZone.SickMarker:setPos(x, y, z)
        end     
    else
        if AdminRadZone.SickMarker then
            AdminRadZone.SickMarker:remove()
            AdminRadZone.SickMarker = nil
        end
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.RadiationMarker)

function AdminRadZone.isOutOfBound(pl)
    if not AdminRadZoneData or not AdminRadZoneData.active then return end
    pl = pl or getPlayer()
    if not pl then return end 
    local centerX = AdminRadZoneData.x
    local centerY = AdminRadZoneData.y
    local rad = AdminRadZoneData.rad

    local sq = pl:getCurrentSquare() 
    if not sq or not centerX or not centerY or not rad then return false end
    local dx = sq:getX() - centerX
    local dy = sq:getY() - centerY
    local distSq = dx * dx + dy * dy
    return distSq > (rad * rad)
end

function AdminRadZone.RadiationEffects(curSec)
    local pl = getPlayer()
    if not pl then return end 
    local stats = pl:getStats()
    if not stats then return end 

    local RadDamage = SandboxVars.AdminRadZone.RadDamage or 8.5
    RadDamage = math.min(1, math.max(0, stats:getSickness()+(RadDamage / 100)))
    stats:setSickness(RadDamage)
    if stats:getSickness() > 0.2 then
        if ticks % 3 == 0 then 
            if SandboxVars.AdminRadZone.doRadFloorVisual then
                AdminRadZone.doRadSpr()
            end
        end
        if ticks % 10 == 0 then 
            if SandboxVars.AdminRadZone.doNVG then
                AdminRadZone.doRadNvg()
            end
        end
    end
end

Events.OnClockUpdate.Add(AdminRadZone.RadiationEffects)

function AdminRadZone.doRadNvg()
    local pl = getPlayer() 
    pl:setWearingNightVisionGoggles(true)
    pl:startMuzzleFlash()
    AdminRadZone.pauseForSeconds(1, function() 
        pl:setWearingNightVisionGoggles(false)  
    end)
end
function AdminRadZone.pauseForSeconds(seconds, callback)
    local start = getTimestampMs()
    local duration = seconds * 1000

    local function tick()
        local now = getTimestampMs()
        if now - start >= duration then
            Events.OnTick.Remove(tick)
            if callback then callback() end
        end
    end

    Events.OnTick.Add(tick)
end

function AdminRadZone.getRadColor(pick)
    pick = pick or SandboxVars and SandboxVars.AdminRadZone and SandboxVars.AdminRadZone.RadColor or 5
   return AdminRadZone.getMarkerColor(1, pick)
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
    obj:setOutlineHighlightCol(col);
    obj:setOutlineThickness(1);
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

