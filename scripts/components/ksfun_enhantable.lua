

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
    if table.contains(item.prefab) then
        local level = self.inst.components.ksfun_level
        if not level:IsMax() then
            level:Up(1)
            item:Remove()
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