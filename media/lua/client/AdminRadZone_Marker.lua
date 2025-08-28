
function AdminRadZone.updateClientMarker(pl)
    local data = AdminRadZoneData
    if not data or not data.state then return end
    if data.x == -1 or data.y == -1 then return end
    if not data.rad   then return end
    local sq = getCell():getOrCreateGridSquare(data.x, data.y, 0)
    if not sq then return end
    
    local col = col or AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)


    AdminRadZone.shouldPick = AdminRadZone.shouldPick or "AdminRadZone_Img2"

    local function spawnMarker()
        if AdminRadZonePanel.instance ~= nil then
           -- col = AdminRadZone.stateColors[AdminRadZoneData.state]
            col = AdminRadZone.getRadColor(SandboxVars.AdminRadZone.RadColor)
            AdminRadZone.shouldPick = "AdminRadZone_Img1"
        else
            col = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
           -- col = AdminRadZone.getRadColor(SandboxVars.AdminRadZone.RadColor)
            AdminRadZone.shouldPick = "AdminRadZone_Img2"
        end
        
        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
        if AdminRadZone.forceSwap ~= nil  then
            AdminRadZone.shouldPick = AdminRadZone.swapImg[AdminRadZone.shouldPick] 
            AdminRadZone.forceSwap = nil
        end
        AdminRadZone.markerChoice = AdminRadZone.markerChoice or AdminRadZone.swapImg[AdminRadZone.markerChoice] 
        AdminRadZone.marker = getWorldMarkers():addGridSquareMarker( AdminRadZone.shouldPick, AdminRadZone.markerChoice, sq, col.r, col.g, col.b, true, data.rad  )
    end
    

    if AdminRadZone.forceSwap ~= nil  then
        spawnMarker()  
        return 
    end

    if AdminRadZone.isShouldShowMarker() then
        if not AdminRadZone.marker then
            spawnMarker()     
            return
        else
            AdminRadZone.marker:setPosAndSize(data.x, data.y, pl:getZ(), data.rad )
            --AdminRadZone.marker:setSize(data.rad)
            --AdminRadZone.marker:setPos(data.x, data.y, 0)
        end
    else
       if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
    end

    if AdminRadZone.marker then
        if AdminRadZone.markerChoice ~= AdminRadZone.shouldPick then
            spawnMarker()  
        end
        
        if AdminRadZone.marker:getR() ~= col.r then AdminRadZone.marker:setR(col.r) end
        if AdminRadZone.marker:getG() ~= col.g then AdminRadZone.marker:setG(col.g) end
        if AdminRadZone.marker:getB() ~= col.b then AdminRadZone.marker:setB(col.b) end
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.updateClientMarker)


--AdminRadZoneSym:setScale(data.rad)
-----------------------            ---------------------------
--[[ 
function AdminRadZone.updateClientMarker()
    local data = AdminRadZoneData
    if not data or not data.state then return end
    if data.x == -1 or data.y == -1 or not data.rad then
        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
        return
    end

    local sq = getCell():getOrCreateGridSquare(data.x, data.y, 0)
    if not sq then return end

    local col = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
    local imgChoice = "AdminRadZone_Img1"

    if AdminRadZonePanel.instance ~= nil then
        col = AdminRadZone.stateColors[data.state] or col
        imgChoice = "AdminRadZone_Img2"
    end

    local function spawnMarker()
        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
        AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
            imgChoice,
            imgChoice,  -- match highlightName to texture
            sq,
            col.r, col.g, col.b,
            true,
            data.rad
        )
    end

    if AdminRadZone.isShouldShowMarker() then
        if not AdminRadZone.marker then
            spawnMarker()
        else
            -- If texture changed, respawn
            if AdminRadZone.marker:getTextureName() ~= imgChoice then
                spawnMarker()
            else
                -- update size/pos only when panel is closed
                if not AdminRadZonePanel.instance then
                    AdminRadZone.marker:setSize(data.rad)
                    AdminRadZone.marker:setPos(data.x, data.y, 0)
                end
            end
        end
    else
        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
    end

    -- always enforce color in case state changed
    if AdminRadZone.marker then
        AdminRadZone.updateMarkerColor(AdminRadZone.marker)
    end
end

Events.OnPlayerUpdate.Add(AdminRadZone.updateClientMarker)
 ]]


