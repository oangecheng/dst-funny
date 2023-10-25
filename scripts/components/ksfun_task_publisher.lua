
local helper = require("tasks/ksfun_task_helper")


local function updateTask(self)
    if self.listener ~= nil then
        self.listener(self.inst, self.tasks)
    end
end


local TaskPublisher = Class(function (self, inst)
    self.inst = inst
    self.tasks = nil
end)


function TaskPublisher:SetListener(func)
    self.listener = func
end


function TaskPublisher:CreateTasks(num)
    self.tasks = {}
    for i = 1, num do
        local task = helper.randomTaskData()
        if KsFunGetTaskDesc(task) ~= nil then
            self.task[i] = task
        end
    end
    updateTask(self)
end


function TaskPublisher:GetTasks()
    return self.tasks
end


function TaskPublisher:ClearTasks()
    self.tasks = nil
    updateTask(self)
end


--- 接任务
function TaskPublisher:TakeTask(doer, taskid)
    local system = doer and doer.components.ksfun_task_system
    local task = self.tasks and self.tasks[taskid]
    if system and task then
        local ret = system:AddTask(task.name, task)
        if ret ~= nil then
            table.remove(self.tasks, taskid)
            updateTask(self)
            return true
        end
    end
    return false    
end


function TaskPublisher:OnSave()
    return {
        tasks = self.tasks
    }
end


function TaskPublisher:OnLoad(data)
    self.tasks = data.tasks or nil
end


return TaskPublisher