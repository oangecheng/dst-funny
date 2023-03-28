
DEMAND_DEFS = {
    {type = 1, data = {victim = "dragonfly", num = 1, duration = 2*TUNING.TOTAL_DAY_TIME}}
}

REWARD_DEFS = {
    {type = 1, data = {item = "greengem", num = 5}}
}

PUNISH_DEFS = {
    {type = 1, data = {event = "ksfun_downgrade_hunger", num = 1}}
}

OWNER_DEFS = {
    {type = 1, name = "ksfun_hunger"},
    {type = 2, name = "ksfun_weapon"}
}

local function isKillTaskSuccess(inst, data, task)
    if not (data and data.victim) then return false end
    local demand = task.demand.data
    if data.victim.prefab == demand.victim then
        demand.num = math.max(demand.num - 1, 0)
        if demand.num == 0 and on_success then
            return true
        end
    end
    return false
end


-- 任务成功监听
local function onTaskSuccess(inst, task)
    inst.components.timer:StopTimer(inst)
    inst:DoTaskInTime(0, inst.Remove)
end


-- 任务失败监听
local function onTaskFail(inst, task)
    inst:DoTaskInTime(0, inst.Remove)
end


local function startMonitorTask(inst, task)
    local player = task.player
    if task.demand.type == 1 then

        player:ListenForEvent("killed", function(inst, data)
            if isKillTaskSuccess(inst, data, task) then
                task:Success()
            end
        end)

    elseif task.demand.type == 2 then

    end
end


local function onTaskStart(inst, task)
    -- 任务开始校验一下，后面不需要校验了
    if not (task and task.player and task.demand and task.reward) then 
        return 
    end

    task.player.components.talker:Say(task.desc)

    local function onTimeDone(inst, data)
        task:Fail()
    end

    startMonitorTask(inst, task)
    inst.components.timer:StartTimer(inst, task.demand.data.duration)
    inst:ListenForEvent("timerdone", onTimeDone)
end



local function MakeTask(name, data)
    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:Hide()
        inst.persists = true
        inst:AddTag("CLASSIFIED")
        inst:AddTag("ksfun_task")

        inst:AddComponent("timer")
        inst:AddComponent("ksfun_task")
        inst.components.ksfun_task.type = data.type
        inst.components.ksfun_task.demand = data.demand
        inst.components.ksfun_task.reward = data.reward
        inst.components.ksfun_task.punish = data.punish

        inst.components.ksfun_task.on_start = onTaskStart
        inst.components.ksfun_task.on_success = onTaskSuccess
        inst.components.ksfun_task.on_fail = onTaskFail

        return inst
    end

    return Prefab(name, fn, nil, prefabs)
end


local data = {
    type = 1,
    demand = DEMAND_DEFS[1],
    reward = REWARD_DEFS[1],
    punish = PUNISH_DEFS[1],
}

return MakeTask("ksfun_task_test", data)
