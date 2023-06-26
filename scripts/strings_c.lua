
local MOOSE = "MOOSE"
if STRINGS.NAMES[MOOSE] == nil then
    STRINGS.NAMES[MOOSE] = "麋鹿鹅" 
end

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
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_DAPPERNESS   = "愉悦石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_INSULATOR    = "冰火石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_DAMAGE       = "锋锐石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_CHOP         = "伐木石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_MINE         = "精矿石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_LIFESTEAL    = "饮血石"         
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_MAXUSES      = "耐久石"
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_SPEED        = "移速石"
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_ABSORB       = "防护石"
STRINGS.NAMES.KSFUN_POWER_GEM_ITEM_AOE          = "溅射石"         


--- 通用属性名称
STRINGS.NAMES.KSFUN_POWER_CRIT_DAMAGE           = "致命一击"
STRINGS.NAMES.KSFUN_POWER_HEALTH                = "血量增强"
STRINGS.NAMES.KSFUN_POWER_LOCOMOTOR             = "快如闪电"
STRINGS.NAMES.KSFUN_POWER_DAMAGE                = "伤害加深"


--- 角色属性名称
STRINGS.NAMES.KSFUN_POWER_PLAYER_HUNGER         = "大胃王"
STRINGS.NAMES.KSFUN_POWER_PLAYER_SANITY         = "基建狂魔"
STRINGS.NAMES.KSFUN_POWER_PLAYER_PICK           = "园艺大师"
STRINGS.NAMES.KSFUN_POWER_PLAYER_FARM           = "当代神农"


--- 怪物属性，可以不显示名称，预留
STRINGS.NAMES.KSFUN_POWER_MONSTER_REAL_DAMAGE   = "真实伤害"
STRINGS.NAMES.KSFUN_POWER_MONSTER_SANITY_AURA   = "降智光环"
STRINGS.NAMES.KSFUN_POWER_MONSTER_ICE_EXPLOSION = "死亡冰爆"
STRINGS.NAMES.KSFUN_POWER_MONSTER_ABSORB        = "防御强化"





-------------------------------------------------------------------------- 任务相关字符串----------------------------------------------------------------------------------
STRINGS.NAMES.KSFUN_TASK_KILL = "击杀任务"
STRINGS.KSFUN_TASK_WIN  = "任务成功"
STRINGS.KSFUN_TASK_LOSE = "任务失败"

STRINGS.KSFUN_GAIN      = "获得"
STRINGS.KSFUN_EXP       = "经验"
STRINGS.KSFUN_LV        = "等级"
STRINGS.KSFUN_REWARD    = "奖励"
STRINGS.KSFUN_ITEM     = "特殊物品"

STRINGS.KSFUN_REWARD_EXP   = STRINGS.KSFUN_GAIN..STRINGS.KSFUN_EXP..STRINGS.KSFUN_REWARD
STRINGS.KSFUN_REWARD_LV    = STRINGS.KSFUN_GAIN..STRINGS.KSFUN_LV..STRINGS.KSFUN_REWARD
STRINGS.KSFUN_REWARD_ITEM  = STRINGS.KSFUN_GAIN..STRINGS.KSFUN_ITEM..STRINGS.KSFUN_REWARD

