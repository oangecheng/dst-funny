local PREFABS= require("defs/ksfun_prefabs_def")
local NAMES = KSFUN_TASK_NAMES



local TYPES = {
    KILL = "kill",
    PICK = "pick",
    FISH = "fish",
    COOK = "cook",
}


local LIMITS = {
    NONE      = "none", 
    TIME      = "time",
    FULL_MOON = "fullmoon",
    NO_HURT   = "nohurt",
    AREA      = "area"
}


local LIMITS_LV = {}
LIMITS_LV[LIMITS.NONE].fn      = function () return 0 end
LIMITS_LV[LIMITS.TIME].fn      = function () return 1 end
LIMITS_LV[LIMITS.FULL_MOON].fn = function () return 2 end
LIMITS_LV[LIMITS.AREA].fn      = function () return 1 end
LIMITS_LV[LIMITS.NO_HURT].fn   = function (originlv)
    if originlv > 5 then return 3
    elseif originlv > 3 then return 2
    else return 1 end
end


--- 生成一条全新的任务数据
--- @param type string
--- @param tasklv number
--- @param target any
--- @param num number
--- @param limit string
--- @param extra any
local function obtainTask(type, tasklv, target, num, limit, extra)
    local time = 0
    if limit == LIMITS.TIME then
        local days = (tasklv * 0.5) * TUNING.TOTAL_DAY_TIME
    end
    return {
        type   = type,
        tasklv = tasklv,
        target = target,
        duration = time,
        num    = num,
        limit  = limit,
        extra  = extra,
    }
end



------------------------------------------------------击杀类型的任务定义-------------------------------------------------------------
local monsters = require("defs/ksfun_monsters_def")
local killlimits = { LIMITS.NONE, LIMITS.TIME, LIMITS.NO_HURT }

local function obtainKillTask()
    local victim, num, lv = monsters.randomTaskMonster()
    local limit = GetRandomItem(killlimits)
    local tasklv = LIMITS_LV[limit].fn(lv) + lv
    return obtainTask(TYPES.KILL, tasklv,  victim, num, limit, nil)
end


-- 击杀任务目标
local function onKillOther(killer, data)
    local victim = data.victim
    local system = killer.components.ksfun_task_system
    if system then
        local inst = system:GetTask(NAMES.KILL)
        local task = inst and inst.components.ksfun_task or nil
        if task then
            local taskdata = task:GetTaskData()
            if taskdata and taskdata.target == victim.prefab then
                taskdata.num = taskdata.num - 1
                if taskdata.num < 1 then
                    task:Win()
                end
                system:SyncData()
            end
        end
    end
end


-- 无伤任务
local function onAttacked(inst, data)
    local task = inst.components.ksfun_task_system:GetTask(NAMES.KILL)
    if task then
        local taskdata = task.components.ksfun_task:GetTaskData()
        -- 被任务目标攻击到，认为任务失败
        if taskdata.demand.data.victim == data.attacker.prefab then
            task.components.ksfun_task:Lose()
        end
    end
end

local killJudge = {
    onattach = function (inst, player, data)
        player:ListenForEvent("killed", onKillOther)
        if data and data.limit == LIMITS.NO_HURT then
            player:ListenForEvent("attacked", onAttacked)
        end
    end,
    ondetach = function (inst, player, data)
        player:RemoveEventCallback("killed", onKillOther)
        if data and data.limit == LIMITS.NO_HURT then
            player:RemoveEventCallback("attacked", onAttacked)
        end
    end,
}







------------------------------------------------------采集类型的任务定义------------------------------------------------------
local pickables = PREFABS.taskpickable
local picklimits = { LIMITS.NONE, LIMITS.TIME, LIMITS.FULL_MOON }

local function calcPickItemsNum()
    return KSFUN_TUNING.DEBUG and 1 or math.random(10) + 10
end


local function obtainPickTask()
    ---@diagnostic disable-next-line: undefined-field
    local prefab = GetRandomItem(table.getkeys(pickables))
    local orglv  = pickables[prefab]
    local num    = calcPickItemsNum()
    local limit  = GetRandomItem(picklimits)
    local tasklv = LIMITS_LV[limit].fn(orglv) + orglv
    return obtainTask(TYPES.PICK, tasklv, prefab, num, limit, nil)
end


local function onPickSomeThing(inst, data)
    local system = inst.components.ksfun_task_system
    local task   = system:GetTask(NAMES.PICK)
    local taskdata = task and task.components.ksfun_task:GetTaskData() or nil
    if taskdata and data then
        -- 判定是否是目标
        if taskdata.target == data.object.prefab then
            local delta = 0
            if taskdata.limit == LIMITS.FULL_MOON then
                if TheWorld.state.isfullmoon then
                    delta = 1
                end
            else
                delta = 1
            end
            taskdata.num = taskdata.num - delta
            if taskdata.num < 1 then
                task.components.ksfun_task:Win()
            end
            system:SyncData()
        end
    end
end

local pickJudge = {
    onattach = function(inst, player)
        player:ListenForEvent("picksomething", onPickSomeThing)
        player:ListenForEvent("ksfun_picksomething", onPickSomeThing)
    end,
    ondetach = function(inst, player)
        player:RemoveEventCallback("picksomething", onPickSomeThing)
        player:RemoveEventCallback("ksfun_picksomething", onPickSomeThing)
    end,
}





local fishes = PREFABS.fishes
local ponds  = PREFABS.ponds
local fishlimits = { LIMITS.NONE, LIMITS.AREA, LIMITS.TIME } 

--- 计算鱼的数量
local function calcFishNum()
    return KSFUN_TUNING.DEBUG and 1 or math.random(3)
end


local function obtainFishTask()
    local seed = math.random(2)

    local fish = nil
    local orglv = 1
    local extra = nil

    local limit = GetRandomItem(fishlimits)
    if limit == LIMITS.AREA  then
        local pond = GetRandomItem(ponds)
        extra = { area = pond }
    else
        if math.random() <= 0.5 then
            ---@diagnostic disable-next-line: undefined-field
            fish = GetRandomItem(table.getkeys(fishes))
            orglv = fishes[fish]
        end
    end

    local tasklv = orglv + LIMITS_LV[limit].fn()
    local num = calcFishNum()

    return obtainTask(TYPES.FISH, tasklv, fish, num, limit,  extra)
end






local foods = PREFABS.foods
local cooklimits = { LIMITS.NONE, LIMITS.TIME }


local function calcFoodNum()
    return KSFUN_TUNING.DEBUG and 1 or math.random(5)
end

local function obtainCookTask()
    local orglv = 0
    local food = nil
    if math.random() <= 0.5  then
        ---@diagnostic disable-next-line: undefined-field
        food = GetRandomItem(table.getkeys(foods))
        orglv = foods[food]
    end

    local num = calcFoodNum()
    local limit = GetRandomItem(cooklimits)
    local tasklv = orglv + LIMITS_LV[limit].fn()
    return obtainTask(TYPES.COOK, tasklv, food, num, limit, nil)
end