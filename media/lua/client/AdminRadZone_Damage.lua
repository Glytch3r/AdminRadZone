AdminRadZone = AdminRadZone or {}

function AdminRadZone.getRadiusFromSquares(sq1, sq2)
    if not sq1 or not sq2 then return 0 end
    local dx = sq2:getX() - sq1:getX()
    local dy = sq2:getY() - sq1:getY()
    return math.sqrt(dx * dx + dy * dy)
end

function AdminRadZone.radiate(marker, val)
    marker = marker or AdminRadZone.SickMarker or nil
    if not marker then return end
    local step = math.floor(val / 1000)
    local result = ((step % 10) + 10) % 10 + 1
    marker:setSize(result)
end
-----------------------            ---------------------------

function AdminRadZone.getRadColor(pick)
    pick = pick or (SandboxVars and SandboxVars.AdminRadZone and SandboxVars.AdminRadZone.RadColor) or 3
    
    local colors = {
        ColorInfo.new(0.5, 0.5, 0.5),  -- gray
        ColorInfo.new(1, 0, 0),        -- red
        ColorInfo.new(1, 0.5, 0),      -- orange
        ColorInfo.new(1, 1, 0),        -- yellow
        ColorInfo.new(0, 1, 0),        -- green
        ColorInfo.new(0, 0, 1),        -- blue
        ColorInfo.new(0.5, 0, 0.5),    -- purple
        ColorInfo.new(0, 0, 0),        -- black
        ColorInfo.new(1, 1, 1),        -- white
        ColorInfo.new(1, 0.75, 0.8),   -- pink
    }
    
    return colors[pick] or colors[3]
end

function AdminRadZone.removeSickMarker()
    if AdminRadZone.SickMarker then
        AdminRadZone.SickMarker:remove()
        AdminRadZone.SickMarker = nil
    end
end

function AdminRadZone.RadiationMarker(pl)
    pl = pl or getPlayer()
    if not pl then return end 

 
    if not AdminRadZoneData or not AdminRadZoneData.run or not AdminRadZone.isOutOfBound(pl) then
        AdminRadZone.removeSickMarker()
        return
    end


    if AdminRadZone.isOutOfBound(pl) then
        if not AdminRadZone.SickMarker then
            local sq = pl:getCurrentSquare()
            if sq and AdminRadZoneData then
                local img  = "AdminRadZone_Img"..tostring(ZombRand(2,5))
                local overlay  = "AdminRadZone_Img"..tostring(ZombRand(2,5))
                local rad = ZombRand(1, 101) / 100
                local col = AdminRadZone.getRadColor() or getCore():getMpTextColor()--AdminRadZone.getRadColor(SandboxVars.AdminRadZone.RadColor)
                AdminRadZone.SickMarker = getWorldMarkers():addGridSquareMarker(img, overlay, sq, col.r or 0, col.g or 1, col.b or 0, true, rad)
            end
        end
        if AdminRadZone.SickMarker then       
            AdminRadZone.SickMarker:setPosAndSize(pl:getX(), pl:getY(), pl:getZ(), ZombRand(1, 101) / 100)  
        end   
    end

end
Events.OnPlayerUpdate.Remove(AdminRadZone.RadiationMarker)
Events.OnPlayerUpdate.Add(AdminRadZone.RadiationMarker)

-----------------------            ---------------------------


-----------------------            ---------------------------



local ticks = 0
function AdminRadZone.RadiationHandler()
    local pl = getPlayer() 
    if not pl then return end 
    local RadDamage = SandboxVars.AdminRadZone.RadDamage or 8.5

    if not AdminRadZoneData or not AdminRadZoneData.run then return end
     
    --if not AdminRadZone.isRadZone() then return end

    AdminRadZone.RadiationDamage(pl, RadDamage)     

    if AdminRadZone.isOutOfBound(pl) then  
        ticks = ticks + 1
        AdminRadZone.wasOut = true
        if ticks % 20 == 0 then
            AdminRadZone.wasOut = false            
        end
        if ticks >= 60 then
            ticks = 0 
        end
    end
     
end
Events.EveryOneMinute.Remove(AdminRadZone.RadiationHandler)
Events.EveryOneMinute.Add(AdminRadZone.RadiationHandler)

function AdminRadZone.doRoll(percent)
	if percent <= 0 then return false end
	if percent >= 100 then return true end
	return percent >= ZombRand(1, 101)
end

function AdminRadZone.playSfx(pl)
    if not  SandboxVars.AdminRadZone.playSFX  then return end
    pl = pl or getPlayer()
    pl:getEmitter():playSound('AdminRadZone_Warn'..tostring(ZombRand(1,3)))
