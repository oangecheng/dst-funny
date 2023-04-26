
-- 任务状态变更
local function onTaskStateChange(inst, task)
    if not (task and task.target and task.inst) then return end
    local task_system = task.target.components.ksfun_task_system
    if task_system then
        task_system:Detach(task.inst)
    end
end


-- 初始化角色
AddPlayerPostInit(function(player)
    player:AddComponent("ksfun_task_system")
    player:AddComponent("ksfun_powers")

    player:ListenForEvent("ksfun_task_finish", onTaskStateChange)
end)