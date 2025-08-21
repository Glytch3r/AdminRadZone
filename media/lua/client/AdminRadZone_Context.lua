--client folder
--AdminRadZone_Context.lua
AdminRadZone = AdminRadZone or {}

-----------------------            ---------------------------

function AdminRadZone.context(player, context, worldobjects, test)
	local pl = getSpecificPlayer(player)
	local sq = clickedSquare
	if not AdminRadZone.isAdm(pl) then return end
	local title = ""
	
	
	local x, y = round(pl:getX()), round(pl:getY())

	if 	sq:DistTo(x, y) <= 3 or sq == pl:getCurrentSquare() then
		if not x or not y then return end
 

        local tip = ISWorldObjectContextMenu.addToolTip()
		local mainMenu = "Admin Radiation Zone: "..tostring(title)
		local Main = context:addOptionOnTop(tostring(mainMenu), worldobjects, function()
            AdminRadZonePanel.TogglePanel()
			getSoundManager():playUISound("UIActivateMainMenuItem")
			context:hideAndChildren()
		end)
		Main.iconTexture = getTexture("media/ui/LootableMaps/map_radiation.png")
		context:setOptionChecked(Main, AdminRadZonePanel.instance ~= nil)
        if AdminRadZoneData.active then
            local zoneDetails = "Rounds Remaining: "..tostring(AdminRadZoneData.rounds).."\nRound Time: "..tostring(AdminRadZoneData.duration)
            if AdminRadZoneData.cooldown > 0 then
                zoneDetails = "Rounds Remaining: "..tostring(AdminRadZoneData.rounds).."\nCooldown: "..tostring(AdminRadZoneData.cooldown)
            end
            tip.description = tostring(zoneDetails)
            Main.toolTip = tip
        end

	end
end
Events.OnFillWorldObjectContextMenu.Remove(AdminRadZone.context)
Events.OnFillWorldObjectContextMenu.Add(AdminRadZone.context)
