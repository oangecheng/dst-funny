
local KSFUN_TASK = Class(function(self, inst)
    self.inst = inst
    self.tasks = {}
end)


function KSFUN_TASK:Start(task)
    table.insert(self.tasks, task)
end

function KSFUN_TASK:Complete(task)
    
end

return KSFUN_TASK