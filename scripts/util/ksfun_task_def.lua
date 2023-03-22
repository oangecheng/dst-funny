local TARGET = {
    PICK = {type = 1, victim = nil, num = nil, duration = nil},
    KILL = {type = 2, victim = nil, num = nil, duration = nil},
}

local OWNER = {
    KSFUN_HUNGER = 1,
}


local REWARD = {
    UNKOCK = {type = 1, num = 1},
    ITEM = {type = 2, num = 1},
}


local task_data = {
    {target = TARGET.PICK, owner = OWNER.KSFUN_HUNGER, reward = REWARD.UNKOCK},
}



local function MakeKillTask(player, task_data)
    local task = {
        start = nil,
        isvaild = true,
        on_complete = nil,
        on_fail = nil,
        tick = nil,
    }

    task.start = function()
        if task.tick then
            task.tick()
        end
        player:ListenForEvent("killed", function(inst, data)
            if data.victim and data.victim.prefab == task_data.target.victim then
                task.isvaild = false
                if task.on_complete then
                    task.on_complete({reward = task_data.reward})
                end
            end
        end)
    end

    task.tick = function()
        player.components.timer:StartTimer(task_data.owner, task_data.target.duration)
    end
end
