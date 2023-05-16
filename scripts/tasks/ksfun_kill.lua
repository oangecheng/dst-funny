
local MONSTER = require("tasks/ksfun_monster_defs")
local REWARD = require("tasks/ksfun_reward_items")

local NAME = KSFUN_TUNING.TASK_NAMES.KILL

local KILL_TYPES = {
    DEFAULT = 1,
}

local REWARD_TYPES = {
    ITEM = 1,
}



local function descFunc(inst, player, name)
    local kill_task = inst.components.ksfun_task
    if kill_task then
        local task_data = kill_task:GetTaskData()
        if task_data.type == KILL_TYPES.DEFAULT then
            local victim_name = STRINGS.NAMES[string.upper(task_data.victim)] or ""
            local time = KsFunFormatTime(task_data.duration)
            return "在"..time.."时间内击杀"..tostring(task_data.num).."只"..victim_name
        end
    end
    return ""
end



local function randomKillTask(task_lv)
    local victim, lv, num = MONSTER.RandomMonster(task_lv)
    local item, lv, num = REWARD.randomItem(task_lv)
    return {
        type = KILL_TYPES.DEFAULT,
        victim = victim,
        num = num,
        duration = 15,
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
            local kill_data = kill_task:GetTaskData()
            if kill_data.type == KILL_TYPES.DEFAULT then
                if kill_data.victim == data.victim.prefab then
                    kill_data.num = kill_data.num - 1
                end
                if kill_data.num < 1 then
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