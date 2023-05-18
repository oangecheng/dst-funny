
local REWARD  = require("tasks/defs/ksfun_reward_items")
local DEMANDS = require("tasks/utils/ksfun_demands")

local NAME = KSFUN_TUNING.TASK_NAMES.KILL
local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES


local function descFunc(inst, player, name)
    local kill_task = inst.components.ksfun_task
    if kill_task then
        local kill_demand = kill_task:GetTaskData().demand
        if kill_demand.type == KILL_TYPES.NORMAL then
            local victim_name = STRINGS.NAMES[string.upper(kill_demand.data.victim)] or ""
            return "击杀"..tostring(kill_demand.data.num).."只"..victim_name
        end
    end
    return ""
end


local function onKillOther(killer, data)
    local victim = data.victim

    if killer.components.ksfun_task_system then
        local inst = killer.components.ksfun_task_system:GetTask(NAME)
        local kill_task = inst and inst.components.ksfun_task or nil
        if kill_task then
            local demand = kill_task:GetTaskData().demand
            if demand.type == KILL_TYPES.NORMAL then
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
}


return KILL