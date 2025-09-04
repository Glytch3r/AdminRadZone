
----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

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
        if not (data and data.state and data.x and data.y and data.rad and data.run) then return end

        local mapAPI = self.inner.mapAPI

        AdminRadZone.renderSym(mapAPI, data.x, data.y, data.rad,
            1, 0, 0, 1,
            self.inner,
            nil, nil,
            nil,    
            3
        )
    end

end
Events.OnCreatePlayer.Add(AdminRadZone.hookInit)

----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------
----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

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
        if not (data and data.state and data.x and data.y and data.rad and data.run) then return end

        local mapAPI = self.inner.mapAPI
        local mask = {
            x1 = 0,
            y1 = 0,
            x2 = self.inner:getWidth(),
            y2 = self.inner:getHeight()
        }

        AdminRadZone.renderSym(mapAPI, data.x, data.y, data.rad,
            1, 0, 0, 1,
            self.inner,
            nil, nil,
            mask,
            3
        )
    end
end

function AdminRadZone.renderSym(mapAPI, posX, posY, radius, r, g, b, alpha, drawTarget, uiXOffset, uiYOffset, mask, thickness)
    thickness = thickness or 2
    local screenCenterX = mapAPI:worldToUIX(posX, posY)
    local screenCenterY = mapAPI:worldToUIY(posX, posY)
    
    if uiXOffset then
        screenCenterX = screenCenterX + uiXOffset
        screenCenterY = screenCenterY + uiYOffset
    end
    
    local screenEdgeX = mapAPI:worldToUIX(posX + radius, posY)
    local screenEdgeY = mapAPI:worldToUIY(posX, posY + radius)
    local screenRadiusX = math.abs(screenEdgeX - screenCenterX)
    local screenRadiusY = math.abs(screenEdgeY - screenCenterY)
    
    local circumference = 2 * math.pi * math.max(screenRadiusX, screenRadiusY)
    local dotSpacing = 8
    local numDots = math.max(36, math.floor(circumference / dotSpacing))
    local step = (math.pi * 2) / numDots
    local isShow = SandboxVars.AdminRadZone.MapSymbols
    local mapVisible = drawTarget and drawTarget:getIsVisible()
    
    for deg = 0, math.pi * 2, step do
        local xScreen1 = screenCenterX + screenRadiusX * math.cos(deg)
        local yScreen1 = screenCenterY + screenRadiusY * math.sin(deg)
        local xScreen2 = screenCenterX + screenRadiusX * math.cos(deg + step)
        local yScreen2 = screenCenterY + screenRadiusY * math.sin(deg + step)
        
        local hide = false
        if mask then
            hide, xScreen1, yScreen1, xScreen2, yScreen2 = AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
        end
        
        if not hide and drawTarget and isShow and mapVisible then
            local halfThickness = thickness / 2
            drawTarget:drawRect(xScreen1 - halfThickness, yScreen1 - halfThickness, thickness, thickness, alpha, r, g, b)
            drawTarget:drawRect(xScreen2 - halfThickness, yScreen2 - halfThickness, thickness, thickness, alpha, r, g, b)
        end
    end
end

function AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
    if not mask then return false, xScreen1, yScreen1, xScreen2, yScreen2 end
    
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

Events.OnCreatePlayer.Add(AdminRadZone.hookInit)
--[[ 
function AdminRadZone.renderSym(mapAPI, posX, posY, radius, r, g, b, alpha, drawTarget, uiXOffset, uiYOffset, mask, thickness)
    thickness = thickness or 2
    
    local screenCenterX = mapAPI:worldToUIX(posX, posY)
    local screenCenterY = mapAPI:worldToUIY(posX, posY)
    if uiXOffset then
        screenCenterX = screenCenterX + uiXOffset
        screenCenterY = screenCenterY + uiYOffset
    end
    
    local screenRadiusX = math.abs(mapAPI:worldToUIX(posX + radius, posY) - screenCenterX)
    local screenRadiusY = math.abs(mapAPI:worldToUIY(posX, posY + radius) - screenCenterY)
    
    local avgRadius = (screenRadiusX + screenRadiusY) / 2
    local circumference = 2 * math.pi * avgRadius
    local dotSpacing = 8  
    local numDots = math.max(36, math.floor(circumference / dotSpacing)) 
    local step = (math.pi * 2) / numDots
    
    local isShow = SandboxVars.AdminRadZone.MapSymbols
    local mapVisible = drawTarget and drawTarget:getIsVisible()
    
    for deg = 0, math.pi * 2, step do
        local xScreen1 = screenCenterX + screenRadiusX * math.cos(deg)
        local yScreen1 = screenCenterY + screenRadiusY * math.sin(deg)
        local xScreen2 = screenCenterX + screenRadiusX * math.cos(deg + step)
        local yScreen2 = screenCenterY + screenRadiusY * math.sin(deg + step)
        
        local hide = false
        if mask then
            hide, xScreen1, yScreen1, xScreen2, yScreen2 = AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
        end
        
        if not hide and drawTarget and isShow and mapVisible then
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
 ]]
