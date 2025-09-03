
require "ISUI/ISPanel"

AdminRadZone = AdminRadZone or {}
AdminRadZone.StateStr = {
    ["inactive"] = "Inactive",
    ["active"] = "Active", 
    ["cooldown"] = "Cooldown",
    ["pause"] = "Paused"
}

AdminRadZoneIndicator = ISPanel:derive("AdminRadZoneIndicator")
AdminRadZoneIndicator.instance = nil

function AdminRadZoneIndicator:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o:setAnchorLeft(false)
    o:setAnchorRight(true)
    o:setAnchorTop(true)
    o:setAnchorBottom(false)
    o.borderColor = {r=0, g=0, b=0, a=0}
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.texture = getTexture("media/ui/LootableMaps/map_radiation.png")
    o.tooltip = nil
    return o
end

function AdminRadZoneIndicator:render()
    if self.texture then
        local color = {r=1, g=1, b=1, a=1}
        if AdminRadZoneData.state and AdminRadZone.stateColors[AdminRadZoneData.state] then
            local stateColor = AdminRadZone.stateColors[AdminRadZoneData.state]
            color = {r=stateColor:getR(), g=stateColor:getG(), b=stateColor:getB(), a=1}
        end
        self:drawTexture(self.texture, 0, 0, color.a, color.r, color.g, color.b)
    end
end

function AdminRadZoneIndicator:onMouseMove(dx, dy)
    if AdminRadZoneData.state and AdminRadZone.StateStr[AdminRadZoneData.state] then
        self.tooltip = AdminRadZone.StateStr[AdminRadZoneData.state]
    end
end

function AdminRadZoneIndicator:onMouseMoveOutside(dx, dy)
    self.tooltip = nil
end


function AdminRadZone.openIndicator()
    if AdminRadZoneIndicator.instance then
        return AdminRadZoneIndicator.instance
    end
    
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()
    
    local buttonSize = 124
    local margin = 100
    
    local button = AdminRadZoneIndicator:new(screenWidth - buttonSize - margin, margin, buttonSize, buttonSize)
    button:initialise()
    button:addToUIManager()
    
    AdminRadZoneIndicator.instance = button
    return button
end

function AdminRadZone.closeIndicator()
    if AdminRadZoneIndicator.instance then
        AdminRadZoneIndicator.instance:removeFromUIManager()
        AdminRadZoneIndicator.instance = nil
    end
end


function AdminRadZone.IndicatorHandler()
    if not SandboxVars.AdminRadZone.VisibleIndicator then return end

    if AdminRadZoneData.run then
        if not AdminRadZoneIndicator.instance then
            AdminRadZone.openIndicator()
        end
    else
        if AdminRadZoneIndicator.instance then
            AdminRadZone.closeIndicator()
        end
    end
end

Events.EveryOneMinute.Add(AdminRadZone.IndicatorHandler)