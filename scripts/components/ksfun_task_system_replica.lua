

local function onTaskDataDirty(self, inst)
    local data = self._itemtasks:value()
    if data == nil then return end
    
    if data ~= "" then
        local d1 = string.split(data, ";")
        for i1,v1 in pairs(d1) do
            local d2 = string.split(v1, ",")
            if #d2 == 2 then
                local name = d2[1]
                local desc = d2[2]
                self.tasks[name] = {
                    desc = desc
                }
            end
        end
    else
        self.tasks = {}
    end

    KsFunLog("onTaskDataDirty", data)
    if self.inst then
        self.inst:PushEvent(KSFUN_TUNING.EVENTS.PLAYER_PANEL, self.tasks)
    end

end


local KSFUN_TASK_SYSTEM = Class(function(self, inst)
    self.inst = inst
    self.tasks= {}
    self.onTasksChangeFunc = nil

    self._itemtasks= net_string(inst.GUID, "ksfun_power_system._itemtasks", "ksfun_itemdirty")
    self.inst:ListenForEvent("ksfun_itemdirty", function(inst) onTaskDataDirty(self, inst) end)

end)


function KSFUN_TASK_SYSTEM:SyncData(data)
    self._itemtasks:set_local(data)
    self._itemtasks:set(data)
end



function KSFUN_TASK_SYSTEM:GetTasks()
    return self.tasks
end


return KSFUN_TASK_SYSTEM