local PREFABS= require("defs/ksfun_prefabs_def")
local NAMES = KSFUN_TASK_NAMES
local TYPES = NAMES
local LIMITS = KSFUN_TASK_LIMITS


---获取不同的任务类型的限制条件
---@param type string|nil 任务类型
---@return string 限制列表
local function getTypeLimits(type)
    local limits = { LIMITS.NONE, LIMITS.TIME }
    if type == TYPES.KILL then
        table.insert(limits, LIMITS.NO_HURT)
    elseif type == TYPES.PICK then
        table.insert(limits, LIMITS.FULL_MOON)
    elseif type == TYPES.FISH  then
        table.insert(limits, LIMITS.AREA)
    end
    return GetRandomItem(limits)
end


---计算限制类型的难度加成
---@param limit string 限制条件
---@param orglv integer 原始的任务等级
---@return integer 额外等级
local function getLimitExtLv(limit, orglv)
    if     limit == LIMITS.TIME then return 1
    elseif limit == LIMITS.FULL_MOON then return 2
    elseif limit == LIMITS.AREA then return 1
    elseif limit == LIMITS.NO_HURT then
        if orglv > 5 then return 3
        elseif orglv > 3 then return 2
        else return 1 end 
    end
    return 0
end



---通用的任务校验函数
---@param taskdata table
---@param judgedata table
local function commonTaskCheck(taskdata, judgedata)
    --- 先校验目标是否符合要求
    if taskdata.target ~= nil then
        if judgedata.target == nil or taskdata.target ~= judgedata.target then
            return false
        end
    end

    --- 校验限制条件
    local limit = taskdata.limit
    if limit ~= nil then
        if limit == LIMITS.FULL_MOON then
            return TheWorld.state.isfullmoon
        elseif limit == LIMITS.AREA then
            KsFunLog("commonTaskCheck", taskdata.extra.area, judgedata.area)
            return taskdata.extra and taskdata.extra.area and judgedata.area
                and taskdata.extra.area == judgedata.area
        end
    end

    return true
end


---任务是否成功的check
---@param task table
---@param taskdata table
---@param delta number
local function commonTaskCosume(task, taskdata, delta)
    if delta > 0 and task and taskdata.num ~= nil and taskdata.num > 0 then
        taskdata.num = taskdata.num - delta
        if taskdata.num <= 0 then
            task.components.ksfun_task:Win()
        end
    end
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
        time = (tasklv * 0.5) * TUNING.TOTAL_DAY_TIME
    end
    KsFunLog("obtainTask", type, target, num)
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


local function obtainKillTask()
    local limit = getTypeLimits(TYPES.KILL)
    local victim, num, lv = monsters.randomTaskMonster()
    local tasklv = getLimitExtLv(limit, lv) + lv
    return obtainTask(TYPES.KILL, tasklv,  victim, num, limit, nil)
end


-- 击杀任务目标
local function onKillOther(killer, data)
    local victim = data.victim
    local system = killer.components.ksfun_task_system
    if system and victim then
        local inst = system:GetTask(NAMES.KILL)
        local task = inst and inst.components.ksfun_task or nil
        if task then
            local judge = { target = victim.prefab }
            local taskdata = task:GetTaskData()
            if commonTaskCheck(taskdata, judge) then
                commonTaskCosume(inst, taskdata, 1)
                -- 刷新任务状态
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
        KsFunLog("onAttach", taskdata.limit, taskdata.target, data.attacker.prefab)
        if taskdata.target == data.attacker.prefab then
            task.components.ksfun_task:Lose()
        end
    end
end

