

local TASK_DEMAND = Class(function(self, inst)
    self.inst = inst
    self.demand = nil
end)


function TASK_DEMAND:GetDemand()
    return self.demand
end


function TASK_DEMAND:SetDemand(task)
    if task == nil then return end
    self.demand = task
    local desc = KsFunGetTaskDesc(self.demand)
    -- 任务显示有问题，移除这个任务卷轴
    if desc == nil then
        local demand = task and task.demand or nil
        local data = demand and demand.data or nil
        local content = data and data.victim or nil
        local type = demand and demand.type or nil
        KsFunLog("SetDemand fail", task.name, type, content)
        return false
    else
        if self.inst.replica.ksfun_task_demand then
            self.inst.replica.ksfun_task_demand:SyncData(desc)
        end
        return true
    end
end


function TASK_DEMAND:OnSave()
    return {
        demand = self.demand
    }
end


function TASK_DEMAND:OnLoad(data)
    self.demand = data.demand or nil
    self:SetDemand(self.demand)
end

return TASK_DEMAND