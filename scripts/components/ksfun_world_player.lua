-- 数据缓存



local KSFUN_WORLD_PLAYERS = Class(function(self, inst)
    self.inst = inst
    self.playerdatas = {}
    self.powerdatas = {}
    
    inst:ListenForEvent("ms_playerdespawnanddelete", function(inst, player)
        KsFunLog("player exist")
        self:CachePlayerStatus(player)
    end)

    inst:ListenForEvent("ms_newplayerspawned", function(inst, player)
        KsFunLog("player enter")
        self:RecoverPlayerStatus(player)
    end)
end)



--- 缓存用户的数据
function KSFUN_WORLD_PLAYERS:CachePlayerStatus(player)
    local data = self.playerdatas[player.userid] or {}
    data.powers = player.components.ksfun_power_system:GetAllPowers()
    for k,v in pairs(data.powers) do
        v.components.ksfun_power:Detach()
    end
    self.playerdatas[player.userid] = data
end


--- 恢复用户的数据
--- 换人可以保留属性
function KSFUN_WORLD_PLAYERS:RecoverPlayerStatus(player)
    local data = self.playerdatas[player.userid]
    if data and data.powers then
        for k,v in pairs(data.powers) do
            player.components.ksfun_power_system:AddPower(k, v)
        end
    end
end



--- 属性计数器+1
function KSFUN_WORLD_PLAYERS:AddWorldPowerCount(name)
    local data = self.powerdatas[name] or {}
    local count = data.count or 0
    data.count = count + 1
    self.powerdatas[name] = data
end


--- 获取属性计数器 
function KSFUN_WORLD_PLAYERS:GetWorldPowerCount(name)
    local data = self.powerdatas[name]
    if data then
        return data.count or 0
    else
        return 0
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