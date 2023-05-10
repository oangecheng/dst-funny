
local MONSTER = require("tasks/ksfun_monster_defs")
local NAME = KSFUN_TUNING.TASK_NAMES.KILL

local KILL_TYPES = {
    DEFAULT = 1,
}


local function randomKillTask(task_lv)
    local victim, lv, num = MONSTER.RandomMonster(task_lv)
    return {
        type = KILL_TYPES.DEFAULT,
        victim = victim,
        num = num,
        reward = nil,
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
                if kill_data.victim == data.victim then
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
    player:ListenForEvent("killed", onKillOther)
end


local function onDetachFunc(inst, player, name)
    player:RemoveEventCallback("killed", onKillOther)
end


local function onWinFunc(inst, player, name)
    player.components.talker:Say("任务成功")
end


local function onLoseFunc(inst, player, name)
    player.components.talker:Say("任务失败")
end



local KILL = {
    name = NAME,
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onWinFunc = onWinFunc,
    onLoseFunc = onLoseFunc,
    task_data = randomKillTask(5)
}



return KILL