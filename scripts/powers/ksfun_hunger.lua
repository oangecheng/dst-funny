
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
        player.components.hunger.burnratemodifiers:SetModifier(inst, hunger_multi)
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
        print(KSFUN_TUNING.LOG_TAG.."ksfun_hunger onStateChangeFunc")
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


--- 计算食物能够获得的经验值
--- 经验系数 饱食0.2  生命值0.4 精神值0.6
--- 如果是某一项为负值，此次获得的经验值可能为负数
local function calcFoodExp(eater, food)
    if food == nil or food.components.edible == nil then return 0 end
    local hunger = food.components.edible:GetHunger(eater)
    local health = food.components.edible:GetHealth(eater)
    local sanity = food.components.edible:GetSanity(eater)
    return (0.2 * hunger + health * 0.4 + sanity * 0.6) * 20
end


local function onEat(eater, data)
    local hunger = eater.components.ksfun_power_system:GetPower(NAMES.HUNGER)
    if data and data.food and hunger then
        local hunger_exp = calcFoodExp(eater, data.food)
        hunger.components.ksfun_level:GainExp(hunger_exp) 
    end
end


--- 绑定对象
local function onAttachFunc(inst, player, name)
    inst.target = player
    if not inst.originHunger then
        inst.originHunger = player.components.hunger.max
    end
    updateHungerStatus(inst)
    player:ListenForEvent("oneat", onEat)
end


--- 解绑对象
local function onDetachFunc(inst, player, name)
    player:RemoveEventCallback("oneat", onEat)
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


local power = {
    name = NAMES.HUNGER,
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
    onStateChangeFunc = onStateChangeFunc,
    nextLvExpFunc = nextLvExpFunc,
}

KSFUN_HUNGER.data = {
    power = power,
    level = level,
}

return KSFUN_HUNGER