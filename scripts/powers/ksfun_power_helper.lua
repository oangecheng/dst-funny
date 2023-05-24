
local helper = {}



local ITEM_NAMES = KSFUN_TUNING.ITEM_POWER_NAMES

local waterproofer = require("powers/ksfun_item_waterproofer")
local dapperness   = require("powers/ksfun_item_dapperness")
local insulator    = require("powers/ksfun_item_insulator")
local damage       = require("powers/ksfun_item_damage")


local itempowers = {}
itempowers[ITEM_NAMES.WATER_PROOFER] = waterproofer
itempowers[ITEM_NAMES.DAPPERNESS]    = dapperness
itempowers[ITEM_NAMES.INSULATOR]     = insulator
itempowers[ITEM_NAMES.DAMAGE]        = damage

helper.MakeItemPower = function(name)
    local power = itempowers[name]
    return power and power.data or {}
end




-------------------------------------------------------------我是分割线-----------------------------------------------------------------


local PLAYER_NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local hunger = require("powers/ksfun_hunger")
local sanity = require("powers/ksfun_sanity")
local health = require("powers/ksfun_player_health")


local playerpowers = {}
playerpowers[PLAYER_NAMES.HUNGER] = hunger
playerpowers[PLAYER_NAMES.HEALTH] = health
playerpowers[PLAYER_NAMES.SANITY] = sanity


helper.MakePlayerPower = function(name)
    local power = playerpowers[name]
    return power and power.data or {}
end


return helper