local killJudge = {
    onattach = function (inst, player, data)
        player:ListenForEvent("killed", onKillOther)
        KsFunLog("onAttach", data.limit, data.target)
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

local function calcPickItemsNum()
    return KSFUN_TUNING.DEBUG and 1 or math.random(10) + 10
end


local function obtainPickTask()
    local limit = getTypeLimits(TYPES.PICK)
    ---@diagnostic disable-next-line: undefined-field
    local prefab = GetRandomItem(table.getkeys(pickables))
    local orglv  = pickables[prefab]
    local num    = calcPickItemsNum()
    local tasklv = getLimitExtLv(limit, orglv) + orglv
    return obtainTask(TYPES.PICK, tasklv, prefab, num, limit, nil)
end


local function onPickSomeThing(inst, data)
    local system = inst.components.ksfun_task_system
    local task   = system:GetTask(NAMES.PICK)
    local taskdata = task and task.components.ksfun_task:GetTaskData() or nil
    if taskdata and data then
       local judge = { target = data.object.prefab }
       if commonTaskCheck(taskdata, judge) then
            commonTaskCosume(task, taskdata, 1)
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






------------------------------------------------------钓鱼任务定义------------------------------------------------------
local fishes = PREFABS.fishes
local ponds  = PREFABS.ponds

---计算鱼的数量
---@param fish string|nil 鱼的代码
---@return integer 鱼的数量
local function calcFishNum(fish)
    return fish ~= nil and 1 or math.random(3)
end


local function obtainFishTask()
    local fish = nil
    local orglv = 1
    local extra = nil
    local limit = getTypeLimits(TYPES.FISH)

    if limit == LIMITS.AREA  then
        local pond, lv = GetRandomItemWithIndex(ponds)
        orglv = lv
        extra = { area = pond }
    elseif math.random() <= 0.5 then
        fish, orglv = GetRandomItemWithIndex(fishes)
    end

    local tasklv = orglv + getLimitExtLv(limit, orglv)
    local num = calcFishNum(fish)

    return obtainTask(TYPES.FISH, tasklv, fish, num, limit,  extra)
end



local function onFishSuccess(inst, data)
    local task = inst.components.ksfun_task_system:GetTask(NAMES.FISH)
    local taskdata = task and task.components.ksfun_task:GetTaskData() or nil
    if taskdata then
        local judge = { target = data.fish, area = data.pond.prefab }
        if commonTaskCheck(taskdata, judge) then
           commonTaskCosume(task, taskdata, 1) 
           inst.components.ksfun_task_system:SyncData()
        end
    end
end


local fishJudge = {
    onattach = function(inst, player)
        player:ListenForEvent(KSFUN_EVENTS.FISH_SUCCESS, onFishSuccess)
    end,
    ondetach = function(inst, player)
        player:RemoveEventCallback(KSFUN_EVENTS.FISH_SUCCESS, onFishSuccess)
    end,
}






------------------------------------------------------烹调任务定义------------------------------------------------------
local foods = PREFABS.foods

---计算鱼的任务数量
---@param food string|nil 食物代码，nil代码任意食物
---@return integer
local function calcFoodNum(food)
    return food ~= nil and 1 or math.random(3)
end

local function obtainCookTask()
    local limit = getTypeLimits(TYPES.COOK)
    local orglv = 1
    local food = nil
    if math.random() <= 0.5  then
        food, orglv = GetRandomItemWithIndex(foods)
        orglv = foods[food]
    end

    local tasklv = orglv + getLimitExtLv(limit, orglv)
    local num = calcFoodNum(food)
    return obtainTask(TYPES.COOK, tasklv, food, num, limit, nil)
end



local function onHarvestSelfFood(inst, data)
    local task   = inst.components.ksfun_task_system:GetTask(NAMES.COOK)
    local taskdata = task and task.components.ksfun_task:GetTaskData() or nil
    if taskdata then
        local judge = { target = data.food }
        if commonTaskCheck(taskdata, judge) then
            commonTaskCosume(task, taskdata, 1)
            inst.components.ksfun_task_system:SyncData()
        end
    end 
end

local cookJudge = {
    onattach = function(inst, player)
        player:ListenForEvent(KSFUN_EVENTS.HARVEST_SELF_FOOD, onHarvestSelfFood)
    end,
    ondetach = function(inst, player)
        player:RemoveEventCallback(KSFUN_EVENTS.HARVEST_SELF_FOOD, onHarvestSelfFood)
    end,
}




---通用工作类型的任务判定
---@param player any 玩家
---@param data any work的数据 { target = self.inst, action = self.action }
---@param actid any string
local function onWorkTaskFinsh(player, data, actid)
    if data and data.action.id == actid then
        local task = player.components.ksfun_task_system:GetTask(TYPES.MINE)
        local taskdata = task and task.components.ksfun_task:GetTaskData()
        if taskdata ~= nil then
            local judge = { target = data.target.prefab }
            if commonTaskCheck(taskdata, judge) then
                commonTaskCosume(task, taskdata, 1)
                player.components.ksfun_task_system:SyncData()
            end
        end
    end 
end


------------------------------------------------------挖矿任务定义------------------------------------------------------
local rocks = PREFABS.rocks

local function calcRockNum()
    return math.random(3)
end


local function obtainMineTask()
    local rock, orglv = GetRandomItemWithIndex(rocks)
    local limit  = getTypeLimits(TYPES.MINE)
    local number = calcRockNum()
    local tasklv = getLimitExtLv(limit, orglv) + orglv
    return obtainTask(TYPES.MINE, tasklv, rock, number, limit)
end


local function onMineFinish(inst, data)
    onWorkTaskFinsh(inst, data, ACTIONS.MINE.id)
end


local mineJudge = {
    onattach = function(inst, player)
        player:ListenForEvent("finishedwork", onMineFinish)
    end,
    ondetach = function(inst, player)
        player:RemoveEventCallback("finishedwork", onMineFinish)
    end,
}




------------------------------------------------------砍树任务定义------------------------------------------------------






local tasks = {
    [NAMES.KILL] = {
        create = obtainKillTask,
        judge  = killJudge,
    },
    [NAMES.PICK] = {
        create = obtainPickTask,
        judge  = pickJudge,
    },
    [NAMES.FISH] = {
        create = obtainFishTask,
        judge  = fishJudge,
    },
    [NAMES.COOK] = {
        create = obtainCookTask,
        judge  = cookJudge,
    },
    [NAMES.MINE] = {
        create = obtainMineTask,
        judge  = mineJudge,
    }
}


return tasks