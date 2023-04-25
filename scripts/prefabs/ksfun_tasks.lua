
DEMAND_DEFS = {
    {type = 1, data = {victim = "dragonfly", num = 1, duration = 15}}
}

REWARD_DEFS = {
    {type = 1, data = {item = "walrushat", num = 5}}
}

PUNISH_DEFS = {
    {type = 1, data = {event = "ksfun_downgrade_hunger", num = 1}}
}

OWNER_DEFS = {
    {type = 1, name = "ksfun_hunger"},
    {type = 2, name = "ksfun_weapon"}
}


local function onTaskFinish(task)
    task.target:RemoveEventCallback("killed", task.inst.monitorFunc)
    task.target:PushEvent("ksfun_task_finish", task)
    task.inst:DoTaskInTime(0.5, task.inst:Remove())
end


-- 击杀任务完成判定
local function isKillTaskSuccess(inst, data, task)
    if not (data and data.victim) then return false end
    local demand = task.demand.data
    if data.victim.prefab == demand.victim then
        demand.num = math.max(demand.num - 1, 0)
        if demand.num == 0 then
            return true
        end
    end
    return false
end


-- 任务成功监听
local function onTaskSuccess(task)
    local player = task.target
     -- 角色说话
     if player and player.components.talker then
        player.components.talker:Say("任务完成")
    end

    if task.reward then
        if task.reward.type == KSFUN_TUNING.TASK_REWARD_TYPES.ITEM then
            local item = SpawnPrefab(task.reward.data.item)
            if item and player and player.components.inventory then
                player.components.inventory:GiveItem(item, nil, player:GetPosition())
            end
        end
    end
    
    task.inst.components.timer:StopTimer(task.inst)
    onTaskFinish(task)
end


-- 任务失败监听
local function onTaskFail(task)
    -- 角色说话
    if task.target.components.talker then
        task.target.components.talker:Say("任务失败")
    end
    onTaskFinish(task)
end


local function startMonitorTask(task)
    local inst = task.inst
    local target = task.target

    inst.monitorFunc = function(player, data)
        if isKillTaskSuccess(player, data, task) then
            task:Success()
        end
    end

    if task.demand.type == 1 then
        target:ListenForEvent("killed", inst.monitorFunc)
    
    elseif task.demand.data.type == 2 then

    end
end


local function onTaskStart(task)
    -- 任务开始校验一下，后面不需要校验了
    if not task then return  end
    -- 角色说话
    if task.target.components.talker then
        local victim_name = STRINGS.NAMES[string.upper(task.demand.data.victim)] or ""
        local count = task.demand.data.num or 0
        local reward_name = STRINGS.NAMES[string.upper(task.reward.data.item)] or ""
        local str = "击杀"..tostring(count).."个"..victim_name.."奖励"..reward_name
        task.target.components.talker:Say(str)
    end

    local function onTimeDone(data)
        task:Fail()
    end

    startMonitorTask(task)
    task.inst.components.timer:StartTimer(task.inst, task.demand.data.duration)
    task.inst:ListenForEvent("timerdone", onTimeDone)
end



local function createTestTask()
    local task  = {}
    local demand = require("defs/ksfun_task_demand_defs")
    local reward = require("defs/ksfun_task_reward_defs")
    
    task.demand = demand.createDemandByType(KSFUN_TUNING.TASK_DEMAND_TYPES.KILL)
    task.reward = reward.createRewardByType(KSFUN_TUNING.TASK_REWARD_TYPES.ITEM, task.demand.level)
    task.punish = PUNISH_DEFS[1]
    return task
end


local function MakeTask(name)
    local function fn()
        local inst = CreateEntity()
        inst:AddTag("CLASSIFIED")
        inst:AddTag("ksfun_task")

        if not TheWorld.ismastersim then
            inst:DoTaskInTime(0, inst:Remove())
            return inst
        end

        inst.entity:Hide()
        inst.persists = true

        inst:AddComponent("timer")
        inst:AddComponent("ksfun_task")

        inst.components.ksfun_task.onStart = onTaskStart
        inst.components.ksfun_task.onSuccess = onTaskSuccess
        inst.components.ksfun_task.onFail = onTaskFail

        inst.monitorFunc = nil

        -- 任务生成时，
        inst.components.ksfun_task.onAttach = function(task)
            local test = createTestTask()
            task.name = test.type
            task.demand = test.demand
            task.reward = test.reward
            task.punish = test.punish
        end

        return inst
    end

    return Prefab(name, fn, nil, prefabs)
end

return MakeTask("ksfun_task_test")
