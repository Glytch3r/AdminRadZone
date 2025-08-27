
function AdminRadZone.updateClientSymbol(pl)
    local data = AdminRadZoneData
    if not data or not data.state then return end
    if data.x == -1 or data.y == -1 then return end
    if not data.rad   then return end
    local sq = getCell():getOrCreateGridSquare(data.x, data.y, 0)
    if not sq then return end
    
    AdminRadZone.markCol = AdminRadZone.markCol or AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
    AdminRadZone.shouldPick = AdminRadZone.shouldPick or "AdminRadZone_Img1"

    local function spawnSymbol()
        if AdminRadZonePanel.instance ~= nil then
            AdminRadZone.markCol = AdminRadZone.stateColors[AdminRadZoneData.state]
            AdminRadZone.shouldPick = "AdminRadZone_Img2"
        else
            AdminRadZone.markCol = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
            AdminRadZone.shouldPick = "AdminRadZone_Img1"
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
        AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
        AdminRadZone.shouldPick, 
        AdminRadZone.markerChoice,
        sq,
        AdminRadZone.markCol.r,
        AdminRadZone.markCol.g,
        AdminRadZone.markCol.b,
        true,
        data.rad
        )

      --  AdminRadZone.markerChoice = AdminRadZone.shouldPick
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
        
        if AdminRadZone.marker:getR() ~= AdminRadZone.markCol.r then AdminRadZone.marker:setR(AdminRadZone.markCol.r) end
        if AdminRadZone.marker:getG() ~= AdminRadZone.markCol.g then AdminRadZone.marker:setG(AdminRadZone.markCol.g) end
        if AdminRadZone.marker:getB() ~= AdminRadZone.markCol.b then AdminRadZone.marker:setB(AdminRadZone.markCol.b) end
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.updateClientMarker)





