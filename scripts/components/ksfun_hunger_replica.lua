local function OnItemDirty(self, inst)
    local data = self._itemdata:value()
    self.level = data or 0
end

-- 生命值组件
local KsFunHunger = Class(function(self, inst)
    self.inst = inst
    self.level = 0
    self._itemdata = net_string(inst.GUID, "ksfun_hunger._itemdata", "ksfun_itemdirty")
    inst:ListenForEvent("ksfun_itemdirty", function(inst) OnItemDirty(self, inst) end)

end)


function KsFunHunger:SyncData(data)
    print("哈哈哈")
    self._itemdata:set_local(data)
    self._itemdata:set(data)
end


return KsFunHunger 