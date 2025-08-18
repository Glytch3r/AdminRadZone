--[[ 
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
]]
AdminRadZone = AdminRadZone or {}

function AdminRadZone.pause(seconds, callback)
    local start = getTimestampMs()
    local duration = seconds * 1000

    local function tick()
        local now = getTimestampMs()
        if now - start >= duration then
            Events.OnTick.Remove(tick)
            if callback then callback() end
        end
    end

    Events.OnTick.Add(tick)
end





-----------------------            ---------------------------





--[[ 



function AdminRadZone.getStateStr()
	local prefix = "Zone Recovery:"
	local recover = AdminRadZone.isSafeZoneRecover()
	local state = tostring(prefix) .." [OFF]"
	if recover then 
		state = tostring(prefix) .." [ON]"
	end
	return state
end
function AdminRadZone.context(player, context, worldobjects, test)
	local pl = getSpecificPlayer(player)
	local sq = clickedSquare
	if not  AdminRadZone.isAdm(pl) then return end
	local title = ""
	
	
	local x, y = round(pl:getX()), round(pl:getY())

	if 	sq:DistTo(x, y) <= 3 or sq == pl:getCurrentSquare() then
		if not x or not y then return end
		local isInSafe = NonPvpZone.getNonPvpZone(x, y) or false
		if isInSafe then
			title =  isInSafe:getTitle()
		end

		local mainMenu = "AdminRadZone: "..tostring(title)
		local Main = context:addOptionOnTop(mainMenu)
		Main.iconTexture = getTexture("media/ui/LootableMaps/map_trap.png")
		local opt = ISContextMenu:getNew(context)
		context:addSubMenu(Main, opt)

		
		local optTip = opt:addOption("Admin Fence Panel", worldobjects, function()
			MiniToolkitPanel.Launch()

			getSoundManager():playUISound("UIActivateMainMenuItem")
			context:hideAndChildren()
		end)

		local optTip = opt:addOption(tostring(AdminRadZone.getStateStr()), worldobjects, function()
			AdminRadZone.setSafeZoneRecover(not AdminRadZone.isSafeZoneRecover())
			getSoundManager():playUISound("UIActivateMainMenuItem")
			context:hideAndChildren()
		end)
		context:setOptionChecked(optTip, AdminRadZone.isSafeZoneRecover())
	
	end
end
Events.OnFillWorldObjectContextMenu.Remove(AdminRadZone.context)
Events.OnFillWorldObjectContextMenu.Add(AdminRadZone.context)

function AdminRadZone.getCenter(x1,y1,x2,y2)
	local x = (x1 + x2) / 2
	local y = (y1 + y2) / 2
	return x, y
end ]]