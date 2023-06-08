
local NAME = KSFUN_TUNING.TASK_NAMES.KILL
local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL


local function descFunc(inst, player, name, d)
    local taskdata = inst.components.ksfun_task:GetTaskData()
    return KsFunGeneratTaskDesc(taskdata)
end



local function onKillOther(killer, data)
    local victim = data.victim

    if killer.components.ksfun_task_system then
        local inst = killer.components.ksfun_task_system:GetTask(NAME)
        local kill_task = inst and inst.components.ksfun_task or nil
        if kill_task then
            local demand = kill_task:GetTaskData().demand
            if KSFUN_TUNING.DEBUG or demand.type == KILL_TYPES.NORMAL then
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


local function onAttachFunc(inst, player, name, data)
    local str = descFunc(inst, player, name)
    player.components.talker:Say(str)
    player:ListenForEvent("killed", onKillOther)
end


local function onDetachFunc(inst, player, name, data)
    player:RemoveEventCallback("killed", onKillOther)
end


local KILL = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    descFunc = descFunc,
}


return KILL