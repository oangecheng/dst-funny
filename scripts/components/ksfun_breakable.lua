-- 最大次数
local MAX_CNT = 10

local function canBreak(self, doer, item)
    if self.enable and self.count < MAX_CNT then
        return self.breaktest == nil and true or self.breaktest(self.inst, doer, item)
    end
    return false
end


local Breakable = Class(function(self, inst)
    self.inst = inst
    self.enable = false
    self.count = 0

    self.onBreakFunc = nil
    self.breaktest = nil
end)


--- 突破成功的回调函数
---@param func function inst, doer, item 回调函数
function Breakable:SetOnBreakFunc(func)
    self.onBreakFunc = func
end


--- 是否可以突破的hook函数
---@param func function inst, doer, item 回调函数
function Breakable:SetBreakTest(func)
    self.breaktest = func
end


--- 判断是否可以突破
--- @param doer table 玩家
--- @param item table 材料
function Breakable:CanBreak(doer, item)
    return canBreak(self, doer, item)
end


--- 判断是否已经是最高等阶
--- @return boolean
function Breakable:IsMax()
    return self.count >= MAX_CNT
end


--- 是否可用
--- @return boolean
function Breakable:Enable()
    self.enable = true
end


--- 获取突破次数
--- @return number
function Breakable:GetCount()
    return self.count
end


--- 装备突破，能够提升最大等级上限
--- @param doer table 操作者
--- @param item table 用于突破的物品
function Breakable:Break(doer, item)
    if canBreak(self, doer, item) then
        self.count = self.count + 1
        if self.onBreakFunc then
            self.onBreakFunc(self.inst, doer, item)
        end
        if item then
            item:DoTaskInTime(0, item:Remove())
        end
    end
end


function Breakable:OnSave()
    return {
        enable = self.enable,
        count  = self.count,
    }
end


function Breakable:OnLoad(data)
    self.enable = data.enable
    self.count  = data.count or 0
end


return Breakable 