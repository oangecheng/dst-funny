
local isCh = KSFUN_TUNING.IS_CH

-- 任务大类型定义
KSFUN_TASK_NAMES = {
    KILL = "kill",
    PICK = "pick",
    FISH = "fish",
    COOK = "cook",
    -- WORK = "work",
}


KSFUN_TASK_LIMITS = {
    NONE      = "none", 
    TIME      = "time",
    FULL_MOON = "fullmoon",
    NO_HURT   = "nohurt",
    AREA      = "area"
}


--- 惩罚类型定义
KSFUN_PUNISHES = {
    POWER_LV_LOSE  = 1,
    POWER_EXP_LOSE = 2,
    MONSTER        = 3,
    NEGA_POWER     = 4,
}



KSFUN_REWARD_TYPES = {
    -- 物品奖励
    ITEM  = 1,
}



local LIMITS = KSFUN_TASK_LIMITS
local NAMES  = KSFUN_TASK_NAMES


local LIMITS_STR = {
    [LIMITS.NONE] = isCh and "无" or "none",
    [LIMITS.FULL_MOON] = isCh and "满月" or "need fullmoon",
    [LIMITS.NO_HURT] = isCh and "无伤" or "no hurt by target",
}

local TIME_STR = isCh and "%s 秒内完成" or "complete in %s s"




local function KsFunTaskGetLimitDesc(taskdata)
    local base = isCh and "限制: " or "Limit: "
    if taskdata.limit == LIMITS.TIME then
        return base..string.format(TIME_STR, taskdata.duration)
    elseif taskdata.limit == LIMITS.AREA then
        local area = taskdata.extra and taskdata.extra.area
        return base..KsFunGetPrefabName(area)
    end
    if taskdata.limit then
        return base..LIMITS_STR[taskdata.limit]
    end
    return nil
end



function KsFunTaskGetTargetDesc(taskdata)
    local base = isCh and "目标: " or "Targe: "
    local target = taskdata.target
    if target == nil then
        return base..(isCh and "任意" or "Any")
    end
    local str = KsFunGetPrefabName(target)
    if str ~= nil  then
        return base..str
    end
    return nil
end



local function KsFunTaskGetTargetNumDesc(taskdata)
    local base = isCh and "剩余数量: " or "Left Count: "
    return base..tostring(math.max(1, taskdata.num or 1))
end



function KsFunTaskGetDesc(taskdata)
    local target = KsFunTaskGetTargetDesc(taskdata)
    if target ~= nil then
        local numstr = KsFunTaskGetTargetNumDesc(taskdata)
        local limitstr = KsFunTaskGetLimitDesc(taskdata)
        return target.."\n"..tostring(numstr).."\n"..tostring(limitstr)
    end
    return nil
end
