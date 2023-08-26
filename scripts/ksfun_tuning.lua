

KSFUN_TUNING =  {

    -- 难度配置，0为默认
    DIFFCULTY = 0,
    MODE = 1,

    DEBUG = false,
    PRINT_LOG = false,
    LOG_TAG = "ksfun_log: ",  

    -- 角色属性
    PLAYER_POWER_NAMES = {

        HEALTH        = "player_health",
        HUNGER        = "player_hunger",
        SANITY        = "player_sanity",
        LUCKY         = "player_lucky",
        LOCOMOTOR     = "player_locomotor",
        PICK          = "player_pick",
        FARM          = "player_farm",
        KILL_DROP     = "player_killdrop",
        COOKER        = "player_cooker",
        
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
}