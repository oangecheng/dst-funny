local tasks_def = {}


--------------------------------------------- 奖励函数定义---------------------------------------------------------------------
local TASK_NAMES = KSFUN_TUNING.TASK_NAMES
local demandsdef = require("tasks/defs/ksfun_demands_def")

--- 要求定义
local demands = {
    [TASK_NAMES.KILL] = demandsdef.randomKill  
}


local DEMAND = {}


--- 生成任务需求，需要指定任务类型
--- @param name 任务名称
--- @param demand_type 需求的类型，比如击杀任务有自己的类型
tasks_def.generateDemand = function(name)
    KsFunLog("generateDemand", name)
    local generateFunc = demands[name]
    if generateFunc ~= nil then    
        local d = generateFunc()
        return d
    end
end






--------------------------------------------- 奖励函数定义---------------------------------------------------------------------
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES
local rewadsdef  = require("tasks/defs/ksfun_rewards_def")
local rewardsfunc = {
    [REWARD_TYPES.PLAYER_POWER]     = rewadsdef.randomNewPower,
    [REWARD_TYPES.PLAYER_POWER_LV]  = rewadsdef.randomPowerLv,
    [REWARD_TYPES.PLAYER_POWER_EXP] = rewadsdef.randomPowerExp,
    [REWARD_TYPES.ITEM]             = rewadsdef.randomNormalItem,
    [REWARD_TYPES.KSFUN_ITEM]       = rewadsdef.randomKsFunItem,

}

--- 特殊类型奖励
local reward_special = {
    REWARD_TYPES.PLAYER_POWER,
    REWARD_TYPES.PLAYER_POWER_LV,
    REWARD_TYPES.PLAYER_POWER_EXP,
    REWARD_TYPES.KSFUN_ITEM,
}

-- 任务等级越高，越容易获得特殊奖励
-- 最高等级的任务有40%的概率获得特殊奖励
tasks_def.randomReward = function(player, tasklv)
    KsFunLog("randomReward", tasklv)
    local s = tasklv
    local v = KSFUN_TUNING.DEBUG and 0 or math.random(200)

    local reward = nil
    if s>v then
        -- 循环3次查找,找到一个就可以
        for i=1,3 do
            local rewardtype = KsFunRandomValueFromList(reward_special)
            KsFunLog("random special reward", rewardtype)
            local func = rewardsfunc[rewardtype]
            if func then
                local r = func(player, tasklv)
                if r then
                    return r
                end
            end
        end
    end

    local func = rewardsfunc[REWARD_TYPES.ITEM]
    return func(player, tasklv)
end





return tasks_def
