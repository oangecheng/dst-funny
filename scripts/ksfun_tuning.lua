

KSFUN_TUNING =  {

    -- 难度配置，0为默认
    DIFFCULTY = 0,
    MODE = 1,

    DEBUG = false,
    PRINT_LOG = true,
    LOG_TAG = "ksfun_log: ",  

    -- 角色属性
    PLAYER_POWER_NAMES = {

        HEALTH        = "player_health",
        HUNGER        = "player_hunger",
        SANITY        = "player_sanity",
        LUCKY         = "player_lucky",

        CRIT_DAMAGE   = "player_critdamage",
        LOCOMOTOR     = "player_locomotor",

        PICK          = "player_pick",
        FARM          = "player_farm",
        KILL_DROP     = "player_killdrop",
    },

    -- 物品属性
    ITEM_POWER_NAMES = {
        WATER_PROOFER = "item_waterproofer",
        DAPPERNESS    = "item_dapperness",
        INSULATOR     = "item_insulator",
        
        DAMAGE        = "item_damage",
        CHOP          = "item_chop",
        MINE          = "item_mine",
        LIFESTEAL     = "item_lifesteal",
        AOE           = "item_aoe",
        MAXUSES       = "item_maxuses",
        SPEED         = "item_speed",
        ABSORB        = "item_absorb"
    },

    --- 怪物属性
    MONSTER_POWER_NAMES = {
        CRIT_DAMAGE   = "monster_critdamage",
        HEALTH        = "monster_health",
        LOCOMOTOR     = "monster_locomotor",
        DAMAGE        = "monster_damage",
        REAL_DAMAGE   = "monster_real_damage",
        ICE_EXPLOSION = "monster_ice_explosion",
        SANITY_AURA   = "monster_sanity_aura",
        ABSORB        = "monster_absorb",
        KNOCK_BACK    = "monster_knockback",
        STEAL         = "monster_steal",
        LIFESTEAL     = "monster_lifesteal"
    },


    NEGA_POWER_NAMES = {
        DIARRHEA      = "nega_diarrhea",
        UNLUCKY       = "nega_unlucky",
        WEAK          = "nega_weak",
    },


    TIME_SEG = TUNING.SEG_TIME,
    TOTAL_DAY_TIME = TUNING.TOTAL_DAY_TIME,



    TASK_NAMES = {
        KILL = "kill",
        PICK = "pick",
        FISH = "fish",
        COOK = "cook",
    },

    --- 任务需求的类型
    TASK_DEMAND_TYPES = {
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
        }
    },


    KSFUN_ITEM_TYPES = {
        WEAPON = 1,
        HAT    = 2,
        ARMOR  = 3,
        GEM    = 4,
    },

    EVENTS = {
        TASK_FINISH  = "ksfun_task_finish",
        PLAYER_PANEL = "ksfun_player_refresh_panel",
        POWER_ATTACH = "ksfun_power_attach",

        POWER_REMOVE   = "ksfun_power_remove", 
    },

}


KSFUN_EVENTS = {
    POWER_REMOVE      = "ksfun_power_remove",
    FISH_SUCCESS      = "ksfun_fish_success", 
    HARVEST_SELF_FOOD = "ksfun_harvest_self_food",
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