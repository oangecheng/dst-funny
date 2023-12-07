
-- 升级需要多少经验值
local function defaultExpFunc(lv)
    return KSFUN_TUNING.DEBUG and 1 or (lv + 1) * 10
end


local function onlvfn(self, lv)
    self.inst.replica.ksfun_level:SyncData(tostring(self.lv))
    if self.onlvfn then
        self.onlvfn(self.inst, lv, self:IsMax())
    end
end


local KsFunLevel = Class(function(self, inst)
    self.inst = inst
    self.lv = 0
    self.exp = 0
    self.max = math.maxinteger
end,
nil,
{
    lv = onlvfn
})


---comment 自定义经验函数
---@param fn function
function KsFunLevel:SetExpFunc(fn)
    self.expfn = fn
end


function KsFunLevel:SetOnStateChange(fn)
    self.onstatefn = fn
end


---comment 设置等级变化的监听函数
---@param fn function
function KsFunLevel:SetOnLvFn(fn)
    self.onlvfn = fn
end


---comment 设置等级，一般只用在怪物身上
---@param lv integer 等级
function KsFunLevel:SetLevel(lv)
    local tlv = self.max and math.min(lv, self.max) or lv
    if tlv ~= self.lv then
        self.lv = tlv
    end
end




function KsFunLevel:GetLevel()
    return self.lv
end


function KsFunLevel:GetExp()
    return self.exp
end


function KsFunLevel:SetMax(max)
    self.max = max or math.maxinteger
    self:SetLevel(self.lv)
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


---comment 获取经验值
---@param exp any
function KsFunLevel:DoExpDelta(exp)
    if self:IsMax() then
        return
    end
    self.exp = math.max(self.exp + exp, 0)
    local fn = self.expfn or defaultExpFunc
    local lv = self.lv
    while self.exp >= fn(lv) do
        self.exp = self.exp - fn(lv)
        lv = lv + 1
    end

    if lv ~= self.lv then
        self:SetLevel(lv)
    end

    if self:IsMax() then
        self.exp = 0
    end
    if self.onstatefn then
        self.onstatefn(self.inst)
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