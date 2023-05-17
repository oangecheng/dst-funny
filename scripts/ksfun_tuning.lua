KSFUN_TUNING =  {

    DEBUG = true,
    LOG_TAG = "ksfun_log: ",


    PLAYER_POWER_NAMES = {
        HEALTH = "player_health",
        HUNGER = "player_hunger",
        SANITY = "player_sanity",
    },

    ITEM_POWER_NAMES = {
        WATER_PROOFER = "item_water_proofer",
        DAPPERNESS = "item_dapperness",
        INSULATOR = "item_insulator",
    },


    ITEM_QUALITY = {
        WHITE = 1,
        GREEN = 2,
        BLUE = 3,
        GOLD = 4,
        ORANGE = 5,
        RED = 6,
        MAX = 6,
    },
    


    TASK_TIME_SEG = TUNING.SEG_TIME,
    TASK_TIME_TOTAL_DAY = TUNING.TOTAL_DAY_TIME,


    --- 任务需求的类型
    TASK_DEMAND_TYPES = {
        --- 击杀类型
        KILL = {
            NORMAL = 1,
            TIME_LIMIT = 2,
            ATTACKED_LIMIT = 3,
        },
    },

    TASK_REWARD_TYPES = {
        ITEM = {
            NORMAL = 1,
        }, -- 物品
        KSFUN_ITEM = {
            WEAPON = 1,
            HAT = 2,
            ARMOR = 3,
            MELT = 4,
        },
        PLAYER_POWER = PLAYER_POWER_NAMES,
    },

    --- 任务等级定义，分为6级
    TASK_LV_DEFS = {
        UNKNOWN = 0, LV1 = 1, LV2 = 2, LV3 = 3, LV4 = 4, LV5 = 5, LV6 = 6, MAX = 6
    },

    TASK_NAMES = {
        KILL = "kill",
    },


    EVENTS = {
        PLAYER_STATE_CHANGE = "ksfun_player_state_change",
        PLAYER_PANEL = "ksfun_player_refresh_panel",
        TASK_FINISH = "ksfun_task_finish",
    }

}