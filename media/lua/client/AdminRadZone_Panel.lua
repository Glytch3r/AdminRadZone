-- client/AdminRadZone_Panel.lua
require "ISUI/ISPanel"

AdminRadZone = AdminRadZone or {}
AdminRadZonePanel = ISPanel:derive("AdminRadZonePanel")

function AdminRadZonePanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.moveWithMouse = true
    return o
end

function AdminRadZonePanel:initialise()
    ISPanel.initialise(self)

    local col = AdminRadZone.getMarkerColor(1)

    AdminRadZone.tempMarker = getWorldMarkers():addGridSquareMarker(
        "AdminRadZone_Border", "circle_only_highlight", getPlayer():getCurrentSquare() , 
        1, 0, 0, true, AdminRadZoneData.rad)
    -- Ensure AdminRadZoneData exists
    if not AdminRadZoneData then
        AdminRadZoneData = ModData.getOrCreate("AdminRadZoneData")
        AdminRadZone.initData()
    end
    
    local isActive = AdminRadZoneData.state == "active"
    
    local margin = 15
    local spacing = 20
    local labelHeight = 15
    local entryWidth = 70
    local buttonWidth = 80
    local buttonHeight = 25
    local y = margin
    
    self.statusIcon = ISImage:new(margin - 5, y - 2, 32, 32, getTexture("media/ui/LootableMaps/map_radiation.png"))
    self.statusIcon:initialise()
    self.statusIcon:instantiate()
    self:addChild(self.statusIcon)
    
    self.titleLabel = ISLabel:new(margin + 40, y, labelHeight, "Radiation Zone Controller", 1, 1, 1, 1, UIFont.Large, true)
    self:addChild(self.titleLabel)
    y = y + 35
    
    self.roundsLabel = ISLabel:new(margin, y, labelHeight, "Rounds:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.roundsLabel)
    
    local cRound = SandboxVars.AdminRadZone.DefaultRounds or 5
    if isActive then
        cRound = AdminRadZoneData.rounds
    end
    
    self.roundsEntry = ISTextEntryBox:new(tostring(cRound), margin + 60, y - 2, entryWidth, 18)
    self.roundsEntry:initialise()
    self.roundsEntry:instantiate()
    self.roundsEntry.onTextChange = AdminRadZonePanel.onRoundsChange
    self:addChild(self.roundsEntry)
    
    self.currentRoundLabel = ISLabel:new(margin + 140, y, labelHeight, "Round: 0/0", 0.8, 0.2, 0.2, 1, UIFont.Small, true)
    self:addChild(self.currentRoundLabel)
    y = y + spacing
    
    self.radiusLabel = ISLabel:new(margin, y, labelHeight, "Radius:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.radiusLabel)
    
    local cRad = SandboxVars.AdminRadZone.DefaultRadius or 4
    if isActive then
        cRad = AdminRadZoneData.rad
    end
    
    self.radiusEntry = ISTextEntryBox:new(tostring(cRad), margin + 60, y - 2, entryWidth, 18)
    self.radiusEntry:initialise()
    self.radiusEntry:instantiate()
    self.radiusEntry.onTextChange = AdminRadZonePanel.onRadiusChange
    self:addChild(self.radiusEntry)
    
    self.currentRadiusLabel = ISLabel:new(margin + 140, y, labelHeight, "Current: 0", 0.8, 0.2, 0.2, 1, UIFont.Small, true)
    self:addChild(self.currentRadiusLabel)
    y = y + spacing
    
    self.totalTimeLabel = ISLabel:new(margin, y, labelHeight, "Total Time:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.totalTimeLabel)
    
    self.totalTimeValueLabel = ISLabel:new(margin + 80, y, labelHeight, "0s", 0.2, 0.8, 1.0, 1, UIFont.Medium, true)
    self:addChild(self.totalTimeValueLabel)
    y = y + spacing
    
    self.statusLabel = ISLabel:new(margin, y, labelHeight, "Status:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.statusLabel)
    
    self.statusValueLabel = ISLabel:new(margin + 60, y, labelHeight, "Inactive", 0.5, 0.5, 0.5, 1, UIFont.Medium, true)
    self:addChild(self.statusValueLabel)
    
    self.timerLabel = ISLabel:new(margin + 140, y, labelHeight, "Timer: --", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self:addChild(self.timerLabel)
    y = y + spacing
    
    self.coordLabel = ISLabel:new(margin, y, labelHeight, "Coordinates:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.coordLabel)
    y = y + 18
    
    self.teleportBtn = ISButton:new(margin, y, buttonWidth, buttonHeight, "Teleport", self, AdminRadZonePanel.onTeleport)
    self.teleportBtn.borderColor = {r = 0.41, g = 0.80, b = 1.0, a = 1}
    self.teleportBtn:initialise()
    self.teleportBtn:instantiate()
    self:addChild(self.teleportBtn)
    
    self.markerCoordLabel = ISLabel:new(margin + 90, y, labelHeight, "Zone", 1, 1, 0.2, 1, UIFont.Small, true)
    self:addChild(self.markerCoordLabel)
    y = y + buttonHeight + 5
    
    self.selectSquareBtn = ISButton:new(margin, y, buttonWidth + 20, buttonHeight, "Select Square", self, function() self:onXY() end)
    self.selectSquareBtn.borderColor = {r = 0.41, g = 0.80, b = 1.0, a = 1}
    self.selectSquareBtn:initialise()
    self.selectSquareBtn:instantiate()
    self:addChild(self.selectSquareBtn)
    
    self.playerCoordLabel = ISLabel:new(margin + 110, y, labelHeight, "Player", 1, 1, 0.2, 1, UIFont.Small, true)
    self:addChild(self.playerCoordLabel)
    y = y + buttonHeight + spacing
    
    local buttonY = y
    
    self.pausePlayBtn = ISButton:new(margin, buttonY, buttonWidth, buttonHeight, "PAUSE", self, AdminRadZonePanel.onPausePlay)
    self.pausePlayBtn:initialise()
    self.pausePlayBtn:instantiate()
    self:addChild(self.pausePlayBtn)
    
    self.applyBtn = ISButton:new(margin + buttonWidth + 5, buttonY, buttonWidth - 10, buttonHeight, "Apply", self, function() self:onApply() end)
    self.applyBtn:initialise()
    self.applyBtn:instantiate()
    self:addChild(self.applyBtn)
    
    y = y + buttonHeight + 10
    self.runBtn = ISButton:new(margin + buttonWidth + 5, y, buttonWidth - 10, buttonHeight, "Run", self, function() self:onRun() end)
    self.runBtn:initialise()
    self.runBtn:instantiate()
    self:addChild(self.runBtn)
    
    self.clearBtn = ISButton:new(margin, y, buttonWidth, buttonHeight, "CLEAR", self, AdminRadZonePanel.onClear)
    self.clearBtn.borderColor = {r = 1, g = 0, b = 0, a = 0.67}
    self.clearBtn:initialise()
    self.clearBtn:instantiate()
    self:addChild(self.clearBtn)
    
    self.exitBtn = ISButton:new(margin + buttonWidth * 2, y, buttonWidth - 10, buttonHeight, "Exit", self, AdminRadZonePanel.onExit)
    self.exitBtn.borderColor = {r = 1, g = 0, b = 0, a = 0.67}
    self.exitBtn:initialise()
    self.exitBtn:instantiate()
    self:addChild(self.exitBtn)
end

function AdminRadZonePanel.onRadiusChange()
    local pl = getPlayer()
    if not pl then return end 
    local sq = pl:getCurrentSquare() 
    local rad = tonumber(AdminRadZonePanel.instance.radiusEntry:getText()) or 5
    
    if sq and rad then
        if AdminRadZone.tempMarker then
            AdminRadZone.tempMarker:setSize(rad)
        end
    end
end

function AdminRadZonePanel.onRoundsChange()
    
end

function AdminRadZonePanel:onXY()
    local pl = getPlayer()
    if not pl then return end 
    
    self.tempX = round(pl:getX())
    self.tempY = round(pl:getY())
    
    AdminRadZone.tempMarker:setPos(self.tempX, self.tempY, 0)    
end

function AdminRadZonePanel.onExit()
    AdminRadZonePanel.ClosePanel()    
    if AdminRadZone.tempMarker then
        AdminRadZone.tempMarker:remove()
        AdminRadZone.tempMarker = nil
    end
end

function AdminRadZonePanel.onClear()
    AdminRadZone.clear()
end

function AdminRadZonePanel:onRun()
    self:doApply()    
    AdminRadZoneData.state = "active"
    sendClientCommand(getPlayer(), "AdminRadZone", "Run", {x=AdminRadZoneData.x, y= AdminRadZoneData.y, rad=AdminRadZoneData.rad, rounds=AdminRadZoneData.rounds})
end
function AdminRadZonePanel:doApply()
    if self.tempX and self.tempY  then
        AdminRadZoneData.x =  self.tempX
        AdminRadZoneData.y =  self.tempY
        --if AdminRadZone.marker then AdminRadZone.marker:setPos(AdminRadZoneData.x, AdminRadZoneData.y, 0) end 
    end
   if self.tempRad then
        AdminRadZoneData.rad = self.tempRad
        --if AdminRadZone.marker then AdminRadZone.marker:setSize(self.tempRad) end 
    end
    if self.tempRounds then
        AdminRadZoneData.rounds = self.tempRounds
    end    
    AdminRadZone.doTransmit(AdminRadZoneData)
end
function AdminRadZonePanel:onApply()
    self:doApply()
end

function AdminRadZonePanel.onPausePlay()
    if AdminRadZoneData.state == "pause" then
        AdminRadZoneData.state = "inactive"
    else
        AdminRadZoneData.state = "pause"
    end
    
    AdminRadZone.doTransmit(AdminRadZoneData)
end

function AdminRadZonePanel.onTeleport()
    if AdminRadZoneData.x and AdminRadZoneData.y and AdminRadZoneData.x ~= -1 and AdminRadZoneData.y ~= -1 then
        local pl = getPlayer()
        if pl then
            pl:setX(AdminRadZoneData.x)
            pl:setY(AdminRadZoneData.y)
            pl:setLx(AdminRadZoneData.x)
            pl:setLy(AdminRadZoneData.y)
            pl:setZ(0)
        end
    end
end

function AdminRadZonePanel:render()
    ISPanel.render(self)
end

AdminRadZone.panelColors = {
    ["pause"] = {r=1.0, g=0.85, b=0.2, a=0.8},         
    ["cooldown"] = {r=0.4, g=0.8, b=1.0, a=0.8},   
    ["inactive"] = {r=0.5, g=0.5, b=0.5, a=0.8},    
    ["active"] = {r=0.2, g=0.85, b=0.2, a=0.8},        
}

function AdminRadZonePanel:update()
    ISPanel.update(self)
    
    if not AdminRadZoneData then return end
    
    self.statusText = AdminRadZoneData.state or "inactive"
    self.statusColor = AdminRadZone.panelColors[AdminRadZoneData.state] or AdminRadZone.panelColors["inactive"]
    
    self.statusValueLabel.name = AdminRadZoneData.state or "inactive"
    self.statusValueLabel:setColor(self.statusColor.r, self.statusColor.g, self.statusColor.b)
    
    local pl = getPlayer()
    if pl then
        local px, py = math.floor(pl:getX()), math.floor(pl:getY())
        self.playerCoordLabel.name = "player " .. px .. " " .. py
    end
    
    local mx = AdminRadZoneData.x or -1
    local my = AdminRadZoneData.y or -1
    self.markerCoordLabel.name = "marker " .. mx .. " " .. my
    
    local startingRounds = tonumber(self.roundsEntry:getText()) or SandboxVars.AdminRadZone.DefaultRounds or 5
    local currentRound = startingRounds - (AdminRadZoneData.rounds or startingRounds) + 1
    if AdminRadZoneData.rounds <= 0 or AdminRadZoneData.state == "inactive" then
        if AdminRadZoneData.rounds == 0 then 
            currentRound = startingRounds 
        else
            currentRound = AdminRadZoneData.rounds 
        end
    end
    self.currentRoundLabel.name = "Round: " .. currentRound .. "/" .. startingRounds
    
    local currentRadius = math.floor(AdminRadZoneData.rad or 0)
    self.currentRadiusLabel.name = "Current: " .. currentRadius
    
    local inputRounds = tonumber(self.roundsEntry:getText()) or startingRounds
    local cooldownTime = SandboxVars.AdminRadZone.Cooldown or 60
    local durationTime = SandboxVars.AdminRadZone.RoundDuration or 60
    local totalTime = (inputRounds * cooldownTime) + (inputRounds * durationTime)
    
    local minutes = math.floor(totalTime / 60)
    local seconds = totalTime % 60
    local timeStr = ""
    if minutes > 0 then
        timeStr = minutes .. "m " .. seconds .. "s"
    else
        timeStr = seconds .. "s"
    end
    self.totalTimeValueLabel.name = timeStr
    
    local timerText = "--"
    if AdminRadZoneData.state == "active" and not AdminRadZoneData.pause then
        if AdminRadZoneData.duration and AdminRadZoneData.duration > 0 then
            timerText = "Shrink: " .. AdminRadZoneData.duration .. "s"
        elseif AdminRadZoneData.cooldown and AdminRadZoneData.cooldown > 0 then
            timerText = "Cool: " .. AdminRadZoneData.cooldown .. "s"
        end
    end
    self.timerLabel.name = "Timer: " .. timerText
    
    self.borderColor = self.statusColor
    self.statusIcon.backgroundColor = {r = self.statusColor.r, g = self.statusColor.g, b = self.statusColor.b, a = 0.8}

    if AdminRadZoneData.state == "pause" then
        self.pausePlayBtn:setTitle( "UnPause")
    else
        self.pausePlayBtn:setTitle("PAUSE")
    end
    if self.tempX == nil or self.tempY == nil then
        self.applyBtn.enable = false
        self.runBtn.enable = false
    else

        self.applyBtn.enable = true
        self.runBtn.enable = true
    end

    

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
        if AdminRadZone.marker and AdminRadZoneData.state ~= "active" then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
        local x = getCore():getScreenWidth() / 3
        local y = getCore():getScreenHeight() / 2 - 200
        local w = 290
        local h = 320
        AdminRadZonePanel.instance = AdminRadZonePanel:new(x, y, w, h)
        AdminRadZonePanel.instance:initialise()
    end
    AdminRadZonePanel.instance:addToUIManager()
    AdminRadZonePanel.instance:setVisible(true)
end

function AdminRadZonePanel.TogglePanel()
    if AdminRadZone.isAdm(getPlayer()) and AdminRadZonePanel.instance == nil then
        AdminRadZonePanel.OpenPanel()
    else
        AdminRadZonePanel.ClosePanel()
    end
end