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
--AdminRadZone_Context.lua
AdminRadZone = AdminRadZone or {}

-----------------------            ---------------------------
function AdminRadZone.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end


function AdminRadZone.context(player, context, worldobjects, test)
	local pl = getSpecificPlayer(player)
	local sq = clickedSquare
	if not pl then return end 
	if not AdminRadZone.isAdm(pl) then return end
	
	if getActivatedMods():contains("AdminFence") and not getCore():getDebug() then
		return
    end
	local x, y = round(pl:getX()), round(pl:getY())
	
	if not x or not y then return end
	if getCore():getDebug() or	sq:DistTo(x, y) <= 3 or sq == pl:getCurrentSquare() then
        local tip = ISWorldObjectContextMenu.addToolTip()
		local mainMenu = "Admin Radiation Zone: "..tostring(AdminRadZoneData.state)
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
Events.OnFillWorldObjectContextMenu.Add(AdminRadZone.context)
