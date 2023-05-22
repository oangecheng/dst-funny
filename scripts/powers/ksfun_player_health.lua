local KSFUN_HEALTH = {}

local POWER_NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES


-- 更新角色的血量数据
local function updateHealthState(power, isInit)
    local lv = power.components.ksfun_level.lv
    local player = power.target
    if player and player.components.health then
        local initHealth = power.originHealth or 120
        player.components.health.maxhealth = initHealth + lv
        local percent = player.components.health:GetPercent()
        player.components.health:SetPercent(percent)
    end
end


--- 生命上限提升时
local function onLvChangeFunc(inst, lv, notice)
    updateHealthState(inst, false)
    if notice and inst.target then
        inst.target.components.talker:Say("血量提升！")
    end
end

--- 用户等级状态变更
--- 通知用户面板刷新状态
local function onStateChangeFunc(inst)
    if inst.target then
        inst.target:PushEvent(KSFUN_TUNING.EVENTS.PLAYER_STATE_CHANGE)
    end
end


--- 击杀怪物后，范围10以内的角色都可以获得血量升级的经验值
--- 范围内只有一个人时，经验值为100%获取
--- 人越多经验越低，最低50%
--- @param killer 击杀者 data 受害者数据集
local function onKillOther(killer, data)
    local victim = data.victim
    if victim == nil then return end
    if victim.components.health == nil then return end

    if victim.components.freezable or victim:HasTag("monster") then
        local exp = victim.components.health.maxhealth

        -- 击杀者能够得到满额的经验
        KsFunPowerGainExp(killer, POWER_NAMES.HEALTH, exp)

        -- 非击杀者经验值计算
        local x,y,z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x,y,z, 10, {"player"})
        if players == nil then return end
        local players_count = #players
        -- 单人模式经验100%，多人经验获取会减少，最低50%
        local exp_multi = math.max((6 - players_count) * 0.2, 0.5)
        for i, player in ipairs(players) do
            -- 击杀者已经给了经验了
            if player ~= killer then
                KsFunPowerGainExp(player, POWER_NAMES.HEALTH, exp * exp_multi)
            end
        end
    end
end


--- 获取升到下一级需要的经验
--- @param inst power lv 当前等级
local function nextLvExpFunc(inst, lv)
    if KSFUN_TUNING.DEBUG then
        return 10
    else
        return 100 * (lv + 1)
    end
end


--- power 绑定
--- @param 属性  玩家  属性名称
local function onAttach(inst, player, name)
    inst.target = player
    --- 缓存原始血量
    if not inst.originHealth then
        inst.originHealth = player.components.health.maxhealth
    end

    inst.onKillOther = onKillOther
    updateHealthState(inst, true)
    player:ListenForEvent("killed", inst.onKillOther)
end


--- power解绑
--- 血量回复到初始值
--- @param 属性 角色 属性名称
local function onDetach(inst, player, name)
    inst.target = nil
    player:RemoveEventCallback("killed", inst.onKillOther)
    if player.components.health and inst.originHealth then
        local percent = player.components.health:GetPercent()
        player.components.health.maxhealth = inst.originHealth or 120
        player.components.health:SetPercent(percent)
    end
end


local power = {
    onAttachFunc = onAttach,
    onDetachFunc = onDetach,
    onExtendFunc = nil,
    onGetDescFunc = nil
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
    onStateChangeFunc = onStateChangeFunc,
    nextLvExpFunc = nextLvExpFunc
}


KSFUN_HEALTH.data = {
    power = power,
    level = level,
}

return KSFUN_HEALTH