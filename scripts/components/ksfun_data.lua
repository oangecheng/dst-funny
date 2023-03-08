
local KsFun_Data = Class(
    function(self, inst)
        self.inst = inst
        self.data = {

        }

        inst:ListenForEvent("ms_newplayerspawned",
            function(src,player)
                if player and player.userid and player.components.ksfun_hunger ~= nil then
                    player.components.ksfun_hunger.level = self.data[player.userid] or 0
                end
            end)
end)


function KsFun_Data:Save(player)
    self.data[player.userid] = player.components.ksfun_hunger.level
end

return KsFun_Data