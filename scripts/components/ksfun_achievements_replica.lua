local function OnContentDirty(self, inst)
    local achievements = self._content:value()
    self.achievements = achievements and tonumber(achievements) or 0
end

local ACHIEVEMENTS = Class(function(self, inst)
    self.inst = inst
    self.achievements = 0

    self._content = net_string(inst.GUID, "ksfun_achievements._content", "ksfun_itemdirty")
    inst:ListenForEvent("ksfun_itemdirty", function(inst) OnContentDirty(self, inst) end)
end, nil, {})


function ACHIEVEMENTS:GetValue()
    return self.achievements
end


function ACHIEVEMENTS:SyncData(data)
    self._content:set_local(data)
    self._content:set(data)
end


return ACHIEVEMENTS