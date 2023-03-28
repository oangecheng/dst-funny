
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


-- 击杀任务完成判定
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
local function onTaskSuccess(task)
    task.inst.components.timer:StopTimer(inst)
    task.inst:DoTaskInTime(0, inst.Remove)
end


-- 任务失败监听
local function onTaskFail(task)
    task.inst:DoTaskInTime(0, task.inst.Remove)
end


local function startMonitorTask(task)
    local inst = task.inst
    local target = task.target
    if task.demand.data.type == 1 then
        target:ListenForEvent("killed", function(inst, data)
            if isKillTaskSuccess(inst, data, task) then
                task:Success()
            end
        end)

    elseif task.demand.data.type == 2 then

    end
end


local function onTaskStart(task)
    -- 任务开始校验一下，后面不需要校验了
    if not task then return  end
    -- 角色说话
    if task.target.components.talker then
        task.target.components.talker:Say(task.desc)
    end

    local function onTimeDone(data)
        task:Fail()
    end

    startMonitorTask(task)
    inst.components.timer:StartTimer(task.inst, task.demand.data.duration)
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

        inst.components.ksfun_task.onStart = onTaskStart
        inst.components.ksfun_task.onSuccess = onTaskSuccess
        inst.components.ksfun_task.onFail = onTaskFail
        inst.components.ksfun_task.onAttach = function(task)
            inst.entity:SetParent(task.target)
        end

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
