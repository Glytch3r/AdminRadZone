
--client side
AdminRadZone = AdminRadZone or {}
if not isClient() then return end

-----------------------            ---------------------------

function AdminRadZone.clear()
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end
    local str = AdminRadZone.toDataString(-1, -1, 0)
    local sOpt = getSandboxOptions()
    sOpt:getOptionByName("AdminRadZone.DataString"):setValue(tostring(str))
    sOpt:toLua()
    AdminRadZone.data = {
            x = -1,
            y = -1,
            rad = 0,
            pause = 1,
        }
    --sOpt:sendToServer()
end

function AdminRadZone.doSave(x,y,rad,pause)
    if not x or not y or not rad then return end
    local sOpt = getSandboxOptions()
    pause = pause or 1
    local str = AdminRadZone.toDataString(x, y, rad, pause)
    sOpt:getOptionByName("AdminRadZone.DataString"):setValue(tostring(str))
    sOpt:toLua()
    --sOpt:sendToServer()
end

function AdminRadZone.clientSync(module, command, args)
    if module ~= "AdminRadZone" then return end
    if command == "Clear" then
        AdminRadZone.clear()
        return        
    elseif command == "Clear" then
        if not AdminRadZone.data then AdminRadZone.init() end
        local x, y, rad, pause = AdminRadZone.toStringData(str)
        pause = args.pause
        AdminRadZone.data.pause  = args.pause
        AdminRadZone.doSave(x, y, rad, pause)
    
        return
    elseif command == "Sync" then
        if not args.x or not args.y or not args.rad then return end
        local pause = args.pause or 1
        AdminRadZone.data = {
            x = args.x,
            y = args.y,
            rad = args.rad,
            pause = pause,
        }
        AdminRadZone.doSave(args.x, args.y, args.rad, pause)
    end
end
Events.OnServerCommand.Add(AdminRadZone.clientSync)
-----------------------            ---------------------------


function AdminRadZone.dataHandler()
    if not AdminRadZone.data then AdminRadZone.init() end
    
    if AdminRadZone.isDisabled() then
        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
    end
    local x, y, rad, pause = AdminRadZone.data.x, AdminRadZone.data.y, AdminRadZone.data.rad , AdminRadZone.data.pause       
    pause = pause or 1
    if not x or not y or not rad then return end
    if pause == 1 then return end

    if AdminRadZone.marker then
        local curX, curY = AdminRadZone.marker:getX(), AdminRadZone.marker:getY()
        local curRad = AdminRadZone.marker:getSize()

        if curX ~= x or curY ~= y or curRad ~= rad then
            AdminRadZone.marker:setPosAndSize(x, y, 0, rad)
        end
    else
        local sq = getCell():getOrCreateGridSquare(x, y, 0)
        if sq then
            local col = AdminRadZone.getMarkerColor(1)
            AdminRadZone.marker = getWorldMarkers():addGridSquareMarker(
                "circle_center", "circle_only_highlight",
                sq, col.r, col.g, col.b, true, rad
            )
        end
    end
end
Events.OnPlayerUpdate.Add(AdminRadZone.dataHandler)
