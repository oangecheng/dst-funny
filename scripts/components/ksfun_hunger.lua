-- 生命值组件
local KsFunHunger = Class(function(self, inst)
    self.inst = inst
    self.level  = 0
    self.exp = 0
    self.exp_multi = 1
    self.hunger_up_func = nil
end)

-- 升级需要多少经验值
local function require_exp(level)
    return (level + 1) *100
end


function KsFunHunger:SetLevel(level, gain_exp)
    self.level = level
       -- 大于0表示可以升级，触发升级逻辑
    if self.hunger_up_func ~= nil then
        self.hunger_up_func(self.inst, gain_exp)
    end
end

-- 设置监听
function KsFunHunger:SetHungerUpFunc(func)
    self.hunger_up_func = func
end 

-- 获取经验
function KsFunHunger:GainExp(value)
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
        SetLevel(self.level, true)
    end
end 

-- 读取数据
function KsFunHunger:OnLoad(data)
    self.level = data.level or 0
    self.exp = data.exp or 0
end

-- 存数据
function KsFunHunger:OnSave()
    return {
        level = self.level,
        exp = self.exp 
    }
end




return KsFunHunger 