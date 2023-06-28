-- 数据缓存



local KSFUN_WORLD_PLAYERS = Class(function(self, inst)
    self.inst = inst
    self.playerdatas = {}
    
    inst:ListenForEvent("ms_playerdespawnanddelete", function(inst, player)
        KsFunShowNotice("哈哈哈断开连接了")
        self:CachePlayerStatus(player)
    end)

    inst:ListenForEvent("ms_newplayerspawned", function(inst, player)
        KsFunShowNotice("哈哈哈重新进入了")
        self:RecoverPlayerStatus(player)
    end)
end)




function KSFUN_WORLD_PLAYERS:CachePlayerStatus(player)
    local data = self.playerdatas[player.userid] or {}
    data.powers = player.components.ksfun_power_system:GetAllPowers()
    for k,v in pairs(data.powers) do
        v.components.ksfun_power:Detach()
    end
    self.playerdatas[player.userid] = data
end



function KSFUN_WORLD_PLAYERS:RecoverPlayerStatus(player)
    local data = self.playerdatas[player.userid]
    if data and data.powers then
        for k,v in pairs(data.powers) do
            player.components.ksfun_power_system:AddPower(k, v)
        end
    end
end



function KSFUN_WORLD_PLAYERS:OnSave()
    if next(self.playerdatas) == nil then return end
    local data = {}
    -- k用户id, v每个角色的数据
    for k, v in pairs(self.playerdatas) do

        if next(v.powers) then
            local powers = {}
            for k1, v1 in pairs(v.powers) do
                local saved = v1:GetSaveRecord()
                powers[k1] = saved
            end
            data[k] = { powers = powers}
        end

    end
    return data
end



function KSFUN_WORLD_PLAYERS:OnLoad(data)
    if data ~= nil and next(data) then
        for k, v in pairs(data) do
            if next(v.powers) then
                local powers = {}
                for k1, v1 in pairs(v.powers) do
                    local ent = SpawnSaveRecord(v1)
                    if ent then
                        powers[k1] = ent
                    end
                end
                self.playerdatas[v] = { powers = powers}
            end
        end
    end
end


return KSFUN_WORLD_PLAYERS