--[[ AdminRadZone = AdminRadZone or {}
function AdminRadZone.hookInit()
    AdminRadZone.Hook_ISWorldMapRender = AdminRadZone.Hook_ISWorldMapRender or ISWorldMap.render
    AdminRadZone.Hook_ISMiniMapOuterRender = AdminRadZone.Hook_ISMiniMapOuterRender or ISMiniMapOuter.render
    function ISWorldMap:render()
        AdminRadZone.Hook_ISWorldMapRender(self)
        local data = AdminRadZoneData
        if data and data.state and data.x and data.y and data.rad and AdminRadZone.showZoneSymbol then
            AdminRadZone.renderSym(self.mapAPI, data.x, data.y, data.rad, 1, 0, 0, 1, self, nil, nil, nil, 3)
        end
    end
    function ISMiniMapOuter:render()
        AdminRadZone.Hook_ISMiniMapOuterRender(self)
        local data = AdminRadZoneData
        if data and data.state and data.x and data.y and data.rad and AdminRadZone.showZoneSymbol then
            local miniMapXOffset = self:getX() + self.inner:getX()
            local miniMapYOffset = self:getY() + self.inner:getY()
            local mask = {
                x1 = miniMapXOffset,
                x2 = miniMapXOffset + self.inner:getWidth(),
                y1 = miniMapYOffset,
                y2 = miniMapYOffset + self.inner:getHeight()
            }
            AdminRadZone.renderSym(self.inner.mapAPI, data.x, data.y, data.rad, 1,0,0,1, self.inner, miniMapXOffset, miniMapYOffset, mask, 3)
        end
    end
end
Events.OnGameStart.Add(AdminRadZone.hookInit)
function AdminRadZone.renderSym(mapAPI, posX, posY, radius, r, g, b, alpha, drawTarget, uiXOffset, uiYOffset, mask, thickness)
    thickness = thickness or 2
    local angularStep = math.pi / 27
    local screenCenterX = mapAPI:worldToUIX(posX, posY)
    local screenCenterY = mapAPI:worldToUIY(posX, posY)
    
    if uiXOffset then
        screenCenterX = screenCenterX + uiXOffset
        screenCenterY = screenCenterY + uiYOffset
    end
    
    local screenRadius = math.abs(mapAPI:worldToUIX(posX + radius, posY) - screenCenterX)
    
    for angularIter = 0, math.pi * 2, angularStep do
        local xScreen1 = screenCenterX + screenRadius * math.cos(angularIter)
        local yScreen1 = screenCenterY + screenRadius * math.sin(angularIter)
        local xScreen2 = screenCenterX + screenRadius * math.cos(angularIter + angularStep)
        local yScreen2 = screenCenterY + screenRadius * math.sin(angularIter + angularStep)
        
        local hide = false
        if mask then
            hide, xScreen1, yScreen1, xScreen2, yScreen2 = AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
        end
        
        if not hide then
            if drawTarget then
                local halfThickness = thickness / 2
                drawTarget:drawRect(xScreen1-halfThickness, yScreen1-halfThickness, thickness, thickness, alpha, r, g, b)
                drawTarget:drawRect(xScreen2-halfThickness, yScreen2-halfThickness, thickness, thickness, alpha, r, g, b)
            end
        end
    end
end
function AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
    if not mask then
        return false, xScreen1, yScreen1, xScreen2, yScreen2
    end
    local hide = false
    if (xScreen1 < mask.x1 and xScreen2 < mask.x1) or
       (xScreen1 > mask.x2 and xScreen2 > mask.x2) or
       (yScreen1 < mask.y1 and yScreen2 < mask.y1) or
       (yScreen1 > mask.y2 and yScreen2 > mask.y2) then
        hide = true
        return hide, xScreen1, yScreen1, xScreen2, yScreen2
    end
    if xScreen1 < mask.x1 then xScreen1 = mask.x1 end
    if xScreen1 > mask.x2 then xScreen1 = mask.x2 end
    if yScreen1 < mask.y1 then yScreen1 = mask.y1 end
    if yScreen1 > mask.y2 then yScreen1 = mask.y2 end
    if xScreen2 < mask.x1 then xScreen2 = mask.x1 end
    if xScreen2 > mask.x2 then xScreen2 = mask.x2 end
    if yScreen2 < mask.y1 then yScreen2 = mask.y1 end
    if yScreen2 > mask.y2 then yScreen2 = mask.y2 end
    return hide, xScreen1, yScreen1, xScreen2, yScreen2
end
function AdminRadZone.symHandler()
    local data = AdminRadZoneData
    if not data then 
        AdminRadZone.showZoneSymbol = false
        return 
    end
    
    if AdminRadZone.isShouldShowMarker() then
        AdminRadZone.showZoneSymbol = true
    else
        AdminRadZone.showZoneSymbol = false
    end
end
Events.OnPostRender.Add(AdminRadZone.symHandler)
 ]]
