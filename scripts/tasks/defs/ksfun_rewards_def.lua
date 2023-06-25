
local KSFUN_ITEM_TYPES = KSFUN_TUNING.KSFUN_ITEM_TYPES
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES

local ksfun_rewards = {}




--------------------------------------------- 普通物品相关奖励 ---------------------------------------------------------------------
local item1 = {
    "goldnugget", -- 金块
    "charcoal", -- 木炭
    "flint", -- 燧石
    "cutgrass",  -- 草
    "marble", -- 大理石
    "nitre", -- 硝石
}


local item2 = {
    "livinglog", -- 活木
    "nightmarefuel", -- 噩梦燃料
    "waxpaper", -- 蜡纸
    "pigskin",  -- 猪皮
    "redgem", -- 红宝石
    "bluegem", -- 绿宝石

}


local item3 = {
    "trunk_summer", -- 夏日象鼻
    "trunk_winter", -- 冬日象鼻
    "steelwool", -- 钢丝绒
    "walrus_tusk", -- 海象牙
    "purplegem", -- 紫宝石
    "moonrocknugget", -- 月石
}


local item4 = {
    "greengem",  -- 绿宝石
    "orangegem", -- 橙宝石
    "yellowgem", -- 黄宝石
    "townportaltalisman", -- 砂石
    "gears", -- 齿轮
    "fossil_piece", -- 化石碎片
}


local item5 = {
    "minotaurhorn",
    "shroom_skin",
    "deerclops_eyeball",
    "dragon_scales",
    "shadowheart",
    "ruins_bat", -- 铥矿棒
    "greenstaff", -- 绿法杖
    "orangestaff", -- 橙法杖
    "yellowstaff", -- 星杖
}


-- 等级6的物品中，包含可升级的物品
local item6 = {
  "opalpreciousgem", -- 彩虹宝石
  "opalstaff", -- 月杖
}


local items = {}
items[1] = item1
items[2] = item2
items[3] = item3
items[4] = item4
items[5] = item5
items[6] = item6

--- 普通物品的最大等级
local item_max_lv = #items


--- 随机生成物品数量
--- 例如任务等级为 6 物品等级为 6, 那么最多生成 2^(6-5) = 2个，  最少生成 6-5 = 1 个
--- 例如任务等级为 7 物品等级为 6, 那么最多生成 2^(6-6) = 1个，  最少生成 6-5 = 1 个， 等级附加1个，总共2个
local function randomItemNum(task_lv, item_lv)
    local max_lv = item_max_lv
    local num = 2
    local m =  math.max(max_lv - item_lv, 0)
    local max = num^m
    local min = math.min(max_lv - item_lv, max)
    min = math.max(min, 1)
    -- 任务等级附加
    local extra = math.max(task_lv - item_lv, 0)
    return math.random(min, max) + extra
end


--- 随机生成一些物品
--- @param task_lv 任务难度等级
--- @return 名称，等级，数量，类型
ksfun_rewards.randomNormalItem = function(player, task_lv)

    local r = task_lv or item_max_lv
    local item_lv = math.random(r) 
    item_lv = math.max(item_lv, item_max_lv)

    local items = items[item_lv] 
    local index = math.random(#items)
    local name = items[index]
    local num = randomItemNum(task_lv, item_lv)
    return {
        type = REWARD_TYPES.ITEM,
        data = {
            item = name,
            num = num,
        }
    }
end





--------------------------------------------- 特殊物品奖励 ---------------------------------------------------------------------
local ksfun_items = require("defs/ksfun_items_def")

--- 随机获取一个特殊物品奖励
ksfun_rewards.randomKsFunItem = function(player, task_lv)
    local itemtype = GetRandomItem(KSFUN_ITEM_TYPES)

    local list = nil
    local num = 1
    if itemtype == KSFUN_ITEM_TYPES.WEAPON then
        list =  ksfun_items.weapon
    elseif itemtype == KSFUN_ITEM_TYPES.HAT then
        list = ksfun_items.hat
    elseif itemtype == KSFUN_ITEM_TYPES.ARMOR then
        list = ksfun_items.armor
    elseif itemtype == KSFUN_ITEM_TYPES.GEM then
        list = ksfun_items.gems
    end
    
    -- 随机一个物品
    local name = list[math.random(#list)]
    -- 随机一个等级
    local lv = 1
    local temp = math.random(math.max(1, task_lv - 2))
    lv = math.min(temp, 3) 

    return {
        -- 主类别
        type = REWARD_TYPES.KSFUN_ITEM,
        data = {
            item = name,
            num = num,
            -- 次类别
            type = itemtype,
            lv = lv,
        }   
    }
end



--------------------------------------------- 属性相关奖励 ---------------------------------------------------------------------
local POWERS = KSFUN_TUNING.PLAYER_POWER_NAMES


--- 随机给予一个数据奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a}
ksfun_rewards.randomNewPower = function(player, task_lv)
    local power = KsFunRandomPower(player, POWERS, false)
    if power then
        return {
            type = REWARD_TYPES.PLAYER_POWER,
            data = {
                power = power
            }
        }
    end
    return nil
end


--- 随机查找一个存在的属性给予等级奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a, num = b}
ksfun_rewards.randomPowerLv = function(player, task_lv)
    local power = KsFunRandomPower(player, POWERS, true)
    local lv = math.random(3)
    if power then
        return {
            type = REWARD_TYPES.PLAYER_POWER_LV,
            data = {
                power = power,
                num = lv,
            }
        }
    end
    return nil
end


--- 随机一个属性给予一定的经验值奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a, num = b}
ksfun_rewards.randomPowerExp = function(player, task_lv)
    local power = KsFunRandomPower(player, POWERS, true)
    local exp = math.random(task_lv) * 10
    if power then
        return {
            type = REWARD_TYPES.PLAYER_POWER_EXP,
            data = {
                power = power,
                num = exp,
            }
        }
    end
    return nil
end


return ksfun_rewards