
local KSFUN_ITEM_TYPES = KSFUN_TUNING.KSFUN_ITEM_TYPES
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES

local ksfun_rewards = {}




--------------------------------------------- 普通物品相关奖励 ---------------------------------------------------------------------
local prefabsdef = require("defs/ksfun_prefabs_def")

--- 普通物品的最大等级
local maxitemlv = 7


--- 随机生成一些物品
--- 任务等级越高，奖励越丰富，同时附加幸运值策略
--- @param  tasklv 任务难度等级
--- @return 名称，等级，数量，类型
local function randomNormalItem(player, tasklv)
    -- 计算奖励物品等级
    local lv = tasklv
    local r  = math.random()

    local luckyratio = 0
    if player.components.ksfun_lucky then
        luckyratio = player.components.ksfun_lucky:GetRatio() 
    end

    -- 默认10%概率，附加幸运等级
    r = r - luckyratio * 0.1
    if r < 0.1 then
        lv = lv + 2
    elseif r < 0.3 then
        lv = lv + 1
    end
    lv = math.max(maxitemlv, lv)

    local name,num = prefabsdef.getItemsByLv(lv)
    --- 数量有幸运值加成
    --- 不走运时收益减半，至少保留一个物品的奖励
    local luckymulti = math.max(0.5, 1 + luckyratio)
    local delta = math.max(0, tasklv - maxitemlv)
    num = math.max(1, num * luckymulti + delta)

    return {
        type = REWARD_TYPES.ITEM,
        data = {
            item = name,
            num = num,
        }
    }
end





--------------------------------------------- 特殊物品奖励 ---------------------------------------------------------------------
local ksfun_items = require("defs/ksfun_items_def")

--- 随机获取一个特殊物品奖励
local function randomKsFunItem(player, task_lv)
    local itemtype = math.random(4)
    local list = nil
    local num = 1
    if itemtype == 1 then
        list =  ksfun_items.weapon
    elseif itemtype == 2 then
        list = ksfun_items.hat
    elseif itemtype == 3 then
        list = ksfun_items.armor
    elseif itemtype == 4 then
        list = ksfun_items.gems
    end
    
    -- 随机一个物品
    local name = list[math.random(#list)]
    -- 随机一个等级
    local temp = math.random(2)
    local lv = math.max(temp, 1) 

    return {
        -- 主类别
        type = REWARD_TYPES.KSFUN_ITEM,
        data = {
            item = name,
            num = num,
            -- 次类别
            type = itemtype,
            lv = lv,
        }   
    }
end



--------------------------------------------- 属性相关奖励 ---------------------------------------------------------------------
local POWERS = KSFUN_TUNING.PLAYER_POWER_NAMES


--- 随机给予一个数据奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a}
local function randomNewPower(player, task_lv)
    local name = KsFunGetCanRewardPower(player)
    if name then
        return {
            type = REWARD_TYPES.PLAYER_POWER,
            data = {
                power = name
            }
        }
    end
    return nil
end


--- 随机查找一个存在的属性给予等级奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a, num = b}
local function randomPowerLv(player, task_lv)
    local power = KsFunRandomPower(player, POWERS, true)
    local lv = math.random(3)
    if power then
        return {
            type = REWARD_TYPES.PLAYER_POWER_LV,
            data = {
                power = power,
                num = lv,
            }
        }
    end
    return nil
end


--- 随机一个属性给予一定的经验值奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a, num = b}
local function randomPowerExp(player, task_lv)
    local power = KsFunRandomPower(player, POWERS, true)
    local exp = math.random(task_lv) * 10
    if power then
        return {
            type = REWARD_TYPES.PLAYER_POWER_EXP,
            data = {
                power = power,
                num = exp,
            }
        }
    end
    return nil
end



--- 任务奖励和难度绑定
local function calcRewardRatio(player, tasklv)
    local v = 0
    if KSFUN_TUNING.DIFFCULTY > 0 then
        v = tasklv * 0.5
    elseif KSFUN_TUNING.DIFFCULTY < 0 then
        v = tasklv * 2
    else
        v =  tasklv
    end

    -- 附加幸运值，幸运值倍率有可能小于0
    local lucky = player.components.ksfun_lucky
    if lucky then
        v = v * (1 + math.min(lucky:GetRatio(), 1))
    end

    return v
end



--- 任务等级越高，越容易获得特殊奖励
--- 任务等级最高基准为10，也就是高级任务有50%概率获得特殊奖励
--- 如果幸运值拉满，100%获得特殊奖励
local function randomReward(player, tasklv)
    local r = calcRewardRatio(player, tasklv)
    local v = KSFUN_TUNING.DEBUG and 1 or r * 0.05

    local reward = nil
    if math.random() < v then

        local rewardpower = math.random() < 0.5
        --- 50%概率分配属性相关奖励
        if rewardpower then
            -- 优先分配属性奖励，再分配属性等级或者经验
            reward = randomNewPower(player, tasklv)
            -- 没命中，再去分配经验或者等级
            if not reward then
                local rewardlv = math.random() < 0.5
                if rewardlv then
                    reward = randomPowerLv(player, tasklv)
                else
                    reward = randomPowerExp(player, tasklv)
                end
            end
        end

        -- 还是没有命中，尝试分配特殊装备
        if not reward then
            reward = randomKsFunItem(player, tasklv)
        end

        if reward then
            return reward
        end
    end

    --- 兜底奖励，各种普通物品
    return randomNormalItem(player, tasklv)
end


local rewardsfunc = {
    random = randomReward
}

return rewardsfunc