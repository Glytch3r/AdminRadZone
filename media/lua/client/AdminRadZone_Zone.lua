AdminRadZone = AdminRadZone or {}

function AdminRadZone.getBoundStr(pl)
    pl = pl or getPlayer()
    if not pl then return "" end
    local data = AdminRadZoneData
    if not data or not data.state or not data.run then return "" end
    if data.x == -1 or data.y == -1 then return "" end
    local centerX, centerY, rad = data.x, data.y, data.rad
    local sq = pl:getCurrentSquare()
    if not sq then return "" end
    local dx = (sq:getX() + 0.5) - centerX
    local dy = (sq:getY() + 0.5) - centerY
    local distance = math.sqrt(dx * dx + dy * dy)
    local inBound = distance <= rad
    return inBound and "InBound" or "OutOfBound"
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

function AdminRadZone.updateClientMarker(pl)
    pl = pl or getPlayer()
    local data = AdminRadZoneData
    if not data or not data.state or not data.rad then return end
    if data.x == -1 or data.y == -1 then return end

    local z = (pl and pl:getZ()) or 0
    local col = AdminRadZone.getColorProperties()
    local centerX, centerY = data.x, data.y
    local mult = 1.5

    if AdminRadZone.isShouldShowMarker() or AdminRadZone.forceSwap then
        if not AdminRadZone.marker or AdminRadZone.forceSwap then
            local sq = getCell():getOrCreateGridSquare(math.floor(centerX), math.floor(centerY), math.floor(z))
            if sq then
                col = AdminRadZone.getColorProperties()
                if AdminRadZone.marker then
                    AdminRadZone.marker:remove()
                    AdminRadZone.marker = nil
                end
                AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
                    AdminRadZone.shouldPick,
                    AdminRadZone.shouldPick,
                    sq,
                    col:getR(), col:getG(), col:getB(),
                    true,
                    data.rad * mult
                )
                if AdminRadZone.marker then
                    AdminRadZone.marker:setScaleCircleTexture(false)
                    AdminRadZone.marker:setPosAndSize(centerX, centerY, z, data.rad * mult)
                end
            end
        end

        col = AdminRadZone.getColorProperties()
        if AdminRadZone.marker then
            AdminRadZone.marker:setPosAndSize(centerX, centerY, z, data.rad * mult)
            AdminRadZone.marker:setR(col:getR())
            AdminRadZone.marker:setG(col:getG())
            AdminRadZone.marker:setB(col:getB())
        end
    elseif AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
end

function AdminRadZone.debugBoundStr(pl)
    pl = pl or getPlayer()
    if not pl then return end
    if not AdminRadZoneData or not AdminRadZoneData.state then return end
    if not AdminRadZoneData.run then return end
    if AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 then return end

    local centerX, centerY, rad = AdminRadZoneData.x, AdminRadZoneData.y, AdminRadZoneData.rad
    local sq = pl:getCurrentSquare()
    if not sq then return end

    local sqX = sq:getX()
    local sqY = sq:getY()
    local dx = (sqX + 0.5) - centerX
    local dy = (sqY + 0.5) - centerY

    local ratios = {
        {1.0, 1.0, "Circle"},
        {1.0, 0.5, "Wide 2:1"},
        {0.5, 1.0, "Tall 1:2"},
        {1.0, 0.75, "Wide 4:3"},
        {0.75, 1.0, "Tall 3:4"}
    }

    local debugInfo = string.format(
        "Player Square: %d, %d\nZone Center: %.2f, %.2f\nZone Radius: %.2f\nDX: %.2f, DY: %.2f\n\n",
        sqX, sqY, centerX, centerY, rad, dx, dy
    )

    for i, ratio in ipairs(ratios) do
        local radiusX = rad * ratio[1]
        local radiusY = rad * ratio[2]
        local ellipseValue = (dx * dx) / (radiusX * radiusX) + (dy * dy) / (radiusY * radiusY)
        local inBound = ellipseValue <= 1
        local result = inBound and "InBound" or "OutOfBound"
        debugInfo = debugInfo .. string.format("%s: Value=%.3f, %s\n", ratio[3], ellipseValue, result)
    end

    Clipboard.setClipboard(debugInfo)
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

function AdminRadZone.getDistance(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil end
    local data = AdminRadZoneData
    if not data or data.x == -1 or data.y == -1 or not data.rad then return nil, nil end

    local sq = pl:getCurrentSquare()
    if not sq then return nil, nil end

    local dx = (sq:getX() + 0.5) - data.x
    local dy = (sq:getY() + 0.5) - data.y
    local distance = math.sqrt(dx * dx + dy * dy)
    local inBound = distance <= data.rad
    return distance, inBound
end

Events.OnPlayerUpdate.Add(AdminRadZone.updateClientMarker)
