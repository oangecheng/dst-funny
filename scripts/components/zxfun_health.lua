-- 生命值组件
local zxfun_health = Class(function(self, inst)
    self.inst = inst
    self.health  = 0
end)

-- 饱食度增长
function zxfun_health:Increase(value)
    self.health = self.health + value
end

-- 饱食度下降
function zxfun_health:Decrease(value)
    self.health = self.health - value
end

-- 存取数据
function zxfun_health:OnLoad(data)
    self.health = data and data.health or 0
end

function zxfun_health:OnSave()
    return {
        health = self.health 
    }
end

return zxfun_health 