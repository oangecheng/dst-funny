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
local taskfinish   = require("tasks/ksfun_task_finish")


helper.getTaskHandler = function(taskname)
    local judge = taskdefs[taskname].judge
    return {
        onAttachFunc = judge.onattach,
        onDetachFunc = judge.ondetach,
        onWinFunc    = taskfinish.win,
        onLoseFunc   = taskfinish.lose,
    }
end

return helper