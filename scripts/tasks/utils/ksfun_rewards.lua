local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES

local ITMES  = require("tasks/defs/ksfun_rewards_items")
local POWERS = require("tasks/defs/ksfun_rewards_powers")


local REWARDS = {}

--- 属性奖励
REWARDS[REWARD_TYPES.PLAYER_POWER.NORMAL]     = { random = POWERS.randomNewPower}
REWARDS[REWARD_TYPES.PLAYER_POWER_UP.NORMAL]  = { random = POWERS.randomPowerLv }
REWARDS[REWARD_TYPES.PLAYER_POWER_EXP.NORMAL] = { random = POWERS.randomPowerExp}
--- 物品类型
REWARDS[REWARD_TYPES.ITEM.NORMAL]       =  { random = ITMES.randomNormalItem }
REWARDS[REWARD_TYPES.KSFUN_ITEM.NORMAL] =  { random = ITMES.randomKsFunItem }


local function defaultReward(player, task_lv)
    return REWARDS[REWARD_TYPES.ITEM.NORMAL].random(player, task_lv)
end

--- 暂时只支持随机生成物品
--- 制定类型type后续再迭代
REWARDS.generateReward = function(player, task_lv, reward_type)
    print(KSFUN_TUNING.LOG_TAG.."generate reward "..tostring(reward_type))
    local reward = REWARDS[reward_type]
    if reward then
        local data =  reward.random(player, task_lv)
        if data then
            return data
        end
    end
    --- 兜底物品奖励
    return defaultReward(player, task_lv)
end


--- 随机生成奖励
REWARDS.randomReward = function(player, task_lv)
    local reward = KsFunRandomValueFromKVTable(REWARDS)
    if reward then
        local data =  reward.random(player, task_lv)
        if data then
            return data
        end
    end
    --- 兜底物品奖励
    return defaultReward(player, task_lv)
end


return REWARS
