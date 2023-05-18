local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES
local TASK_LV_DEFS = KSFUN_TUNING.TASK_LV_DEFS

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


--- 特殊类型奖励
local REWARD_SPECIAL = {
    REWARD_TYPES.PLAYER_POWER.NORMAL,
    REWARD_TYPES.PLAYER_POWER_UP.NORMAL,
    REWARD_TYPES.PLAYER_POWER_EXP.NORMAL,
    REWARD_TYPES.KSFUN_ITEM.NORMAL,
}


local function defaultReward(player, task_lv)
    local d = REWARD_DEFS[REWARD_TYPES.ITEM.NORMAL]
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
            local power_type = KsFunRandomValueFromList(REWARD_SPECIAL)
            print(KSFUN_TUNING.LOG_TAG..tostring(power_type))
            reward = REWARD_DEFS[power_type].random(player, task_lv)
            if reward then
                return reward
            end
        end
    end

    return defaultReward(player, task_lv)
end


local REWARDS = {}

--- 随机生成奖励
REWARDS.randomReward = function(player, task_lv)
    return random(player, task_lv)
end



--- 暂时只支持随机生成物品
--- z指定类型type后续再迭代
REWARDS.generateReward = function(player, task_lv, reward_type)
    print(KSFUN_TUNING.LOG_TAG.."generate reward "..tostring(reward_type))

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


return REWARDS
