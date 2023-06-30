
local ksfun_demands = {}




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


ksfun_demands.randomKill = function()
    local type = GetRandomItem(KILL_TYPES)
    if type == KILL_TYPES.TIME_LIMIT then
        return timeLimit()
    elseif type == KILL_TYPES.ATTACKED_LIMIT then
        return attackedLimit()
    else
        return normal()
    end
end




--------------------------------------------- 采集任务定义---------------------------------------------------------------------





return ksfun_demands
