
local isCh = KSFUN_TUNING.IS_CH




-- 任务大类型定义
KSFUN_TASK_NAMES = {
    KILL = "kill",
    PICK = "pick",
    FISH = "fish",
    COOK = "cook",
    MINE = "mine",
    CHOP = "chop",
    DRY  = "dry" ,

    NO_KILL = "no_kill"
}


KSFUN_TASK_LIMITS = {
    NONE      = "none", 
    TIME      = "time",
    FULL_MOON = "fullmoon",
    NO_HURT   = "nohurt",
    AREA      = "area",
}


local LIMITS = KSFUN_TASK_LIMITS
local NAMES  = KSFUN_TASK_NAMES



KSFUN_TASK_TYPE_LIMITS = {
    [NAMES.KILL] = { LIMITS.NONE, LIMITS.TIME, LIMITS.NO_HURT },
    [NAMES.PICK] = { LIMITS.NONE, LIMITS.TIME, LIMITS.FULL_MOON },
    [NAMES.FISH] = { LIMITS.NONE, LIMITS.AREA },
    [NAMES.COOK] = { LIMITS.NONE },
    [NAMES.MINE] = { LIMITS.NONE },
    [NAMES.CHOP] = { LIMITS.NONE },
    [NAMES.DRY ] = { LIMITS.NONE },

    [NAMES.NO_KILL] = { LIMITS.NONE }
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

    if taskdata.target ~= nil then
        local str = KsFunGetPrefabName(taskdata.target)
        return str and base..str or nil
    elseif taskdata.tag ~= nil then
        return base..STRINGS.KSFUN_TAGS[taskdata.tag]
    else
        return base..(isCh and "任意" or "Any")
    end
end



local function KsFunTaskGetTargetNumDesc(taskdata)
    local base = isCh and "剩余数量: " or "Left Count: "
    return base..tostring(math.max(1, taskdata.num or 1))
end




local othertasks = {
    [NAMES.NO_KILL] = function (data)
        local str = isCh and "%s秒不杀生 \n 放下屠刀，立地成佛" or "%s sec no kill"
        return string.format(str, tostring(data.time))
    end
}

function KsFunTaskGetDesc(taskdata)

    local func = othertasks[taskdata.name]
    if func ~= nil then
        return func(taskdata)
    end

    local target = KsFunTaskGetTargetDesc(taskdata)
    if target ~= nil then
        local numstr = KsFunTaskGetTargetNumDesc(taskdata)
        local limitstr = KsFunTaskGetLimitDesc(taskdata)
        return target.."\n"..tostring(numstr).."\n"..tostring(limitstr)
    end
    return nil
end



local tasknames = {
    [NAMES.KILL]    = "击杀任务",
    [NAMES.PICK]    = "采集任务",
    [NAMES.FISH]    = "钓鱼任务",
    [NAMES.COOK]    = "烹调任务",
    [NAMES.MINE]    = "挖矿任务",
    [NAMES.CHOP]    = "伐木任务",
    [NAMES.DRY]     = "晾晒任务",
    [NAMES.NO_KILL] = "保护动物",
}

---获取任务标题
---@param type string 任务类型
---@return string 任务标题
function KsFunGetTaskName(type)
    return tasknames[type]
end
