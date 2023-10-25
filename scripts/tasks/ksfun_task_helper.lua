local helper = {}



--------------------------------------------- 生成任务要求函数定义---------------------------------------------------------------------
local demandsdef = require("tasks/defs/ksfun_demands_def")

helper.randomTaskData = function(initlv)
    local name,demand = demandsdef.random(initlv)
    local task = {}
    task.name     = name
    task.tasklv   = math.max(1, demand.diffculty)
    task.duration = demand.duration
    task.demand   = demand
    return task
end



--------------------------------------------- 生成回调处理---------------------------------------------------------------------
local taskjudge = require("tasks/ksfun_task_judge")
local taskwin   = require("tasks/ksfun_task_reward")
local tasklose  = require("tasks/ksfun_task_punish")
-- 生成惩罚和奖励数据
local rewards   = require("tasks/defs/ksfun_rewards_def")
local punishes  = require("tasks/defs/ksfun_punishes_def")


local function onWinFunc(inst, player, taskdata)
    taskdata.reward = rewards.random(player, taskdata.tasklv)
    taskwin.onWinFunc(inst, player, taskdata)
end


local function onLoseFunc(inst, player, taskdata)
    taskdata.punish = punishes.random(player, taskdata.tasklv)
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