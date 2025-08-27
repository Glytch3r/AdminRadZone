
--AdminRadZone_Zone.lua
AdminRadZone = AdminRadZone or {}

-----------------------            ---------------------------
function AdminRadZone.getRadiusFromSquares(sq1, sq2)
    if not sq1 or not sq2 then return 0 end
    local dx = sq2:getX() - sq1:getX()
    local dy = sq2:getY() - sq1:getY()
    return math.sqrt(dx * dx + dy * dy)
end


-----------------------            ---------------------------


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

-----------------------            ---------------------------
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

    if AdminRadZone.wasOut then
        pl:getBodyDamage():AddGeneralHealth(RadDamage)
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.RadiationDamage)


-----------------------            ---------------------------
--[[ 
local ticks = 0
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