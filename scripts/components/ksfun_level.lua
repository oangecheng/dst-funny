
-- 升级需要多少经验值
local function defaultExpFunc(lv)
    return KSFUN_TUNING.DEBUG and 1 or (lv + 1) * 10
end


--- 等级数据变更
--- @param self table 组件
--- @param lvdelta any 等级变更值 
local function notifyStateChange(self, lvdelta)
    if self.onstatechange then
        self.onstatechange(self.inst, lvdelta)
    end
    if self.inst.replica.ksfun_level then
        self.inst.replica.ksfun_level:SyncData(tostring(self.lv))
    end
end


local KsFunLevel = Class(function(self, inst)
    self.inst = inst
    self.lv = 0
    self.exp = 0
    --- 不设置即无上限
    self.max = nil
end)



function KsFunLevel:SetOnStateChange(func)
    self.onstatechange = func
end


function KsFunLevel:SetLevel(lv)
    if self.max == nil or lv <= self.max then
        if self.lv ~= lv then
            local delta = lv - self.lv
            self.lv = lv
            notifyStateChange(self, delta)
        end
    end
end


function KsFunLevel:SetExpFunc(fn)
    self.expfn = fn
end


function KsFunLevel:GetLevel()
    return self.lv
end


function KsFunLevel:GetExp()
    return self.exp
end


function KsFunLevel:SetMax(max)
    self.max = max
    if self.max then
        self:SetLevel(math.min(self.max, self.lv))
    end
end


--- 判断当前是否已是最大等级
function KsFunLevel:IsMax()
    return self.max and self.lv >= self.max
end


--- <0降低 or >0提升等级
function KsFunLevel:DoDelta(delta)
    if delta ~= 0 then
        self:SetLevel(self.lv + delta)
    end
end


function KsFunLevel:DoExpDelta(exp)
    if self:IsMax() then
        self.exp = 0
        return
    end
    self.exp = math.max(self.exp + exp, 0)
    local func = self.expfn or defaultExpFunc
    local lv = self.lv
    while self.exp >= func(lv) do
        self.exp = self.exp - func(lv)
        lv = lv + 1
    end

    if lv ~= self.lv then
        self:SetLevel(lv)
    else
        notifyStateChange(self)
    end
end



function KsFunLevel:OnSave()
    return {
        lv  = self.lv,
        exp = self.exp,
    }
end


function KsFunLevel:OnLoad(data)
    self:SetLevel(data.lv or 0)
    self.exp = data.exp or 0
end


return KsFunLevel