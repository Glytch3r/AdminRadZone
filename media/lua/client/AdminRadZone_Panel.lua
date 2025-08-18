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


AdminRadZone.point1 = nil
AdminRadZone.point2 = nil
function AdminRadZone.setPoint(sq, int)
    local pl = getPlayer(); if not pl then return end 
    int = int or 1
    if int == 2 then
        AdminRadZone.point2 = pl:getCurrentSquare() 
    else
        AdminRadZone.point1 = pl:getCurrentSquare() 
    end
end


function AdminRadZone.setRadZoneMarker(targRad, targSq, seconds)
    local pl = getPlayer()
    local sq = targSq or pl:getSquare()
    local rad = targRad or (SandboxVars.AdminRadZone.DefaultRadius or 50)
    local sec = seconds or 5
    AdminRadZone.doMarkerSteps(rad, sq, sec)
end

function AdminRadZone.demo()
    AdminRadZone.setRadZoneMarker(100, getPlayer():getSquare(), 5)
end


function AdminRadZone.getRadiusFromSquares(sq1, sq2)
    if not sq1 or not sq2 then return 0 end
    local dx = sq2:getX() - sq1:getX()
    local dy = sq2:getY() - sq1:getY()
    return math.sqrt(dx * dx + dy * dy)
end


 ----------------------------------------------------------------

