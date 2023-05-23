

local ENHANTABLE = Class(function(self, inst)
    self.inst = inst
    self.items = {}

    self.onEnhantFunc = nil
end)


function ENHANTABLE:SetOnEnhantFunc(func)
    self.onEnhantFunc = func
end


function ENHANTABLE:SetItems(itemprefabs)
    self.items = itemprefabs
end


function ENHANTABLE:Enhant(item)
    if table.contains(self.items, item.prefab) then
        local level  = self.inst.components.ksfun_level
        local system = self.inst.components.ksfun_power_system
        if level and system and system:GetPowerNum() < level.lv then
            if self.onEnhantFunc then
                self.onEnhantFunc(self.inst, item)
            end
            item:DoTaskInTime(0, item:Remove())
        end
    end
end


function ENHANTABLE:OnSave()
    return {
        items = self.items
    }
end


function ENHANTABLE:OnLoad(data)
    self.items = data.items or {}
end


return ENHANTABLE