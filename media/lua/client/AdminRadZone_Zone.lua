AdminRadZone = AdminRadZone or {}
AdminRadZone.imageOffset = 0.71
function AdminRadZone.getBoundStr(pl)
    pl = pl or getPlayer()
    if not pl then return "" end
    local data = AdminRadZoneData
    if not data or not data.state or not data.run then return "" end
    if data.x == -1 or data.y == -1 then return "" end
    local centerX, centerY, rad = data.x, data.y, data.rad
    local sq = pl:getCurrentSquare()
    if not sq then return "" end
    local dx = (sq:getX()) - centerX
    local dy = (sq:getY()) - centerY
    local distance = math.sqrt(dx * dx + dy * dy)
    local inBound = distance <= rad
    return inBound and "InBound" or "OutOfBound"
end
function AdminRadZone.getDistance(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil end
    local data = AdminRadZoneData
    if not data or data.x == -1 or data.y == -1 or not data.rad then return nil, nil end

    local dx = pl:getX() - data.x
    local dy = pl:getY() - data.y
    local distance = math.sqrt(dx * dx + dy * dy)
    local inBound = distance <= data.rad
    return distance, inBound
end
--[[ 
function AdminRadZone.mask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
    if not mask then return false, xScreen1, yScreen1, xScreen2, yScreen2 end

    if (xScreen1 < mask.x1 or xScreen1 > mask.x2 or
        yScreen1 < mask.y1 or yScreen1 > mask.y2 or
        xScreen2 < mask.x1 or xScreen2 > mask.x2 or
        yScreen2 < mask.y1 or yScreen2 > mask.y2) then
        return true, xScreen1, yScreen1, xScreen2, yScreen2
    end

    return false, xScreen1, yScreen1, xScreen2, yScreen2
end ]]

function AdminRadZone.mask(x, y, mask)
    if not mask then return false, x, y end
    if x < mask.x1 or x > mask.x2 or y < mask.y1 or y > mask.y2 then
        return true, x, y
    end
    return false, x, y
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
    local dotSpacing = SandboxVars.AdminRadZone.MapDots or 6
    local numDots = math.max(36, math.floor(circumference / dotSpacing))
    local step = (math.pi * 2) / numDots
    local isShow = SandboxVars.AdminRadZone.MapSymbols
    local mapVisible = drawTarget and drawTarget:getIsVisible()

    for deg = 0, math.pi * 2, step do
        local xScreen = screenCenterX + screenRadiusX * math.cos(deg)
        local yScreen = screenCenterY + screenRadiusY * math.sin(deg)

        local hide = false
        if mask then
            hide, xScreen, yScreen = AdminRadZone.mask(xScreen, yScreen, mask)
        end

        if not hide and drawTarget and isShow and mapVisible then
            local halfThickness = thickness / 2
            drawTarget:drawRect(xScreen - halfThickness, yScreen - halfThickness, thickness, thickness, alpha, r, g, b)
        end
    end
end


--[[ 
local pl = getPlayer() 
pl:setX(round(pl:getX())+0.5)
pl:setY(round(pl:getY())+0.5)
pl:setLx(round(pl:getX())+0.5)
pl:setLy(round(pl:getY())+0.5)
 ]]

function AdminRadZone.updateClientMarker(pl)
    pl = pl or getPlayer()
    local data = AdminRadZoneData
    if not data or not data.state or not data.rad then return end
    if data.x == -1 or data.y == -1 then return end

    local z = (pl and pl:getZ()) or 0
    local col = AdminRadZone.getColorProperties()
    local centerX, centerY = data.x, data.y

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
                    data.rad
                )
                if AdminRadZone.marker then
                    AdminRadZone.marker:setScaleCircleTexture(false)
                    AdminRadZone.marker:setPosAndSize(centerX, centerY, z, AdminRadZone.getImageRad(data.rad))
                end
            end
        end

        col = AdminRadZone.getColorProperties()
        if AdminRadZone.marker then

            AdminRadZone.marker:setPosAndSize(centerX, centerY, z, AdminRadZone.getImageRad(data.rad))
            AdminRadZone.marker:setR(col:getR())
            AdminRadZone.marker:setG(col:getG())
            AdminRadZone.marker:setB(col:getB())
        end
    elseif AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.updateClientMarker)

function AdminRadZone.getImageRad(rad)
    rad = rad  or AdminRadZoneData.rad
    return rad / AdminRadZone.imageOffset
end

-----------------------            ---------------------------
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
    local dx = (sqX) - centerX
    local dy = (sqY) - centerY

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
