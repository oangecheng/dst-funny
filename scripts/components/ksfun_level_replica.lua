local function OnContentDirty(self, inst)
    local lv = self._content:value()
    KsFunLog("WORLD_MONSTER", lv)
    self.lv = lv and tonumber(lv) or 0
end

local LEVEL = Class(function(self, inst)
    self.inst = inst
    self.lv = 0

    self._content = net_string(inst.GUID, "ksfun_world_monster._content", "ksfun_itemdirty")
    inst:ListenForEvent("ksfun_itemdirty", function(inst) OnContentDirty(self, inst) end)
end, nil, {})


function LEVEL:GetLevel()
    return self.lv
end


function LEVEL:SyncData(data)
    self._content:set_local(data)
    self._content:set(data)
end


return LEVEL