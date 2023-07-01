

KSFUN_TUNING =  {

    -- 难度配置，0为默认
    DIFFCULTY = 0,
    MODE = 1,

    DEBUG = true,
    LOG_TAG = "ksfun_log: ",  

    -- 角色属性
    PLAYER_POWER_NAMES = {

        HEALTH        = "player_health",
        HUNGER        = "player_hunger",
        SANITY        = "player_sanity",

        CRIT_DAMAGE   = "player_critdamage",
        LOCOMOTOR     = "player_locomotor",
        DAMAGE        = "player_damage",

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
    },


    TIME_SEG = TUNING.SEG_TIME,
    TIME_TOTAL_DAY = TUNING.TOTAL_DAY_TIME,



    TASK_NAMES = {
        KILL = "kill",
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
    POWER_REMOVE   = "ksfun_power_remove", 
}