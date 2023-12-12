local isch = KSFUN_TUNING.IS_CH

--- 角色属性名称
STRINGS.NAMES.KSFUN_POWER_HEALTH = isch and "血之祭祀" or ""
STRINGS.NAMES.KSFUN_POWER_HUNGER = "大胃王"
STRINGS.NAMES.KSFUN_POWER_SANITY = "建造专精"
STRINGS.NAMES.KSFUN_POWER_PICKER = "园艺大师"
STRINGS.NAMES.KSFUN_POWER_FARMER = "当代神农"
STRINGS.NAMES.KSFUN_POWER_HUNTER = "猎人"
STRINGS.NAMES.KSFUN_POWER_LUCKY  = "幸运"


STRINGS.PLAYER_POWERS = isch and {
    HUNGER = { "饥民", "助手", "厨子", "主厨", "食神" },
    SANITY = { "学徒", "通识者", "解密专家" },
    HEALTH = { "侍从", "狂战士", "骑士", "圣骑士", "战神" }
} or {
    HUNGER = { "Hungry people", "Assistant", "Cooker", "Chief", "Food god" },
    HEALTH = { "Squire", "Warrior", "Knight", "Paladin", "Mars", }
}






