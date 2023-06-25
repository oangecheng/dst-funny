

local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL

local MONSTER = require "tasks/defs/ksfun_monsters"


-- 算了一下最大值不超过64
local function calcDifficulty(lv, num)
    return 2^lv * num
end


local function default(kill_type, task_lv)
    local victim, lv, num = MONSTER.randomMonster(task_lv)
    return {
        type = kill_type,
        duration = 0,
        diffculty = 0, -- 难度系数评估
        data = {
            victim = victim,
            lv = lv,
            num = num,
        }
    }
end


-- 普通任务，不限制时间
local function normal(task_lv)
    return default(KILL_TYPES.NORMAL, task_lv)
end


-- 限时任务
local function timeLimit(task_lv)
    local ret = default(KILL_TYPES.TIME_LIMIT, task_lv)
    local data = ret.data
    --- 计算时长，6级任务，需要的时间为 2^6 * 30s = 8天
    local time = calcDifficulty(data.lv, data.num) * KSFUN_TUNING.TIME_SEG
    ret.duration = time
    ret.diffculty = 2
    return ret
end


-- 无伤任务
local function attackedLimit(task_lv)
    local ret = default(KILL_TYPES.ATTACKED_LIMIT, task_lv)
    ret.diffculty = 4
    return ret
end



local kills = {}

kills.generate = function(task_lv, kill_type)
    if kill_type == KILL_TYPES.TIME_LIMIT then
        return timeLimit(task_lv)
    elseif kill_type == KILL_TYPES.ATTACKED_LIMIT then
        return attackedLimit(task_lv)
    else
        return normal(task_lv)
    end
end


kills.random = function(task_lv)
    local kill_type = KsFunRandomValueFromKVTable(KILL_TYPES)
    return kill.generate(task_lv, kill_type)
end

return kills

