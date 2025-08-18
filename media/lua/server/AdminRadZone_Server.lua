-- server side
if isClient() then return end

AdminRadZone = AdminRadZone or {}
local Commands = {}
Commands.AdminRadZone = {}

Commands.AdminRadZone.Clear = function(player, args)
    sendServerCommand("AdminRadZone", "Clear", {})
end

Commands.AdminRadZone.Sync = function(player, args)
    if not args.x or not args.y or not args.rad then return end
    sendServerCommand("AdminRadZone", "Sync", {x = args.x, y = args.y, rad = args.rad})
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](player, args)
    end
end)
