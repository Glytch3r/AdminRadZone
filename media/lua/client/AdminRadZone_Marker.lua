--client\AdminRadZone_Marker.lua
AdminRadZone = AdminRadZone or {}


function AdminRadZone.getColorProperties()
    local col
    if AdminRadZone.isPanelInit() then
        col = getCore():getMpTextColor()
        AdminRadZone.shouldPick = "AdminRadZone_Img1"
    else
        col = AdminRadZone.getMarkerColor(1, SandboxVars.AdminRadZone.MarkerColor)
        AdminRadZone.shouldPick = "AdminRadZone_Img2"
    end
    return col
end

function AdminRadZone.updateClientMarker(pl)
    local data = AdminRadZoneData
    if not data or not data.state or not data.rad then return end
    if data.x == -1 or data.y == -1 then return end

    local sq = getCell():getOrCreateGridSquare(data.x, data.y, 0)
    if not sq then return end

    local col = AdminRadZone.getColorProperties()

    function AdminRadZone.spawnMarker()
        col = AdminRadZone.getColorProperties()
        if AdminRadZone.forceSwap then
            AdminRadZone.shouldPick = AdminRadZone.swapImg[AdminRadZone.shouldPick]
            AdminRadZone.forceSwap = nil
        end

        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end

        AdminRadZone.markerChoice = AdminRadZone.markerChoice or AdminRadZone.swapImg[AdminRadZone.shouldPick]
        AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
            AdminRadZone.markerChoice,
            AdminRadZone.markerChoice,
            sq,
            col.r, col.g, col.b,
            true,
            data.rad
        )
    end

    if AdminRadZone.isShouldShowMarker() or AdminRadZone.forceSwap then
        if not AdminRadZone.marker or AdminRadZone.forceSwap then
            AdminRadZone.spawnMarker()
        end
        if AdminRadZone.marker then
            col = AdminRadZone.getColorProperties()
            AdminRadZone.marker:setPosAndSize(data.x, data.y, pl:getZ(), data.rad)
            AdminRadZone.marker:setR(col.r)
            AdminRadZone.marker:setG(col.g)
            AdminRadZone.marker:setB(col.b)
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
        return true 

    end
    if AdminRadZoneData  then
        return AdminRadZone.showStates[AdminRadZoneData.state] == true 
    end
    return false
end
