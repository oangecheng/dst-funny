
local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local KSFUN_HUNGER = {}


local function onLvChangeFunc(inst, lv, notice)
end

local function onStateChangeFunc(inst)
end

local function nextLvExpFunc(inst, lv)
end


local function onAttachFunc(inst, player, name)
    
end


local function onDetachFunc(inst, player, name)
end


KSFUN_HUNGER.power = {
    name = NAMES.HUNGER,
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
}

KSFUN_HUNGER.level = {
    onLvChangeFunc = onLvChangeFunc,
    onStateChangeFunc = onStateChangeFunc,
    nextLvExpFunc = nextLvExpFunc,
}