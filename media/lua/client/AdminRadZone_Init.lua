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
AdminRadZone = AdminRadZone or {}

function AdminRadZone.init(plNum, pl)
	if AdminRadZone.isDisabled() then return end
	local x, y, rad, pause = AdminRadZone.toStringData()
	pause = pause or 1
	AdminRadZone.data = {
		x = x,
		y = y,
		rad = rad,
		pause = pause,
	}
end
Events.OnCreatePlayer.Add(AdminRadZone.init)

----------------------------------------------------------------

--     ▄▄▄▄ ▄▄▄▄   ▄     ▄    ▄▄▄  ▄   ▄  ▄▄▄  ▄   ▄    
--    █  ▄█ █      █     █   █   ▀ █   █ ▀   █ █   █       
--    █   ▄ █    █▀▀▀█   █   █   ▄ █▀▀▀█ ▄  ▀█ █ ▀▀▄    
--     ▀▀▀  ▀    ▀   ▀ ▀▀▀▀▀  ▀▀▀  ▀   ▀  ▀▀▀   ▀▀▀     

----------------------------------------------------------------
