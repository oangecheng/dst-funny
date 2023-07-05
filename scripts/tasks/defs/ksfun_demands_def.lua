
local daytime = KSFUN_TUNING.TIME_SEG * 16
local prefabsdef = require("defs/ksfun_prefabs_def")


--------------------------------------------- 击杀任务定义---------------------------------------------------------------------
local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL
local MONSTER = require "tasks/defs/ksfun_monsters_def"

local function default(kill_type)

    -- 任务难度系数
    local function calcDifficulty(lv, num)
        return num > 1 and lv + 1 or lv
    end

    local victim, lv, num = MONSTER.randomMonster()
    return {
        type = kill_type,
        duration = 0,
        diffculty = calcDifficulty(lv, num), -- 难度系数评估
        data = {
            victim = victim,
            lv = lv,
            num = num,
        }
    }
end


-- 普通任务，不限制时间
local function normal()
    return default(KILL_TYPES.NORMAL)
end


-- 限时任务
local function timeLimit()
    local ret = default(KILL_TYPES.TIME_LIMIT)
    ret.diffculty = ret.diffculty + 1
    --- 计算时长，6级任务，需要的时间为 (6*10 + 10) / 10 = 7天
    --- 最少有一天的时间
    local seg = KSFUN_TUNING.TIME_SEG * 8
    ret.duration = math.max(seg * ret.diffculty, seg)
    return ret
end


-- 无伤任务
local function attackedLimit()
    local ret = default(KILL_TYPES.ATTACKED_LIMIT)
    ret.diffculty = ret.diffculty + 2
    return ret
end

local kill = {
    random = function()
        local type = GetRandomItem(KILL_TYPES)
        if type == KILL_TYPES.TIME_LIMIT then
            return timeLimit()
        elseif type == KILL_TYPES.ATTACKED_LIMIT then
            return attackedLimit()
        else
            return normal()
        end
    end
}






--------------------------------------------- 采集任务定义---------------------------------------------------------------------
local PICK_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.PICK
local pickables  = prefabsdef.taskpickable

local function calcPickItemsNum()
    local num = math.random(20) + 10
    return KSFUN_TUNING.DEBUG and 1 or num
end

--- 计算采集任务难度
local function calcPickDifficulty(type, lv, num)
    local base = lv + (num > 20 and 2 or 1)
    if type == PICK_TYPES.TIME_LIMIT then
        return base + 1
    elseif type == PICK_TYPES.FULL_MOON then
        return base + 2    
    end
    return base
end


local function generatePickDemand(picktype)
    local prefab = GetRandomItem(table.getkeys(pickables))
    local lv     = pickables[prefab]
    local num    = calcPickItemsNum()

    local diffculty = calcPickDifficulty(picktype, lv, num)
    local duration = 0
    if picktype == PICK_TYPES.TIME_LIMIT then
        duration  = math.random(2) * daytime
    end

    return {
        type      = picktype,
        duration  = duration,
        diffculty = diffculty,
        data = {
            target = prefab,
            lv = lv,
            num = num,
        }
    }
end

local pick = {
    random = function()
        local picktype = GetRandomItem(PICK_TYPES)
        return generatePickDemand(picktype)
    end
}










--------------------------------------------- 钓鱼任务定义---------------------------------------------------------------------
local FISH_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.FISH
local fishes     = prefabsdef.fishes

local function calcFishNum()
    local n = math.random(8) + 2 
    return KSFUN_TUNING.DEBUG and 1 or n
end

--- 计算钓鱼任务难度
local function calcFishDifficulty(fishtype, lv, num)
    local base = lv + (num > 5 and 2 or 1)
    if fishtype == FISH_TYPES.TIME_LIMIT then
        return base + 1
    elseif fishtype == FISH_TYPES.POND_LIMIT then
        return base + 1
    elseif fishtype == FISH_TYPES.FISH_LIMIT then
        return base + 2    
    end
    return base
end

local function generateFishDemand(fishtype)

    local num = calcFishNum()
    local diffculty = calcFishDifficulty()
    local duration = 0
    if fishtype == FISH_TYPES.TIME_LIMIT then
        duration  = math.random(2) * daytime
    end

    local fish = nil
    local lv = 0
    local pond = nil

    if fishtype == FISH_TYPES.FISH_LIMIT then
        fish = GetRandomItem(table.getkeys(fishes))
        lv   = fishes[fish]
    elseif fishtype == FISH_TYPES.POND_LIMIT then
        pond = GetRandomItem(prefabsdef.ponds)
    end
    
    return {
        type = fishtype,
        duration = duration,
        diffculty = diffculty,
        data = {
            num = num,
            fish = fish,
            pond = pond,
        }
    }

end


local fish = {
    random = function()
        local fishtype = GetRandomItem(FISH_TYPES)
        return generateFishDemand(fishtype)
    end
}








local demands = {
    [NAMES.KILL] = kill,
    [NAMES.PICK] = pick,
    [NAMES.FISH] = fish,

}


return demands
