
-- 升级需要多少经验值
local function defaultExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (lv + 1) * 10
end


local KSFUN_LEVEL = Class(function(self, inst)
    self.inst = inst
    self.lv = 0
    self.exp = 0
    --- 不设置即无上限
    self.max = 10000

    self.onLvChangeFunc = nil
    self.nextLvExpFunc = nil
end)


function KSFUN_LEVEL:SetOnLvChangeFunc(func)
    self.onLvChangeFunc = func
end


function KSFUN_LEVEL:SetNextLvExpFunc(func)
    self.nextLvExpFunc = func
end


function KSFUN_LEVEL:SetLevel(lv)
    if lv == self.lv then
        return
    end

    local originlv = self.lv
    if lv >= self.max then self.exp = 0 end
    self.lv = math.min(lv, self.max)
    local delta = self.lv - originlv

    if self.onLvChangeFunc then
        self.onLvChangeFunc(self.inst, { delta = delta, lv = self.lv })
    end
    if self.inst.replica.ksfun_level then
        self.inst.replica.ksfun_level:SyncData(tostring(self.lv))
    end
    self.inst:PushEvent("ksfun_level_changed", {lv = self.lv, exp = self.exp})   
end


function KSFUN_LEVEL:GetLevel()
    return self.lv
end


function KSFUN_LEVEL:GetExp()
    return self.exp
end


function KSFUN_LEVEL:SetMax(max)
    self.max = max
    self:SetLevel(math.min(self.max, self.lv))
end


function KSFUN_LEVEL:GetMax()
    return self.max
end



function KSFUN_LEVEL:UpMax(v)
    self.max = self.max + v or 1
end


--- 判断当前是否已是最大等级
function KSFUN_LEVEL:IsMax()
    return self.lv >= self.max
end


function KSFUN_LEVEL:Up(v)
    if v and v > 0 then
        self:SetLevel(self.lv + v, true)
    end
end


--- <0降低 or >0提升等级
function KSFUN_LEVEL:DoDelta(delta)
    if delta ~= 0 then
        self:SetLevel(self.lv + delta)
    end
end


function KSFUN_LEVEL:LoseLv(lv)
    if lv > 0 then
        self:SetLevel(self.lv - lv)
    end
end


--- 获取剩余可升级次数
function KSFUN_LEVEL:GetLeftUpCount()
    return self.max - self.lv
end


function KSFUN_LEVEL:GainExp(exp)
    -- 小于0掉经验，不会掉级
    if exp < 0 then
        self:LoseExp(-exp)
        return
    end

    local e = math.floor(exp)
    self.exp = self.exp + e
    local expFun = defaultExpFunc

     -- 计算可以升的级数
    local lv = self.lv
    while self.exp >= expFun(self.inst, lv) do
        self.exp = self.exp - expFun(self.inst, lv)
        lv = lv + 1
    end
 
     -- 大于0表示可以升级，触发升级逻辑
    self:SetLevel(lv)
    -- 刷新客户端数据
    self.inst:PushEvent("ksfun_level_changed", {lv = self.lv, exp = self.exp})   
end


function KSFUN_LEVEL:LoseExp(exp)
    self.exp = math.max(self.exp - exp, 0)
    self.inst:PushEvent("ksfun_level_changed", {lv = self.lv, exp = self.exp})   
end


function KSFUN_LEVEL:OnSave()
    return {
        lv  = self.lv,
        exp = self.exp,
        max = self.max,
    }
end


function KSFUN_LEVEL:OnLoad(data)
    self.lv  = data.lv or 0
    self.exp = data.exp or 0
    self.max = data.max or 10000
end


return KSFUN_LEVEL