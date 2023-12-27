

KSFUN_TUNING =  {

    -- 难度配置，0为默认
    DIFFCULTY = 0,
    MODE = 1,
    IS_CH = true,

    DEBUG = true,
    PRINT_LOG = true,
    LOG_TAG = "ksfun_log: ",  

    -- 角色属性
    PLAYER_POWER_NAMES = {
        HEALTH        = "health",
        HUNGER        = "hunger",
        SANITY        = "sanity",
        LUCKY         = "lucky",
        PICK          = "picker",
        FARM          = "farmer",
        HUNTER        = "hunter",        
    },

    -- 物品属性
    ITEM_POWER_NAMES = {
        WATER         = "item_waterproofer",
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
        LIFESTEAL     = "monster_lifesteal",
        BRAMBLE       = "monster_bramble",
    },


    NEGA_POWER_NAMES = {
        DIARRHEA      = "nega_diarrhea",
        UNLUCKY       = "nega_unlucky",
        WEAK          = "nega_weak",
    },


    TIME_SEG = TUNING.SEG_TIME,
    TOTAL_DAY_TIME = TUNING.TOTAL_DAY_TIME,

}


KSFUN_EVENTS = {
    POWER_REMOVE      = "ksfun_power_remove",
    FISH_SUCCESS      = "ksfun_fish_success", 
    HARVEST_SELF_FOOD = "ksfun_harvest_self_food",
    TASK_FINISH       = "ksfun_task_finish",
    PLAYER_PANEL      = "ksfun_player_refresh_panel",
    POWER_ATTACH      = "ksfun_power_attach",
    HARVEST_DRY       = "ksfun_harvest_dry", 
}


KSFUN_POWER_CONFIGS = {
    PLAYER_3D = 0.01
}


KSFUN_TAGS = {
    REPAIRABLE = "ksfun_repairable",
    FERTILIZER = "ksfun_fertilizer",
}


---抗性定义
KSFUN_RESISTS = {
    STEAL = "health_steal",
    KNOCK = "knockback",
    BRAMBLE = "bramble",
    REALITY = "reality",
    STIFF = "stiff", --僵直
}