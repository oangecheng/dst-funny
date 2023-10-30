local helper = {}
local NAMES = KSFUN_TASK_NAMES


local taskdefs = require("tasks/ksfun_task_defs")
local randoms = {}
for k, v in pairs(NAMES) do
    if v ~= NAMES.KILL then
        table.insert(randoms, v)
    end
end

---随机生成一个任务，击杀任务占比为50%
---@return table|nil 任务数据
local function randomTask()
    local name = math.random() <= 0.5 and NAMES.KILL or GetRandomItem(randoms)
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