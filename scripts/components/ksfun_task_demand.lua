

local TASK_DEMAND = Class(function(self, inst)
    self.inst = inst
    self.demand = nil
end)


function TASK_DEMAND:GetDemand()
    return self.demand
end


function TASK_DEMAND:SetDemand(demand)
    if demand == nil then return end
    self.demand = demand
    local desc = KsFunGetTaskDesc(self.demand)
    -- 任务显示有问题，移除这个任务卷轴
    if desc == nil then
        KsFunLog("SetDemand fail", self.demand.name)
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