
-- 升级需要多少经验值
local function defaultExpFunc(inst, lv)
    return (lv + 1) * 100
end


local KSFUN_LEVEL = Class(function(self, inst)
    self.inst = inst
    self.lv = 0
    self.exp = 0
    --- 不设置即无上限
    self.max = 10000

    self.onLvChangeFunc = nil
    self.onStateChangeFunc = nil
    self.nextLvExpFunc = nil
end)


function KSFUN_LEVEL:SetOnLvChangeFunc(func)
    self.onLvChangeFunc = func
end

function KSFUN_LEVEL:SetOnStateChangeFunc(func)
    self.onStateChangeFunc = func
end

function KSFUN_LEVEL:SetNextLvExpFunc(func)
    self.nextLvExpFunc = func
end


function KSFUN_LEVEL:SetLevel(lv, notice)
    if lv < max then
        self.lv = lv
    else
        self.lv = max
        self.exp = 0
    end

    if self.onLvChangeFunc then
        self.onLvChangeFunc(self.inst, lv, notice)
    end    
end


--- 判断当前是否已是最大等级
function KSFUN_LEVEL:IsMax()
    return self.lv == self.max
end


function KSFUN_LEVEL:Up(v)
    if v and v > 0 then
        self:SetLevel(self.lv, true)
        if self.onStateChangeFunc then
            self.onStateChangeFunc(self.inst)
        end
    end
end


--- 获取剩余可升级次数
function KSFUN_LEVEL:GetLeftUpCount()
    return self.max - self.lv
end


function KSFUN_LEVEL:GainExp(exp)
    self.exp = self.exp + exp

    local expFun = nil
    if self.nextLvExpFunc then
        expFun = self.nextLvExpFunc
    else
        expFun = defaultExpFunc
    end

     -- 计算可以升的级数
    local delta = 0
    while self.exp > expFun(self.inst, self.lv) do
        delta = delta + 1 
        self.exp = self.exp - expFun(self.inst, self.lv)
    end
 
     -- 大于0表示可以升级，触发升级逻辑
    if delta > 0 then
        self:SetLevel(self.lv + delta, true)
    end

    -- 刷新客户端数据
    if self.onStateChangeFunc then
        self.onStateChangeFunc(self.inst)
    end
end


function KSFUN_LEVEL:OnSave()
    return {
        lv = self.lv,
        exp = self.exp,
        max = self.max,
    }
end


function KSFUN_LEVEL:OnLoad(data)
    self.lv = data.lv or 0
    self.exp = data.exp or 0
    self.max = data.max or 10000
end


return KSFUN_LEVEL