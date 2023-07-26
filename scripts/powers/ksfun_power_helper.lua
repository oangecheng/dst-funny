
local helper = {}


-------------------------------------------------------------物品属性 我是分割线-----------------------------------------------------------------
local itempowers = require("powers/ksfun_item_powers")
helper.MakeItemPower = function(name)
    return itempowers[name] or {}
end



-------------------------------------------------------------人物属性 我是分割线-----------------------------------------------------------------
local playerpowers  = require("powers/ksfun_player_powers")
helper.MakePlayerPower = function(name)
    return playerpowers[name] or {}
end



-------------------------------------------------------------怪物属性 我是分割线-----------------------------------------------------------------
local monsterpowersdef = require("powers/ksfun_mon_powers")
helper.MakeMonsterPower = function(name)
    local power = monsterpowersdef[name]
    return power or {}
end



-------------------------------------------------------------负面属性 我是分割线-----------------------------------------------------------------
local negapowers = require("powers/ksfun_nega_powers")
helper.MakeNegaPower = function(name)
    return negapowers[name] or {}
end



return helper