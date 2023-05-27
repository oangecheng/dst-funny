

KSFUN_TUNING =  {

    DEBUG = true,
    LOG_TAG = "ksfun_log: ",


    PLAYER_POWER_NAMES = {
        HEALTH = "player_health",
        HUNGER = "player_hunger",
        SANITY = "player_sanity",
    },

    ITEM_POWER_NAMES = {
        FOREVER       = "item_forever",
        WATER_PROOFER = "item_waterproofer",
        DAPPERNESS    = "item_dapperness",
        INSULATOR     = "item_insulator",
        DAMAGE        = "item_damage",
        CHOP          = "item_chop",
        MINE          = "item_mine",
        LIFESTEAL     = "item_lifesteal",
        AOE           = "item_aoe",
    },


    ITEM_QUALITY = {
        WHITE = 1, GREEN = 2, BLUE = 3, GOLD = 4, ORANGE = 5, RED = 6, MAX = 6,
    },


    TIME_SEG = TUNING.SEG_TIME,
    TIME_TOTAL_DAY = TUNING.TOTAL_DAY_TIME,



    TASK_NAMES = {
        KILL = "kill",
    },

    --- 任务等级定义，分为6级
    TASK_LV_DEFS = {
        UNKNOWN = 0, LV1 = 1, LV2 = 2, LV3 = 3, LV4 = 4, LV5 = 5, LV6 = 6, MAX = 6
    },

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
        -- 普通物品奖励
        ITEM = 1,
        -- 升级物品
        KSFUN_ITEM = 2,
        -- 属性奖励
        PLAYER_POWER = 3,
        -- 属性等级奖励
        PLAYER_POWER_LV = 4,
        -- 属性经验奖励
        PLAYER_POWER_EXP = 5,
    },

    KSFUN_ITEM_TYPES = {
        WEAPON = 1,
        HAT    = 2,
        ARMOR  = 3,
        MELT   = 4,
    },

    EVENTS = {
        PLAYER_STATE_CHANGE = "ksfun_player_state_change",
        TASK_FINISH = "ksfun_task_finish",

        PLAYER_PANEL = "ksfun_player_refresh_panel",
    },


    TAGS = {
        "ksfun_melt_material",       --熔炼材料
    }

}