
local POWERS = KSFUN_TUNING.PLAYER_POWER_NAMES
local MAXLV = 5


--- 计算是否命中特殊奖励
--- 和幸运值&难度绑定
--- @param player table 玩家实体
--- @param tasklv number 任务等级
--- @return boolean true 给予
local function canRewardSpecial(player, tasklv)
    local seed = 0
    if tasklv == 1 then
        seed = 0.1
    elseif tasklv == 2 then
        seed = 0.2
    elseif tasklv == 3 then
        seed = 0.4
    elseif tasklv == 4 then
        seed = 0.65
    else
        seed = 1
    end

    local hit = math.random() <= seed
    if KSFUN_TUNING.DEBUG then
        hit = true
    end

    --- 概率命中优先触发
    if hit then
        return true
    end

    --- 兜底策略
    if player.components.achievements then
        if player.components.achievements:Consume() then
            return true
        end
    end
    return false
end






--------------------------------------------- 普通物品相关奖励 ---------------------------------------------------------------------
local prefabsdef = require("defs/ksfun_prefabs_def")

--- 普通物品的最大等级
local maxitemlv = 7


--- 计算是否命中特殊奖励
--- 和幸运值&难度绑定
--- @param player table 玩家实体
--- @param tasklv number 任务等级
--- @return number 返回计算后的物品等级
local function calcRewardNormalLv(player, tasklv)
    local m = KsFunMultiPositive(player)
    -- 附加等级，最大不超过2
    local addlv = m > 1 and math.min(math.floor(m + 0.5), 2) or 0
    return tasklv + addlv
end




--- 智商等级>50有10%的概率获得蓝图奖励
local function checkSanityReward(player, rewardsdata)
    local sanity = player.components.ksfun_power_system:GetPower(POWERS.SANITY)
    if sanity ~= nil then
        local lvlimt = KSFUN_TUNING.DEBUG and 1 or 50
        local ratio  = KSFUN_TUNING.DEBUG and 1 or 0.1
        if sanity.components.ksfun_level:GetLevel() >= lvlimt and math.random() <= ratio then
            local list = prefabsdef.getLostRecipes()
            for i,v in ipairs(list) do
                if player.components.builder and not player.components.builder:KnowsRecipe(v) then
                    table.insert(rewardsdata, { item = v.."_blueprint" , num = 1, special = true })
                    return
                end
            end
        end
    end
end



local function checkSpecialItem(player, tasklv, data)
    if canRewardSpecial(player, tasklv) then
        local ksfunitems = require("defs/ksfun_items_def")
        local num = 2 ^ math.min(tasklv - MAXLV, 0)
        for i = 1, num do
            if math.random() < 0.5 then
                local temp = ksfunitems.gems
                if next(temp) ~= nil then
                    local gem = GetRandomItem(temp)
                    table.insert(data, { item = gem, num = 1, special = true })
                end
            else
                table.insert(data, { item = "ksfun_potion", num = 1, special = true })
            end
        end
    end
end



--- 随机生成一些物品
--- 任务等级越高，奖励越丰富，同时附加幸运值策略
--- @param tasklv number 任务难度等级
--- @return table 名称，等级，数量，类型
local function randomNormalItem(player, tasklv)
    local itemlv = calcRewardNormalLv(player, tasklv)
    itemlv = math.min(maxitemlv, itemlv)
    local name, num = prefabsdef.getItemsByLv(itemlv)
    local extra = math.max(0, tasklv - itemlv)
    num = num + extra

    local data = {}
    table.insert(data, {item = name, num = num})

    --- 当任务等级 > 1 时，有概率获得基础资源的奖励
    if tasklv > 1 and math.random() <= 0.1 * tasklv then
        local item, cnt = prefabsdef.getItemsByLv(1)
        table.insert(data, { item = item, num = cnt })
    end

    checkSanityReward(player, data)
    checkSpecialItem(player, tasklv, data)

    return {
        type = KSFUN_REWARD_TYPES.ITEM,
        data = data
    }
end



--- 普通物品奖励
local function giveReward(player, data)
    local special= ""
    local saystr = ""
    if data and next(data) ~= nil then
        for i,v in ipairs(data) do
            local s = KsFunGetPrefabName(v.item).."x"..v.num
            saystr = saystr..s
            if v.special then
                special = special..s
            end

            for _i = 1, v.num do
                local ent = SpawnPrefab(v.item)
                if ent then
                    player.components.inventory:GiveItem(ent, nil, player:GetPosition())
                end
            end
        end
    end

    if saystr ~= "" then
        local tip = string.format(STRINGS.KSFUN_TASK_REWARD_ITEM_2, saystr)
        KsFunShowTip(player, tip)
    end

    if special ~= "" then
        local notice = string.format(STRINGS.KSFUN_TASK_REWARD_ITEM_3, player.name, special)
        KsFunShowNotice(notice)
    end

end



local function onTaskWinFunc(inst, player, taskdata)
    if taskdata ~= nil then
        local reward = randomNormalItem(player, taskdata.tasklv)
        if reward ~= nil then
            giveReward(player, reward.data)
        end
    end
end








