function AdminRadZone.setSym(sym)

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

function AdminRadZone.symDbg()
    local pl = getPlayer()
    local x, y, z = round(pl:getX()),  round(pl:getY()),  pl:getZ() or 0
    AdminRadZone.MapSymbol = AdminRadZone.addSym(x, y)
end

function AdminRadZone.addSym(x, y, rad)
    if not ISWorldMap_instance or not SandboxVars.AdminRadZone.MapSymbols then return nil end
    if AdminRadZoneData and AdminRadZoneData.run and AdminRadZoneData.state and AdminRadZoneData.state == 'active' then
        x = x or AdminRadZoneData.x 
        y = y or AdminRadZoneData.y 
        rad = rad or AdminRadZoneData.rad or 1
        local img = "O"

        local sym = AdminRadZone.getSym()
        if not sym then
            local symAPI = ISWorldMap_instance.mapAPI:getSymbolsAPI()
            sym = symAPI:addTexture(img, x, y)
            sym:setAnchor(0.5, 0.5)
            sym:setRGBA(0.8, 0.8, 0.2, 1)
            sym:setScale(rad)
            AdminRadZone.setSym(sym)
        end

        return sym
    end
    return nil
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

--[[   


if not AdminRadZone.MapSymbol then
    AdminRadZone.MapSymbol = AdminRadZone.addSym(x, y, rad)
end
print(AdminRadZone.MapSymbol)






  local pl = getPlayer()
    local x, y, z = round(pl:getX()),  round(pl:getY()),  pl:getZ() or 0
    ISWorldMapSymbolTool_AddSymbol:addSymbol(x, y)
 ]]

--[[ 
	o.mapUI = mapUI -- ISUIElement with javaObject=UIWorldMap
	o.mapAPI = mapUI.javaObject:getAPIv1()
	o.symbolsAPI = o.mapAPI:getSymbolsAPI()

function WorldMapStyleEditor:new(editorMode)
	local o = ISPanel.new(self, 0, 0, 100, 100)
	o.editorMode = editorMode
	o.mapUI = editorMode.mapUI
	o.mapAPI = editorMode.mapAPI
	o.styleAPI = editorMode.styleAPI
	return o
end





ISWorldMap_instance.mapAPI
print(worldOriginX)

getMaxXInCells()
getMaxYInCells()
getWidthInCells()

getCenterWorldX()
getCenterWorldY ()

UIWorldMapV1 
ISWorldMap

local mapUI = ISMap:new(0, 0, 0, 0, map, 0); ]]