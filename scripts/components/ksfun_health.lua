-- 生命值组件
local KsFunHealth = Class(function(self, inst)
    self.inst = inst
    self.level  = 0
    self.exp = 0
    self.exp_multi = 1
    self.health_up_func = nil
end)

-- 升级需要多少经验值
local function require_exp(level)
    return (level + 1) * 100
end

function KsFunHunger:SetLevel(level, gain_exp)
    self.level = level
       -- 大于0表示可以升级，触发升级逻辑
    if self.health_up_func ~= nil then
        self.health_up_func(self.inst, gain_exp)
    end
end

-- 设置监听
function KsFunHealth:SetHealthUpFunc(func)
    self.health_up_func = func
end

-- 获取经验
function KsFunHealth:GainExp(value)
    self.exp = self.exp + value

    -- 计算可以升的级数
    local delta = 0
    while self.exp > require_exp(self.level) do
        delta = delta + 1 
        self.exp = self.exp - require_exp(self.level)
        self.level = self.level + 1
    end

    -- 大于0表示可以升级，触发升级逻辑
    if delta > 0 then
        self:SetLevel(self.level, true)
    end
end 

-- 读取数据
function KsFunHealth:OnLoad(data)
    self.level = data.level or 0
    self.exp = data.exp or 0
end

-- 存数据
function KsFunHealth:OnSave()
    return {
        level = self.level,
        exp = self.exp 
    }
end

return KsFunHealth 