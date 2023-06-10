
local helper = {}


-------------------------------------------------------------怪物和人物公用的属性 我是分割线-----------------------------------------------------------------
local critdamage = require("powers/ksfun_com_critdamage")
local health     = require("powers/ksfun_com_health")
local locomotor  = require("powers/ksfun_com_locomotor")
local damage     = require("powers/ksfun_com_damage")

local COM_NAMES = KSFUN_TUNING.COMMON_POWER_NAMES
local compowers = {}
compowers[COM_NAMES.CRIT_DAMAGE] = critdamage
compowers[COM_NAMES.HEALTH]      = health
compowers[COM_NAMES.LOCOMOTOR]   = locomotor
compowers[COM_NAMES.DAMAGE]      = damage


helper.MakeComPower = function(name)
    local power = compowers[name]
    return power and power.data or {}
end





-------------------------------------------------------------物品属性 我是分割线-----------------------------------------------------------------
local ITEM_NAMES = KSFUN_TUNING.ITEM_POWER_NAMES

local waterproofer = require("powers/ksfun_item_waterproofer")
local dapperness   = require("powers/ksfun_item_dapperness")
local insulator    = require("powers/ksfun_item_insulator")
local itemdamage   = require("powers/ksfun_item_damage")
local chop         = require("powers/ksfun_item_chop")
local mine         = require("powers/ksfun_item_mine")
local lifesteal    = require("powers/ksfun_item_lifesteal")
local aoe          = require("powers/ksfun_item_aoe")
local maxuses      = require("powers/ksfun_item_maxuses")



local itempowers = {}
itempowers[ITEM_NAMES.WATER_PROOFER] = waterproofer
itempowers[ITEM_NAMES.DAPPERNESS]    = dapperness
itempowers[ITEM_NAMES.INSULATOR]     = insulator
itempowers[ITEM_NAMES.DAMAGE]        = itemdamage
itempowers[ITEM_NAMES.CHOP]          = chop
itempowers[ITEM_NAMES.MINE]          = mine
itempowers[ITEM_NAMES.LIFESTEAL]     = lifesteal
itempowers[ITEM_NAMES.AOE]           = aoe
itempowers[ITEM_NAMES.MAXUSES]       = maxuses


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


local playerpowers = {}
playerpowers[PLAYER_NAMES.HUNGER] = hunger
playerpowers[PLAYER_NAMES.SANITY] = sanity
playerpowers[PLAYER_NAMES.PICK]   = pick
playerpowers[PLAYER_NAMES.FARM]   = farm


helper.MakePlayerPower = function(name)
    local power = playerpowers[name]
    return power and power.data or {}
end









-------------------------------------------------------------怪物属性 我是分割线-----------------------------------------------------------------
local MONSTER_NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES
local realdamage   = require("powers/ksfun_mon_realdamage")
local iceexplosion = require("powers/ksfun_mon_iceexplosion")
local sanityaura   = require("powers/ksfun_mon_sanityaura")

local monsterpowers = {}
monsterpowers[MONSTER_NAMES.ICE_EXPLOSION] = iceexplosion
monsterpowers[MONSTER_NAMES.SANITY_AURA]   = sanityaura
monsterpowers[MONSTER_NAMES.LOCOMOTOR]     = locomotor


helper.MakeMonsterPower = function(name)
    local power = monsterpowers[name]
    return power and power.data or {}
end







return helper