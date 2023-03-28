
-- 任务状态变更
local function onTaskStateChange(task)
    if not (task and task.player and task.inst) then return end
    local state = task.state
    -- 任务成功或者失败需要从任务系统当中移除
    if (state == 0) or (state == -1) then
        local task_system = task.player.components.ksfun_task_system
        if task_system then
            task_system:Detach(task.inst)
        end
    end
end


-- 初始化角色
AddPlayerPostInit(function(player)
    player:AddComponent("ksfun_task_system")
    player:ListenForEvent("ksfun_task_state", onTaskStateChange)
end)