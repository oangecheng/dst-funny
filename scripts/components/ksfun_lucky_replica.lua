local function OnContentDirty(self, inst)
    local lucky = self._content:value()
    self.lucky = lucky and tonumber(lucky) or 0
end

local LUCKY = Class(function(self, inst)
    self.inst = inst
    self.lucky = 0

    self._content = net_string(inst.GUID, "ksfun_lucky._content", "ksfun_itemdirty")
    inst:ListenForEvent("ksfun_itemdirty", function(inst) OnContentDirty(self, inst) end)
end, nil, {})


function LUCKY:GetLucky()
    return self.lucky
end


function LUCKY:SyncData(data)
    self._content:set_local(data)
    self._content:set(data)
end


return LUCKY