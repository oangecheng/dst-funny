
local MOOSE = "MOOSE"
if STRINGS.NAMES[MOOSE] == nil then
    STRINGS.NAMES[MOOSE] = "麋鹿鹅" 
end


-- 特殊名称处理
STRINGS.KSFUN_NAMES = {
    ["koalefant_summer"] = STRINGS.NAMES[string.upper("koalefant_summer")].."(夏)",
    ["koalefant_winter"] = STRINGS.NAMES[string.upper("koalefant_summer")].."(冬)",
    ["leif_sparse"]      = STRINGS.NAMES[string.upper("leif_sparse")].."(常青)",
    ["moose"]            = "麋鹿鹅",
}



-------------------------------------------------------------------------- 物品相关字符串----------------------------------------------------------------------------------
STRINGS.NAMES.KSFUN_TASK_REEL = "任务卷轴"         
STRINGS.RECIPE_DESC.KSFUN_TASK_REEL = "任务卷轴"
STRINGS.CHARACTERS.GENERIC.KSFUN_TASK_REEL= "任务卷轴"
-- 可升级物品名称
-- STRINGS.KSFUN_WEAPON_DESC = "巨龙的"
-- STRINGS.KSFUN_HAT_DESC    = "遗失的"
-- STRINGS.KSFUN_ARMOR_DESC  = "域外的"
-- STRINGS.NAMES.KSFUN_ITEM_DESC_SPEAR = ""
-- STRINGS.NAMES.KSFUN_ITEM_DESC_SPEAR_WATHGRITHR = ""
-- STRINGS.NAMES.KSFUN_ITEM_DESC_RUINS_BAT = ""
-- STRINGS.NAMES.KSFUN_ITEM_DESC_NIGHTSWORD = ""
-- STRINGS.NAMES.KSFUN_ITEM_DESC_EYEBRELLAHAT = ""
-- STRINGS.NAMES.KSFUN_ITEM_DESC_WALRUSHAT = ""
-- STRINGS.NAMES.KSFUN_ITEM_DESC_ALTERGUARDIANHAT = ""




-------------------------------------------------------------------------- action相关字符串----------------------------------------------------------------------------------
ACTIONS_KSFUN_TASK_DEMAND_GENERIC_STR = "接受"
ACTIONS_KSFUN_TASK_DEMAND_STR = "接受"






-------------------------------------------------------------------------- 属性相关字符串----------------------------------------------------------------------------------
--- 物品属性名称
STRINGS.NAMES.KSFUN_POWER_ITEM_WATERPROOFER     = "防水属性"
STRINGS.NAMES.KSFUN_POWER_ITEM_DAPPERNESS       = "精神恢复"
STRINGS.NAMES.KSFUN_POWER_ITEM_INSULATOR        = "气温防护"
STRINGS.NAMES.KSFUN_POWER_ITEM_DAMAGE           = "锋锐" 
STRINGS.NAMES.KSFUN_POWER_ITEM_CHOP             = "伐木"
STRINGS.NAMES.KSFUN_POWER_ITEM_MINE             = "采矿" 
STRINGS.NAMES.KSFUN_POWER_ITEM_LIFESTEAL        = "生命窃取" 
STRINGS.NAMES.KSFUN_POWER_ITEM_AOE              = "溅射伤害"
STRINGS.NAMES.KSFUN_POWER_ITEM_MAXUSES          = "耐久强化"
STRINGS.NAMES.KSFUN_POWER_ITEM_SPEED            = "移速增强"
STRINGS.NAMES.KSFUN_POWER_ITEM_ABSORB           = "防御强化"
--- 物品属性对应的宝石名称
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_WATERPROOFER = "防水石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_DAPPERNESS   = "精神石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_INSULATOR    = "冰火石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_DAMAGE       = "锋锐石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_CHOP         = "伐木石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_MINE         = "精矿石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_LIFESTEAL    = "饮血石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_MAXUSES      = "耐久石"
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_SPEED        = "移速石"
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_ABSORB       = "防护石"
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_AOE          = "溅射石"         


