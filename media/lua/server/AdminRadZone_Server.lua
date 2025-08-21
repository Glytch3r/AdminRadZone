--server folder
--AdminRadZone_Server.lua
if isClient() then return end

AdminRadZone = AdminRadZone or {}


function AdminRadZone.init()
	AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
end
Events.OnInitGlobalModData.Add(AdminRadZone.init)


function AdminRadZone.clientSync(module, command, args) 
    if module == "AdminRadZone" then             
        if command == "Sync" and args.data then 
            ModData.add("AdminRadZoneData", args.data)
            sendServerCommand("AdminRadZone", "Sync", {data=args.data})
            sendServerCommand("AdminRadZone", "Msg", {msg = "Data synced"})          
        elseif command == "Fetch" then 
            sendServerCommand("AdminRadZone", "Fetch", {data = AdminRadZoneData})          
        end
    end
end 
Events.OnClientCommand.Add(AdminRadZone.clientSync)

