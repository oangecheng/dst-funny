local MAX = 100

local LUCKY = Class(function(self, inst)
    self.inst  = inst
    self.lucky = 0
    self.basemulti = 1
    self.multipliers = SourceModifierList(inst, 0, SourceModifierList.additive)
end)



function LUCKY:DoDelta(delta)
    local v = math.max(0, self.lucky + delta)
    self.lucky = math.min(MAX, v)
end


function LUCKY:GetLucky()
    local v = (self.lucky + self.multipliers:Get()) * self.basemulti
    return math.floor(v + 0.5 )
end


function LUCKY:GetLuckyRatio()
    return 1 + 0.01 * self:GetLucky()
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
    self.lucky = data.lucky or 0
end


return LUCKY