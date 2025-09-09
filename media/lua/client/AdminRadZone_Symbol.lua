
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
            AdminRadZone.renderSym(self.mapAPI, data.x, data.y, data.rad, 1, 0, 0, 1, self, nil, nil, nil, 3)
        end
    end
    function ISMiniMapOuter:render()
        AdminRadZone.Hook_ISMiniMapOuterRender(self)

        local data = AdminRadZoneData
        if not (data and data.state and data.x and data.y and data.rad and data.run) then return end

        local mapAPI = self.inner.mapAPI

        AdminRadZone.renderSym(mapAPI, data.x, data.y, data.rad,
            1, 0, 0, 1,
            self.inner,
            nil, nil,
            nil,    
            3
        )
    end

end
Events.OnCreatePlayer.Add(AdminRadZone.hookInit)

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
            AdminRadZone.renderSym(self.mapAPI, data.x, data.y, data.rad, 1, 0, 0, 1, self, nil, nil, nil, 3)
        end
    end

    function ISMiniMapOuter:render()
        AdminRadZone.Hook_ISMiniMapOuterRender(self)

        local data = AdminRadZoneData
        if not (data and data.state and data.x and data.y and data.rad and data.run) then return end

        local mapAPI = self.inner.mapAPI
        local mask = {
            x1 = 0,
            y1 = 0,
            x2 = self.inner:getWidth(),
            y2 = self.inner:getHeight()
        }

        AdminRadZone.renderSym(mapAPI, data.x, data.y, data.rad,
            1, 0, 0, 1,
            self.inner,
            nil, nil,
            mask,
            3
        )
    end
end
