-- 饱食度组件
local zxfun_sanity = Class(function(self, inst)
    self.inst = inst
    self.hunger = 0
end)

-- 饱食度增长
function zxfun_sanity:Increase(value)
    self.sanity = self.sanity + value
end

-- 饱食度下降
function zxfun_sanity:Decrease(value)
    self.sanity = self.sanity - value
end

-- 存取数据
function zxfun_sanity:OnLoad(data)
    self.sanity = data and data.sanity or 0
end

function zxfun_sanity:OnSave()
    return {
        sanity = self.sanity
    }
end

return zxfun_sanity