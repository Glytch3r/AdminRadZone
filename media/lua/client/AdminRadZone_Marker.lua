--client\AdminRadZone_Marker.lua
AdminRadZone = AdminRadZone or {}

function AdminRadZone.updateClientMarker(pl)
    local data = AdminRadZoneData
    if not data or not data.state or not data.rad then return end
    if data.x == -1 or data.y == -1 then return end

    local sq = getCell():getOrCreateGridSquare(data.x, data.y, 0)
    if not sq then return end

    local col = getCore():getMpTextColor() or ColorInfo.new(0.5, 0.5, 0.5, 1)
    AdminRadZone.shouldPick = AdminRadZone.shouldPick or "AdminRadZone_Img2"

    function AdminRadZone.spawnMarker()
        if AdminRadZonePanel.instance then
            col = getCore():getMpTextColor() or ColorInfo.new(0.5, 0.5, 0.5, 1)
            AdminRadZone.shouldPick = "AdminRadZone_Img1"
        else
            col = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
            AdminRadZone.shouldPick = "AdminRadZone_Img2"
        end

        if AdminRadZone.forceSwap then
            AdminRadZone.shouldPick = AdminRadZone.swapImg[AdminRadZone.shouldPick]
            AdminRadZone.forceSwap = nil
        end

        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end

        AdminRadZone.markerChoice = AdminRadZone.markerChoice or AdminRadZone.swapImg[AdminRadZone.markerChoice]
        AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
            AdminRadZone.shouldPick,
            AdminRadZone.shouldPick,
            sq,
            col.r, col.g, col.b,
            true,
            data.rad
        )
    end

    if AdminRadZone.isShouldShowMarker() or AdminRadZone.forceSwap then
        if not AdminRadZone.marker then
            AdminRadZone.spawnMarker()
        else
            AdminRadZone.marker:setPosAndSize(data.x, data.y, pl:getZ(), data.rad)

            if AdminRadZone.marker:getR() ~= col.r then AdminRadZone.marker:setR(col.r) end
            if AdminRadZone.marker:getG() ~= col.g then AdminRadZone.marker:setG(col.g) end
            if AdminRadZone.marker:getB() ~= col.b then AdminRadZone.marker:setB(col.b) end
        end
    elseif AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
end

Events.OnPlayerUpdate.Add(AdminRadZone.updateClientMarker)


function AdminRadZone.isShouldShowMarker()
    if not AdminRadZoneData then return false end
    if AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 then return false end
    
    if AdminRadZone.isPanelInit() then 
        AdminRadZone.markerChoice = "AdminRadZone_Img2"
        return true 
    else
        AdminRadZone.markerChoice = "AdminRadZone_Img1"
    end
    if AdminRadZoneData  then
        return AdminRadZone.showStates[AdminRadZoneData.state] == true 
    end
    return false
end
