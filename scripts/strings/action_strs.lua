
local isch = KSFUN_TUNING.IS_CH
STRINGS.ACTIONS.KSFUN_USE_ITEM = isch and {
    DRINK_POTION = isch and "服用" or "drink"
}