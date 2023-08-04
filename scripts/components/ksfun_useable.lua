
local USEABLE = Class(function(self, inst)
    self.inst = inst
    self.onused = nil
end)


function USEABLE:SetOnUse(onused)
    self.onused = onused
end


function USEABLE:Use(doer, target)
    if target and self.onused then
        self.onused(self.inst, doer, target)
    end
end



return USEABLE