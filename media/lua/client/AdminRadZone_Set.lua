--client folder
--AdminRadZone_Set.lua
if not isClient() then return end

AdminRadZone = AdminRadZone or {}
--[[ 
local DefaultRadius = SandboxVars.AdminRadZone.DefaultRadius or 50
local DefaultRounds = SandboxVars.AdminRadZone.DefaultRounds or 5
local Cooldown = SandboxVars.AdminRadZone.Cooldown or 60
local RoundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
 ]]

function AdminRadZone.clear()
    if AdminRadZone.marker then
        AdminRadZone.marker:remove()
        AdminRadZone.marker = nil
    end

    AdminRadZoneData.x = -1
    AdminRadZoneData.y = -1
    AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 50
    AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration or 60
    AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    --AdminRadZoneData.shrinkRate = SandboxVars.AdminRadZone.ShrinkRate or 1
    AdminRadZoneData.active = false

    return AdminRadZoneData
    --AdminRadZone.updateMarker()
end
-----------------------            ---------------------------

function AdminRadZone.setXY(data)
    if not data or not data.x or not data.y  then
        AdminRadZoneData.x = -1
        AdminRadZoneData.y = -1
    else
        AdminRadZoneData.x = data.x
        AdminRadZoneData.y = data.y
    end
    AdminRadZone.updateMarker()
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.setRad(data)
    if not data or not data.rad then
        AdminRadZoneData.rad = SandboxVars.AdminRadZone.DefaultRadius or 50
    else
        AdminRadZoneData.rad = data.rad
    end
    AdminRadZone.updateMarker()
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.setduration(data)
    if not data or not data.duration then
        AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration or 60
    else
        AdminRadZoneData.duration = data.duration
    end
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.setRounds(data)
    if not data or not data.rounds then
        AdminRadZoneData.rounds = SandboxVars.AdminRadZone.DefaultRounds or 5
    else
        AdminRadZoneData.rounds = data.rounds
    end
    AdminRadZone.doTransmit(data)
end

function AdminRadZone.setCooldown(data)
    if not data or not data.cooldown then
        AdminRadZoneData.cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    else
        AdminRadZoneData.cooldown = data.cooldown
    end
    AdminRadZone.doTransmit(data)
end

