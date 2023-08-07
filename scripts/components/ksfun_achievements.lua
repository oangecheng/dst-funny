
local function sync(self)
    if self.inst.replica.ksfun_achievements then
        self.inst.replica.ksfun_achievements:SyncData(tostring(self.achievements))
    end
end


local ACHIEVEMENTS = Class(function(self, inst)
    self.inst  = inst
    self.achievements = 0
end)



function ACHIEVEMENTS:DoDelta(delta)
    self.achievements = math.max(self.achievements + delta)
    sync(self)
end


function ACHIEVEMENTS:SetValue(v)
    self.achievements = v
    sync(self)
end


function ACHIEVEMENTS:GetValue()
    return self.achievements
end


function ACHIEVEMENTS:OnSave()
    return {
        achievements = self.achievements,
    }
end


function ACHIEVEMENTS:OnLoad(data)
    self:SetValue(data.achievements or 0)
end


return ACHIEVEMENTS