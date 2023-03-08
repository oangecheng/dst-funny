-- 生命值组件
local KsFunSanity = Class(function(self, inst)
    self.inst = inst
    self.level  = 0
    self.exp = 0
    self.exp_multi = 1
    self.sanity_up_func = nil
end)

-- 升级需要多少经验值
local function require_exp()
    return (self.level + 1) *100
end

-- 设置监听
function KsFunSanity:SetSanityUpFunc(func)
    self.sanity_up_func = func
end 

-- 获取经验
function KsFunSanity:GainExp(value)
    self.exp = self.exp + value

    -- 计算可以升的级数
    local delta = 0
    while self.exp > requireExp() do
        delta = delta + 1 
        self.exp = self.exp - requireExp()
        self.level = self.level + 1
    end

    -- 大于0表示可以升级，触发升级逻辑
    if delta > 0 and self.sanity_up_func ~= nil then
        self.sanity_up_func(self.inst, delta)
    end
end 

-- 读取数据
function KsFunSanity:OnLoad(data)
    self.level = data.level or 0
    self.exp = data.exp or 0
end

-- 存数据
function KsFunSanity:OnSave()
    return {
        level = self.level,
        exp = self.exp 
    }
end

return KsFunSanity 