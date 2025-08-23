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
    
    self.titleLabel = ISLabel:new(margin + 32, y, labelHeight, "Radiation Zone Controller", 1, 1, 1, 1, UIFont.Large, true)
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
	self.roundsEntry:setOnlyNumbers(true);
    self.roundsEntry.onTextChange = function() self:onRoundsChange() end
    self:addChild(self.roundsEntry)
    
    self.currentRoundLabel = ISLabel:new(margin + 140, y, labelHeight, "Round:", 0.8, 0.2, 0.2, 1, UIFont.Small, true)
    self:addChild(self.currentRoundLabel)
    y = y + spacing
    
    self.radiusLabel = ISLabel:new(margin, y, labelHeight, "Radius:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.radiusLabel)

    local cRad = SandboxVars.AdminRadZone.DefaultRadius or 4
    if isActive then
        cRad = AdminRadZoneData.rad
    end

    self.radSlider = ISSliderPanel:new(margin + 65, y , 65 , 10, self, function(_, v)
        self.tempRad = v
        if AdminRadZone.tempMarker then
            AdminRadZone.tempMarker:setSize(self.tempRad)
        end
        self.didChange = true
        self.currentRadiusLabel.name = "Radius: " .. tostring(self.tempRad)
    end)

    self.radSlider:initialise()
    self.radSlider:setValues(-1, 794, 1, 2.5, true) 
    self.radSlider:setCurrentValue(cRad, true)

    

    
    self:addChild(self.radSlider)

    self.currentRadiusLabel = ISLabel:new(margin + 140, y, labelHeight, "Radius: " .. tostring(cRad), 0.8, 0.2, 0.2, 1, UIFont.Small, true)
    self:addChild(self.currentRadiusLabel)
    y = y + spacing + 10

    
    self.totalTimeLabel = ISLabel:new(margin, y, labelHeight, "Total Time:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.totalTimeLabel)
    y = y + spacing 
    self.timerLabel = ISLabel:new(margin + 140, y, labelHeight, "Timer: --", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self:addChild(self.timerLabel)

    self.totalTimeValueLabel = ISLabel:new(margin, y, labelHeight, "0s", 0.2, 0.8, 1.0, 1, UIFont.Medium, true)
    self:addChild(self.totalTimeValueLabel)
    y = y + spacing +5
    
    self.statusLabel = ISLabel:new(margin, y, labelHeight, "Status:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.statusLabel)
    
    self.statusValueLabel = ISLabel:new(margin + 60, y, labelHeight, "Inactive", 0.5, 0.5, 0.5, 1, UIFont.Medium, true)
    self:addChild(self.statusValueLabel)
    

    y = y + spacing +10
    
    self.coordLabel = ISLabel:new(margin, y, labelHeight, "Coordinates:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.coordLabel)
    y = y + 18
    
    self.teleportBtn = ISButton:new(margin, y, buttonWidth, buttonHeight, "Teleport", self, AdminRadZonePanel.onTeleport)
    self.teleportBtn.borderColor = {r = 0.41, g = 0.80, b = 1.0, a = 1}
    self.teleportBtn:initialise()
    self.teleportBtn:instantiate()
    self:addChild(self.teleportBtn)
    y = y + 5
    
    self.markerCoordLabel = ISLabel:new(margin + 90, y, labelHeight, "Zone", 1, 1, 0.2, 1, UIFont.Small, true)
    self:addChild(self.markerCoordLabel)
    y = y + buttonHeight + 10
    
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

    self.tempX = round(getPlayer():getX())
    self.tempY = round(getPlayer():getY())

end
--[[ 
function AdminRadZonePanel:onRadiusChange()
    self.tempRad = tonumber(self.radiusEntry:getText()) or 5
    if AdminRadZone.tempMarker and self.tempRad then
        AdminRadZone.tempMarker:setSize(self.tempRad)
    end
    self.didChange = true
    if  AdminRadZoneData.state ~= "inactive"  then
        if AdminRadZone.marker then
            AdminRadZone.marker:setPos(self.tempX, self.tempY, 0)
        end
        AdminRadZone.doTransmit(AdminRadZoneData)
    else
        if AdminRadZone.tempMarker then
            AdminRadZone.tempMarker:setPos(self.tempX, self.tempY, 0)
        end
    end
end
 ]]

function AdminRadZonePanel:onRoundsChange()
    self.tempRounds = tonumber(self.roundsEntry:getText()) or 5
    self.didChange = true
end

function AdminRadZonePanel:onXY() 
    local pl = getPlayer()
    if not pl then return end 
    
    self.tempX = round(pl:getX())
    self.tempY = round(pl:getY())
    
    if  AdminRadZoneData.state ~= "inactive"  then
        if AdminRadZone.marker then
            AdminRadZone.marker:setPos(self.tempX, self.tempY, 0)
        end
        AdminRadZone.doTransmit(AdminRadZoneData)
    else
        if AdminRadZone.tempMarker then
            AdminRadZone.tempMarker:setPos(self.tempX, self.tempY, 0)
        end
    end
    self.didChange = true
   -- AdminRadZone.doTransmit(AdminRadZoneData)

end
function AdminRadZonePanel.onExit()
    AdminRadZonePanel.ClosePanel()    
end

function AdminRadZonePanel.onClear()
    AdminRadZone.clear()
end

function AdminRadZonePanel:onRun()
    self:doApply()    
    AdminRadZoneData.state = "active"
    AdminRadZone.doTransmit(AdminRadZoneData)
end
function AdminRadZonePanel:doApply()
    local prevState = AdminRadZoneData.state   

    if self.tempX and self.tempY  then
        AdminRadZoneData.x =  self.tempX
        AdminRadZoneData.y =  self.tempY
    end
   if self.tempRad then
       
        AdminRadZoneData.rad = self.tempRad
    end
    if self.tempRounds then
       
        AdminRadZoneData.rounds = self.tempRounds or  self.roundsEntry: getInternalText()
    end    
end
function AdminRadZonePanel:onApply()
    local prevState = AdminRadZoneData.state   
    self:doApply()
    if prevState ~= AdminRadZoneData.state then AdminRadZoneData.state = prevState  end
    AdminRadZone.doTransmit(AdminRadZoneData)
end

function AdminRadZonePanel.onPausePlay()
    
    if AdminRadZoneData.state == "pause" then
        AdminRadZoneData.state = "active"
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
    if not pl then  AdminRadZonePanel.ClosePanel() end
    local px, py = math.floor(pl:getX()), math.floor(pl:getY())
    local sq = pl:getCurrentSquare()


    self.playerCoordLabel.name = "player:\n" .. px .. "  x  " .. py
   
    
    local mx = AdminRadZoneData.x or -1
    local my = AdminRadZoneData.y or -1
    self.markerCoordLabel.name = "marker:\n" .. mx .. "  x  " .. my
    
    self.currentRoundLabel.name = "Round: " .. AdminRadZoneData.rounds
    self.tempRad = self.radSlider.currentValue or SandboxVars.AdminRadZone.DefaultRadius or 4

    local currentRadius = AdminRadZoneData.rad or SandboxVars.AdminRadZone.DefaultRadius or 4 
    self.currentRadiusLabel.name = "Current: " .. tostring(self.tempRad)
    
    self.tempRounds = tonumber(self.roundsEntry:getText())

    local cooldownTime = SandboxVars.AdminRadZone.Cooldown or 60
    local durationTime = SandboxVars.AdminRadZone.RoundDuration or 60

    
    local totalTime = (self.tempRounds * durationTime) + ((self.tempRounds - 1) * cooldownTime)
    
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
    if AdminRadZoneData.state == "active" and AdminRadZoneData.duration and AdminRadZoneData.duration > 0 then
        timerText = "Shrink: " .. AdminRadZoneData.duration .. "s"
    elseif AdminRadZoneData.state == "cooldown" and AdminRadZoneData.cooldown and AdminRadZoneData.cooldown > 0 then
        timerText = "Cool: " .. AdminRadZoneData.cooldown .. "s"
    end
    self.timerLabel.name = "Timer: " .. timerText

    
    self.borderColor = self.statusColor
    self.titleLabel:setColor(self.statusColor.r,self.statusColor.g,self.statusColor.b)
    self.pausePlayBtn.borderColor = {r = self.statusColor.r, g = self.statusColor.g, b = self.statusColor.b, a = 0.8}

    
    if AdminRadZoneData.state == "pause" then
        self.pausePlayBtn:setTitle("Unpause")
    elseif AdminRadZoneData.state == "active" then
        self.pausePlayBtn:setTitle("Pause")
    end

    self.applyBtn.enable = false
    self.runBtn.enable = false

    if self.didChange then
        self.applyBtn.enable = true
        if AdminRadZoneData.state ~= "active" and AdminRadZoneData.state ~= "cooldown" then
            self.runBtn.enable = true
        end
    end
    if AdminRadZoneData.x == -1 or  AdminRadZoneData.y == -1 then
        self.teleportBtn.enable = false
    else
        self.teleportBtn.enable = true
    end
    

    if AdminRadZoneData.state == "inactive" then
        self.pausePlayBtn.enable = false
        self.clearBtn.enable = false
    else
        self.pausePlayBtn.enable = true
        self.clearBtn.enable = true
    end

    if not AdminRadZone.tempMarker then
        if sq then
            local col = AdminRadZone.getRadColor(SandboxVars.AdminRadZone.RadColor)
            AdminRadZone.tempMarker = getWorldMarkers():addGridSquareMarker(
                "AdminRadZone_Highlight", "AdminRadZone_Highlight", sq,
                1, 0.2, 0.2, true, self.tempRad
            )
        end
    else        

    end

end


--[[ 

function AdminRadZone.updateTempMarker()
    if AdminRadZone.tempMarker then
        getWorldMarkers():remove(AdminRadZone.tempMarker)
        AdminRadZone.tempMarker = nil
    end

    if AdminRadZoneData.tempMarker then
        local t = AdminRadZoneData.tempMarker
        local sq = getCell():getGridSquare(t.x, t.y, t.z)
        if sq then
            AdminRadZone.tempMarker = getWorldMarkers():addGridSquareMarker(
                "AdminRadZone_Highlight", "", sq,
                t.r, t.g, t.b, true, 0.8
            )
        end
    end
end
 ]]
function AdminRadZonePanel.ClosePanel()
    if AdminRadZone.tempMarker then
        AdminRadZone.tempMarker:remove()
        AdminRadZone.tempMarker = nil
    end
    if AdminRadZonePanel.instance then
        AdminRadZonePanel.instance:setVisible(false)
        AdminRadZonePanel.instance:removeFromUIManager()
        AdminRadZonePanel.instance = nil
    end
end
function AdminRadZonePanel.OpenPanel()
    if not AdminRadZonePanel.instance then
        local x = getCore():getScreenWidth() / 3
        local y = getCore():getScreenHeight() / 2 - 200
        local w, h = 270, 400
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