--------------------------------------------- 任务失败 ---------------------------------------------------------------------
local punishtypes = KSFUN_PUNISHES
local monstersdef = require("defs/ksfun_monsters_def") 
local negapowers  = KSFUN_TUNING.NEGA_POWER_NAMES


local function punishPower(player, tasklv, islv)
    local system = player.components.ksfun_power_system
    local powers = system and system:GetAllPowers()
    if not (powers and next(powers)) then
        return nil
    end

    local name, _ = GetRandomItemWithIndex(powers)
    local delta = 0

    if islv then
        local v = 1 * KsFunMultiNegative(player)
        delta = math.max(1, math.floor(v + 0.5))
    else
        local v = math.random(tasklv) * 20 * KsFunMultiNegative(player)
        delta = math.max(10, math.floor(v + 0.5))
    end

    return {
        type = islv and punishtypes.POWER_LV_LOSE or punishtypes.POWER_EXP_LOSE,
        data = {
            name = name,
            num  = delta
        }
    }
end



local function punishMonster(player, tasklv)
    local r = math.random()
    local list = monstersdef.punishMonsters()
    local monsters = nil
    local num = 1

    if r < 0.1 then monsters = list["L"]
    elseif r < 0.3 then monsters = list["M"]
    else 
        monsters = list["S"]
        num = math.random(tasklv)
    end

    -- 不超过10个怪物
    num = math.floor(num * KsFunMultiNegative(player) + 0.5)
    ---@diagnostic disable-next-line: undefined-field
    num = math.clamp(num, 1, 10)

    local selected = {}
    for i=1, num do
        local t = GetRandomItem(monsters)
        table.insert(selected, t)
    end

    return {
        type = punishtypes.MONSTER,
        data = {
            monsters = selected  -- prefab list
        }
    }
end


local function punishNegaPower(player, tasklv)
    local name = GetRandomItem(negapowers)
    return {
        type = punishtypes.NEGA_POWER,
        data = {
            name = name,
        }
    }
end



---随机生成惩罚数据
---@param player table 人物
---@param tasklv integer 任务的等级
---@return table|nil 惩罚数据
local function randomPunishData(player, tasklv)
    local type = GetRandomItem(punishtypes)
    --- 人品好的时候没有惩罚
    if math.random() < 0.2 * KsFunMultiPositive(player) then
        return nil
    end
    if type == punishtypes.MONSTER then
        return punishMonster(player, tasklv)
    elseif type == punishtypes.POWER_LV_LOSE then
        return punishPower(player, tasklv, true)
    elseif type == punishtypes.POWER_EXP_LOSE then
        return punishPower(player, tasklv, false)
    elseif type == punishtypes.NEGA_POWER then
        return punishNegaPower(player, tasklv)
    end
    return nil
end




---给予属性相关的惩罚
---@param player table 人物
---@param islv boolean true等级降低，false经验降低
---@param data table 惩罚的数据
local function doLosePowerPunish(player, islv, data)
    local name  = data.name
    local power = player.components.ksfun_power_system:GetPower(name)
    if power == nil then
        return
    end
    
    local ksfunlv = power.components.ksfun_level
    local namestr = KsFunGetPowerNameStr(name)
    if islv then
        ksfunlv:DoDelta(-data.num)
        local msg = string.format(STRINGS.KSFUN_TASK_PUNISH_POWER_LV, namestr, tostring(-data.num))
        KsFunShowTip(player, msg)
    else
        ksfunlv:DoExpDelta(-data.num)
        local msg = string.format(STRINGS.KSFUN_TASK_PUNISH_POWER_EXP, namestr, tostring(-data.num))
        KsFunShowTip(player, msg)
    end
end




---给予生成敌对怪物的惩罚
---@param player table 人物
---@param data table 惩罚的数据
local function doMonsterPunish(player, data)
    KsFunShowTip(player, STRINGS.KSFUN_TASK_PUNISH_MONSTER)
    for i,v in ipairs(data.monsters) do
        KsFunSpawnHostileMonster(player, v, 1)
    end
end



---给予负面效果的惩罚
---@param player table 人物
---@param data table 惩罚的数据
local function doNegaPowerPunish(player, data)
    local system = player.components.ksfun_power_system
    if system and data.name then
        system:AddPower(data.name)
    end
end


---执行惩罚
---@param player table 人物
---@param punish table|nil 惩罚的数据
local function doPunish(player, punish)
    if punish == nil then
       KsFunShowTip(player, STRINGS.KSFUN_TASK_PUNISH_NONE)
       return
    end

    local type = punish.type
    if type == punishtypes.MONSTER then
       doMonsterPunish(player, punish.data)
    elseif type == punishtypes.POWER_LV_LOSE then
        doLosePowerPunish(player, true, punish.data)
    elseif type == punishtypes.POWER_EXP_LOSE then
        doLosePowerPunish(player, false, punish.data)
    elseif type == punishtypes.NEGA_POWER then
        doNegaPowerPunish(player, punish.data)
    end
end




local function onTaskLoseFunc(inst, player, taskdata)
    if taskdata ~= nil then
        local data = randomPunishData(player, taskdata.tasklv)
        doPunish(player, data)
    end
end


return {
    win  = onTaskWinFunc,
    lose = onTaskLoseFunc
}