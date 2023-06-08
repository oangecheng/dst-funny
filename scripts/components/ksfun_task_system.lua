local MAX_TASK_NUM = 1
local MAX_TASK_NUM_SAME_TIME = 1



local function addTask(self, name, ent, data)
    KsFunLog("system addTask 1", name, data)
    if ent.components.ksfun_task then
        self.tasks[name] = {
            inst = ent,
        }
        KsFunLog("system addTask 2", name, data)
        ent.persists = false
        -- init函数会有去重逻辑，只有首次生成任务时才有意义
        ent.components.ksfun_task:Init(data)
        ent.components.ksfun_task:Attach(name, self.inst)
        if self.onTaskAddFunc then
            self.onTaskAddFunc(self.inst, name, ent)
        end
    else
        ent:Remove()
    end
end


local KSFUN_TASK_SYSTEM = Class(function(self, inst)
    self.inst = inst
    self.enable = true
    self.tasks = {}

    self.onTaskAddFunc = nil
    self.onTaskRemoveFunc = nil
end)


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

--- 设置新增属性监听
--- 一般用来刷新数据
function KSFUN_TASK_SYSTEM:SetOnTaskAddFunc(func)
    self.onTaskAddFunc = func
end


--- 设置属性移除监听
--- 一般用来刷新显示
function KSFUN_TASK_SYSTEM:SetOnTaskRemoveFunc(func)
    self.onTaskRemoveFunc = func
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
    KsFunLog("system AddTask 1", name, data)

    -- 超过最大数量时，不能再新增任务
    if #self.tasks >= MAX_TASK_NUM then
        print(KSFUN_TUNING.LOG_TAG.."cant add task because limit")
        return nil
    end

    local task = self.tasks[name]
    local ret = nil
    if task == nil then
        KsFunLog("system AddTask 2", name, data)
        local prefab = "ksfun_task_"..name
        local ent = SpawnPrefab(prefab)
        if ent then
            addTask(self, name, ent, data)
        end
        ret = ent
    else
        ret = task.inst
    end
    KsFunLog("system AddTask 3", name, data)
    self:SyncData()
    return ret
end


--- 彻底移除一个属性
--- 这个属性会被永久移除，一般用于
function KSFUN_TASK_SYSTEM:RemoveTask(name)
    local task = self.tasks[name]
    if task ~= nil then
        self.tasks[name] = nil
        if self.onTaskRemoveFunc then
            self.onTaskRemoveFunc(self.inst, name, task.inst)
        end
        if task.inst.components.ksfun_task then
            task.inst.components.ksfun_task:Deatch()
        else
            task.inst:Remove()
        end
        self:SyncData()
    end
end


--- 开始任务 
function KSFUN_TASK_SYSTEM:Start(name)
  
end


--- 指定暂停一个任务
--- 暂不实现
function KSFUN_TASK_SYSTEM:Stop(name)
    
end


--- 同步用户数据
--- 任务数据
function KSFUN_TASK_SYSTEM:SyncData()
    local data = ""
    for k,v in pairs(self.tasks) do
        local desc = v.inst.components.ksfun_task:GetDesc()
        -- 名称;等级;经验值;描述
        local d = k .. "," .. tostring(desc)
        data = data ..";".. d
    end
    KsFunLog("sync task data", data)
    if data and self.inst.replica.ksfun_task_system then
        self.inst.replica.ksfun_task_system:SyncData(data)
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