--- 角色属性名称
STRINGS.NAMES.KSFUN_POWER_PLAYER_CRITDAMAGE     = "致命一击"
STRINGS.NAMES.KSFUN_POWER_PLAYER_HEALTH         = "血量增强"
STRINGS.NAMES.KSFUN_POWER_PLAYER_LOCOMOTOR      = "快如闪电"
STRINGS.NAMES.KSFUN_POWER_PLAYER_DAMAGE         = "伤害加深"
STRINGS.NAMES.KSFUN_POWER_PLAYER_HUNGER         = "大胃王"
STRINGS.NAMES.KSFUN_POWER_PLAYER_SANITY         = "基建狂魔"
STRINGS.NAMES.KSFUN_POWER_PLAYER_PICK           = "园艺大师"
STRINGS.NAMES.KSFUN_POWER_PLAYER_FARM           = "当代神农"


--- 怪物属性，可以不显示名称，预留
STRINGS.NAMES.KSFUN_POWER_MONSTER_CRITDAMAGE    = "致命一击"
STRINGS.NAMES.KSFUN_POWER_MONSTER_HEALTH        = "血量增强"
STRINGS.NAMES.KSFUN_POWER_MONSTER_LOCOMOTOR     = "快如闪电"
STRINGS.NAMES.KSFUN_POWER_MONSTER_DAMAGE        = "伤害加深"
STRINGS.NAMES.KSFUN_POWER_MONSTER_REAL_DAMAGE   = "真实伤害"
STRINGS.NAMES.KSFUN_POWER_MONSTER_SANITY_AURA   = "降智光环"
STRINGS.NAMES.KSFUN_POWER_MONSTER_ICE_EXPLOSION = "死亡冰爆"
STRINGS.NAMES.KSFUN_POWER_MONSTER_ABSORB        = "防御强化"




STRINGS.KSFUN_LV_UP_HEALTH = "生命等级提升!"
STRINGS.KSFUN_LV_UP_HUNGER = "饱食等级提升!"
STRINGS.KSFUN_LV_UP_SANITY = "精神等级提升!"
STRINGS.KSFUN_LV_MAX       = "已满级!"


STRINGS.KSFUN_POWER_DESC_PICK = "采集加速，倍率获取"


STRINGS.KSFUN_ENHANT_SUCCESS  = "%s成功给%s附加了%s"
STRINGS.KSFUN_ENHANT_FAIL_1   = "装备等级过低!"
STRINGS.KSFUN_ENHANT_FAIL_2   = "装备无法附加相同属性!"

STRINGS.KSFUN_REINFORCE_INVALID_ITEM    = "当前材料无法进行强化!"
STRINGS.KSFUN_REINFORCE_INVALID_TARGET  = "当前装备无法进行强化!"


-------------------------------------------------------------------------- 任务相关字符串----------------------------------------------------------------------------------
STRINGS.NAMES.KSFUN_TASK_KILL = "击杀任务"
STRINGS.KSFUN_TASK_WIN  = "任务成功"
STRINGS.KSFUN_TASK_LOSE = "任务失败"

STRINGS.KSFUN_GAIN      = "获得"
STRINGS.KSFUN_EXP       = "经验"
STRINGS.KSFUN_LV        = "等级"
STRINGS.KSFUN_REWARD    = "奖励"
STRINGS.KSFUN_ITEM      = "特殊物品"


STRINGS.KSFUN_TASK_KILL_DESC  = "击杀 %s 只 %s"
STRINGS.KSFUN_TASK_TIME_LIMIT = "(限制: %s 秒)"
STRINGS.KSFUN_TASK_NO_HURT    = "(限制: 无伤)"


STRINGS.KSFUN_REWARD_EXP   = STRINGS.KSFUN_GAIN..STRINGS.KSFUN_EXP..STRINGS.KSFUN_REWARD
STRINGS.KSFUN_REWARD_LV    = STRINGS.KSFUN_GAIN..STRINGS.KSFUN_LV..STRINGS.KSFUN_REWARD
STRINGS.KSFUN_REWARD_ITEM  = STRINGS.KSFUN_GAIN..STRINGS.KSFUN_ITEM..STRINGS.KSFUN_REWARD