-----------------------            ---------------------------





--[[ 


function AdminRadZone.renderSym(mapAPI, posX, posY, radius, r, g, b, alpha, drawTarget, uiXOffset, uiYOffset, mask, thickness)
    thickness = thickness or 2
    local screenCenterX = mapAPI:worldToUIX(posX, posY)
    local screenCenterY = mapAPI:worldToUIY(posX, posY)
    if uiXOffset then
        screenCenterX = screenCenterX + uiXOffset
        screenCenterY = screenCenterY + uiYOffset
    end
    local screenRadius = math.abs(mapAPI:worldToUIX(posX + radius, posY) - screenCenterX)
    local circumference = 2 * math.pi * screenRadius
    local dotSpacing = 8
    local numDots = math.max(36, math.floor(circumference / dotSpacing))
    local step = (math.pi * 2) / numDots
    local isShow = SandboxVars.AdminRadZone.MapSymbols
    local mapVisible = drawTarget and drawTarget:getIsVisible()
    for deg = 0, math.pi * 2, step do
        local xScreen1 = screenCenterX + screenRadius * math.cos(deg)
        local yScreen1 = screenCenterY + screenRadius * math.sin(deg)
        local xScreen2 = screenCenterX + screenRadius * math.cos(deg + step)
        local yScreen2 = screenCenterY + screenRadius * math.sin(deg + step)
        local hide = false
        if mask then
            hide, xScreen1, yScreen1, xScreen2, yScreen2 = AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
        end
        if not hide and drawTarget and isShow and mapVisible then
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



 ]]

-----------------------            ---------------------------




--[[ 



function AdminRadZone.renderSym(mapAPI, posX, posY, radius, r, g, b, alpha, drawTarget, uiXOffset, uiYOffset, mask, thickness)
    thickness = thickness or 2
    local screenCenterX = mapAPI:worldToUIX(posX, posY)
    local screenCenterY = mapAPI:worldToUIY(posX, posY)
    if uiXOffset then
        screenCenterX = screenCenterX + uiXOffset
        screenCenterY = screenCenterY + uiYOffset
    end
    local screenRadiusX = math.abs(mapAPI:worldToUIX(posX + radius, posY) - screenCenterX)
    local screenRadiusY = math.abs(mapAPI:worldToUIY(posX, posY + radius) - screenCenterY)
    local screenRadius = (screenRadiusX + screenRadiusY) / 2
    local circumference = 2 * math.pi * screenRadius
    local dotSpacing = 8
    local numDots = math.max(36, math.floor(circumference / dotSpacing))
    local step = (math.pi * 2) / numDots
    local isShow = SandboxVars.AdminRadZone.MapSymbols
    local mapVisible = drawTarget and drawTarget:getIsVisible()
    for deg = 0, math.pi * 2, step do
        local xScreen1 = screenCenterX + screenRadius * math.cos(deg)
        local yScreen1 = screenCenterY + screenRadius * math.sin(deg)
        local xScreen2 = screenCenterX + screenRadius * math.cos(deg + step)
        local yScreen2 = screenCenterY + screenRadius * math.sin(deg + step)
        local hide = false
        if mask then
            hide, xScreen1, yScreen1, xScreen2, yScreen2 = AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
        end
        if not hide and drawTarget and isShow and mapVisible then
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




 ]]

