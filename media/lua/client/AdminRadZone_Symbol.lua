
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

AdminRadZone = AdminRadZone or {}
function AdminRadZone.hookInit()
    AdminRadZone.Hook_ISWorldMapRender = AdminRadZone.Hook_ISWorldMapRender or ISWorldMap.render
    AdminRadZone.Hook_ISMiniMapOuterRender = AdminRadZone.Hook_ISMiniMapOuterRender or ISMiniMapOuter.render

    function ISWorldMap:render()
        AdminRadZone.Hook_ISWorldMapRender(self)
        local data = AdminRadZoneData
        if data and data.state and data.x and data.y and data.rad and data.run then
            local col = AdminRadZone.getRadColor()
            local mask = { x1 = self.x, y1 = self.y, x2 = self.x + self.width, y2 = self.y + self.height }
            AdminRadZone.renderSym(self.mapAPI, data.x, data.y, data.rad,
                col:getR(), col:getG(), col:getB(), 1,
                self, nil, nil, mask, 3)
        end
    end

    function ISMiniMapOuter:render()
        AdminRadZone.Hook_ISMiniMapOuterRender(self)
        local data = AdminRadZoneData
        if not (data and data.state and data.x and data.y and data.rad and data.run) then return end
        local mapAPI = self.inner.mapAPI
        local col = AdminRadZone.getRadColor()
        local mask = { x1 = self.inner.x, y1 = self.inner.y, x2 = self.inner.x + self.inner.width, y2 = self.inner.y + self.inner.height }
        AdminRadZone.renderSym(mapAPI, data.x, data.y, data.rad,
            col:getR(), col:getG(), col:getB(), 1,
            self.inner, nil, nil, mask, 3)
    end
end

Events.OnCreatePlayer.Add(AdminRadZone.hookInit)
