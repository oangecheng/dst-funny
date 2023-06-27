
local helper = {}


-------------------------------------------------------------物品属性 我是分割线-----------------------------------------------------------------
local ITEM_NAMES = KSFUN_TUNING.ITEM_POWER_NAMES

local itempowersdef= require("powers/ksfun_item_powers")

local itempowers = {}
itempowers[ITEM_NAMES.WATER_PROOFER] = itempowersdef.waterproofer
itempowers[ITEM_NAMES.DAPPERNESS]    = itempowersdef.dapperness
itempowers[ITEM_NAMES.INSULATOR]     = itempowersdef.insulator
itempowers[ITEM_NAMES.DAMAGE]        = itempowersdef.damage
itempowers[ITEM_NAMES.CHOP]          = itempowersdef.chop
itempowers[ITEM_NAMES.MINE]          = itempowersdef.mine
itempowers[ITEM_NAMES.LIFESTEAL]     = itempowersdef.lifesteal
itempowers[ITEM_NAMES.AOE]           = itempowersdef.aoe
itempowers[ITEM_NAMES.MAXUSES]       = itempowersdef.maxuses
itempowers[ITEM_NAMES.SPEED]         = itempowersdef.speed
itempowers[ITEM_NAMES.ABSORB]        = itempowersdef.absorb


helper.MakeItemPower = function(name)
    local power = itempowers[name]
    return power and power.data or {}
end





-------------------------------------------------------------人物属性 我是分割线-----------------------------------------------------------------
local PLAYER_NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local hunger = require("powers/ksfun_player_hunger")
local sanity = require("powers/ksfun_player_sanity")
local pick   = require("powers/ksfun_player_pick")
local farm   = require("powers/ksfun_player_farm")
local health = require("powers/ksfun_player_health")
--- 人物其他属性，比较复杂的属性单独用一个文件写
local pdefs  = require("powers/ksfun_player_powers")


local playerpowers = {}
playerpowers[PLAYER_NAMES.HUNGER]      = hunger
playerpowers[PLAYER_NAMES.SANITY]      = sanity
playerpowers[PLAYER_NAMES.HEALTH]      = health
playerpowers[PLAYER_NAMES.PICK]        = pick
playerpowers[PLAYER_NAMES.FARM]        = farm
playerpowers[PLAYER_NAMES.CRIT_DAMAGE] = pdefs.critdamage
playerpowers[PLAYER_NAMES.LOCOMOTOR]   = pdefs.locomotor
playerpowers[PLAYER_NAMES.DAMAGE]      = pdefs.damage



helper.MakePlayerPower = function(name)
    local power = playerpowers[name]
    return power and power.data or {}
end









-------------------------------------------------------------怪物属性 我是分割线-----------------------------------------------------------------
local MONSTER_NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES
local monsterpowersdef = require("powers/ksfun_mon_powers")
local monsterpowers = {}
monsterpowers[MONSTER_NAMES.ICE_EXPLOSION] = monsterpowersdef.iceexplosion
monsterpowers[MONSTER_NAMES.SANITY_AURA]   = monsterpowersdef.sanityaura
monsterpowers[MONSTER_NAMES.REAL_DAMAGE]   = monsterpowersdef.realdamage
monsterpowers[MONSTER_NAMES.ABSORB]        = monsterpowersdef.absorb
monsterpowers[MONSTER_NAMES.CRIT_DAMAGE]   = monsterpowersdef.critdamage
monsterpowers[MONSTER_NAMES.DAMAGE]        = monsterpowersdef.damage
monsterpowers[MONSTER_NAMES.HEALTH]        = monsterpowersdef.health
monsterpowers[MONSTER_NAMES.LOCOMOTOR]     = monsterpowersdef.locomotor


helper.MakeMonsterPower = function(name)
    local power = monsterpowers[name]
    return power and power.data or {}
end







return helper