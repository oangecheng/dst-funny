KSFUN_TUNING =  {

    DEBUG = true,


    PLAYER_POWER_NAMES = {
        HEALTH = "player_health",
        HUNGER = "player_hunger",
        SANITY = "player_sanity",
    },


    ITEM_QUALITY = {
        WHITE = 1,
        GREEN = 2,
        BLUE = 3,
        GOLD = 4,
        ORANGE = 5,
        MAX = 5,
    },
    


    TASK_TIME_SEG = TUNING.SEG_TIME,
    TASK_TIME_TOTAL_DAY = TUNING.TOTAL_DAY_TIME,
    --- 任务需求的类型
    TASK_DEMAND_TYPES = {
        --- 击杀类型
        KILL = 1,
        KILL_JUNIOR = 2, 
        KILL_SENIOR = 3,

        PICK = 11,
        DIG = 12,
        HARMMER = 13,
        MINE = 14,
        CHOP = 15,
        FISH = 16,
    },

    TASK_REWARD_TYPES = {
        ITEM = 1, -- 物品
     
    },

    TASK_DEMAND_LEVELS = {
        UNKNOWN = 0, LV1 = 1, LV2 = 2, LV3 = 3, LV4 = 4, LV5 = 5, LV6 = 6, LV_MAX = 6,
    },
    TASK_REWARD_LEVELS = {
        UNKNOWN = 0, LV1 = 1, LV2 = 2, LV3 = 3, LV4 = 4, LV5 = 5, LV6 = 6, LV_MAX = 6,
    },


    EVENTS = {
        PLAYER_STATE_CHANGE = "ksfun_player_state_change",
        PLAYER_PANEL = "ksfun_player_refresh_panel"
    }

}