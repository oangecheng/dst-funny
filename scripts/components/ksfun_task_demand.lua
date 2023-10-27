

local TaskDemand = Class(function(self, inst)
    self.inst = inst
    self.demand = nil
    self.onBind = nil

end)


function TaskDemand:GetDemand()
    return self.demand
end


function TaskDemand:SetOnBind(func)
    self.onBind = func
end


function TaskDemand:Bind(task)
    if task == nil then return end
    self.demand = task

    local content = nil
    if content ~= nil then
        if self.onBind then
            self.onBind(self.inst, self.demand, content)
        end
        return true
    end

    return false
    
end


function TaskDemand:OnSave()
    return {
        demand = self.demand
    }
end


function TaskDemand:OnLoad(data)
    self:Bind(data.demand)
end

return TaskDemand