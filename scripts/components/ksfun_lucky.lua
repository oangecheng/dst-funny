local MAX = 100

local function sync(self)
    if self.inst.replica.ksfun_lucky then
        self.inst.replica.ksfun_lucky:SyncData(tostring(self.lucky))
    end
end


local LUCKY = Class(function(self, inst)
    self.inst  = inst
    self.lucky = 0
    self.basemulti = 1
    self.multipliers = SourceModifierList(inst, 0, SourceModifierList.additive)
end)



function LUCKY:DoDelta(delta)
    self.lucky = math.clamp(self.lucky + delta, 0, MAX)
    sync(self)
end


function LUCKY:SetLucky(v)
    self.lucky = v
    sync(self)
end


function LUCKY:SetMulti(multi)
    self.basemulti = multi
end


function LUCKY:GetLucky()
    return self.lucky
end


function LUCKY:GetDisplayLucky()
    local v = self.lucky * self.basemulti + self.multipliers:Get()
    return math.floor(v + 0.5)
end


function LUCKY:GetRatio()
    return 0.01 * self:GetDisplayLucky()
end


function LUCKY:AddModifier(source, v)
    if source ~= nil then
        self.multipliers:SetModifier(source, v)
    end
end


function LUCKY:RemoveModifier(source)
    if source ~= nil then
        self.multipliers:RemoveModifier(source)
    end
end


function LUCKY:OnSave()
    return {
        basemulti = self.basemulti,
        lucky = self.lucky,
    }
end


function LUCKY:OnLoad(data)
    self.basemulti = data.basemulti or 1
    self:SetLucky(data.lucky or 0)
end


return LUCKY