--[[ -- shared

AdminRadZone = AdminRadZone or {}


-----------------------            ---------------------------
-----------------------            ---------------------------

function AdminRadZone.getRadiusFromSquares(sq1, sq2)
    if not sq1 or not sq2 then return 0 end
    local dx = sq2:getX() - sq1:getX()
    local dy = sq2:getY() - sq1:getY()
    return math.sqrt(dx * dx + dy * dy)
end

function AdminRadZone.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end


function AdminRadZone.StoreData(clientTable, serverTable)
    if not clientTable or not serverTable then return {} end
    for key, value in pairs(serverTable) do
        clientTable[key] = value
    end
    for key, _ in pairs(clientTable) do
        if not serverTable[key] then
            clientTable[key] = nil
        end
    end
    return clientTable
end
function AdminRadZone.floor(n) 
    return math.floor(n + 0.5) 
end
 ]]

--getWorldMarkers():removeGridSquareMarker(marker)
--ISTilesPickerDebugUI:removeMarker()
