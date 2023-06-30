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

        local rewardpower = math.random() < 0.5

        --- 50%概率分配属性相关奖励
        if rewardpower then
            -- 优先分配属性奖励，再分配属性等级或者经验
            local f1 = rewardsfunc[REWARD_TYPES.PLAYER_POWER]
            reward = f1(player, tasklv)

            -- 没命中，再去分配经验或者等级
            if not reward then
                local rewardlv = math.random() < 0.5
                local f2 = nil
                if rewarlv then
                    f2 = rewardsfunc[REWARD_TYPES.PLAYER_POWER_LV]
                else
                    f2 = rewardsfunc[REWARD_TYPES.PLAYER_POWER_EXP]
                end
                if f2 then
                    reward = f2(player, tasklv)
                end
            end
        end

        -- 还是没有命中，尝试分配特殊装备
        if not reward then
            reward = rewardsfunc[REWARD_TYPES.KSFUN_ITEM]
        end

        if reward then
            return reward
        end
    end

    --- 兜底奖励，各种普通物品
    local func = rewardsfunc[REWARD_TYPES.ITEM]
    return func(player, tasklv)
end



return tasks_def
