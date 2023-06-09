
local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local KSFUN_HUNGER = {}


local function getHungerPercent(inst)
    if inst.target then
        return inst.target.components.hunger:GetPercent()
    end
    return 1
end

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
    local data = inst.components.ksfun_power:GetData()
    local player = inst.target
    local lv = inst.components.ksfun_level:GetLevel()
    if player and player.components.hunger and data then
        local percent = getHungerPercent(inst)
        player.components.hunger.max = data.maxhunger + lv
        player.components.hunger:SetPercent(percent)
    end

    -- 100级之后每级新增千分之5的饱食度下降
    if lv > 100  then
        local hunger_multi = calcHungerMulti(lv)
        player.components.hunger.burnratemodifiers:SetModifier("ksfun_power_hunger", hunger_multi)
    end

    
    -- 升级可以提升角色的工作效率
    -- 吃得多力气也越大
    local workmultiplier = player.components.workmultiplier
    if workmultiplier then
        local work_multi = calcWorkMulti(lv)
        workmultiplier:AddMultiplier(ACTIONS.CHOP,   work_multi,   inst)
        workmultiplier:AddMultiplier(ACTIONS.MINE,   work_multi,   inst)
        workmultiplier:AddMultiplier(ACTIONS.HAMMER, work_multi,   inst)
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


--- 计算食物能够获得的经验值
--- 经验系数 饱食0.2  生命值0.3 精神值0.5
--- 如果是某一项为负值，此次获得的经验值可能为负数
local function calcFoodExp(eater, food)
    if food == nil or food.components.edible == nil then return 0 end
    local hunger = food.components.edible:GetHunger(eater)
    local health = food.components.edible:GetHealth(eater)
    local sanity = food.components.edible:GetSanity(eater)
    return 0.2 * hunger + health * 0.3 + sanity * 0.5
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
    inst.components.ksfun_power:SetData({maxhunger = player.components.hunger.max})
    
    -- 修正饱食度百分比
    if inst.percent then
        player.components.hunger:SetPercent(inst.percent)
    end

    updateHungerStatus(inst)
    player:ListenForEvent("oneat", onEat)
end


--- 解绑对象
local function onDetachFunc(inst, player, name)
    player:RemoveEventCallback("oneat", onEat)

    -- 恢复饱食度上限
    local hunger = player.components.hunger
    local data   = inst.components.ksfun_power:GetData()


    if hunger then
        hunger.burnratemodifiers:RemoveModifier("ksfun_power_hunger")
    end

    if hunger and data then
        local percent = getHungerPercent(inst)
        hunger.max = data.maxhunger
        hunger:SetPercent(percent)
    end

    -- 恢复
    local workmultiplier = player.components.workmultiplier
    if workmultiplier then
        workmultiplier:RemoveMultiplier(ACTIONS.CHOP,   inst)
        workmultiplier:RemoveMultiplier(ACTIONS.MINE,   inst)
        workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)
    end

    inst.target = nil
end


local power = {
    name = NAMES.HUNGER,
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onSaveFunc   = function(inst, data)
        data.percent = getHungerPercent(inst)
    end,
    onLoadFunc   = function(inst, data)
        inst.percent = data.percent or 1
    end
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
}

KSFUN_HUNGER.data = {
    power = power,
    level = level,
}

return KSFUN_HUNGER