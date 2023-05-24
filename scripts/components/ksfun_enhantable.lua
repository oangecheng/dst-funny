

local ENHANTABLE = Class(function(self, inst)
    self.inst = inst
    self.enable = false
    self.onEnhantFunc = nil
end)


function ENHANTABLE:SetOnEnhantFunc(func)
    self.onEnhantFunc = func
end


function ENHANTABLE:Enable()
    self.enable = true
end


--- 尝试附魔
function ENHANTABLE:Enhant(item)
    KsFunLog("enhant start", self.inst.prefab, item.prefab, self.enable)
    if self.enable and self.onEnhantFunc then
        if self.onEnhantFunc(self.inst, item) then
            KsFunLog("enhant success")
            item:DoTaskInTime(0, item:Remove())
            return true
        end
    end
    return false
end


function ENHANTABLE:OnSave()
    return {
        enable = self.enable
    }
end


function ENHANTABLE:OnLoad(data)
    self.enable = data.enable
end


return ENHANTABLE