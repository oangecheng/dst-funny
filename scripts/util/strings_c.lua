
local MOOSE = "MOOSE"
if STRINGS.NAMES[MOOSE] == nil then
    STRINGS.NAMES[MOOSE] = "麋鹿鹅" 
end


-- 特殊名称处理
STRINGS.KSFUN_NAMES = {
    ["koalefant_summer"]   = STRINGS.NAMES[string.upper("koalefant_summer")].."(夏)",
    ["koalefant_winter"]   = STRINGS.NAMES[string.upper("koalefant_summer")].."(冬)",
    ["leif_sparse"]        = STRINGS.NAMES[string.upper("leif_sparse")].."(常青)",
    ["cactus"]             = STRINGS.NAMES[string.upper("cactus")].."(球形)",
    ["oasis_cactus"]       = STRINGS.NAMES[string.upper("cactus")].."(叶形)",
    ["berrybush2"]         = STRINGS.NAMES[string.upper("berrybush")].."(多叶)", -- 浆果丛2
    ["flower_cave"]        = STRINGS.NAMES[string.upper("flower_cave")].."(1果)",
    ["flower_cave_double"] = STRINGS.NAMES[string.upper("flower_cave")].."(2果)", 
    ["flower_cave_triple"] = STRINGS.NAMES[string.upper("flower_cave")].."(3果)",
    ["pond_cave"]          = STRINGS.NAMES[string.upper("pond")].."(洞穴)",
    ["pond_mos"]           = STRINGS.NAMES[string.upper("pond")].."(蚊子)",
    ["moose"]              = "麋鹿鹅",
    ["gears_blueprint"]    = STRINGS.NAMES[string.upper("gears")].."蓝图",
}





-------------------------------------------------------------------------- 物品相关字符串----------------------------------------------------------------------------------
STRINGS.NAMES.KSFUN_TASK_REEL = "任务卷轴"         
STRINGS.RECIPE_DESC.KSFUN_TASK_REEL = "任务卷轴"
STRINGS.CHARACTERS.GENERIC.KSFUN_TASK_REEL= "任务卷轴"

STRINGS.NAMES.KSFUN_POTION = "魔法药剂"         
STRINGS.RECIPE_DESC.KSFUN_POTION = "一种具有神奇能力的药剂！"
STRINGS.CHARACTERS.GENERIC.KSFUN_POTION= "神奇的药剂！"

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

ACTIONS_KSFUN_USE_ITEM_GENERIC_STR = "使用"
ACTIONS_KSFUN_USE_ITEM_STR = "使用"





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
STRINGS.NAMES.KSFUN_POWER_PLAYER_HEALTH         = "血之祭祀"
STRINGS.NAMES.KSFUN_POWER_PLAYER_LOCOMOTOR      = "快如闪电"
STRINGS.NAMES.KSFUN_POWER_PLAYER_HUNGER         = "大胃王"
STRINGS.NAMES.KSFUN_POWER_PLAYER_SANITY         = "建造专精"
STRINGS.NAMES.KSFUN_POWER_PLAYER_PICK           = "园艺大师"
STRINGS.NAMES.KSFUN_POWER_PLAYER_FARM           = "当代神农"
STRINGS.NAMES.KSFUN_POWER_PLAYER_KILLDROP       = "猎人"
STRINGS.NAMES.KSFUN_POWER_PLAYER_LUCKY          = "幸运"
STRINGS.NAMES.KSFUN_POWER_PLAYER_GIANT          = "巨人"
STRINGS.NAMES.KSFUN_POWER_PLAYER_COOKER         = "厨子"


--- 怪物属性，可以不显示名称，预留
STRINGS.NAMES.KSFUN_POWER_MONSTER_CRITDAMAGE    = "暴击"
STRINGS.NAMES.KSFUN_POWER_MONSTER_HEALTH        = "生命"
STRINGS.NAMES.KSFUN_POWER_MONSTER_LOCOMOTOR     = "移速"
STRINGS.NAMES.KSFUN_POWER_MONSTER_DAMAGE        = "攻击"
STRINGS.NAMES.KSFUN_POWER_MONSTER_REAL_DAMAGE   = "真伤"
STRINGS.NAMES.KSFUN_POWER_MONSTER_SANITY_AURA   = "降智"
STRINGS.NAMES.KSFUN_POWER_MONSTER_ICE_EXPLOSION = "冰爆"
STRINGS.NAMES.KSFUN_POWER_MONSTER_ABSORB        = "防御"
STRINGS.NAMES.KSFUN_POWER_MONSTER_KNOCKBACK     = "击退"
STRINGS.NAMES.KSFUN_POWER_MONSTER_STEAL         = "窃取"
STRINGS.NAMES.KSFUN_POWER_MONSTER_LIFESTEAL     = "吸血"
STRINGS.NAMES.KSFUN_POWER_MONSTER_BRAMBLE       = "荆棘"

