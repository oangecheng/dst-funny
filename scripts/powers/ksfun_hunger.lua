
local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local KSFUN_HUNGER = {}


-- 计算饥饿速率
-- 100级之后每级新增千分之5的饱食度下降，最大不超过50%
local function calcHungerMulti(lv)
    return math.max(math.max(0 , lv - 100) * 0.005 + 1, 1.5)
end


--- 计算工作效率
--- 每一级新增1%的工作效率，暂时不设置上限
--- @return 效率
local function calcWorkMulti(lv)
    return lv / 100 + 1
end


-- 更新角色的状态
-- 设置最大饱食度和饱食度的下降速率
-- 肚子越大，饿的越快
local function updateHungerStatus(inst)
    local lv = inst.components.ksfun_level.lv
    local player = inst.target

    if player and player.components.hunger then
        player.components.hunger.max = inst.originHunger + lv
        local percent = player.components.hunger:GetPercent()
        player.components.hunger:SetPercent(percent)
    end

    -- 100级之后每级新增千分之5的饱食度下降
    if lv > 100  then
        local hunger_multi = calcHungerMulti(lv)
        inst.components.hunger.burnratemodifiers:SetModifier(inst, hunger_multi)
    end

    
    -- 升级可以提升角色的工作效率
    -- 吃得多力气也越大
    local workmultiplier = player.components.workmultiplier
    if workmultiplier then
        local work_multi = calcWorkMulti(lv)
        workmultiplier:AddMultiplier(ACTIONS.CHOP, work_multi,   inst)
        workmultiplier:AddMultiplier(ACTIONS.MINE, work_multi,   inst)
        workmultiplier:AddMultiplier(ACTIONS.HAMMER, work_multi, inst)
    end 
end


--- 监听等级提升
--- @param inst power实例
--- @param lv  等级
--- @param notice 是否需要说话
local function onLvChangeFunc(inst, lv, notice)
    updateHungerStatus(inst)
    if notice and inst.target then
        inst.target.components.talker:Say("饱食度提升！")
    end
end


--- 用户等级状态变更
--- 通知用户面板刷新状态
local function onStateChangeFunc(inst)
    if inst.target then
        inst.target:PushEvent(KSFUN_TUNING.EVENTS.PLAYER_STATE_CHANGE)
    end
end


--- 下一级饱食度所需经验值
local function nextLvExpFunc(inst, lv)
    if KSFUN_TUNING.DEBUG then
        return 10
    else
        return 100 * (lv + 1)
    end
end



--- 绑定对象
local function onAttachFunc(inst, player, name)
    inst.target = player
    if not ints.originHunger then
        inst.originHunger = player.components.hunger.max
    end
    updateHungerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, player, name)
    local hunger = player.components.hunger
    if hunger then
        hunger.burnratemodifiers:RemoveModifier(inst)
        if inst.originHealth then
            local percent = health:GetPercent()
            hunger.max = inst.originHealth
            hunger:SetPercent(percent)
        end
    end
    local workmultiplier = player.components.workmultiplier
    if workmultiplier then
        workmultiplier:RemoveMultiplier(ACTIONS.CHOP,   inst)
        workmultiplier:RemoveMultiplier(ACTIONS.MINE,   inst)
        workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)
    end

    inst.target = nil
    inst.originHealth = nil
end



local function hookPlayerWalkSpeed(inst)
end



KSFUN_HUNGER.power = {
    name = NAMES.HUNGER,
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
}

KSFUN_HUNGER.level = {
    onLvChangeFunc = onLvChangeFunc,
    onStateChangeFunc = onStateChangeFunc,
    nextLvExpFunc = nextLvExpFunc,
}