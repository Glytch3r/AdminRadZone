

AdminRadZone = AdminRadZone or {}

function AdminRadZone.symHandler()
    if not SandboxVars.AdminRadZone.MapSymbols then return end
    local data = AdminRadZoneData
    if not data then return end
    if not data.run then 
        if AdminRadZoneSym then
            AdminRadZoneSym:setRGBA(0, 0, 0, 0)            
        end
        return 
    end
    if data.state == "active" then
        local col = AdminRadZone.panelColors[data.state]
        local pl = getPlayer()
        local x, y = data.x , data.y

        rad = rad or 5


        local mapAPI = ISWorldMap_instance.javaObject:getAPIv1()
        local symAPI = mapAPI:getSymbolsAPI()
        --local symAPI = ISWorldMap_instance.mapAPI:getSymbolsAPI()
        if not AdminRadZoneSym then
            AdminRadZoneSym = symAPI:addTexture("Circle", x, y)
        end

        if AdminRadZoneSym then
            AdminRadZoneSym:setAnchor(0.5, 0.5)
            local run = data.run or false
            if run  then
                local r,g,b = col.r or 1, col.g or 0, col.b or 0
                AdminRadZoneSym:setRGBA(r,g,b, 1)

                local rad = AdminRadZoneData.rad or SandboxVars.AdminRadZone.DefaultRadius or 4

                if AdminRadZoneSym and AdminRadZoneData and rad then
                    AdminRadZoneSym:setScale(rad)
                    AdminRadZoneSym:setScaleCircleTexture(rad)
                end

            end
        end
    end    
end

Events.OnRenderTick.Add(AdminRadZone.symHandler)
-----------------------            ---------------------------
--[[ 

function AdminRadZone.symHandler()
    if not SandboxVars.AdminRadZone.MapSymbols then return end
    local data = AdminRadZoneData
    if not data then return end

    if not data.run then
        if AdminRadZoneSym then
            AdminRadZoneSym:setRGBA(0, 0, 0, 0)
        end
        return
    end

    if data.state == "active" then
        local col = AdminRadZone.panelColors[data.state]
        local x, y = data.x, data.y
        local rad = data.rad or SandboxVars.AdminRadZone.DefaultRadius or 4

        local mapAPI = ISWorldMap_instance.javaObject:getAPIv1()
        local symAPI = mapAPI:getSymbolsAPI()

        if not AdminRadZoneSym then
            AdminRadZoneSym = symAPI:addTexture("Circle", x, y)
        end

        if AdminRadZoneSym then
            AdminRadZoneSym:setAnchor(0.5, 0.5)
            AdminRadZoneSym:setRGBA(col.r or 1, col.g or 0, col.b or 0, 1)

            -- key line: scales the circle in world tile units
            AdminRadZoneSym:setScaleCircleTexture(rad)
        end
    end
end

Events.OnRenderTick.Add(AdminRadZone.symHandler)
 ]]