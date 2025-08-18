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
--[[ 
AdminRadZone = AdminRadZone or {}

function AdminRadZone.isSafeZoneRecover()
    return getSandboxOptions():getOptionByName("AdminRadZone.SafeZoneRecover"):getValue()
end

function AdminRadZone.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end


local ticks = 0
function AdminRadZone.doDmg(pl)
    local bd = doDmg:getBodyDamage()
    local hp =  bd:getOverallBodyHealth()
    bd:ReduceGeneralHealth()
end
function AdminRadZone.DamageHandler(pl)
    if not pl or not pl:isAlive() then return end
    if AdminRadZone.isAdm(pl) or pl:isGodMod() then return end
    local x, y = round(pl:getX()), round(pl:getY())
    if not x or not y then return end
    ticks = ticks + 1

    local DamageDelay = SandboxVars.AdminRadZone.DamageDelay 
    if ticks % DamageDelay == 0 then
        AdminRadZone.doDmg(pl)
        ticks = 0
    end
end

Events.OnPlayerUpdate.Add(AdminRadZone.DamageHandler) ]]
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------