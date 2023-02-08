-- 饱食度组件
local zxfun_hunger = Class(function(self, inst)
    self.inst = inst
    self.hunger = 0
end)

-- 饱食度增长
function zxfun_hunger:Increase(value)
    self.hunger = self.hunger + value
end

-- 饱食度下降
function zxfun_hunger:Decrease(value)
    self.hunger = self.hunger - value
end

-- 存取数据
function zxfun_hunger:OnLoad(data)
    self.hunger = data and data.hunger or 0
end

function zxfun_hunger:OnSave()
    return {
        hunger = self.hunger
    }
end

return zxfun_hunger