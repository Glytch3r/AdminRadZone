--client folder
--AdminRadZone_Panel.lua
require "ISUI/ISPanel"

AdminRadZone = AdminRadZone or {}
AdminRadZonePanel = ISPanel:derive("AdminRadZonePanel")
--[[ 
AdminRadZonePanel.TogglePanel()
 ]]
function AdminRadZone.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end

function AdminRadZonePanel.ClosePanel()
    if AdminRadZonePanel.instance then
        AdminRadZonePanel.instance:setVisible(false)
        AdminRadZonePanel.instance:removeFromUIManager()
        AdminRadZonePanel.instance = nil
    end
end

function AdminRadZonePanel.OpenPanel()
    if AdminRadZonePanel.instance == nil then
        AdminRadZoneData.active   = (AdminRadZoneData.active   ~= nil) and AdminRadZoneData.active   or false
        AdminRadZoneData.cooldown = AdminRadZoneData.cooldown or 0
        AdminRadZoneData.duration = AdminRadZoneData.duration or 0
        AdminRadZoneData.rounds   = AdminRadZoneData.rounds   or 0
        AdminRadZoneData.x        = AdminRadZoneData.x        or -1
        AdminRadZoneData.y        = AdminRadZoneData.y        or -1

        if AdminRadZone.marker and not AdminRadZoneData.active then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end

        local x = getCore():getScreenWidth() / 3
        local y = getCore():getScreenHeight() / 2 - 200
        local w = 290
        local h = 340
        AdminRadZonePanel.instance = AdminRadZonePanel:new(x, y, w, h)
        AdminRadZonePanel.instance:initialise()
    end
    AdminRadZonePanel.instance:addToUIManager()
    AdminRadZonePanel.instance:setVisible(true)
end


function AdminRadZonePanel.isValid()
    return AdminRadZone.isAdm(getPlayer())
end

function AdminRadZonePanel.TogglePanel()
    if not AdminRadZonePanel.isValid() then
        AdminRadZonePanel.ClosePanel()
        return
    end
    if AdminRadZonePanel.instance == nil then
        AdminRadZonePanel.OpenPanel()
    else
        if AdminRadZonePanel.instance:isVisible() then
            AdminRadZonePanel.instance:setVisible(false)
        else
            AdminRadZonePanel.instance:setVisible(true)
        end
    end
