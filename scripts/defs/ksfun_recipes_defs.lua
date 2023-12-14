local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES

local potionpick   = NAMES.PICK
local potionsanity = NAMES.SANITY



local recipespick = {
    dug_berrybush_juicy = { placer = 0, materials = { [potionpick] = 1, dug_grass = 1, berries = 2 }},
    dug_berrybush       = { placer = 0, materials = { [potionpick] = 1, dug_grass = 1, berries = 2 }},
    dug_berrybush2      = { placer = 0, materials = { [potionpick] = 1, dug_grass = 1, berries = 2 }},
    green_mushroom      = { placer = 1, materials = { [potionpick] = 1, green_cap = 1 } },
    red_mushroom        = { placer = 1, materials = { [potionpick] = 1, red_cap   = 1 } },
    blue_mushroom       = { placer = 1, materials = { [potionpick] = 1, blue_cap  = 1 } },
    reeds               = { placer = 1, materials = { [potionpick] = 1, cutreeds  = 5 } },
    oasis_cactus        = { placer = 1, materials = { [potionpick] = 1, cactus_meat = 4, cactus_flower = 2 }},
    cactus              = { placer = 1, materials = { [potionpick] = 1, cactus_meat = 4, cactus_flower = 2 }},
    mandrake            = { placer = 1, materials = { [potionpick] = 1, reviver = 1, seeds = 1 } }
}


local recipessanity = {
    gears               = { placer = 0, materials = { [potionsanity] = 1, goldnugget = 10, redgem = 1, bluegem = 1 }}
}



return {
    [NAMES.SANITY] = recipessanity,
    -- [NAMES.PICK]   = recipespick
}