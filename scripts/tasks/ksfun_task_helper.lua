local helper = {}



--------------------------------------------- 生成任务要求函数定义---------------------------------------------------------------------
local TASK_NAMES = KSFUN_TUNING.TASK_NAMES
--- 要求定义
local demands = require("tasks/defs/ksfun_demands_def")

local function randomDemand()
    local name = GetRandomItem(TASK_NAMES)
    local d = demands[name].random()
    return name, d
end




helper.randomTaskData = function()
    local name,demand = randomDemand()
    local task = {}
    task.name     = name
    task.tasklv   = demand.diffculty
    task.duration = demand.duration
    task.demand   = demand
    return task
end










--------------------------------------------- 生成任务奖励函数定义---------------------------------------------------------------------
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES
local rewardsfunc  = require("tasks/defs/ksfun_rewards_def")

--- 任务奖励和难度绑定
local function calcRewardRatio(tasklv)
    if KSFUN_TUNING.DIFFCULTY > 0 then
        return tasklv * 0.5
    elseif KSFUN_TUNING.DIFFCULTY < 0 then
        return tasklv * 2
    else
        return tasklv
    end
end


--- 任务等级越高，越容易获得特殊奖励
--- 任务等级最高基准为10，也就是高级任务有25%概率获得特殊奖励
local function randomReward(player, tasklv)
    local r = calcRewardRatio(tasklv)
    local v = KSFUN_TUNING.DEBUG and 1 or r/40

    local reward = nil
    if math.random() < v then
        local rewardpower = math.random() < 0.5
        --- 50%概率分配属性相关奖励
        if rewardpower then
            -- 优先分配属性奖励，再分配属性等级或者经验
            local func1 = rewardsfunc[REWARD_TYPES.PLAYER_POWER]
            reward = func1(player, tasklv)
            -- 没命中，再去分配经验或者等级
            if not reward then
                local rewardlv = math.random() < 0.5
                local func2 = nil
                if rewardlv then
                    func2 = rewardsfunc[REWARD_TYPES.PLAYER_POWER_LV]
                else
                    func2 = rewardsfunc[REWARD_TYPES.PLAYER_POWER_EXP]
                end
                if func2 then
                    reward = func2(player, tasklv)
                end
            end
        end

        -- 还是没有命中，尝试分配特殊装备
        if not reward then
            local func3 = rewardsfunc[REWARD_TYPES.KSFUN_ITEM]
            reward = func3(player, tasklv)
        end

        if reward then
            return reward
        end
    end

    --- 兜底奖励，各种普通物品
    local func = rewardsfunc[REWARD_TYPES.ITEM]
    return func(player, tasklv)
end








--------------------------------------------- 生成任务惩罚函数定义---------------------------------------------------------------------
local punishes  = require("tasks/defs/ksfun_punishes_def")
local function randomPunish(player, tasklv)
    return {}
end











--------------------------------------------- 生成回调处理---------------------------------------------------------------------
local taskjudge = require("tasks/ksfun_task_judge")
local taskwin   = require("tasks/ksfun_task_reward")
local tasklose  = require("tasks/ksfun_task_punish")

local function onWinFunc(inst, player, taskdata)
    local reward = randomReward(player, taskdata.tasklv)
    taskdata.reward = reward
    taskwin.onWinFunc(inst, player, taskdata)
end

local function onLoseFunc(inst, player, taskdata)
    local punish = randomPunish(player, taskdata.tasklv)
    taskdata.punish = punish
    tasklose.onLoseFunc(inst, player, taskdata)
end

helper.getTaskHandler = function(taskname)
    local judge = taskjudge[taskname]
    return {
        onAttachFunc = judge.onattach,
        onDetachFunc = judge.ondetach,
        descFunc     = judge.ondesc,
        onWinFunc    = onWinFunc,
        onLoseFunc   = onLoseFunc,
    }
end

return helper