end
-----------------------            ---------------------------

function AdminRadZone.isRadZone()
    return AdminRadZoneData and AdminRadZoneData.run
end

function AdminRadZone.isNormal()
    return not AdminRadZoneData or not AdminRadZoneData.run
end

function AdminRadZone.isOutOfBound(pl)
    local str = AdminRadZone.getBoundStr(pl)
    if str == "" then return false end
    return str == "OutOfBound"
end

function AdminRadZone.getBoundStr(pl)
    pl = pl or getPlayer()
    if not pl then return "" end
    if not AdminRadZoneData or not AdminRadZoneData.state then return "" end
    if not AdminRadZoneData.run then return "" end
    if AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 then return "" end

    local centerX, centerY, rad = AdminRadZoneData.x, AdminRadZoneData.y, AdminRadZoneData.rad
    local sq = pl:getCurrentSquare()
    if not sq or not centerX or not centerY or not rad then return "" end

    local dx = sq:getX() - centerX
    local dy = sq:getY() - centerY
    local distSq = dx * dx + dy * dy
    local outOfBound = distSq > (rad * rad)
    local note = outOfBound and "OutOfBound" or "InBound"


    return note
end


-----------------------            ---------------------------
function AdminRadZone.RadiationDamage(pl, RadDamage)

    pl = pl or getPlayer()
    if not pl then return end 

    local bd = pl:getBodyDamage()
    if not bd then return end
    local sickness = bd:getFoodSicknessLevel()
    if RadDamage and RadDamage > 0 then
        if not AdminRadZone.isOutOfBound() then         
            if AdminRadZone.wasOut then
                bd:setFoodSicknessLevel(math.max(0, sickness - RadDamage))
                bd:AddGeneralHealth( RadDamage )
                if AdminRadZone.doRoll(4) then
                    AdminRadZone.wasOut = false
                end  
            end
            return

        end
        if sickness > 60 then bd:setHasACold(true) end

        bd:ReduceGeneralHealth(ZombRand(1, RadDamage))
        bd:setFoodSicknessLevel(math.min(100, sickness + RadDamage))
    end
    -----------------------            ---------------------------
    if AdminRadZone.isNormal() then return end
    if AdminRadZone.isOutOfBound() then
        local fx1 = SandboxVars.AdminRadZone.FloorVisualChance or 10
        if fx1 > 0 then
            if AdminRadZone.doRoll(fx1) then
                AdminRadZone.doRadSpr(pl)
            end
            AdminRadZone.playSfx(pl)
        end

        local fx2 = SandboxVars.AdminRadZone.NVGChance or 10
        if fx2 > 0 then
            if AdminRadZone.doRoll(fx2) then
                AdminRadZone.doRadNvg(pl)
            end
            AdminRadZone.playSfx(pl)
        end

        if fx2 == 0 and fx1 == 0 then
            if AdminRadZone.doRoll(5) then
                pl:setHitReaction("HeadLeft")
                AdminRadZone.playSfx(pl)            
            end
        end
    end
end



-----------------------            ---------------------------

function AdminRadZone.doRadSpr()
    local pl = getPlayer()
    if not pl then return end
    local sq = pl:getCurrentSquare()
    if not sq then return end

    if AdminRadZone.obj ~= nil then return end

    local sprName = "d_plants_1_2"..tostring(ZombRand(4, 8))
    local sprName2 = "d_plants_1_"..tostring(ZombRand(61, 64))
    local sprName3 = "d_plants_1_"..tostring(ZombRand(57, 60))
    
    AdminRadZone.obj = IsoObject.new(getCell(), sq, sprName, false, {})
    sq:AddTileObject(obj)

    local col = AdminRadZone.getRadColor(5)
    if col and AdminRadZone.obj then
        AdminRadZone.obj:setHighlightColor(col.r*255, col.g*255, col.b*255, 1)
        AdminRadZone.obj:setHighlighted(true, true)
        AdminRadZone.obj:setBlink(true)
    end

    AdminRadZone.halt(0.5, function() AdminRadZone.obj:setSprite(sprName2) end)
    AdminRadZone.halt(1, function() AdminRadZone.obj:setSprite(sprName3) end)
    AdminRadZone.halt(1.5, function()
        AdminRadZone.doSledge(AdminRadZone.obj) 
        AdminRadZone.obj = nil
    end)

end


function AdminRadZone.doRadNvg(pl)
    pl = pl or getPlayer()
    if not pl then return end
    pl:setWearingNightVisionGoggles(true)
    pl:startMuzzleFlash()
    AdminRadZone.halt(0.01, function()
        pl:setWearingNightVisionGoggles(false)
    end)
end


-----------------------            ---------------------------

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
