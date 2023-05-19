local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES
local TASK_LV_DEFS = KSFUN_TUNING.TASK_LV_DEFS

local items  = require("tasks/defs/ksfun_reward_items")
local powers = require("tasks/defs/ksfun_reward_powers")


local reward_defs = {}

--- 属性奖励
reward_defs[REWARD_TYPES.PLAYER_POWER]     = { random = powers.randomNewPower}
reward_defs[REWARD_TYPES.PLAYER_POWER_LV]  = { random = powers.randomPowerLv }
reward_defs[REWARD_TYPES.PLAYER_POWER_EXP] = { random = powers.randomPowerExp}
--- 物品类型
reward_defs[REWARD_TYPES.ITEM] =  { random = items.randomNormalItem }
reward_defs[REWARD_TYPES.KSFUN_ITEM] =  { random = items.randomKsFunItem }


--- 特殊类型奖励
local reward_special = {
    REWARD_TYPES.PLAYER_POWER,
    REWARD_TYPES.PLAYER_POWER_LV,
    REWARD_TYPES.PLAYER_POWER_EXP,
    REWARD_TYPES.KSFUN_ITEM,
}


local function defaultReward(player, task_lv)
    local d = reward_defs[REWARD_TYPES.ITEM]
    return d.random(player, task_lv)
end


-- 任务等级越高，越容易获得特殊奖励
-- 最高等级的任务有10%的概率获得特殊奖励
local function random(player, task_lv)
    local s = 2^task_lv
    local max = 2^TASK_LV_DEFS.MAX * 10
    local v = KSFUN_TUNING.DEBUG and 0 or math.random(max)

    local reward = nil
    if s>v then
        -- 循环3次查找,找到一个就可以
        for i=1,3 do
            local power_type = KsFunRandomValueFromList(reward_special)
            KsFunLog("random special reward", power_type)
            reward = reward_defs[power_type].random(player, task_lv)
            if reward then
                return reward
            end
        end
    end

    return defaultReward(player, task_lv)
end


local rewards = {}

--- 随机生成奖励
rewards.randomReward = function(player, task_lv)
    KsFunLog("randomReward", task_lv)
    return random(player, task_lv)
end


--- 暂时只支持随机生成物品
--- z指定类型type后续再迭代
rewards.generateReward = function(player, task_lv, reward_type)
    KsFunLog("generateReward", task_lv, reward_type)
    -- 未指定type，随机生成任务
    if reward_type == nil then
        return random(player, task_lv)
    end

    local reward = REWARD_DEFS[reward_type]
    if reward then
        local data =  reward.random(player, task_lv)
        if data then
            return data
        end
    end
    --- 兜底物品奖励
    return defaultReward(player, task_lv)
end


return rewards
