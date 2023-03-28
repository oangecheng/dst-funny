
-- 查找任务
local function findExistTask(task, list)
    for i,v in ipairs(self.tasks) do
        if v.prefab == task.prefab then
            return i
        end
    end
    return nil
end


local KSFUN_TASK_SYSTEM = Class(function(self, inst)
    self.inst = inst
    self.tasks = {}
    self.current_task = nil
end)


-- 绑定任务
function KSFUN_TASK_SYSTEM:Attach(task)
    local i = findExistTask(task, self.tasks)
    if not i then
        table.insert(self.tasks, task)
    end
    -- 当前没有任务在执行，开始执行任务
    if not current_task then
        task.components.ksfun_task:Start(self.inst)
        current_task = task
    end
end


-- 将任务从队列当中移除
function KSFUN_TASK_SYSTEM:Detach(task)
    local i = findExistTask(task, self.tasks)
    if i then
        table.remove(self.tasks, i)
    end
    -- 当有任务移除时，5s后执行列表当中的下一个任务
    for i,v in ipairs(self.tasks) do
        self.inst:DoTaskInTime(5, function(inst)
            v.components.ksfun_task:Start(self.inst)
            current_task = v
        end)
        break
    end
end

return KSFUN_TASK_SYSTEM