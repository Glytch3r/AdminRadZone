AdminRadZone = AdminRadZone or {}

function AdminRadZone.getTextureForRadius(rad)
    if rad <= 128 then return "AdminRadZone_1" end
    if rad <= 256 then return "AdminRadZone_2" end
    if rad <= 512 then return "AdminRadZone_3" end
    if rad <= 1024 then return "AdminRadZone_4" end
    return "AdminRadZone_5"
end

function AdminRadZone.symHandler()
    if not SandboxVars.AdminRadZone.MapSymbols then return end
    local data = AdminRadZoneData
    if not data then return end

    if not data.run then 
        if AdminRadZoneSym then
            AdminRadZoneSym:setRGBA(0, 0, 0, 0)
        end
        return 
    else
        if not data.state then return end

        local x, y = data.x, data.y
        if not x or not y or x == -1 or y == -1 then return end

        if not ISWorldMap_instance then
            ISWorldMap.ShowWorldMap(0)
            ISWorldMap_instance:close()
        end

        local mapAPI = ISWorldMap_instance.javaObject:getAPIv1()
        local symAPI = mapAPI:getSymbolsAPI()

        if not AdminRadZoneSym then
            AdminRadZoneSym = symAPI:addTexture("Circle", x, y)
        end

        if AdminRadZoneSym then
            AdminRadZoneSym:setAnchor(0.5, 0.5)
            if data.state == 'active' then
                local col = AdminRadZone.panelColors[data.state]
                if not col then return end
                local r,g,b = col.r or 1, col.g or 0, col.b or 0
                AdminRadZoneSym:setRGBA(r,g,b, 1)

                local rad = data.rad or SandboxVars.AdminRadZone.DefaultRadius or 4
                if not rad then return end
                -- pick best texture for current radius
                local tex = AdminRadZone.getTextureForRadius(rad)
                --AdminRadZoneSym:setTexture(tex)
                AdminRadZoneSym:setScale(1.0) 
              --  AdminRadZoneSym:setScaleCircleTexture(true)
            end
        end
    end
end

Events.OnRenderTick.Remove(AdminRadZone.symHandler)
--Events.OnRenderTick.Add(AdminRadZone.symHandler)
-----------------------            ---------------------------
--[[ 
local pl = getPlayer()
local x, y, z = round(pl:getX()),  round(pl:getY()),  pl:getZ() or 0

local mapAPI = ISWorldMap_instance.javaObject:getAPIv1()
local symAPI = mapAPI:getSymbolsAPI()
AdminRadZoneSym = symAPI:addTexture("circle", x, y)

AdminRadZoneSym:setRGBA(1,1,1, 1)
AdminRadZoneSym:setScale(2) 
 ]]