
local KSFUN_TASK_SYSTEM = Class(function(self, inst)
    self.inst = inst
    self.task = nil
end)


function KSFUN_TASK_SYSTEM:Attach(task)
    self.task = task
end

function KSFUN_TASK_SYSTEM:Detach(task)
    self.task = nil
end

return KSFUN_TASK_SYSTEM