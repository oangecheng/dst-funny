

local TASK_DEMAND = Class(function(self, inst)
    self.inst = inst
    self.demand = nil
end)


function TASK_DEMAND:SetDemand(demand)
    self.demand = demand
    if self.inst.replica.ksfun_task_demand then
        self.inst.replica.ksfun_task_demand("击杀1只猪")
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