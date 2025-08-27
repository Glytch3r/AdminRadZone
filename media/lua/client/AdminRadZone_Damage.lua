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

local ticks = 0
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
        AdminRadZone.wasOut = true
        
        if ticks % 250 == 0 then
            AdminRadZone.wasOut = false            
        end
        if AdminRadZone.SickMarker then
            AdminRadZone.SickMarker:remove()
            AdminRadZone.SickMarker = nil
        end
        if not AdminRadZone.SickMarker then
            local sq = pl:getCurrentSquare()
            if sq then
                local col = AdminRadZone.getRadColor(SandboxVars.AdminRadZone.RadColor)
                AdminRadZone.SickMarker = getWorldMarkers():addGridSquareMarker(
                    "AdminRadZone_Img"..tostring(ZombRand(2,5)), "AdminRadZone_Img"..tostring(ZombRand(2,5)), sq,
                    col.r, col.g, col.b, true, 0.4 )
            end
        end
        
        if AdminRadZone.SickMarker then
            AdminRadZone.SickMarker:setPos(pl:getX(), pl:getY(), pl:getZ())           
            AdminRadZone.radiate(AdminRadZone.SickMarker, ticks/1000)
        end
        
        if ticks % 1800 == 0 then
            AdminRadZone.RadiationDamage(pl)
            if SandboxVars.AdminRadZone.doRadFloorVisual then
                AdminRadZone.doRadSpr()
            end
        end
        
        if ticks % 6000 == 0 then
            ticks = 0
        end
    else
        if AdminRadZone.SickMarker then
            AdminRadZone.SickMarker:remove()
            AdminRadZone.SickMarker = nil
        end
        if AdminRadZone.wasOut then
            local bodyDamage = pl:getBodyDamage()
            local RadDamage = SandboxVars.AdminRadZone.RadDamage or 8.5
            bodyDamage:setFoodSicknessLevel(math.max(0, bodyDamage:getFoodSicknessLevel() - RadDamage * 0.5))
            bodyDamage:AddGeneralHealth( RadDamage )
            
            AdminRadZone.wasOut = false
        end
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.RadiationMarker)



function AdminRadZone.RadiationDamage(pl)
    pl = pl or getPlayer()
    if not AdminRadZoneData or AdminRadZoneData.state == "inactive" then return end
    
    local bodyDamage = pl:getBodyDamage()
    local RadDamage = SandboxVars.AdminRadZone.RadDamage or 8.5
    local sickness = bodyDamage:getFoodSicknessLevel()
    
    if SandboxVars.AdminRadZone.playSFX then
        local audio = "AdminRadZone_Warn"..tostring(ZombRand(1,3))
        pl:playSoundLocal(audio)
    end
    
    if SandboxVars.AdminRadZone.doNVG and ZombRand(0,8) == 0 then
        AdminRadZone.doRadNvg()
    end
    
    if sickness > 60 then
        if ZombRand(0, 3) == 2 then
            bodyDamage:ReduceGeneralHealth(RadDamage)
        end
        bodyDamage:setFoodSicknessLevel(math.min(100, sickness + RadDamage))
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
Events.OnPlayerUpdate.Add(AdminRadZone.RadiationDamage)



