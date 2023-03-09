-- 数据缓存
-- player_status 缓存格式 { user1 = {ksfun_hunger = 1, ksfun_health = 1}}

local function recovery_player_status(data, src, player)
    if player == nil or player.userid == nil then return end
    local player_status = data.player_status[player.userid]
    if player_status == nil then return end

    if player.components.ksfun_hunger ~= nil then
        player.components.ksfun_hunger:SetLevel(player_status.ksfun_hunger or 0, false)
    end
    if player.components.ksfun_health ~= nil then
        player.components.ksfun_health:SetLevel(player_status.ksfun_health or 0, false)
    end
    if player.components.ksfun_sanity ~= nil then
        player.components.ksfun_sanity:SetLevel(player_status.ksfun_sanity or 0, false)
    end 
end




local KsFun_Data = Class(
    function(self, inst)
        self.inst = inst
        self.data = {
            player_status = {}
        }

        -- 玩家切换角色的时候，恢复之前缓存的等级
        inst:ListenForEvent("ms_newplayerspawned", function(src, player)
            recovery_player_status(self.data, src, player)
        end)
end)


-- 缓存人物的状态
-- 这里不做持久化保存，仅支持角色切换时保留角色的一些属性状态
-- 如果用户在切换角色的时候离开游戏，会导致角色的属性被重置
function KsFun_Data:CachePlayerStatus(player)
    if player == nil or player.userid == nil then return end

    local userid = player.userid
    local player_status = self.data.player_status
    player_status[userid] = {}

    -- 缓存用户等级等级
    if player.components.ksfun_hunger ~= nil then
        player_status[userid].ksfun_hunger = player.components.ksfun_hunger.level
    end
    if player.components.ksfun_health ~= nil then
        player_status[userid].ksfun_health = player.components.ksfun_health.level
    end 
    if player.components.ksfun_sanity ~= nil then
        player_status[userid].ksfun_sanity = player.components.ksfun_sanity.level
    end    
end

return KsFun_Data