

local function OnContentDirty(self, inst)
    self.content = self._content:value()
end

local TASK_DEMAND = Class(function(self, inst)
    self.inst = inst

    self._content = net_string(inst.GUID, "ksfun_task_demand._content", "ksfun_itemdirty")
    inst:ListenForEvent("ksfun_itemdirty", function(inst) OnContentDirty(self, inst) end)
end, nil, {})


function TASK_DEMAND:GetContent(content)
    return self.content
end


function TASK_DEMAND:SyncData(content)
    self._content:set_local(content)
    self._content:set(content)
end


return TASK_DEMAND