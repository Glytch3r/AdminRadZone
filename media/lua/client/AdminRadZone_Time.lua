AdminRadZone = AdminRadZone or {}
if not isClient() then return end

function AdminRadZone.stepper(seconds, CallWhileCount, CallAfter, delay)
    local count = seconds
    local lastTick = getTimestampMs()
    local delay = delay or SandboxVars.AdminRadZone.StepDelay or 1000
    local function ticker()
        local now = getTimestampMs()
        if now - lastTick >= delay then
            if CallWhileCount then CallWhileCount(count) end
            lastTick = now
            count = count - 1
            if count < 0 then
                Events.OnTick.Remove(ticker)
                if CallAfter then CallAfter() end
            end
        end
    end
    Events.OnTick.Add(ticker)
end
function AdminRadZone.getRadZoneRadius(sq1, sq2)
    sq1 = sq1 or AdminRadZone.point1
    sq2 = sq2 or AdminRadZone.point2
    if not sq1 or not sq2 then return 0 end
    local dx = sq2:getX() - sq1:getX()
    local dy = sq2:getY() - sq1:getY()
    return math.sqrt(dx * dx + dy * dy)
end

function AdminRadZone.doMarkerSteps(targRad)
    if not AdminRadZone.point1 or not AdminRadZone.point2  then return end
    local rad = AdminRadZone.getRadZoneRadius(AdminRadZone.point1, AdminRadZone.point2)
    local startX, startY, startRad = AdminRadZone.point1:getX(), AdminRadZone.point1:getY(), rad
    local delay = SandboxVars.AdminRadZone.StepDelay or 1000
    local tx, ty = AdminRadZone.point2:getX(), AdminRadZone.point2:getY()
    local seconds = delay/targRad
    seconds = math.max(seconds or 5, 1)
    
    local stepX = (tx - startX) / seconds
    local stepY = (ty - startY) / seconds
    local stepR = (targRad - startRad) / seconds

    local curX, curY, curR = startX, startY, startRad

    AdminRadZone.stepper(
        seconds,
        function()
            curX = curX + stepX
            curY = curY + stepY
            curR = curR + stepR
            AdminRadZone.Send(AdminRadZone.floor(curX), AdminRadZone.floor(curY), curR, 0)
        end,
        function()
            AdminRadZone.Send(tx, ty, tr, 1)
        end
    )
end
function AdminRadZone.doPause(int)    
    AdminRadZone.Send(AdminRadZone.floor(AdminRadZone.data.x), AdminRadZone.floor(AdminRadZone.data.y), AdminRadZone.data.rad, tonumber(int))
end