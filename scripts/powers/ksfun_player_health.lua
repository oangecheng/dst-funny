local KSFUN_HEALTH = {}

local POWER_NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES


-- 更新角色的血量数据
local function updateHealthState(power)
    local lv = power.components.ksfun_level.lv
    local player = power.target
    if player and player.components.health then
        player.components.health.maxhealth = 100 + lv
        local health_percent = player.components.health:GetPercent()
        player.components.health:SetPercent(health_percent)
    end
end


--- 生命上限提升时
local function onLvUpFunc(inst, lv, notice)
    updateHealthState(inst)
    if notice and inst.target then
        inst.target.components.talker:Say("血量提升！")
    end
end


-- 击杀怪物后，范围10以内的角色都可以获得血量升级的经验值
-- 范围内只有一个人时，经验值为100%获取
-- 人越多经验越低，最低50%
local function onKillOther(killer, data)
    local victim = data.victim
    if victim == nil then return end
    if victim.components.health == nil then return end

    if victim.components.freezable or victim:HasTag("monster") then
        local exp = victim.components.health.maxhealth
        local x,y,z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x,y,z, 10, {"player"})
        
        if players == nil then return end
        local players_count = #players
        -- 单人模式经验100%，多人经验获取会减少，最低50%
        local exp_multi = math.max((6 - players_count) * 0.2, 0.5)
        for i, player in ipairs(players) do
            if player.components.ksfun_powers then
                local inst = player.components.ksfun_powers:GetPower(POWER_NAMES.HEALTH)
                if inst and inst.components.ksfun_level then
                    inst.components.ksfun_level:GainExp(exp * exp_multi)
                end
            end
        end
    end
end


local function onAttach(inst, player, name)
    inst.target = player
    if not inst.originHealth then
        inst.originHealth = player.components.health.maxhealth
    end

    inst.onLvUpFunc = onLvUpFunc
    updateHealthState(inst)
    player:ListenForEvent("killed", inst.onKillOther)
end


local function onDetach(inst, player, name)
    inst.onLvUpFunc = nil
    inst.onExpChangeFunc = nil
    inst.nextLvExpFunc = nil

    player:RemoveEventCallback("killed", inst.onKillOther)
    if player.components.health and inst.originHealth then
        player.components.health.maxhealth = inst.originHealth
    end
end



KSFUN_HEALTH.data = {
    name = POWER_NAMES.HEALTH,
    onAttachFunc = onAttach,
    onDetachFunc = onDetach,
    onExtendFunc = nil,
    onGetDescFunc = nil
}


return KSFUN_HEALTH