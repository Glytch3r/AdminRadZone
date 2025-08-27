
--AdminRadZone_Zone.lua
AdminRadZone = AdminRadZone or {}

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
--[[ local ticks = 0
function AdminRadZone.RadiationMarker()
    ticks = ticks + 1
    local pl = getPlayer()
    if not pl then return end
    local bodyDamage = pl:getBodyDamage()
    local RadDamage = SandboxVars.AdminRadZone.RadDamage or 8.5

    if ticks % 30 == 0 then
        if AdminRadZoneData.state == "inactive" then
            if AdminRadZone.SickMarker then
                AdminRadZone.SickMarker:remove()
                AdminRadZone.SickMarker = nil
            end
            return
        end
        if AdminRadZone.isOutOfBound(pl) then
            AdminRadZone.wasOut = true

            local sickness = bodyDamage:getFoodSicknessLevel()
            if sickness > 60 then
                if ZombRand(0, 5) == 2 then
                    bodyDamage:ReduceGeneralHealth(RadDamage)
                end
                bodyDamage:setFoodSicknessLevel(math.min(100, sickness + RadDamage))
                if ticks % 300 == 0 and SandboxVars.AdminRadZone.doNVG then
                    AdminRadZone.doRadNvg()
                    bodyDamage:setHasACold(true)
                end
            elseif sickness > 40 then
                if ZombRand(0, 5) == 2 then
                    bodyDamage:ReduceGeneralHealth(RadDamage)
                end
                bodyDamage:setFoodSicknessLevel(math.min(100, sickness + RadDamage))
            else
                bodyDamage:setFoodSicknessLevel(math.min(100, sickness + RadDamage))
            end

        elseif AdminRadZone.wasOut then
            bodyDamage:setFoodSicknessLevel(math.max(0, bodyDamage:getFoodSicknessLevel() - RadDamage))
            pl:setHealth(math.min(pl:getMaxHealth(), pl:getHealth() + RadDamage))
        end
    end

    if ticks >= 2000 then
        ticks = 0
        AdminRadZone.wasOut = false
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.RadiationMarker)
 ]]

local ticks = 0

function AdminRadZone.radiate(marker, val)
    marker = marker or AdminRadZone.SickMarker or nil
    if not marker then return end
    local step = math.floor(val / 1000)
    local result = ((step % 10) + 10) % 10 + 1
    marker:setSize(result)
end

function AdminRadZone.RadiationMarker(pl)
    if not AdminRadZoneData or AdminRadZoneData.state == "inactive" then  
        if AdminRadZone.SickMarker then
            AdminRadZone.SickMarker:remove()
            AdminRadZone.SickMarker = nil
        end
        return
    end

    if AdminRadZone.isOutOfBound(pl) then
        ticks = ticks + 1
        if ticks % 250 == 0 then
            AdminRadZone.wasOut = false            
        end
        if ticks % 5000 == 0 then
            AdminRadZone.RadiationDamage(pl)
        end

            AdminRadZone.wasOut = true

            if AdminRadZone.SickMarker then
                AdminRadZone.SickMarker:remove()
                AdminRadZone.SickMarker = nil
            end
            local sq = pl:getCurrentSquare()
            if sq then
                local col = AdminRadZone.getRadColor(SandboxVars.AdminRadZone.RadColor)
                AdminRadZone.SickMarker = getWorldMarkers():addGridSquareMarker(
                    "AdminRadZone_Img"..tostring(ZombRand(2,5)), "AdminRadZone_Img"..tostring(ZombRand(2,5)), sq,
                    col.r, col.g, col.b, true, 0.4
                )
            end
        
            AdminRadZone.SickMarker:setPos(pl:getX(), pl:getY(), pl:getZ())           
            AdminRadZone.radiate(AdminRadZone.SickMarker, ticks/100)
            if ticks % 6000 == 0 then
                ticks = 0
                AdminRadZone.RadiationDamage(pl)
                AdminRadZone.doRadSpr()
            end
    else
        if AdminRadZone.SickMarker then
            AdminRadZone.SickMarker:remove()
            AdminRadZone.SickMarker = nil
        end
        if AdminRadZone.wasOut then
            pl:getBodyDamage():AddGeneralHealth(RadDamage)
        end
    end

end
Events.OnPlayerUpdate.Add(AdminRadZone.RadiationMarker)


function AdminRadZone.RadiationDamage(pl)
    pl = pl or getPlayer()
    if not AdminRadZoneData or AdminRadZoneData.state == "inactive" then return end

    local bodyDamage = pl:getBodyDamage()
    local RadDamage = SandboxVars.AdminRadZone.RadDamage or 8.5

        if SandboxVars.AdminRadZone.playSFX  then
            local audio = "AdminRadZone_Warn"..tostring(ZombRand(1,3))
            pl:playSoundLocal(audio)
        end


        if SandboxVars.AdminRadZone.doNVG and ZombRand(0,3) == 0 then
            AdminRadZone.doRadNvg()
        end
        AdminRadZone.wasOut = true
        local sickness = bodyDamage:getFoodSicknessLevel()
        
        if sickness > 60 then
            if ZombRand(0, 3) == 2 then
                bodyDamage:ReduceGeneralHealth(RadDamage)
            end
            bodyDamage:setFoodSicknessLevel(math.min(100, sickness + RadDamage))
            if SandboxVars.AdminRadZone.doRadFloorVisual  then
                AdminRadZone.doRadSpr()
            end
            bodyDamage:setHasACold(true)
        elseif sickness > 40 then
            if ZombRand(0, 5) == 2 then
                bodyDamage:ReduceGeneralHealth(RadDamage)
            end
            bodyDamage:setFoodSicknessLevel(math.min(100, sickness + RadDamage))
            bodyDamage:setHasACold(true)
           
        else
            bodyDamage:setFoodSicknessLevel(math.min(100, sickness + RadDamage))
        end


end


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

function AdminRadZone.getRadColor(pick)
    pick = pick or (SandboxVars and SandboxVars.AdminRadZone and SandboxVars.AdminRadZone.RadColor) or 1
    local colors = {
        {r=1, g=0.2, b=0.2},     -- red
        {r=1, g=0.5, b=0},       -- orange  
        {r=1, g=1, b=0.2},       -- yellow
        {r=0.2, g=1, b=0.2},     -- green
        {r=0.2, g=0.5, b=1},     -- blue
        {r=0.8, g=0.2, b=0.8},   -- purple
    }
    return colors[pick] or colors[1]
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

    AdminRadZone.halt(0.5, function() obj:setSprite(sprName2) end)
    AdminRadZone.halt(1, function() obj:setSprite(sprName3) end)
    AdminRadZone.halt(1.5, function() AdminRadZone.doSledge(obj) end)
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
