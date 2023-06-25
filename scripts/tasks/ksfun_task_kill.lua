
local NAME = KSFUN_TUNING.TASK_NAMES.KILL
local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL


local function descFunc(inst, player, name, d)
    local taskdata = inst.components.ksfun_task:GetTaskData()
    return KsFunGeneratTaskDesc(taskdata)
end


-- 击杀任务目标
local function onKillOther(killer, data)
    local victim = data.victim

    if killer.components.ksfun_task_system then
        local inst = killer.components.ksfun_task_system:GetTask(NAME)
        local kill_task = inst and inst.components.ksfun_task or nil
        if kill_task then
            local demand = kill_task:GetTaskData().demand
            if demand.data.victim and demand.data.num then
                if demand.data.victim == victim.prefab then
                    demand.data.num = demand.data.num - 1
                end
                if demand.data.num < 1 then
                    kill_task:Win()
                end 
            end
        end
    end
end


-- 无伤任务
local function onAttacked(inst, data)
    local task = inst.components.ksfun_task_system:GetTask(NAME)
    if task then
        local taskdata = task.components.ksfun_task:GetTaskData()
        -- 被任务目标攻击到，认为任务失败
        if taskdata.demand.data.victim == data.attacker.prefab then
            task.components.ksfun_task:Lose()
        end
    end
end



local function onAttachFunc(inst, player, name, data)
    local str = descFunc(inst, player, name)
    player.components.talker:Say(str)
    player:ListenForEvent("killed", onKillOther)

    if data and data.demand.type == KILL_TYPES.ATTACKED_LIMIT then
        player:ListenForEvent("attacked", onAttacked)
    end
end


local function onDetachFunc(inst, player, name, data)
    player:RemoveEventCallback("killed", onKillOther)
    if data and data.demand.type == KILL_TYPES.ATTACKED_LIMIT then
        player:RemoveEventCallback("attacked", onAttacked)
    end
end


local KILL = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    descFunc = descFunc,
}


return KILL