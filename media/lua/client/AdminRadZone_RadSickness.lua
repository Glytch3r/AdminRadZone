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
    if not AdminRadZone.isOutOfBound(pl) then 
        AdminRadZone.setGreenFog(false)
        return
    else
        AdminRadZone.setGreenFog(true)
    end     
    local RadDamage = SandboxVars.AdminRadZone.RadDamage or 8.5
    RadDamage = math.min(1, math.max(0, stats:getSickness()+(RadDamage / 100)))
    stats:setSickness(RadDamage)
    if stats:getSickness() > 0.2 then
        if ticks % 3 == 0 then 
            AdminRadZone.doRadSpr()
        end
        if ticks % 10 == 0 then 
            pl:setWearingNightVisionGoggles(true)
            pl:startMuzzleFlash()
            AdminRadZone.pauseForSeconds(1, function() 
                pl:setWearingNightVisionGoggles(false)  
            end)
        end
    end
end
Events.OnClockUpdate.Add(AdminRadZone.RadiationEffects)

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



function AdminRadZone.FogHandler()

    local pl = getPlayer()
    if not pl then return end 
    
    local top = ImprovedFog.getTopAlphaHeight()
    local bot = ImprovedFog.getBottomAlphaHeight()    
    local circle = ImprovedFog.getAlphaCircleAlpha()
    local alpha = ImprovedFog.getBaseAlpha()
    
    ImprovedFog.setEnableEditing(true)
    ImprovedFog.setColorR(0.2); 
    ImprovedFog.setColorG(0.9); 
    ImprovedFog.setColorB(0.4);
    

    if alpha and alpha == 1 then 
        ImprovedFog.setAlphaCircleAlpha(0);   
        ImprovedFog.setBaseAlpha(0.7) 
    else
        ImprovedFog.setBaseAlpha(alpha+0.001) 
        ImprovedFog.setAlphaCircleAlpha(circle+0.001);
    end
    
    if top and top ~= 1 then 
        ImprovedFog.setTopAlphaHeight(top+0.0001) 
    else
        ImprovedFog.setTopAlphaHeight(0.6) 
    end

    if bot and bot ~= 0.6 then 
        ImprovedFog.getBottomAlphaHeight(bot-0.0001) 
    else
        ImprovedFog.getBottomAlphaHeight(1) 
    end

end

function AdminRadZone.radZone(active)
    local clim = getClimateManager()
    if not clim then return end

    local fogFloat = clim:getClimateFloat(ClimateManager.FLOAT_FOG_INTENSITY)
    if fogFloat then
        fogFloat:setEnableAdmin(active)
        if active then
            fogFloat:setAdminValue(0.8) -- heavy fog
        end
    end

    ImprovedFog.setHighQuality(active)
    
    if active then


        local col = AdminRadZone.getRadColor(5)
        AdminRadZone.startFogTransition(600, {r=col.r, g=col.g, b=col.b, a1=0.7, a2=0.4})

    else
        --rever
    end

    print("Foggy green weather " .. (active and "activated" or "disabled") .. " locally")
end
