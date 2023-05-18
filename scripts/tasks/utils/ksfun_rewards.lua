local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES

local ITMES  = require("tasks/defs/ksfun_reward_items")
local POWERS = require("tasks/defs/ksfun_reward_powers")


local REWARD_DEFS = {}

--- 属性奖励
REWARD_DEFS[REWARD_TYPES.PLAYER_POWER.NORMAL]     = { random = POWERS.randomNewPower}
REWARD_DEFS[REWARD_TYPES.PLAYER_POWER_UP.NORMAL]  = { random = POWERS.randomPowerLv }
REWARD_DEFS[REWARD_TYPES.PLAYER_POWER_EXP.NORMAL] = { random = POWERS.randomPowerExp}
--- 物品类型
REWARD_DEFS[REWARD_TYPES.ITEM.NORMAL] =  { random = ITMES.randomNormalItem }
REWARD_DEFS[REWARD_TYPES.KSFUN_ITEM.NORMAL] =  { random = ITMES.randomKsFunItem }


local function defaultReward(player, task_lv)
    local d = REWARD_DEFS[REWARD_TYPES.ITEM.NORMAL]
    return d.random(player, task_lv)
end




local REWARDS = {}


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


return REWARDS
