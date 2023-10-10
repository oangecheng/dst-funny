
-- 任务大类型定义
KSFUN_TASK_NAMES = {
    KILL = "kill",
    PICK = "pick",
    FISH = "fish",
    COOK = "cook",
    WORK = "work",
}



--- 任务需求细分类型
KSFUN_DEMAND_TYPES = {
    --- 击杀类型
    KILL = {
        NORMAL         = 1,
        TIME_LIMIT     = 2,
        ATTACKED_LIMIT = 3,
    },

    PICK = {
        NORMAL         = 1,
        TIME_LIMIT     = 2,
        FULL_MOON      = 3,
    },

    FISH = {
        NORMAL         = 1,
        TIME_LIMIT     = 2,
        POND_LIMIT     = 3,
        FISH_LIMIT     = 4,
    },

    COOK = {
        NORMAL         = 1,
        TIME_LIMIT     = 2,
        FOOD_LIMIT     = 3,
    },

    WORK = {
        NORMAL = 1,
    }
}


--- 惩罚类型定义
KSFUN_PUNISHES = {
    POWER_LV_LOSE  = 1,
    POWER_EXP_LOSE = 2,
    MONSTER        = 3,
    NEGA_POWER     = 4,
}



KSFUN_REWARD_TYPES = {
    -- 普通物品奖励
    ITEM  = 1,
    POTION = 2,
    GEM   = 3
}



local function getKillTaskDesc(demand)
    local KILL_TYPES = KSFUN_DEMAND_TYPES.KILL
    -- 先从自定义的名称里面拿，有些怪物的名称是一样的，所以要区分一下
    local victimname = KsFunGetPrefabName(demand.data.victim)
    local num = demand.data.num
    if victimname then
        local str = string.format(STRINGS.KSFUN_TASK_KILL_DESC, tostring(num), tostring(victimname))
        -- 击杀1只蜘蛛
        if demand.type == KILL_TYPES.NORMAL then
            return str
        -- 击杀1只蜘蛛(限制:480秒)
        elseif demand.type == KILL_TYPES.TIME_LIMIT then
            return str..string.format(STRINGS.KSFUN_TASK_TIME_LIMIT, tostring(demand.duration))
        -- 击杀1只蜘蛛(限制:无伤)
        elseif demand.type == KILL_TYPES.ATTACKED_LIMIT then
            return str..STRINGS.KSFUN_TASK_NO_HURT
        end
    end
    return nil
end


local function getPickTaskDesc(demand)
    local name  = KsFunGetPrefabName(demand.data.target)
    if name == nil then 
        return nil 
    end

    local num = tostring(demand.data.num)
    local picktype  = demand.type
    local TYPES = KSFUN_DEMAND_TYPES.PICK
    
    local base = string.format(STRINGS.KSFUN_TASK_PICK_DESC, num, name)
    if picktype == TYPES.TIME_LIMIT then
        return base..string.format(STRINGS.KSFUN_TASK_TIME_LIMIT, tostring(demand.duration))
    elseif picktype == TYPES.FULL_MOON then
        return base..STRINGS.KSFUN_TASK_FULL_MOON
    end
    return base
end



local function getFishTaskDesc(demand)
    local name = nil
    local TYPES = KSFUN_DEMAND_TYPES.FISH
    local fishtype  = demand.type

    if fishtype == TYPES.FISH_LIMIT then
        name = KsFunGetPrefabName(demand.data.fish)
    else
        name = STRINGS.KSFUN_TASK_FISH
    end

    if name == nil then
        return nil
    end

    local num = tostring(demand.data.num)
    local base = string.format(STRINGS.KSFUN_TASK_FISH_DESC , num, name)
    
    if fishtype == TYPES.POND_LIMIT then
        local pondname = KsFunGetPrefabName(demand.data.pond)
        return base..string.format(STRINGS.KSFUN_TASK_LIMIT, pondname)
    elseif fishtype == TYPES.TIME_LIMIT then
        return base..string.format(STRINGS.KSFUN_TASK_TIME_LIMIT, tostring(demand.duration))
    end
    return base
end




local function getCookTaskDesc(demand)
    local name = nil
    local TYPES = KSFUN_DEMAND_TYPES.COOK
    local cooktype = demand.type

    if cooktype == TYPES.FOOD_LIMIT then
        name = KsFunGetPrefabName(demand.data.food)
    else
        name = STRINGS.KSFUN_TASK_FOOD
    end

    if name == nil then
        return nil
    end

    local num  = tostring(demand.data.num)
    local base = string.format(STRINGS.KSFUN_TASK_COOK_DESC , num, name)
    
    if cooktype == TYPES.TIME_LIMIT then
        return base..string.format(STRINGS.KSFUN_TASK_TIME_LIMIT, tostring(demand.duration))
    end
    return base
end




local function getWorkDesc(demand)
     local data = demand.data
     local num = data.num
     if data.act == "CHOP" then
        return "砍"..num.."棵树"
     elseif data.act == "MINE" then
        return "挖"..num.."个矿石"
    elseif data.act == "DIG" then
        return "铲"..num.."株植物"
    end
    return nil
end




KsFunGetTaskDesc = function(taskdata)
    local NAMES  = KSFUN_TASK_NAMES
    local demand = taskdata.demand
    local name   = taskdata.name
    if name == NAMES.KILL then
        return getKillTaskDesc(demand)
    elseif name == NAMES.PICK then
        return getPickTaskDesc(demand)
    elseif name == NAMES.FISH then
        return getFishTaskDesc(demand)
    elseif name == NAMES.COOK then
        return getCookTaskDesc(demand)
    elseif name == NAMES.WORK then
        return getWorkDesc(demand)
    end
    return nil
end