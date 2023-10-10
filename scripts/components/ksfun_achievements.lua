local STEP = 256

local function sync(self)
    if self.inst.replica.ksfun_achievements then
        self.inst.replica.ksfun_achievements:SyncData(tostring(self.achievements))
    end
end


local Achievement = Class(function(self, inst)
    self.inst  = inst
    self.achievements = 0
    self.stepvalue = 0
end)


--- @param delta number 获得成就点
function Achievement:DoDelta(delta)
    self.stepvalue = self.stepvalue + math.max(0, delta)
    self.achievements = math.max(self.achievements + delta)
    sync(self)
end


function Achievement:SetValue(v)
    self.achievements = v
    sync(self)
end


function Achievement:Consume()
    if self.stepvalue >= STEP then
       self.stepvalue = self.stepvalue - STEP
       return true
    end
    return false
end


function Achievement:GetValue()
    return self.achievements
end


function Achievement:OnSave()
    return {
        achievements = self.achievements,
        stepvalue = self.stepvalue,
    }
end


function Achievement:OnLoad(data)
    self.stepvalue = data.stepvalue or 0
    self:SetValue(data.achievements or 0)
end


return Achievement