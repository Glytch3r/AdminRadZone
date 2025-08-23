--client folder
--AdminRadZone_Marker.lua
AdminRadZone = AdminRadZone or {}

function AdminRadZone.shiftColor(marker)
    marker = marker or AdminRadZone.marker
    if not marker then return end
    local statusColor = AdminRadZone.getPanelColor()
    local r,g,b = statusColor.r, statusColor.g, statusColor.b
    if marker:getR() ~= r then marker:setR(r) end
    if marker:getG() ~= g then marker:setG(g) end
    if marker:getB() ~= b then marker:setB(b) end
end



--[[ 
function AdminRadZone.getMarkerColor(alpha, pick)
    alpha = alpha or 1
    pick = pick or SandboxVars and SandboxVars.AdminRadZone and SandboxVars.AdminRadZone.MarkerColor or 3
    local colors = {
        ColorInfo.new(0.5, 0.5, 0.5, alpha),  -- gray
        ColorInfo.new(1, 0, 0, alpha),        -- red
        ColorInfo.new(1, 0.5, 0, alpha),      -- orange
        ColorInfo.new(1, 1, 0, alpha),        -- yellow
        ColorInfo.new(0, 1, 0, alpha),        -- green
        ColorInfo.new(0, 0, 1, alpha),        -- blue
        ColorInfo.new(0.5, 0, 0.5, alpha),    -- purple
        ColorInfo.new(0, 0, 0, alpha),        -- black
        ColorInfo.new(1, 1, 1, alpha),        -- white
        ColorInfo.new(1, 0.75, 0.8, alpha),   -- pink
    }
    return colors[pick] or colors[3]
end



 ]]