
local KSFUN_BREAKABLE = Class(function(self, inst)
    self.inst = inst
    self.enable = false
    self.count = 0

    self.onBreakFunc = nil
end)


function KSFUN_BREAKABLE:SetOnBreakFunc(func)
    self.onBreakFunc = func
end


function KSFUN_BREAKABLE:Enable()
    self.enable = true
end


function KSFUN_BREAKABLE:GetCount()
    return self.count
end


--- 装备突破，能够提升最大等级上限
function KSFUN_BREAKABLE:Break(doer, item)
    KsFunLog("break start", self.inst.prefab, item.prefab, self.enable)
    if self.enable and self.onBreakFunc then
        if self.onBreakFunc(self.inst, doer, item) then
            item:DoTaskInTime(0, item:Remove())
            self.count = self.count + 1
            KsFunLog("break success", self.inst.prefab)
            return true
        end
    end
    return false
end


function KSFUN_BREAKABLE:OnSave()
    return {
        enable = self.enable,
        count  = self.count,
    }
end


function KSFUN_BREAKABLE:OnLoad(data)
    self.enable = data.enable
    self.count  = data.count or 0
end


return KSFUN_BREAKABLE 