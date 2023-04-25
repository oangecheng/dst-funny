
-- 查找任务
local function findExistTask(task, list)
    for i,v in ipairs(list) do
        if v.name == task.name then
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
        task.components.ksfun_task:Bind(self.inst)
    end
end


-- 开始执行任务
function KSFUN_TASK_SYSTEM:Start(task)
    if self.current_task ~= nil then return end
    local next_t = nil
    for i,v in ipairs(self.tasks) do
        next_t = v
        break
    end
    if next_t ~= nil then
        self.current_task = next_t
        self.current_task.components.ksfun_task:Start()
    end
end


-- 将任务从队列当中移除
function KSFUN_TASK_SYSTEM:Detach(task)
    self.current_task = nil
    local i = findExistTask(task, self.tasks)
    print("哈哈哈哈"..tostring(i))
    if i then
        table.remove(self.tasks, i)
        self:Start()
    end
end

return KSFUN_TASK_SYSTEM