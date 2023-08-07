local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES

local playersdef = {
    ["wilson"]       = {},
    ["willow"]       = {},
    ["wolfgang"]     = {},
    ["wendy"]        = { achievements = 20 },
    ["wx78"]         = { pblacks = {NAMES.HEALTH, NAMES.HUNGER, NAMES.SANITY} },  -- 机器人三维会变化，暂时不兼容
    ["wickerbottom"] = {},
    ["woodie"]       = {},
    ["wes"]          = { exp = 1.2, achievements = 20 },
    ["waxwell"]      = {},
    ["wathgrithr"]   = {},
    ["webber"]       = {},
    ["winona"]       = {},
    ["warly"]        = {},
    ["walter"]       = {},
}



local players = {}

players.playerconfig = function(player)
    return playersdef[player.prefab]
end


return players