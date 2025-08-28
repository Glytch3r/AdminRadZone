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
function AdminRadZone.doTransmit(data)
    sendClientCommand("AdminRadZone", "Sync", {data = data or AdminRadZoneData})
end
function AdminRadZone.isCanRun(x,y,rad)  
    x = x or AdminRadZoneData.x
    y = y or AdminRadZoneData.y
    rad = rad or AdminRadZoneData.rad
    return x ~= -1 and y ~= -1 and AdminRadZoneData.state == "inactive" 
end

function AdminRadZonePanel:getTempTotalTime()
    if not AdminRadZoneData then return 0 end
    local roundDuration = SandboxVars.AdminRadZone.RoundDuration or 60
    local cooldown = SandboxVars.AdminRadZone.Cooldown or 60
    local rounds = AdminRadZoneData.rounds or 0
    

    local activeTime = self.tempRounds * roundDuration
    local cooldownTime = math.max(0, self.tempRounds - 1) * cooldown

    return activeTime + cooldownTime
end

function AdminRadZonePanel:initialise()
    ISPanel.initialise(self)
    local col = AdminRadZone.getMarkerColor(1)

    self.didChange = AdminRadZoneData.x  and AdminRadZoneData.y and AdminRadZoneData.x ~= -1  and AdminRadZoneData.y ~= -1
    local running = AdminRadZone.isShouldShowMarker()
    local data = AdminRadZoneData
    local isActive = data.state == "active"
    
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
    


    
    self.statusLabel = ISLabel:new(margin, y, labelHeight, "Status:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.statusLabel)
    
    self.statusValueLabel = ISLabel:new(margin + 60, y, labelHeight, "Inactive", 0.5, 0.5, 0.5, 1, UIFont.Large, true)
    self:addChild(self.statusValueLabel)
    
    y = y + spacing +20



    self.roundsLabel = ISLabel:new(margin, y, labelHeight, "Rounds:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.roundsLabel)


    self.tempRounds = AdminRadZoneData.rounds or SandboxVars.AdminRadZone.DefaultRounds  or 5


    self.roundsEntry = ISTextEntryBox:new(tostring(self.tempRounds), margin + 60, y - 2, entryWidth, 18)
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
    -----------------------            ---------------------------
--[[ 
    self.tempRad = AdminRadZoneData.rad or SandboxVars.AdminRadZone.DefaultRadius or 4
    self.radSlider = ISSliderPanel:new(margin + 65, y+2, 65, 10, self, function(_, value)
        self.tempRad = value  -- Set tempRad first
        
        if AdminRadZone.tempMarker and data.state == "inactive" then
            AdminRadZone.tempMarker:setSize(self.tempRad)
        end
        if AdminRadZone.marker then
            AdminRadZoneData.rad = self.tempRad
            AdminRadZone.marker:setSize(self.tempRad)
            ModData.transmit('AdminRadZoneData')
        end
        
        self.didChange = true
        self.currentRadiusLabel.name = "Radius: " .. tostring(math.floor(value))
    end)
 ]]
    -----------------------            ---------------------------
    self.radSlider = ISSliderPanel:new(margin + 65, y+2, 65, 10, self, function(_, value)
        self.tempRad = value
        self.didChange = AdminRadZone.isCanRun(x,y,self.tempRad) 

        local data = AdminRadZoneData
        if data then
            if AdminRadZone.marker then
                AdminRadZoneData.rad = value
                --AdminRadZone.marker:setSize(self.tempRad)
                ModData.transmit('AdminRadZoneData')
            end
        end
        --self.currentRadiusLabel.name = "Radius: " .. tostring(math.floor(value))
    end)
    self:addChild(self.radSlider)

    self.tempRad = AdminRadZoneData.rad or SandboxVars.AdminRadZone.DefaultRadius or 4

    self.radSlider.currentValue = self.tempRad
    self.radSlider:setValues(1, 7940, 1, 5)

    self.radSlider:setCurrentValue(self.tempRad)



    self.currentRadiusLabel = ISLabel:new(margin + 140, y, labelHeight, "Radius: " .. tostring(self.tempRad), 0.8, 0.2, 0.2, 1, UIFont.Small, true)
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
    
    self.selectSquareBtn = ISButton:new(margin, y, buttonWidth + 20, buttonHeight, "Select Square", self, function()   
        local pl = getPlayer()
        if not pl then return end 
        
        AdminRadZoneData.x = round(pl:getX())
        AdminRadZoneData.y = round(pl:getY())
        
        if AdminRadZone.marker then
            AdminRadZone.marker:setPos(AdminRadZoneData.x, AdminRadZoneData.y, 0)
        end
        self.didChange = true
        self.markerCoordLabel.name = "Zone:\n" .. tostring(AdminRadZoneData.x) .. "  x  " .. tostring(AdminRadZoneData.y)    
        ModData.transmit('AdminRadZoneData')
    
    end)
    self.selectSquareBtn.borderColor = {r = 0.41, g = 0.80, b = 1.0, a = 1}
    self.selectSquareBtn:initialise()
    self.selectSquareBtn:instantiate()
    self:addChild(self.selectSquareBtn)
    
    self.playerCoordLabel = ISLabel:new(margin + 110, y, labelHeight, "Player", 1, 1, 0.2, 1, UIFont.Small, true)
    self:addChild(self.playerCoordLabel)
    y = y + buttonHeight + spacing
    
    local buttonY = y
    
    self.pausePlayBtn = ISButton:new(margin, buttonY, buttonWidth, buttonHeight, "PAUSE", self, function() self:onPausePlay()  end)
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
    
    self.clearBtn = ISButton:new(margin, y, buttonWidth, buttonHeight, "CLEAR", self, AdminRadZone.clear)
    self.clearBtn.borderColor = {r = 1, g = 0, b = 0, a = 0.67}
    self.clearBtn:initialise()
    self.clearBtn:instantiate()
    self:addChild(self.clearBtn)
    
    self.exitBtn = ISButton:new(margin + buttonWidth * 2, y, buttonWidth - 10, buttonHeight, "Exit", self, AdminRadZonePanel.onExit)
    self.exitBtn.borderColor = {r = 1, g = 0, b = 0, a = 0.67}
    self.exitBtn:initialise()
    self.exitBtn:instantiate()
    self:addChild(self.exitBtn)


    self.boundsLabel = ISLabel:new(margin + buttonWidth * 2+5, y-buttonHeight-5, labelHeight, "OUT OF BOUNDS", 1, 0, 0, 0, UIFont.Small, true)
    self:addChild(self.boundsLabel)


    AdminRadZoneData.x = AdminRadZoneData.x or -1
    AdminRadZoneData.y = AdminRadZoneData.y or -1
    if AdminRadZoneData.x ~=  -1 and AdminRadZoneData.y ~=  -1 then
        self.didChange = true
    end
end
function AdminRadZonePanel:onRoundsChange()
    
    self.tempRounds = self.roundsEntry:getText()
    self.didChange = true
end
function AdminRadZonePanel.onExit()
    AdminRadZonePanel.ClosePanel()    
end

function AdminRadZonePanel:onRun()

    --local running = AdminRadZone.showStates[AdminRadZoneData.state]
    if AdminRadZoneData.state == 'inactive' or AdminRadZoneData.state == 'cooldown'  then
        AdminRadZoneData.state = "active"
        AdminRadZoneData.run = true
        AdminRadZone.startZone(AdminRadZoneData)
    end
    --ModData.transmit('AdminRadZoneData')
end
function AdminRadZonePanel:onApply()
    
    AdminRadZoneData.x = AdminRadZoneData.x or -1
    AdminRadZoneData.y = AdminRadZoneData.y or -1
    AdminRadZoneData.rad = self.tempRad   or AdminRadZoneData.rad 
    AdminRadZoneData.rounds = self.tempRounds    or AdminRadZoneData.rounds 
    AdminRadZoneData.duration = 0
    AdminRadZoneData.cooldown = 0
    
    AdminRadZoneData.run = AdminRadZoneData.run or AdminRadZoneData.state == "active"

    if AdminRadZoneData.rounds <= 0 or AdminRadZoneData.x == -1 or AdminRadZoneData.y == -1 then
        AdminRadZoneData.state = "inactive"
        AdminRadZoneData.rounds = self.tempRounds
    end    

    AdminRadZoneData.roundsTotal = tostring(AdminRadZoneData.rounds) 
    AdminRadZoneData.radTotal  = tostring(AdminRadZoneData.rad) 


    AdminRadZone.updateServer(AdminRadZoneData)
    --AdminRadZone.doTransmit(AdminRadZoneData)
    ModData.transmit('AdminRadZoneData')
    self.didChange = true
end
function AdminRadZonePanel.onPausePlay()
    if AdminRadZoneData.state == "pause" then
        AdminRadZoneData.state = "active"
    else
        AdminRadZoneData.state = "pause"
    end
    ModData.transmit('AdminRadZoneData')

    --AdminRadZone.doTransmit(AdminRadZoneData)
end
function AdminRadZonePanel.onTeleport()
    getSoundManager():playUISound("UIActivateButton")
    local running = AdminRadZone.isShouldShowMarker()
    local data = running and AdminRadZoneData 
    
    if data.x and data.y and data.x ~= -1 and data.y ~= -1 then
        local pl = getPlayer()
        if pl then
            pl:setX(data.x)
            pl:setY(data.y)
            pl:setLx(data.x)
            pl:setLy(data.y)
            pl:setZ(0)
        end
    end
end
function AdminRadZonePanel:render()
    ISPanel.render(self)
end

AdminRadZone.panelColors = {
    ["pause"] = { r = 0.99, g = 0.49, b = 0.00, a=0.8},      
    ["cooldown"] = {r = 0.09, g = 0.52, b = 0.82, a=0.8},    
    ["inactive"] = {r = 0.52, g = 0.52, b = 0.62, a=0.8},    
    ["active"] = { r = 0.46, g = 0.84, b = 0.49, a=0.8},        
}
-----------------------            ---------------------------
function AdminRadZonePanel.ClosePanel()
    if AdminRadZonePanel.instance then
        AdminRadZone.forceSwap = true
        if AdminRadZone.marker and AdminRadZoneData.state == 'inactive' then
            AdminRadZone.marker:remove()
            AdminRadZone.marker = nil
        end
        AdminRadZonePanel.instance:setVisible(false)
        AdminRadZonePanel.instance:removeFromUIManager()
        AdminRadZonePanel.instance = nil
    end
end
function AdminRadZonePanel.OpenPanel()
    if not AdminRadZonePanel.instance then
        AdminRadZone.forceSwap = true
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
-----------------------            ---------------------------
function AdminRadZonePanel:update()
    ISPanel.update(self)
    local running = AdminRadZone.isShouldShowMarker()
    if not AdminRadZoneData then return end
    if not AdminRadZoneData then AdminRadZoneData = {} end
     -----------------------            ---------------------------
    local state = AdminRadZoneData.state 
    local liveData = AdminRadZoneData
    local tempData = AdminRadZoneData
    local data = AdminRadZoneData
    AdminRadZoneData.rad = AdminRadZoneData.rad or SandboxVars.AdminRadZone.DefaultRadius or 4
    -----------------------            ---------------------------
    self.statusText = state
    self.statusColor = AdminRadZone.panelColors[state] or AdminRadZone.panelColors["inactive"]
    self.statusValueLabel.name = state or "inactive"
    self.statusValueLabel:setColor(self.statusColor.r, self.statusColor.g, self.statusColor.b)
    local pl = getPlayer()
    if not pl or not AdminRadZone.isAdm(pl)  then AdminRadZonePanel.ClosePanel() end
    local px, py = round(pl:getX()), round(pl:getY())
    self.playerCoordLabel.name = "Player:\n" .. px .. "  x  " .. py
    local durationTime = AdminRadZoneData.duration or 0
    local totalTime = AdminRadZone.getTotalTime() --AdminRadZoneData.totalTime or ( ( (AdminRadZoneData.rounds or 1) * durationTime) + ((AdminRadZoneData.rounds or 1) - 1) * AdminRadZoneData.cooldown )
    -----------------------            ---------------------------
    -----------------------            ---------------------------


    local timerText = "--"
    if data.state == "active" then
        local dur = tostring(SandboxVars.AdminRadZone.RoundDuration - data.duration) ..'  /  '.. tostring(SandboxVars.AdminRadZone.RoundDuration)
        timerText = "Shrink: " .. tostring(dur) 

        --timerText = "Shrink: " .. tostring(data.duration) .. "s"
    elseif data.state == "cooldown" then
        timerText = "Cool: " .. tostring(data.cooldown or 0) .. "s"
    end
    local minutes = math.floor(totalTime / 60)
    local seconds = totalTime % 60
    local timeStr = (minutes > 0) and (minutes .. "m " .. seconds .. "s") or (seconds .. "s")
    -----------------------            ---------------------------
    self.tempRounds = tonumber(self.roundsEntry:getText()) or SandboxVars.AdminRadZone.DefaultRounds  or 5
    
    self.totalTimeValueLabel.name = timeStr
    self.markerCoordLabel.name = "Zone:\n" .. tostring(AdminRadZoneData.x or -1) .. "  x  " .. tostring(AdminRadZoneData.y or -1)    
    -----------------------            ---------------------------

    local roundsTotal = ""
    local radTotal = ""
    if AdminRadZoneData.run then
        if AdminRadZoneData.roundsTotal then roundsTotal = tostring(AdminRadZoneData.roundsTotal) end
        if AdminRadZoneData.radTotal then radTotal = tostring(AdminRadZoneData.radTotal) end
    end
    

    if data.state ~= "inactive" then
        self.currentRoundLabel.name = "Rounds: " .. tostring(AdminRadZoneData.rounds) 
        self.currentRadiusLabel.name = "Radius: " .. tostring(round(tonumber(AdminRadZoneData.rad),3))
    else
        self.currentRoundLabel.name = "Rounds: " .. tostring(self.tempRounds or AdminRadZoneData.rounds )
        self.currentRadiusLabel.name = "Radius: " .. tostring(self.tempRad or round(AdminRadZoneData.rad,2))
    end

    if AdminRadZoneData.run and not  AdminRadZoneData.state == "cooldown" then
        self.currentRoundLabel.name = self.currentRoundLabel.name .." / "..tostring(roundsTotal)
        self.currentRadiusLabel.name = self.currentRadiusLabel.name .." / "..tostring(currentRadiusLabel)
    end
    

    self.borderColor = self.statusColor

    self.timerLabel.name = "Timer:\n" .. timerText
    self.timerLabel:setColor(self.statusColor.r, self.statusColor.g, self.statusColor.b)

    if AdminRadZoneData.x == -1 and AdminRadZoneData.y == -1 then
        self.markerCoordLabel:setColor(1, 0, 0)        
        self.timerLabel:setColor(1, 0, 0)      
    else
        self.markerCoordLabel:setColor(1,1,1)
        self.timerLabel:setColor(1,1,1)
    end


    self.titleLabel:setColor(self.statusColor.r, self.statusColor.g, self.statusColor.b)
    self.pausePlayBtn.borderColor = {r = self.statusColor.r, g = self.statusColor.g, b = self.statusColor.b, a = 0.8}
    -----------------------            ---------------------------
    if data.state == "pause" then
        self.pausePlayBtn:setTitle("UNPAUSE")
        self.pausePlayBtn.enable = true
    elseif data.state == "active" or state == "cooldown" then
        self.pausePlayBtn:setTitle("PAUSE")
        self.pausePlayBtn.enable = true
    else            
        self.pausePlayBtn:setTitle("PAUSE")
        self.pausePlayBtn.enable = false
    end
    
    -----------------------            ---------------------------
    if not AdminRadZoneData.run then
        self.pausePlayBtn:setTitle("PAUSE")
        self.pausePlayBtn.enable = false
    end

    -----------------------            ---------------------------
    self.runBtn.enable = false
    if  AdminRadZoneData.x ~= -1 and not AdminRadZoneData.y ~= -1 then
        self.applyBtn.borderColor = {r = self.statusColor.r, g = self.statusColor.g, b = self.statusColor.b, a = 0.8}
        self.applyBtn.enable = true        
        self.teleportBtn.enable = true
        self.runBtn.enable = data.state == "cooldown" or data.state == "inactive"
    
        if data.state == "cooldown" then
            self.runBtn:setTitle("Continue")
            self.runBtn.enable = true
        elseif data.state == "active" or  data.state == "pause"  then
            self.runBtn:setTitle("Run")
            self.runBtn.enable = false
        else
            self.runBtn:setTitle("Run")
            self.runBtn.enable = true
        end
        
    else
        self.runBtn.enable = false 
        self.applyBtn.enable = false
    end



    -----------------------            ---------------------------
	self.statusIcon.backgroundColor.r = self.borderColor.r;
	self.statusIcon.backgroundColor.g = self.borderColor.g;
	self.statusIcon.backgroundColor.b = self.borderColor.b;
-----------------------            ---------------------------
    self.boundsLabel.name = AdminRadZone.getBoundStr(pl)

    if not AdminRadZoneData.run then
        self.boundsLabel.a = 0
        self.boundsLabel.backgroundColor.a = 0
    else
        self.boundsLabel.a = 1
        self.boundsLabel.backgroundColor.r = 1
        if AdminRadZone.isOutOfBound(pl)  then  
            self.boundsLabel.r = 1
            self.boundsLabel.g = 0
            self.boundsLabel.backgroundColor.r = 1
            self.boundsLabel.backgroundColor.r = 1
        else
            self.boundsLabel.r = 0
            self.boundsLabel.g = 1
            self.boundsLabel.backgroundColor.r = 0
            self.boundsLabel.backgroundColor.a = 1
        end
    end

end


