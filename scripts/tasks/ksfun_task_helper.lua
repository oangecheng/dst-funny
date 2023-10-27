local helper = {}
local NAMES = KSFUN_TASK_NAMES


local taskdefs = require("tasks/ksfun_task_defs")
local function randomTask()
    local name = GetRandomItem(NAMES)
    local task = taskdefs[name].create()
    if task ~= nil then
        task.name = name
        return task
    end
end



helper.randomTaskData = function()
    return randomTask() or {}
end



--------------------------------------------- 生成回调处理---------------------------------------------------------------------
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
    local judge = taskdefs[taskname].judge
    return {
        onAttachFunc = judge.onattach,
        onDetachFunc = judge.ondetach,
        onWinFunc    = onWinFunc,
        onLoseFunc   = onLoseFunc,
    }
end

return helper