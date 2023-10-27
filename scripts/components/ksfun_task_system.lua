local MAX_TASK_NUM = 1


local function addTask(self, name, ent, data)
    if ent.components.ksfun_task then
        self.tasks[name] = {
            inst = ent,
        }
        ent.persists = false
        -- init函数会有去重逻辑，只有首次生成任务时才有意义
        ent.components.ksfun_task:Init(data)
        ent.components.ksfun_task:Attach(name, self.inst)
    else
        ent:Remove()
    end
end


local KSFUN_TASK_SYSTEM = Class(function(self, inst)
    self.inst = inst
    self.enable = true
    self.tasks = {}
end)


function KSFUN_TASK_SYSTEM:SetOnListener(listener)
    self.listener = listener
end


function KSFUN_TASK_SYSTEM:GetTask(name)
    local task = nil
    if name == nil then
        if not IsTableEmpty(self.tasks) then
            task = GetRandomItem(self.tasks)
        end
    else
        task = self.tasks[name]
    end
    return task and task.inst or nil
end


function KSFUN_TASK_SYSTEM:GetAllTasks()
    local tasks = {}
    for k, v in pairs(self.tasks) do
        tasks[k] = v.inst
    end
    return tasks
end




function KSFUN_TASK_SYSTEM:GetTaskNum()
    return GetTableSize(self.tasks)
end



function KSFUN_TASK_SYSTEM:CanAddMoreTask()
    return GetTableSize(self.tasks) < MAX_TASK_NUM
end



function KSFUN_TASK_SYSTEM:CanAddTaskByName(name)
    return self.tasks[name] == nil
end


function KSFUN_TASK_SYSTEM:SetEnable(enable)
    self.enable = enable
end


function KSFUN_TASK_SYSTEM:IsEnable()
    return self.enable
end


--- 新增一个属性
--- @param name type=string
function KSFUN_TASK_SYSTEM:AddTask(name, data)
    
    if not (self:CanAddMoreTask() and self:CanAddTaskByName(name)) then
        return nil
    end

    local task = self.tasks[name]
    local ret = nil
    if task == nil then
        local prefab = "ksfun_task_"..name
        local ent = SpawnPrefab(prefab)
        if ent then
            addTask(self, name, ent, data)
        end
        ret = ent
    else
        ret = task.inst
    end
    self:SyncData()
    return ret
end


--- 彻底移除一个属性
--- 这个属性会被永久移除，一般用于
function KSFUN_TASK_SYSTEM:RemoveTask(name)
    local task = self.tasks[name]
    if task ~= nil then
        self.tasks[name] = nil
        if task.inst.components.ksfun_task then
            task.inst.components.ksfun_task:Deatch()
        else
            task.inst:Remove()
        end
        self:SyncData()
    end
end


--- 同步用户数据
--- 任务数据
function KSFUN_TASK_SYSTEM:SyncData()
    if self.listener then
        self.listener(self.inst, self.tasks)
    end
end



function KSFUN_TASK_SYSTEM:OnSave()
    if next(self.tasks) == nil then return end
    local data = {}
    for k, v in pairs(self.tasks) do
        local saved--[[, refs]] = v.inst:GetSaveRecord()
        data[k] = saved
    end
    return { tasks = data, enable = self.enable }
end


function KSFUN_TASK_SYSTEM:OnLoad(data)
    if data then
        self.enable = data.enable or true
    end
    if data ~= nil and data.tasks ~= nil then
        for k, v in pairs(data.tasks) do
            if self.tasks[k] == nil then
                local ent = SpawnSaveRecord(v)
                if ent ~= nil then
                    addTask(self, k, ent)
                end
            end
        end
    end
    self:SyncData()
end


return KSFUN_TASK_SYSTEM