-- 更新角色的血量数据
local function update_health_state(inst)
    local lv = inst.components.ksfun_health.level
	inst.components.health.maxhealth = 100 + lv
    local health_percent = inst.components.health:GetPercent()
	inst.components.health:SetPercent(health_percent)
end


-- 血量提升时
local function on_health_up(inst, gain_exp)
    update_health_state(inst)
    GLOBAL.TheWorld.components.ksfun_world_player:CachePlayerStatus(player)
    if gain_exp then
        inst.components.talker:Say("血量提升！")
    end
end


-- 击杀怪物后，范围10以内的角色都可以获得血量升级的经验值
-- 范围内只有一个人时，经验值为100%获取
-- 人越多经验越低，最低50%
local function on_kill_other(inst, data)
    local victim = data.victim
    if victim == nil then return end
    if victim.components.health == nil then return end

    if victim.components.freezable or victim:HasTag("monster") then
        local exp = victim.components.health.maxhealth
        local x,y,z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x,y,z, 10, {"player"})
        local players_count = #ents
        -- 单人模式经验100%，多人经验获取会减少，最低50%
        local exp_multi = math.max((6 - players_count) * 0.2, 0.5)
        for i, player in ipairs(players) do
            if player.components.ksfun_health then 
                player.components.ksfun_health:GainExp(exp * exp_multi)
            end
        end
    end
end


-- 初始化角色
AddPlayerPostInit(function(player)
    player:AddComponent("ksfun_health")
    player.components.ksfun_health:SetHealthUpFunc(on_health_up)
    player:ListenForEvent("killed", on_kill_other)

    local old_on_load = player.OnLoad
    player.OnLoad = function(inst)
        update_health_state(inst) 
        if old_on_load ~= nil then
            old_on_load(inst)
        end
    end
end)