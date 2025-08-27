function AdminRadZone.setSym(sym)
    --[[ if AdminRadZone.MapSymbol then
        AdminRadZone.removeSym()       
    end ]]
    AdminRadZone.MapSymbol = sym
end
function AdminRadZone.getSym()
    return AdminRadZone.MapSymbol
end
function AdminRadZone.removeSym()
    local sym = AdminRadZone.getSym()
    if sym then
        sym:remove()
        AdminRadZone.MapSymbol = nil
    end
end

function AdminRadZone.setRad(sym, rad)
    
end


function AdminRadZone.addSym(x, y)
    if not ISWorldMap_instance or not SandboxVars.AdminRadZone.MapSymbols then return nil end

    x = x or AdminRadZoneData.x
    y = y or AdminRadZoneData.y
    local img = "O"

    local sym = AdminRadZone.getSym()
    if not sym then
        local symAPI = ISWorldMap_instance.mapAPI:getSymbolsAPI()
        sym = symAPI:addTexture(img, x, y)
        sym:setAnchor(0.5, 0.5)
        sym:setRGBA(0.8, 0.8, 0.2, 1)
        sym:setScale(1)
        AdminRadZone.setSym(sym)
    end

    return sym
end

function AdminRadZone.updateSym(rad)
    rad = rad or AdminRadZoneData.rad
    local sym = AdminRadZone.getSym()
    if not sym then return end
    local x, y = AdminRadZoneData.x, AdminRadZoneData.y
    sym:setPos(x, y)
    local scale = math.max(0.1, rad / 10)
    sym:setScale(scale)
end

