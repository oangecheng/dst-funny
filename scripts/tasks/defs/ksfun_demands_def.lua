
local ksfun_demands = {}




--------------------------------------------- 击杀任务定义---------------------------------------------------------------------
local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL
local MONSTER = require "tasks/defs/ksfun_monsters_def"

local function default(kill_type)
    -- 算了一下最大值不超过64
    local function calcDifficulty(lv, num)
        return 2^lv * num
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
    ret.diffculty = ret.diffculty * 2
    --- 计算时长，6级任务，需要的时间为 2^6 * 30s * 2 * 2 = 12天
    --- 最少有一天的时间
    ret.duration = math.max(ret.diffculty * KSFUN_TUNING.TIME_SEG * 2, KSFUN_TUNING.TIME_TOTAL_DAY)
    return ret
end


-- 无伤任务
local function attackedLimit()
    local ret = default(KILL_TYPES.ATTACKED_LIMIT)
    ret.diffculty = ret.diffculty * 4
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
