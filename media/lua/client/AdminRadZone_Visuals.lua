


--[[ 
function AdminRadZone.setRadMarker(sq, marker, radius, isDisabled)
    isDisabled = isDisabled or AdminRadZone.isDisabled() 
    if AdminRadZone.isDisabled() then 
        if AdminRadZone.marker ~= nil then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
    end
    sq = sq or getPlayer():getCurrentSquare() 
    marker = marker or AdminRadZone.ZoneMarker
    if not marker then
        local col =  AdminRadZone.getMarkerColor(1)
        AdminRadZone.ZoneMarker = getWorldMarkers():addGridSquareMarker("circle_center", "", sq, col.r, col.g, col.b, true, radius);        
        return
    else 
        if round(marker:getSize()) ~= round(radius) then
            marker:setSize(radius)
        end

        if round(marker:getSize()) ~= round(radius) then
            marker:setSize(radius)
        end
    end
    return marker
end
 ]]