--- 属性描述，先简单点，后面再完善描述
STRINGS.KSFUN_POWER_DESC = {
    KSFUN_POWER_ITEM_WATERPROOFER = "增强装备防水能力",
    KSFUN_POWER_ITEM_DAPPERNESS   = "提升角色精神值回复速度",
    KSFUN_POWER_ITEM_INSULATOR    = "增强装备保暖/隔热能力",
    KSFUN_POWER_ITEM_DAMAGE       = "增强武器的攻击",
    KSFUN_POWER_ITEM_CHOP         = "武器可伐木/效率提升",
    KSFUN_POWER_ITEM_MINE         = "武器可挖矿/效率提升",
    KSFUN_POWER_ITEM_LIFESTEAL    = "攻击获得生命值" ,
    KSFUN_POWER_ITEM_AOE          = "造成%s范围%s溅射伤害",
    KSFUN_POWER_ITEM_MAXUSES      = "装备耐久度提升",
    KSFUN_POWER_ITEM_SPEED        = "装备附加额外移速",
    KSFUN_POWER_ITEM_ABSORB       = "护甲提供额外防护",

    KSFUN_POWER_PLAYER_HEALTH     = "提升角色的血量上限",
    KSFUN_POWER_PLAYER_LOCOMOTOR  = "提升角色的移动速度",
    KSFUN_POWER_PLAYER_HUNGER     = "提示角色饱食度上限",
    KSFUN_POWER_PLAYER_SANITY     = "提升角色精神值上限",
    KSFUN_POWER_PLAYER_PICK       = "采集加速/倍率获取",
    KSFUN_POWER_PLAYER_FARM       = "倍率采集农作物/施肥提效",
    KSFUN_POWER_PLAYER_KILLDROP   = "击杀额外掉落物品",
    KSFUN_POWER_PLAYER_LUCKY      = "更多的好事/更少的坏事",
    KSFUN_POWER_PLAYER_GIANT      = "提升工作效率/增加模型大小",
    KSFUN_POWER_PLAYER_COOKER     = "快速烹调/熟练的使用菜刀",
}

STRINGS.KSFUN_NEGA_POWER_NOTICE = {
    KSFUN_POWER_NEGA_DIARRHEA     = "%s也太不讲卫生了，因为闹肚子随地大小便"

}


STRINGS.KSFUN_POWER_LEVEL_UP_NOTICE = "%s等级提升!"
STRINGS.KSFUN_POWER_LEVEL_MAX       = "已达到最高等级!"
STRINGS.KSFUN_POWER_LOST_PLAYER     = "%s太菜了, [%s] 被系统剥夺了"
STRINGS.KSFUN_PLAYER_DEATH_NOTICE   = "%s受到死亡惩罚,全属性等级下降%s"



-------------------------------------------------------------------------- 装备强化 ----------------------------------------------------------------------------------
STRINGS.KSFUN_ENHANT_SUCCESS  = "%s成功给%s附加了%s"
STRINGS.KSFUN_ENHANT_FAIL_1   = "装备等级过低!"
STRINGS.KSFUN_ENHANT_FAIL_2   = "装备无法附加相同属性!"

STRINGS.KSFUN_REINFORCE_INVALID_ITEM    = "当前材料无法进行强化!"
STRINGS.KSFUN_REINFORCE_INVALID_TARGET  = "当前装备无法进行强化!"
STRINGS.KSFUN_FORG_SUCCESS_NOTICE       = "%s使用%s成功提升了%s"

STRINGS.KSFUN_BREAK_COUNT = "阶"






-------------------------------------------------------------------------- 任务相关字符串----------------------------------------------------------------------------------
STRINGS.NAMES.KSFUN_TASK_KILL = "击杀任务"
STRINGS.NAMES.KSFUN_TASK_PICK = "采集任务"
STRINGS.NAMES.KSFUN_TASK_FISH = "钓鱼任务"
STRINGS.NAMES.KSFUN_TASK_COOK = "烹调任务"

STRINGS.KSFUN_TASK_WIN        = "任务成功"
STRINGS.KSFUN_TASK_LOSE       = "任务失败"
STRINGS.KSFUN_TASK_ACCEPT     = "接受任务"
STRINGS.KSFUN_TASK_LIMIT_NUM  = "任务数量已达上限"
STRINGS.KSFUN_TASK_LIMIT_NAME = "同类型任务只能接受一个"


STRINGS.KSFUN_TASK_KILL_DESC  = "击杀 %s 只 %s"
STRINGS.KSFUN_TASK_KILL_NOT_DESC = "放下屠刀,立地成佛"
STRINGS.KSFUN_TASK_PICK_DESC  = "采集 %s 个 %s"
STRINGS.KSFUN_TASK_FISH_DESC  = "钓 %s 条 %s"
STRINGS.KSFUN_TASK_COOK_DESC  = "制作 %s 份 %s"

STRINGS.KSFUN_TASK_FISH       = "任意的鱼"
STRINGS.KSFUN_TASK_FOOD       = "任意料理" 

STRINGS.KSFUN_TASK_TIME_LIMIT = "(限制: %s秒)"
STRINGS.KSFUN_TASK_NO_HURT    = "(限制: 无伤)"
STRINGS.KSFUN_TASK_FULL_MOON  = "(限制: 满月)"
STRINGS.KSFUN_TASK_LIMIT      = "(限制: %s)" 



STRINGS.KSFUN_TASK_REWARD_ITEM      = "%s的运气爆棚,获得了 [%s]x%s"

STRINGS.KSFUN_TASK_REWARD_ITEM_2    = "任务成功, 奖励%s"
STRINGS.KSFUN_TASK_REWARD_ITEM_3    = "%s完成了任务，获得了%s"

STRINGS.KSFUN_TASK_PUNISH_NONE      = "任务失败, 不过太走运了!"
STRINGS.KSFUN_TASK_PUNISH_POWER_LV  = "任务失败, %s等级%s"
STRINGS.KSFUN_TASK_PUNISH_POWER_EXP = "任务失败, %s经验%s"
STRINGS.KSFUN_TASK_PUNISH_MONSTER   = "任务失败, 接受怪物们的制裁吧!"
