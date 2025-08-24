
--AdminRadZone_Zone.lua
AdminRadZone = AdminRadZone or {}
--[[ LuaEventManager.AddEvent("OnClockUpdate")
function AdminRadZone.verbose(curSec)
    if AdminRadZone.isVerbose then
        print(curSec)
    end
end
Events.OnClockUpdate.Remove(AdminRadZone.verbose)
Events.OnClockUpdate.Add(AdminRadZone.verbose) ]]
-----------------------            ---------------------------

-----------------------            ---------------------------








-----------------------            ---------------------------
function AdminRadZone.getRadiusFromSquares(sq1, sq2)
    if not sq1 or not sq2 then return 0 end
    local dx = sq2:getX() - sq1:getX()
    local dy = sq2:getY() - sq1:getY()
    return math.sqrt(dx * dx + dy * dy)
end

function AdminRadZone.floor(n) 
    return math.floor(n + 0.5) 
end
-----------------------            ---------------------------

local ticks = 0
function AdminRadZone.RadiationMarker()
    ticks = ticks + 1
    local pl = getPlayer()
    if ticks % 2 ~= 0 then return end
    if AdminRadZoneData.state == "inactive" then
        if AdminRadZone.SickMarker then
            AdminRadZone.SickMarker:remove()
            AdminRadZone.SickMarker = nil
        end

        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
        return 
    end

    if not pl then return end 

    if AdminRadZone.isOutOfBound(pl) then 
        if not AdminRadZone.SickMarker then
            local sq = pl:getCurrentSquare()
            if sq then
                local col = AdminRadZone.getRadColor(SandboxVars.AdminRadZone.RadColor)
                AdminRadZone.SickMarker = getWorldMarkers():addGridSquareMarker(
                    "AdminRadZone_Highlight", "", sq,
                    col.r, col.g, col.b, true, 0.4
                )
            end
        else
            AdminRadZone.SickMarker:setPos(pl:getX(), pl:getY(), pl:getZ())
            AdminRadZone.SickMarker:setSize(ticks/10)

        end
    else
        if AdminRadZone.SickMarker then
            AdminRadZone.SickMarker:remove()
            AdminRadZone.SickMarker = nil
        end
    end
    
    -----------------------            ---------------------------
    if AdminRadZone.isOutOfBound(pl) then 
        local stats = pl:getStats()
        if not stats then return end 
    
        local RadDamage = SandboxVars.AdminRadZone.RadDamage or 8.5
        RadDamage = math.min(1, math.max(0, stats:getSickness() + (RadDamage / 100)))
        stats:setSickness(RadDamage)

        if stats:getSickness() > 0.2 then
            if ticks % 3 == 0 and SandboxVars.AdminRadZone.doRadFloorVisual then
                AdminRadZone.doRadSpr()
            end
            if ticks % 5 == 0 and SandboxVars.AdminRadZone.doNVG then
                AdminRadZone.doRadNvg()
            end
        end
    end
    if ticks >= 10 then ticks = 0 end

end
Events.OnPlayerUpdate.Add(AdminRadZone.RadiationMarker)

 function AdminRadZone.isOutOfBound(pl)
    if not AdminRadZoneData then return false end
    
    pl = pl or getPlayer()
    if not pl then return false end

    local centerX, centerY, rad = AdminRadZoneData.x, AdminRadZoneData.y, AdminRadZoneData.rad
    local sq = pl:getCurrentSquare()
    if not sq or not centerX or not centerY or not rad then return false end

    local dx = sq:getX() - centerX
    local dy = sq:getY() - centerY
    local distSq = dx * dx + dy * dy

    return distSq > (rad * rad)
end


function AdminRadZone.doRadNvg()
    local pl = getPlayer()
    if not pl then return end
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
        if getTimestampMs() - start >= duration then
            Events.OnTick.Remove(tick)
            if callback then callback() end
        end
    end
    Events.OnTick.Add(tick)
end

function AdminRadZone.getRadColor(pick)
    pick = pick or (SandboxVars.AdminRadZone and SandboxVars.AdminRadZone.RadColor) or 5
    return AdminRadZone.getMarkerColor(1, pick)
end

function AdminRadZone.doRadSpr()
    local pl = getPlayer()
    if not pl then return end
    local sq = pl:getCurrentSquare()
    if not sq then return end
    
    local sprName = "d_plants_1_2"..tostring(ZombRand(4, 8))
    local sprName2 = "d_plants_1_"..tostring(ZombRand(61, 64))
    local sprName3 = "d_plants_1_"..tostring(ZombRand(57, 60))

    local obj = IsoObject.new(getCell(), sq, sprName, false, {})
    sq:AddTileObject(obj)

    local col = AdminRadZone.getRadColor(5)
    obj:setHighlightColor(col)
    obj:setHighlighted(true, false)
    obj:setOutlineHighlightCol(col)
    obj:setOutlineThickness(1)
    obj:setOutlineHighlight(true)
    obj:setBlink(true)
    obj:setOutlineHlBlink(true)

    AdminRadZone.pauseForSeconds(0.5, function() obj:setSprite(sprName2) end)
    AdminRadZone.pauseForSeconds(1, function() obj:setSprite(sprName3) end)
    AdminRadZone.pauseForSeconds(1.5, function() AdminRadZone.doSledge(obj) end)
end

function AdminRadZone.doSledge(obj)
    if not obj then return end
    if isClient() then
        sledgeDestroy(obj)
    else
        local sq = obj:getSquare()
        if sq then
            sq:RemoveTileObject(obj)
            sq:getSpecialObjects():remove(obj)
            sq:getObjects():remove(obj)
            sq:transmitRemoveItemFromSquare(obj)
        end
    end
end
