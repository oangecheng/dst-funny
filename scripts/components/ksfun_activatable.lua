
local ACTIVATE = Class(function(self, inst)
    self.inst = inst
    self.onactivate = nil
    self.isactivated = false
end)


function ACTIVATE:SetOnActivate(cb)
    self.onactivate = cb
end


function ACTIVATE:CanActivate()
    return not self.isactivated
end


function ACTIVATE:IsActivated()
    return self.isactivated
end


function ACTIVATE:DoActivate(doer, item)
    self.isactivated = true
    if self.onactivate then
        self.onactivate(self.inst, doer, item)
    end
end


function ACTIVATE:OnSave()
    return {
        isactivated = self.isactivated
    }
end


function ACTIVATE:OnLoad(data)
    self.isactivated = data.isactivated
end


return ACTIVATE