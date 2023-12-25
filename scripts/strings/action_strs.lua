
local isch = KSFUN_TUNING.IS_CH
STRINGS.ACTIONS.KSFUN_USE_ITEM = {
    DRINK_POTION = isch and "服用" or "drink",
}
STRINGS.ACTIONS.KSFUN_REPAIR = {
    REPAIR = isch and "修理" or "repair",
}