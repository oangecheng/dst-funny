

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
        NOT_KILL       = 4,
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