--[[




MiniToolkitPanel = MiniToolkitPanel or {}
MiniToolkitPanel.__index = MiniToolkitPanel
  
function MiniToolkitPanel:setTitle(newTitle) 
    if self.window then
        self.window:setTitle(newTitle or self.title)
    end
end

function MiniToolkitPanel:new(x, y, width, height, title)
    local o = ISCollapsableWindow.new(self, x, y, width, height)
    o.buttons = {}
    o.rows = {}
    o.buttonSize = 42
    o.spacing = 2
    o.bgColor = {r=0.1,g=0.1,b=0.1,a=0.8}
    o.x = x
    o.y = y
    o.title = title or "Mini Toolkit"
    o.updateTimer = 0
    o.updateInterval = 30
    o.window = nil
    o:buildWindow()
    return o
end

function MiniToolkitPanel:addFeature(textFunc, callback, sprite, colorFunc, rowIndex, featureId)
    rowIndex = rowIndex or 1
    self.rows[rowIndex] = self.rows[rowIndex] or {}
    local btn = {
        textFunc = textFunc,
        callback = callback,
        sprite = sprite,
        colorFunc = colorFunc,
        active = false,
        tooltipFunc = nil,
        featureId = featureId,
        toggle = false
    }
    table.insert(self.rows[rowIndex], btn)
end

function MiniToolkitPanel:refreshButtons()
    if not self.window then return end
    
    local childrenToRemove = {}
    for i = 1, #self.window.children do
        local child = self.window.children[i]
        if child ~= self.window.closeButton then
            table.insert(childrenToRemove, child)
        end
    end
    
    for _, child in ipairs(childrenToRemove) do
        self.window:removeChild(child)
        if child.destroy then child:destroy() end
    end
    
    self.window:clearChildren()
    if self.window.closeButton then
        self.window:addChild(self.window.closeButton)
    end
    
    local th = self.window:titleBarHeight()
    local yOffset = th
    local maxWidth = 0
    
    for rowIndex = 1, 10 do
        local row = self.rows[rowIndex]
        if row and #row > 0 then
            local xOffset = 4
            for _, btn in ipairs(row) do
                if btn then
                    local b = ISButton:new(xOffset, yOffset, self.buttonSize, self.buttonSize, "", nil, nil)
                    b:initialise()
                    b.borderColor = {r=0,g=0,b=0,a=0}
                    
                    local bgColor
                    if type(btn.colorFunc) == "function" then
                        bgColor = btn.colorFunc()
                    else
                        bgColor = btn.colorFunc
                    end
                    b.backgroundColor = bgColor or {r=0,g=0,b=0,a=0}
                    b.backgroundColorMouseOver = {r=0,g=1,b=0,a=1}
                    
                    if btn.sprite then b:setImage(getTexture(btn.sprite)) end
                    
                    local tooltip = nil
                    if btn.tooltipFunc then
                        tooltip = btn.tooltipFunc()
                    elseif btn.tooltip then
                        tooltip = btn.tooltip
                    else
                        tooltip = btn.textFunc and btn.textFunc() or ""
                    end
                    if tooltip and tooltip ~= "" then 
                        b:setTooltip(tooltip) 
                    end
                    
                    b:setOnClick(function(button)
                        if btn.toggle then
                            btn.active = not btn.active
                            local newColor = type(btn.colorFunc) == "function" and btn.colorFunc() or btn.colorFunc
                            button.backgroundColor = newColor or {r=0,g=0,b=0,a=0}
                        end
                        if btn.callback then btn.callback() end
                    end)
                    
                    self.window:addChild(b)
                    xOffset = xOffset + self.buttonSize + self.spacing
                end
            end
            maxWidth = math.max(maxWidth, xOffset + 4)
            yOffset = yOffset + self.buttonSize + self.spacing
        end
    end
    
    self.window:setWidth(maxWidth)
    self.window:setHeight(yOffset + 4)
    
    if self.window.NewTitle and self.window.NewTitle ~= "" then
        self:setTitle(self.window.NewTitle)
    end
end

function MiniToolkitPanel:buildWindow()
    local minWidth = math.max(160, #self.title*8 + 50)
    self.window = ISCollapsableWindow:new(self.x, self.y, minWidth+15, self.buttonSize + 20)
    self.window.collapseButton = nil
    
    function self.window:createChildren()
        ISCollapsableWindow.createChildren(self)
        if self.collapseButton then
            self:removeChild(self.collapseButton)
            self.collapseButton = nil
        end
        if self.closeButton then
            self:removeChild(self.closeButton)
            self.closeButton = nil
        end
    end
    
    function self.window:update()
        ISCollapsableWindow.update(self)
        if self.panelRef and self.panelRef.onUpdate then
            self.panelRef:onUpdate()
        end
    end
    
    self.window:initialise()
    if self.window.closeButton then
        self.window.closeButton:setVisible(false);
    end
    self.window:addToUIManager()
    self.window.resizable = false
    self.window:setTitle(self.title)
    self.window.defaultTitle = self.title
    self.window:setHeight(self.buttonSize + self.window:titleBarHeight())
    self.window.panelRef = self
end

function MiniToolkitPanel:updateZoneData()
    local zones = NonPvpZone.getAllZones()
    local total = zones:size()
    if total > 0 then
        if not AdminRadZone.selectedIndex or AdminRadZone.selectedIndex >= total then
            AdminRadZone.selectedIndex = 0
        end
        AdminRadZone.selected = zones:get(AdminRadZone.selectedIndex)
    else
        AdminRadZone.selected = nil
        AdminRadZone.selectedIndex = 0
    end


    self:refreshButtons()
end

-----------------------            ---------------------------
function MiniToolkitPanel.prevZone()
    local zones = NonPvpZone.getAllZones()
    local total = zones:size()
    if total == 0 then return end
    AdminRadZone.selectedIndex = (AdminRadZone.selectedIndex - 1 + total) % total
    AdminRadZone.selected = zones:get(AdminRadZone.selectedIndex)
end

function MiniToolkitPanel.nextZone()
    local zones = NonPvpZone.getAllZones()
    local total = zones:size()
    if total == 0 then return end
    AdminRadZone.selectedIndex = (AdminRadZone.selectedIndex + 1) % total
    AdminRadZone.selected = zones:get(AdminRadZone.selectedIndex)
end
-----------------------            ---------------------------
function MiniToolkitPanel:update()
    print('update')
    for _, row in pairs(self.rows) do
        for _, btn in ipairs(row) do
            if btn.tooltipFunc then
                btn.tooltip = btn.tooltipFunc()
            end
            if btn.colorFunc then
                btn.activeColor = btn.colorFunc()
            end
        end
    end
    self:refreshButtons()
end

function MiniToolkitPanel:close()
    if self.window then
        self.window:close()
        self.window = nil
    end
end

function MiniToolkitPanel:isVisible()
    return self.window ~= nil
end

function MiniToolkitPanel:show()
    if not self.window then
        self:buildWindow()
        self:refreshButtons()
    end
end

function MiniToolkitPanel:hide()
    self:close()
end

function MiniToolkitPanel:clearRow(rowIndex)
    if self.rows[rowIndex] then
        self.rows[rowIndex] = nil
        self:refreshButtons()
    end
end

function MiniToolkitPanel:toggleRow(rowIndex)
    if self.rows[rowIndex] then
        self.rows[rowIndex] = nil
    else
        self.rows[rowIndex] = {}
    end
    self:refreshButtons()
end

function MiniToolkitPanel:toggleFeature(featureId, targetRow)
    targetRow = targetRow or 2
    
    --print("Toggling feature: " .. featureId .. ", current active: " .. tostring(self.activeFeature))
    
    if self.activeFeature == featureId then
    
        --print("Hiding feature: " .. featureId)
        self.rows[targetRow] = nil
        self.activeFeature = nil
    else
    
        --print("Switching to feature: " .. featureId)
        self.rows[targetRow] = nil  
        self.activeFeature = featureId
        self.rows[targetRow] = {} 
        
        if self.featureCallbacks and self.featureCallbacks[featureId] then
            self.featureCallbacks[featureId](self, targetRow)
        end
    end
    
    for i, row in pairs(self.rows) do
        if row then
            --print("Row " .. i .. " has " .. #row .. " buttons")
        end
    end
    
    self:refreshButtons()
end

function MiniToolkitPanel:addFeatureCallback(featureId, callback)
    self.featureCallbacks = self.featureCallbacks or {}
    self.featureCallbacks[featureId] = callback
end

MiniToolkitPanel.instances = MiniToolkitPanel.instances or {}

function MiniToolkitPanel.Launch()
    local pl = getPlayer()
    if not pl then return end


    if AdminRadZone.AreaMarkers then
        AdminRadZone.delAreaMarkers(AdminRadZone.AreaMarkers)
        AdminRadZone.AreaMarkers = {}
    end



    AdminRadZone.FirstPoint = nil
    AdminRadZone.SecondPoint = nil
    AdminRadZone.BuildStr = "Stand on Starting Point"
    AdminRadZone.fencedTitle = nil
    AdminRadZone.stage = 0
    if MiniToolkitPanel.panel1 and MiniToolkitPanel.panel1:isVisible() then
        MiniToolkitPanel.panel1:close()
        MiniToolkitPanel.panel1 = nil
        return
    end
    
    MiniToolkitPanel.panel1 = MiniToolkitPanel:new(getCore():getScreenWidth() / 3, getCore():getScreenHeight() / 3, 200, 100, "Mini Toolkit")
    table.insert(MiniToolkitPanel.instances, MiniToolkitPanel.panel1)
    function MiniToolkitPanel.step()
        AdminRadZone.AreaSq = nil
        MiniToolkitPanel:updateZoneData()
        MiniToolkitPanel.panel1:toggleFeature("AdminRadZoneUI", 2)
        MiniToolkitPanel.panel1:toggleFeature("AdminRadZoneUI", 2)
    end
    MiniToolkitPanel:updateZoneData()

    MiniToolkitPanel.panel1:addFeature(
        function() return "Admin Fence" end,
        function()
            MiniToolkitPanel.panel1:toggleFeature("AdminRadZoneUI", 2)
        end,
        "media/ui/LootableMaps/map_trap.png",
        nil,
        1,
        "AdminRadZoneUI"
    )
    
    MiniToolkitPanel.panel1:addFeature(
        function() return "Under Construction" end,
        function()
            MiniToolkitPanel.panel1:toggleFeature("feature2", 2)
        end,
        "media/ui/LootableMaps/map_skull.png",
        nil,
        1,
        "feature2"
    )
    -----------------------            ---------------------------
    
    local cred = "Modded by:\nGlytch3r\n\nCommissioned by:\nProject One/Life Server"
    MiniToolkitPanel.panel1:addFeature(
        function() return "Credits" end,
        function()
            pl:setHaloNote(tostring(cred), 111, 219, 21, 260)
            pl:playSoundLocal("BreakFishingLine")
        end,
        "media/ui/LootableMaps/map_star.png",
        nil,
        1
    )
    
    MiniToolkitPanel.panel1:addFeature(
        function() return "Exit" end,
        function()
            MiniToolkitPanel.Launch()
        end,
        "media/ui/LootableMaps/map_x.png",
        nil,
        1
    )
    -----------------------            ---------------------------
    MiniToolkitPanel.panel1:addFeatureCallback("AdminRadZoneUI", function(panel, row)


        panel:addFeature(
            function() return "Zone Visibility " .. tostring(pl:isSeeNonPvpZone()) end,
            function()
                pl:setSeeNonPvpZone(not pl:isSeeNonPvpZone()) 
                MiniToolkitPanel.step()
            end,
            "media/ui/LootableMaps/map_target.png",
            function()
                return pl:isSeeNonPvpZone() and {r=0.5,g=0.91,b=0.32,a=1} or {r=0.5,g=0,b=0,a=1}
            end,
            row
        )


        panel:addFeature(
            function()
                if AdminRadZone.selected then
                    local cx,cy=AdminRadZone.getCenter(AdminRadZone.selected:getX(), AdminRadZone.selected:getY(), AdminRadZone.selected:getX2(), AdminRadZone.selected:getY2())

                    return "Teleport to Zone " .. tostring(cx) .. "," .. tostring(cy)
                else
                    return "Teleport (No Zone Selected)"
                end
            end,
            function()
                if AdminRadZone.selected then
                    local cx,cy=AdminRadZone.getCenter(AdminRadZone.selected:getX(), AdminRadZone.selected:getY(), AdminRadZone.selected:getX2(), AdminRadZone.selected:getY2())

                    SendCommandToServer("/teleportto " ..tostring(round(cx)) .. "," .. tostring(round(cy)) .. ",0")
                    pl:playSoundLocal("RemoveBarricadeMetal")
                end
            end,
            "media/ui/LootableMaps/map_asterisk.png",
            nil,
            row
        )

        panel:addFeature(
            function() return "Add Fence" end,
            function()
                if AdminRadZone.selected then
                    AdminRadZone.setZoneFence(AdminRadZone.selected, true)
                end
            end,
            "media/ui/LootableMaps/map_medcross.png",
            nil,
            row
        )
        -----------------------            ---------------------------
        
        panel:addFeature(
            function() return "Remove Fence" end,
            function()
                if AdminRadZone.selected then
                    AdminRadZone.setZoneFence(AdminRadZone.selected, false)
                    pl:playSoundLocal("ForkBreak")
                end
            end,
            "media/ui/LootableMaps/map_garbage.png",
            nil,
            row
        )

        local thisZone = NonPvpZone.getNonPvpZone(pl:getX(), pl:getY())
        local zoneTitle = "" 

        if thisZone then
           zoneTitle = thisZone:getTitle()
        end

        panel:addFeature(
            function() return "Remove Fenced Zone\n"..   tostring(zoneTitle) end,
            function()
                if thisZone and zoneTitle then
                    AdminRadZone.setZoneFence(zoneTitle, false)
                    NonPvpZone.removeNonPvpZone(zoneTitle);
                    pl:playSoundLocal("BreakBarricadeMetal")
                    pl:addLineChatElement(tostring(zoneTitle).." Deleted")
                else
                    pl:addLineChatElement("Stand on a zone to use this button")
                end
                MiniToolkitPanel.step()
            end,
            "media/ui/LootableMaps/map_garbage.png",
            nil,
            row
        )
        -----------------------            ---------------------------
        panel:addFeature(
            function()
                return "Zone Recovery " .. (AdminRadZone.isSafeZoneRecover() and "[ON]" or "[OFF]")
            end,
            function()
                AdminRadZone.setSafeZoneRecover(not AdminRadZone.isSafeZoneRecover())
     
            end,
            "media/ui/LootableMaps/map_heart.png",
            function()
                return AdminRadZone.isSafeZoneRecover() and {r=0.5,g=0.91,b=0.32,a=1} or {r=0.5,g=0,b=0,a=1}
            end,
            row
        )

        panel:addFeature(
            function() return "Previous Zone" end,
            function()
                MiniToolkitPanel.prevZone()
                if AdminRadZone.selected then
                    MiniToolkitPanel.panel1:setTitle("AdminRadZone: " .. AdminRadZone.selected:getTitle())
                    pl:addLineChatElement(AdminRadZone.selected:getTitle())
                    pl:playSoundLocal("StakeBreak")
                end
            end,
            "media/ui/LootableMaps/map_arrowwest.png",
            nil,
            row
        )
        

        panel:addFeature(
            function() return "Next Zone" end,
            function()
                MiniToolkitPanel.nextZone()
                if AdminRadZone.selected then
                    MiniToolkitPanel.panel1:setTitle("AdminRadZone: " .. AdminRadZone.selected:getTitle())
                    pl:addLineChatElement(AdminRadZone.selected:getTitle())
                    pl:playSoundLocal("StakeBreak")
                end
            end,
            "media/ui/LootableMaps/map_arroweast.png",
            nil,
            row
        )

  

        if AdminRadZone.fencedTitle and AdminRadZone.FirstPoint and AdminRadZone.SecondPoint  then
            AdminRadZone.FirstPoint  = nil
            AdminRadZone.SecondPoint = nil
            AdminRadZone.fencedTitle = nil
            AdminRadZone.BuildStr = "Stand on Starting Point"
        end
        local buildIco = "media/ui/XBOX_A.png"
        local point1 = AdminRadZone.FirstPoint  or nil
        local point2 = AdminRadZone.SecondPoint or nil
        
        if point2 and point1 and not AdminRadZone.fencedTitle then
            AdminRadZone.stage = 3
            buildIco = "media/ui/LootableMaps/map_diamond.png"
        elseif point1 and not point2 and not AdminRadZone.fencedTitle then
            AdminRadZone.stage = 2
            buildIco = "media/ui/XBOX_B.png"
        elseif not point1 and not point2 and not AdminRadZone.fencedTitle then
            AdminRadZone.stage = 1
            buildIco = "media/ui/XBOX_A.png"
        end
            
        if AdminRadZone.stage == 0 then
                    
            if AdminRadZone.AreaMarkers then
                AdminRadZone.delAreaMarkers(AdminRadZone.AreaMarkers)
                AdminRadZone.AreaMarkers = {}
            end

        end

        panel:addFeature(
            function() return "Fenced Zone\n"..tostring(AdminRadZone.BuildStr) end,
            function()
                if AdminRadZone.stage == 3 then
                    local point1 = AdminRadZone.FirstPoint
                    local point2 = AdminRadZone.SecondPoint
                    if point1 and point2 then
                        local x1, y1 = round(point1:getX()), round(point1:getY())
                        local x2, y2 = round(point2:getX()), round(point2:getY())
                        AdminRadZone.fencedTitle = "Zone #" .. tostring(NonPvpZone.getAllZones():size() + 1) .. " [Fenced]"
                        NonPvpZone.addNonPvpZone(AdminRadZone.fencedTitle, x1, y1, x2, y2)
                        AdminRadZone.selected = NonPvpZone.getZoneByTitle(AdminRadZone.fencedTitle)
                        AdminRadZone.doFence(x1, y1, x2, y2, pl:getZ(), true)
                        pl:addLineChatElement("Added: " .. AdminRadZone.fencedTitle)
                        pl:playSoundLocal("StakeBreak")
                    end
                    AdminRadZone.stage = 0
                    AdminRadZone.FirstPoint = nil
                    AdminRadZone.SecondPoint = nil
                    AdminRadZone.fencedTitle = nil
                    AdminRadZone.BuildStr = "Stand on Starting Point"
                    if AdminRadZone.AreaMarkers then
                        AdminRadZone.delAreaMarkers(AdminRadZone.AreaMarkers)
                        AdminRadZone.AreaMarkers = {}
                    end
                    MiniToolkitPanel.step()

                elseif AdminRadZone.stage == 2 then
                    AdminRadZone.SecondPoint = pl:getCurrentSquare()
                    local p1 = AdminRadZone.FirstPoint
                    local p2 = AdminRadZone.SecondPoint
                    if p1 and p2 then
                        local x1, y1 = round(p1:getX()), round(p1:getY())
                        local x2, y2 = round(p2:getX()), round(p2:getY())
                        AdminRadZone.AreaSq = AdminRadZone.getFenceEdgeSquares(x1, y1, x2, y2)
                        if AdminRadZone.AreaSq then
                            AdminRadZone.AddAreaMarkers(AdminRadZone.AreaSq)
                        end
                        AdminRadZone.BuildStr = "Press to Build"
                        AdminRadZone.stage = 3
                    end
                    MiniToolkitPanel.step()

                elseif AdminRadZone.stage == 1 then
                    AdminRadZone.FirstPoint = pl:getCurrentSquare()
                    AdminRadZone.BuildStr = "Stand on Second Point"
                    AdminRadZone.stage = 2
                    MiniToolkitPanel.step()
                end
            end,
            tostring(buildIco),
            nil,
            row
        )




    end)
    
    
    -----------------------            ---------------------------
    MiniToolkitPanel.panel1:addFeatureCallback("feature2", function(panel, targetRow)
      
        panel:addFeature(           
            function() return "Demo Function 1" end,
            function()
                pl:getCell():addLamppost(IsoLightSource.new(pl:getX(), pl:getY(), pl:getZ(), 255, 255, 255, 255))               
                pl:addLineChatElement("Demo Function" .. tostring(i)..": Only you can see this local light")
            end,
            "media/ui/Glytch3r_1.png",
            nil,
            targetRow
        )
       
        panel:addFeature(
            function() return "Demo Function 2" end,
            function()

                pl:setBumpType("pushedbehind");  
                pl:setVariable("BumpFall", true);
                pl:setVariable("BumpFallType", "pushedbehind");  
                
                getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', pl:getSquare(), 0, 5, 5, false);
                pl:addLineChatElement("Demo Function" .. tostring(i)..": Incase you get animation stuck this will help you escape")

            end,
            "media/ui/Glytch3r_2.png",

            nil,
            targetRow
        )
        panel:addFeature(
            function() return "Demo Function 3" end,
            function()
                getSoundManager():PlayWorldSound('ZombieSurprisedPlayer', pl:getSquare(), 0, 5, 5, false);
                pl:addLineChatElement("Demo Function" .. tostring(i)..": Nearby players can hear that even if youre invi")
            end,
            "media/ui/Glytch3r_3.png",
            nil,
            targetRow
        )

        panel:addFeature(
            function() return "Demo Function 4" end,
            function()
                local args = { x = pl:getX(), y = pl:getY(), z = pl:getZ() }
                sendClientCommand(pl, 'object', 'addExplosionOnSquare', args)
                pl:addLineChatElement("Demo Function" .. tostring(i)..": Boom!")
            end,
            "media/ui/Glytch3r_4.png",

            nil,
            targetRow
        )
        panel:addFeature(
            function() return "Demo Function 5" end,
            function()
                local rad =8
                local cell = pl:getCell()
                local x, y, z = pl:getX(), pl:getY(), pl:getZ()
                for xDelta = -rad, rad do
                    for yDelta = -rad, rad do
                        local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
                        for i=0, sq:getMovingObjects():size()-1 do
                            local zed = sq:getMovingObjects():get(i)
                            if zed and instanceof(zed, "IsoZombie") then
                                zed:setSkeleton(not zed:isSkeleton());          
                            end
                        end
                    end
                end

                pl:addLineChatElement("Demo Function" .. tostring(i)..": Glytch3r's Minions")
            end,
            "media/ui/Glytch3r_5.png",
            nil,
            targetRow
        )
        -----------------------            ---------------------------
    end)
    MiniToolkitPanel.panel1:refreshButtons()
    MiniToolkitPanel:updateZoneData()
end

function MiniToolkitPanel.updateAll()
    for i, instance in ipairs(MiniToolkitPanel.instances) do
        if instance and instance:isVisible() then
            instance:update()
        else
            table.remove(MiniToolkitPanel.instances, i)
        end
    end
end

function MiniToolkitPanel.getInstance(index)
    return MiniToolkitPanel.instances[index or 1]
end

function MiniToolkitPanel.getMainPanel()
    return MiniToolkitPanel.panel1
end

-----------------------            ---------------------------
function AdminRadZone.getFenceEdgeSquares(x1, y1, x2, y2)
    local squares = {}
    for x = x1, x2 do
        for y = y1, y2 do
            if x == x1 or x == x2 or y == y1 or y == y2 then
                local sq = getCell():getGridSquare(x, y, 0)
                if sq then
                    table.insert(squares, sq)
                end
            end
        end
    end
    return squares
end

function AdminRadZone.AddAreaMarkers(edgeSquares)    
    AdminRadZone.AreaMarkers = {}
    for _, sq in ipairs(edgeSquares) do
        local marker = getWorldMarkers():addGridSquareMarker(
            "circle_center",
            "circle_only_highlight",
            sq,
            1, 1, 1,
            true,
            1
        )
        table.insert(AdminRadZone.AreaMarkers, marker)
    end
    return AdminRadZone.AreaMarkers
end

function AdminRadZone.delAreaMarkers(AreaMarkers)
    AreaMarkers = AreaMarkers or AdminRadZone.AreaMarkers or nil
    for _, marker in ipairs(AreaMarkers) do
        if marker then
            marker:remove()
        end
    end
    AdminRadZone.AreaMarkers = nil
end
 ]]