end
-----------------------            ---------------------------
function AdminRadZonePanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    local col = AdminRadZone.getMarkerColor(1)
    o.borderColor = {r=col.r, g=col.g, b=col.b, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.moveWithMouse = true
    return o
end

function AdminRadZonePanel:initialise()
    ISPanel.initialise(self)
    local isActive = AdminRadZoneData.active or false
    
    local y = 30
    local spacing = 25
    
    self.titleLabel = ISLabel:new(20, 10, 15, "Radiation Zone Controller", 1, 1, 1, 1, UIFont.Large, true)
    self:addChild(self.titleLabel)
    local y = y + 16 
    
    self.cooldownLabel = ISLabel:new(10, y, 15, "Cooldown:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.cooldownLabel)
    self.cooldownEntry = ISTextEntryBox:new(tostring(SandboxVars.AdminRadZone.Cooldown or 60), 120, y-2, 80, 18)
    self.cooldownEntry:initialise()
    self.cooldownEntry:instantiate()
    self.cooldownEntry.onTextChange = AdminRadZonePanel.onCooldownChange
    self:addChild(self.cooldownEntry)

    self.currentTimeLabel = ISLabel:new(150, y, 15, "Current: 0", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self:addChild(self.currentTimeLabel)

    y = y + spacing
    
    self.durationLabel = ISLabel:new(10, y, 15, "Round Duration: " .. tostring(SandboxVars.AdminRadZone.RoundDuration or 60) .. "s", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.durationLabel)
    
    y = y + spacing
    
    self.shrinkRateLabel = ISLabel:new(10, y, 15, "Shrink Rate: 0.00/s", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.shrinkRateLabel)
    
    y = y + spacing + 10


    local cRound = SandboxVars.AdminRadZone.DefaultRounds or 5
    local cRad = SandboxVars.AdminRadZone.DefaultRadius or 50
    if isActive then
        cRound = AdminRadZoneData.rounds
        cRad = AdminRadZoneData.rad
    end
    self.roundsLabel = ISLabel:new(15, y, 15, "Rounds:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.roundsLabel)
    self.roundsEntry = ISTextEntryBox:new(tostring(cRound), 120, y-2, 80, 18)
    self.roundsEntry:initialise()
    self.roundsEntry:instantiate()
    self.roundsEntry.onTextChange = AdminRadZonePanel.onRoundsChange
    self:addChild(self.roundsEntry)
    --[[ 
    SandboxVars.AdminRadZone.Cooldown
    SandboxVars.AdminRadZone.RoundDuration
 ]]

    y = y + spacing
    
    self.radiusLabel = ISLabel:new(15, y, 15, "Initial Radius:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.radiusLabel)
    self.radiusEntry = ISTextEntryBox:new(tostring(cRad), 120, y-2, 80, 18)
    self.radiusEntry:initialise()
    self.radiusEntry:instantiate()
    self.radiusEntry.onTextChange = AdminRadZonePanel.onRadiusChange
    self:addChild(self.radiusEntry)
    

    
    y = y + spacing + 10
    

    self.totalTimeLabel = ISLabel:new(150, y, 15, "Total Duration: 0s", 1, 1, 0.5, 1, UIFont.Medium, true)
    self:addChild(self.totalTimeLabel)    



    self.xyBtn = ISButton:new(15, y+40, 80, 25,  "Select Square", self, AdminRadZonePanel.onXY)
    self.xyBtn.borderColor =  { r = 0.41, g = 0.80, b = 1.0 ,a=1}

    self.xyBtn:initialise()
    self.xyBtn:instantiate()
    self:addChild(self.xyBtn)
    self.xyLabel = ISLabel:new(15, y, 15, "Coordinates:", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.xyLabel)
    y = y + spacing + 10

    
    self.startStopBtn = ISButton:new(150, y, 80, 25, "", self, AdminRadZonePanel.onStartStop)
    self.startStopBtn:initialise()
    self.startStopBtn:instantiate()
    self.startStopBtn.borderColor = {r=1, g=1, b=1, a=0.1}
    if isActive then
        --self.startStopBtn.title = "STOP"
        self.startStopBtn:setImage(getTexture("media/ui/AdminRadZonePanel_Stop.png"))
    else
        --self.startStopBtn.title = "START"
        self.startStopBtn:setImage(getTexture("media/ui/AdminRadZonePanel_Start.png"))
    end
    self:addChild(self.startStopBtn)



    self.exitBtn = ISButton:new(150, y+40, 80, 25,  "Exit", self, AdminRadZonePanel.onExit)
    self.exitBtn.borderColor= {r=1, g=0, b=0, a=0.67}
    self.exitBtn:initialise()
    self.exitBtn:instantiate()
    self:addChild(self.exitBtn)
    y = y + spacing + 15
    self.currentRadiusLabel = ISLabel:new(15, y, 15, "Radius: 0", 0.7, 0.7, 0.7, 1, UIFont.Medium, true)
    self:addChild(self.currentRadiusLabel)

end

function AdminRadZonePanel:update()
    ISPanel.update(self)
    
    if not AdminRadZoneData then return end
    

    local shrinkRate = 0
    if AdminRadZoneData.rad and AdminRadZoneData.rounds and AdminRadZoneData.rounds > 0 then
        local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
        if roundDuration > 0 then
            shrinkRate = AdminRadZoneData.rad / roundDuration
        end
    end
    self.shrinkRateLabel.name = "Shrink Rate: " .. string.format("%.2f", shrinkRate) .. "/s"
    
    local currentRad = AdminRadZoneData.rad or 0
    self.currentRadiusLabel.name = "Radius: " .. string.format("%.1f", currentRad)


    local pl = getPlayer()
    local x, y = round(pl:getX()),  round(pl:getY())

    self.xyLabel.name = "Coordinates:\nX:" .. tostring(x).."\nY:".. tostring(y)    

    local rounds = tonumber(self.roundsEntry:getText()) or SandboxVars.AdminRadZone.DefaultRounds 
    local cooldown = tonumber(self.cooldownEntry:getText()) or 60
    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    local totalTime = (rounds * roundDuration) + (cooldown * rounds)
    self.totalTimeLabel.name = "Total Duration:\n" .. totalTime .. "s (" .. math.floor(totalTime/60) .. "m " .. (totalTime%60) .. "s)"
    AdminRadZoneData.duration = AdminRadZoneData.duration or 0
    AdminRadZoneData.cooldown = AdminRadZoneData.cooldown
    local currentCd = AdminRadZoneData.duration or 0
    self.currentTimeLabel:setColor( 0.86,  0.86, 0.67)

    if cooldown <= 0 then
        currentCd = AdminRadZoneData.cooldown or 0
        self.currentTimeLabel:setColor(0.61,  0.86, 1.0)
    end
    self.currentTimeLabel.name = "Round Time: "..tostrintg(currentCd)
end

function AdminRadZonePanel.onCooldownChange()
    local value = tonumber(AdminRadZonePanel.instance.cooldownEntry:getText())
    if value and value >= 0 then
        AdminRadZone.setCooldown({cooldown = value})
    end
end

function AdminRadZonePanel.onXY()
    local pl = getPlayer()
    local x, y = round(pl:getX()),  round(pl:getY())
    AdminRadZoneData.x = x
    AdminRadZoneData.y = y

    AdminRadZone.updateMarker()
    AdminRadZone.doTransmit(AdminRadZoneData)
end

function AdminRadZonePanel.onRoundsChange()
    local value = tonumber(AdminRadZonePanel.instance.roundsEntry:getText())
    if value and value > 0 then
        AdminRadZone.setRounds({rounds = value})
    end
end

function AdminRadZonePanel.onRadiusChange()
    local value = tonumber(AdminRadZonePanel.instance.radiusEntry:getText())
    if value and value > 0 then
        AdminRadZone.setRad({rad = value})
    end
end

function AdminRadZonePanel:onStartStop()
    local isActive = AdminRadZoneData and AdminRadZoneData.active or false
    if isActive then
        AdminRadZone.activate(false)
        self.startStopBtn:setImage(getTexture("media/ui/AdminRadZonePanel_Start.png"))
    else
        self.startStopBtn:setImage(getTexture("media/ui/AdminRadZonePanel_Stop.png"))

        if AdminRadZone.marker then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end

        local pl = getPlayer()
        local x, y = -1, -1
        if pl then
            x, y = round(pl:getX()), round(pl:getY())
        end

        if x and y then
            AdminRadZoneData.x = x
            AdminRadZoneData.y = y
        end

        AdminRadZoneData.rad = tonumber(self.radiusEntry:getText()) or (SandboxVars.AdminRadZone.DefaultRadius or 50)
        AdminRadZoneData.rounds = tonumber(self.roundsEntry:getText()) or (SandboxVars.AdminRadZone.DefaultRounds or 5)
        AdminRadZoneData.cooldown = tonumber(self.cooldownEntry:getText()) or (SandboxVars.AdminRadZone.Cooldown or 60)
        AdminRadZoneData.duration = SandboxVars.AdminRadZone.RoundDuration or 60

        AdminRadZone.activate(true)
        AdminRadZone.doTransmit(AdminRadZoneData)--[[  ]]
    end
    print(AdminRadZoneData.active)
end


function AdminRadZonePanel:onExit()
    AdminRadZonePanel.ClosePanel()
end

function AdminRadZonePanel:onClear()
    AdminRadZone.clear()
end

function AdminRadZonePanel:render()
    ISPanel.render(self)
end