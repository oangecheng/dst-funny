local isch = KSFUN_TUNING.IS_CH

--- 角色属性名称
STRINGS.NAMES.KSFUN_POWER_HEALTH = isch and "血之祭祀" or ""
STRINGS.NAMES.KSFUN_POWER_HUNGER = "大胃王"
STRINGS.NAMES.KSFUN_POWER_SANITY = "建造专精"
STRINGS.NAMES.KSFUN_POWER_PICKER = "园艺大师"
STRINGS.NAMES.KSFUN_POWER_FARMER = "当代神农"
STRINGS.NAMES.KSFUN_POWER_HUNTER = "猎人"
STRINGS.NAMES.KSFUN_POWER_LUCKY  = "幸运"


STRINGS.PLAYER_POWERS = {
    HUNGER = {
        isch and "饥民" or "Hungry people",
        isch and "助手" or "Assistant",
        isch and "厨子" or "Cooker",
        isch and ""
    },
    HEALTH = {
        isch and "侍从" or "Squire",
        isch and "狂战士" or "Warrior", 
        isch and "骑士" or "Knight",
        isch and "圣骑士" or "Paladin",
        isch and "战神" or "Mars",
    }
}






