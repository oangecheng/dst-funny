

local Enhantable = Class(function(self, inst)
    self.inst = inst
    self.enable = false

    --- @type function
    self.onEnhantFunc = nil
    --- @type function 
    self.enhantTest = nil
end)


--- @param func function callback
function Enhantable:SetOnEnhantFunc(func)
    self.onEnhantFunc = func
end


--- @param func function callback
function Enhantable:SetEnhantTest(func)
    self.enhantTest = func
end


function Enhantable:IsEnable()
    return self.enable
end


function Enhantable:Enable()
    self.enable = true
end


---@return boolean
function Enhantable:CanEnhant(doer, item)
    if self.enable then
        return self.enhantTest == nil and true or self.enhantTest(self.inst, doer, item)
    end
    return false
end


--- 尝试附魔
function Enhantable:Enhant(doer, item)
    if self:CanEnhant(doer, item) then
        if self.onEnhantFunc then
            self.onEnhantFunc(self.inst, doer, item)
        end
        item:DoTaskInTime(0, item:Remove())
    end
end


function Enhantable:OnSave()
    return {
        enable = self.enable
    }
end


function Enhantable:OnLoad(data)
    self.enable = data.enable
end


return Enhantable