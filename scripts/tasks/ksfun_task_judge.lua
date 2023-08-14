
local NAME = KSFUN_TASK_NAMES.KILL
local KILL_TYPES = KSFUN_DEMAND_TYPES.KILL
local NAMES = KSFUN_TASK_NAMES


local function descFunc(inst, player, taskdata)
    local taskdata = inst.components.ksfun_task:GetTaskData()
    return KsFunGetTaskDesc(taskdata)
end


-- 击杀任务目标
local function onKillOther(killer, data)
    local victim = data.victim

    if killer.components.ksfun_task_system then
        local inst = killer.components.ksfun_task_system:GetTask(NAME)
        local kill_task = inst and inst.components.ksfun_task or nil
        if kill_task then
            local demand = kill_task:GetTaskData().demand
            -- 杀怪任务就失败了
            if demand.type == KILL_TYPES.NOT_KILL then
                kill_task:Lose()
            elseif demand.data.victim and demand.data.num then
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


-- 无伤任务
local function onAttacked(inst, data)
    local task = inst.components.ksfun_task_system:GetTask(NAME)
    if task then
        local taskdata = task.components.ksfun_task:GetTaskData()
        -- 被任务目标攻击到，认为任务失败
        if taskdata.demand.data.victim == data.attacker.prefab then
            task.components.ksfun_task:Lose()
        end
    end
end



local function onAttachFunc(inst, player, data)
    local str = descFunc(inst, player, data)
    player.components.talker:Say(str)
    player:ListenForEvent("killed", onKillOther)
    if data and data.demand.type == KILL_TYPES.ATTACKED_LIMIT then
        player:ListenForEvent("attacked", onAttacked)
    end
end


local function onDetachFunc(inst, player, data)
    player:RemoveEventCallback("killed", onKillOther)
    if data and data.demand.type == KILL_TYPES.ATTACKED_LIMIT then
        player:RemoveEventCallback("attacked", onAttacked)
    end
end


local kill = {
    onattach = onAttachFunc,
    ondetach = onDetachFunc,
    ondesc   = descFunc,
}








-------------------------------------------------------------------------------------------采集任务完成判定-------------------------------------------------------------------------------------------
local PICK_TYPES = KSFUN_DEMAND_TYPES.PICK

local function onPickSomeThing(inst, data)
    local task   = inst.components.ksfun_task_system:GetTask(NAMES.PICK)
    local demand = task and task.components.ksfun_task:GetDemand() or nil
    if demand and demand.data then
        -- 判定是否是目标
        if demand.data.target == data.object.prefab then
            local delta = 0
            if demand.type == PICK_TYPES.FULL_MOON then
                if TheWorld.state.isfullmoon then
                    delta = 1
                end
            else
                delta = 1
            end
            demand.data.num = demand.data.num - delta
            if demand.data.num < 1 then
                task.components.ksfun_task:Win()
            end
        end
    end
end

local pick = {
    onattach = function(inst, player)
        player:ListenForEvent("picksomething", onPickSomeThing)
        player:ListenForEvent("ksfun_picksomething", onPickSomeThing)
    end,
    ondetach = function(inst, player)
        player:RemoveEventCallback("picksomething", onPickSomeThing)
        player:RemoveEventCallback("ksfun_picksomething", onPickSomeThing)
    end,
    ondesc = descFunc,
}










-------------------------------------------------------------------------------------------钓鱼任务完成判定-------------------------------------------------------------------------------------------
local FISH_TYPES = KSFUN_DEMAND_TYPES.FISH

local function onFishSuccess(inst, data)
    local task = inst.components.ksfun_task_system:GetTask(NAMES.FISH)
    local demand = task and task.components.ksfun_task:GetDemand() or nil
    if demand then
        local delta = 0
        if demand.type == FISH_TYPES.FISH_LIMIT then
            if data.fish and data.fish.prefab == demand.data.fish then
                delta = 1
            end
        elseif demand.type == FISH_TYPES.POND_LIMIT then
            if data.pond and data.pond.prefab == demand.data.pond then
                delta = 1
            end
        else
            delta = 1
        end
        demand.data.num = demand.data.num - delta
        if demand.data.num < 1 then
            task.components.ksfun_task:Win()
        end
    end
end

local fish = {
    onattach = function(inst, player)
        player:ListenForEvent(KSFUN_EVENTS.FISH_SUCCESS, onFishSuccess)
    end,
    ondetach = function(inst, player)
        player:RemoveEventCallback(KSFUN_EVENTS.FISH_SUCCESS, onFishSuccess)
    end,
    ondesc = descFunc
}




-------------------------------------------------------------------------------------------烹调任务完成判定-------------------------------------------------------------------------------------------
local COOK_TYPES = KSFUN_DEMAND_TYPES.COOK


local function onHarvestSelfFood(inst, data)
    KsFunLog("onHarvestSelfFood", data.food)
    local task   = inst.components.ksfun_task_system:GetTask(NAMES.COOK)
    local demand = task and task.components.ksfun_task:GetDemand() or nil
    if demand then
        local cooktype = demand.type
        local delta = 0
        if cooktype == COOK_TYPES.FOOD_LIMIT then
            if data.food == demand.data.food then
                delta = 1
            end
        else
            delta = 1
        end
        demand.data.num = demand.data.num - delta
        if demand.data.num < 1 then
            task.components.ksfun_task:Win()
        end
    end 
end

local cook = {
    onattach = function(inst, player)
        player:ListenForEvent(KSFUN_EVENTS.HARVEST_SELF_FOOD, onHarvestSelfFood)
    end,
    ondetach = function(inst, player)
        player:RemoveEventCallback(KSFUN_EVENTS.HARVEST_SELF_FOOD, onHarvestSelfFood)
    end,
    ondesc = descFunc
}






-------------------------------------------------------------------------------------------工作任务完成判定-------------------------------------------------------------------------------------------
local WORKTYPES = KSFUN_DEMAND_TYPES.WORK

local function finishWork(player, data)
    local task = player.components.ksfun_task_system:GetTask(KSFUN_TASK_NAMES.WORK)
    local demand = task and task.components.ksfun_task:GetDemand()
    if  demand then
        if demand.type == WORKTYPES.NORMAL then
            local delta = 0
            if demand.act == data.action then
                delta = 1
            end
            demand.data.num = demand.data.num - delta
            if demand.data.num < 1 then
                task.components.ksfun_task:Win()
            end
        end
    end
end

local work = {
    onattach = function(inst, player)
        player:ListenForEvent("finishedwork", finishWork)
        
    end,
    ondetach = function(inst, player)
        player:RemoveEventCallback("finishedwork", finishWork)
    end,
    ondesc = descFunc
}



local judge = {
    [NAMES.KILL] = kill,
    [NAMES.PICK] = pick,
    [NAMES.FISH] = fish,
    [NAMES.COOK] = cook,
    [NAMES.WORK] = work,
 }



return judge