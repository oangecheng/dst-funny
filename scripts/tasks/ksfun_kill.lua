
local REWARD = require("tasks/defs/ksfun_reward_items")
local DEMANDS = require("tasks/ksfun_task_demand")

local NAME = KSFUN_TUNING.TASK_NAMES.KILL
local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL


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



local function randomKillTask(task_lv)
    local demand = DEMANDS.generateDemand(NAME, task_lv, KILL_TYPES.NORMAL)
    local item, lv, num = REWARD.randomNormlItem(task_lv)
    return {
        demand = demand,
        reward = {
            type = REWARD_TYPES.ITEM, 
            data = {
                item = item,
                num = num,
            }
        },
        punish = nil,
    }
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


local function onAttachFunc(inst, player, name)
    local str = descFunc(inst, player, name)
    player.components.talker:Say(str)
    player:ListenForEvent("killed", onKillOther)
end


local function onDetachFunc(inst, player, name)
    player:RemoveEventCallback("killed", onKillOther)
end


local function onWinFunc(inst, player, name)
    player.components.talker:Say("任务成功")
    local task_data = inst.components.ksfun_task:GetTaskData()
    if task_data.reward then
        if task_data.reward.type == REWARD_TYPES.ITEM then
            for i=1, task_data.reward.num do
                local item = SpawnPrefab(task_data.reward.item)
                player.components.inventory:GiveItem(item, nil, player:GetPosition())
            end
        end
    end
end


local function onLoseFunc(inst, player, name)
    player.components.talker:Say("任务失败")
end


local function generateTaskData()
    return randomKillTask(5)

end

local KILL = {
    name = NAME,
    generateTaskData = generateTaskData,
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onWinFunc = onWinFunc,
    onLoseFunc = onLoseFunc,
}


return KILL