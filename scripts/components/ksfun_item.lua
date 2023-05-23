
local KSFUN_ITEM = Class(function(self, inst)
    self.inst = inst
    self.enable = false
end)

function KSFUN_ITEM:Enable()
    self.enable = true
end

function KSFUN_ITEM:OnSave()
    return { enable = self.enable }
end

function KSFUN_ITEM:OnLoad(data)
    self.enable = data.enable
end

return KSFUN_ITEM