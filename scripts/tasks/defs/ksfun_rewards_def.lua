
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
local item_max_lv = 6


--- 随机生成物品数量
--- 如果任务等级比奖励等级高，奖励数量会变多
local function randomItemNum(lv, itemlv)
    local delta = math.max(1, lv - itemlv)
    return math.random(2^delta)
end


--- 随机生成一些物品
--- @param tasklv 任务难度等级
--- @return 名称，等级，数量，类型
ksfun_rewards.randomNormalItem = function(player, tasklv)

    local lv = math.min(tasklv, item_max_lv)
    local item_lv = lv

    local list = items[item_lv] 
    local name = GetRandomItem(list)
    local num  = randomItemNum(tasklv, item_lv)
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
    local temp = math.random(2)
    local lv = math.max(temp, 1) 

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
    local name = KsFunGetCanRewardPower(player)
    if name then
        return {
            type = REWARD_TYPES.PLAYER_POWER,
            data = {
                power = name
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