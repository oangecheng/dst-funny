
local helper = {}

local critdamage = require("powers/ksfun_common_critdamage")
local health     = require("powers/ksfun_common_health")




local ITEM_NAMES = KSFUN_TUNING.ITEM_POWER_NAMES

local waterproofer = require("powers/ksfun_item_waterproofer")
local dapperness   = require("powers/ksfun_item_dapperness")
local insulator    = require("powers/ksfun_item_insulator")
local damage       = require("powers/ksfun_item_damage")
local chop         = require("powers/ksfun_item_chop")
local mine         = require("powers/ksfun_item_mine")
local lifesteal    = require("powers/ksfun_item_lifesteal")
local aoe          = require("powers/ksfun_item_aoe")


local itempowers = {}
itempowers[ITEM_NAMES.WATER_PROOFER] = waterproofer
itempowers[ITEM_NAMES.DAPPERNESS]    = dapperness
itempowers[ITEM_NAMES.INSULATOR]     = insulator
itempowers[ITEM_NAMES.DAMAGE]        = damage
itempowers[ITEM_NAMES.CHOP]          = chop
itempowers[ITEM_NAMES.MINE]          = mine
itempowers[ITEM_NAMES.LIFESTEAL]     = lifesteal
itempowers[ITEM_NAMES.AOE]           = aoe


helper.MakeItemPower = function(name)
    local power = itempowers[name]
    return power and power.data or {}
end




-------------------------------------------------------------人物属性 我是分割线-----------------------------------------------------------------


local PLAYER_NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local hunger = require("powers/ksfun_hunger")
local sanity = require("powers/ksfun_sanity")


local playerpowers = {}
playerpowers[PLAYER_NAMES.HUNGER] = hunger
playerpowers[PLAYER_NAMES.HEALTH] = health
playerpowers[PLAYER_NAMES.SANITY] = sanity


helper.MakePlayerPower = function(name)
    local power = playerpowers[name]
    return power and power.data or {}
end











-------------------------------------------------------------怪物属性 我是分割线-----------------------------------------------------------------
local MONSTER_NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES
local realdamage = require("powers/ksfun_monster_realdamage")

local monsterpowers = {}
monsterpowers[MONSTER_NAMES.REAL_DAMAGE] = realdamage
monsterpowers[MONSTER_NAMES.CRIT_DAMAGE] = critdamage
monsterpowers[MONSTER_NAMES.HEALTH]      = health


helper.MakeMonsterPower = function(name)
    local power = monsterpowers[name]
    return power and power.data or {}
end







return helper