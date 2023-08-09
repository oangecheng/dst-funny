
local function canBreak(self, doer, item)
    if self.enable then
        return self.breaktest == nil and true or self.breaktest(self.inst, doer, item)
    end
    return false
end


local KSFUN_BREAKABLE = Class(function(self, inst)
    self.inst = inst
    self.enable = false
    self.count = 0

    self.onBreakFunc = nil
    self.breaktest = nil
end)


function KSFUN_BREAKABLE:SetOnBreakFunc(func)
    self.onBreakFunc = func
end


function KSFUN_BREAKABLE:SetBreakTest(func)
    self.breaktest = func
end


function KSFUN_BREAKABLE:CanBreak(doer, item)
    return canBreak(self, doer, item)
end


function KSFUN_BREAKABLE:Enable()
    self.enable = true
end


function KSFUN_BREAKABLE:GetCount()
    return self.count
end


--- 装备突破，能够提升最大等级上限
--- @param doer table 操作者
--- @param item table 用于突破的物品
function KSFUN_BREAKABLE:Break(doer, item)
    if canBreak(self, doer, item) then
        self.count = self.count + 1
        if self.onBreakFunc then
            self.onBreakFunc(self.inst, doer, item)
        end
        item:DoTaskInTime(0, item:Remove())
    end
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