AdminRadZone = AdminRadZone or {}
function AdminRadZone.hookInit()
    AdminRadZone.Hook_ISWorldMapRender = AdminRadZone.Hook_ISWorldMapRender or ISWorldMap.render
    AdminRadZone.Hook_ISMiniMapOuterRender = AdminRadZone.Hook_ISMiniMapOuterRender or ISMiniMapOuter.render

    function ISWorldMap:render()
        AdminRadZone.Hook_ISWorldMapRender(self)
        local data = AdminRadZoneData
        if data and data.state and data.x and data.y and data.rad and data.run then
            AdminRadZone.renderSym(self.mapAPI, data.x, data.y, data.rad, 1, 0, 0, 1, self, nil, nil, nil, 3)
        end
    end

    function ISMiniMapOuter:render()
        AdminRadZone.Hook_ISMiniMapOuterRender(self)
        local data = AdminRadZoneData

        if data and data.state and data.x and data.y and data.rad and data.run then
            AdminRadZone.renderSym(self.inner.mapAPI, data.x, data.y, data.rad, 1, 0, 0, 1, self.inner, nil, nil, nil, 3)
        end
    end
end
Events.OnCreatePlayer.Add(AdminRadZone.hookInit)

function AdminRadZone.renderSym(mapAPI, posX, posY, radius, r, g, b, alpha, drawTarget, uiXOffset, uiYOffset, mask, thickness)
    thickness = thickness or 2
    local shrink = math.pi / 27
    local screenCenterX = mapAPI:worldToUIX(posX, posY)
    local screenCenterY = mapAPI:worldToUIY(posX, posY)

    if uiXOffset then
        screenCenterX = screenCenterX + uiXOffset
        screenCenterY = screenCenterY + uiYOffset
    end

    local screenRadius = math.abs(mapAPI:worldToUIX(posX + radius, posY) - screenCenterX)
    local isShow = SandboxVars.AdminRadZone.MapSymbols

    for deg = 0, math.pi * 2, shrink do
        local xScreen1 = screenCenterX + screenRadius * math.cos(deg)
        local yScreen1 = screenCenterY + screenRadius * math.sin(deg)
        local xScreen2 = screenCenterX + screenRadius * math.cos(deg + shrink)
        local yScreen2 = screenCenterY + screenRadius * math.sin(deg + shrink)

        local hide = false
        if mask then
            hide, xScreen1, yScreen1, xScreen2, yScreen2 = AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
        end
        if not hide and drawTarget and isShow then
            local halfThickness = thickness / 2
        
            drawTarget:drawRect(xScreen1 - halfThickness, yScreen1 - halfThickness, thickness, thickness, alpha, r, g, b)
            drawTarget:drawRect(xScreen2 - halfThickness, yScreen2 - halfThickness, thickness, thickness, alpha, r, g, b)
        end
    end
end

function AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
    if not mask then
        return false, xScreen1, yScreen1, xScreen2, yScreen2
    end
    local hide = false
    if (xScreen1 < mask.x1 and xScreen2 < mask.x1) or
       (xScreen1 > mask.x2 and xScreen2 > mask.x2) or
       (yScreen1 < mask.y1 and yScreen2 < mask.y1) or
       (yScreen1 > mask.y2 and yScreen2 > mask.y2) then
        hide = true
        return hide, xScreen1, yScreen1, xScreen2, yScreen2
    end
    if xScreen1 < mask.x1 then xScreen1 = mask.x1 end
    if xScreen1 > mask.x2 then xScreen1 = mask.x2 end
    if yScreen1 < mask.y1 then yScreen1 = mask.y1 end
    if yScreen1 > mask.y2 then yScreen1 = mask.y2 end
    if xScreen2 < mask.x1 then xScreen2 = mask.x1 end
    if xScreen2 > mask.x2 then xScreen2 = mask.x2 end
    if yScreen2 < mask.y1 then yScreen2 = mask.y1 end
    if yScreen2 > mask.y2 then yScreen2 = mask.y2 end
    return hide, xScreen1, yScreen1, xScreen2, yScreen2
end
