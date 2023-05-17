
local LV_DEFS = KSFUN_TUNING.TASK_LV_DEFS


local ITEMS_LV1 = {
    "goldnugget", -- 金块
    "charcoal", -- 木炭
    "flint", -- 燧石
    "nitre", -- 硝石
    "marble" -- 大理石
}


local ITEMS_LV2 = {
    "livinglog", -- 活木
    "nightmarefuel", -- 噩梦燃料
    "waxpaper", -- 蜡纸
    "pigskin",  -- 猪皮
    "redgem", -- 红宝石
    "bluegem", -- 绿宝石
}


local ITEMS_LV3 = {
    "trunk_summer", -- 夏日象鼻
    "trunk_winter", -- 冬日象鼻
    "steelwool", -- 钢丝绒
    "walrus_tusk", -- 海象牙
    "purplegem", -- 紫宝石
    "moonrocknugget", -- 月石
}



local ITEMS_LV4 = {
    "greengem",  -- 绿宝石
    "orangegem", -- 橙宝石
    "yellowgem", -- 黄宝石
    "townportaltalisman", -- 砂石
    "gears", -- 齿轮
    "fossil_piece", -- 化石碎片
}


local ITEMS_LV5 = {
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
local ITEMS_LV6 = {
  "opalpreciousgem", -- 彩虹宝石
  "opalstaff", -- 月杖
}


local NORMAL_ITMES = {}
NORMAL_ITMES[LV_DEFS.LV1] = ITEMS_LV1
NORMAL_ITMES[LV_DEFS.LV2] = ITEMS_LV2
NORMAL_ITMES[LV_DEFS.LV3] = ITEMS_LV3
NORMAL_ITMES[LV_DEFS.LV4] = ITEMS_LV4
NORMAL_ITMES[LV_DEFS.LV5] = ITEMS_LV5
NORMAL_ITMES[LV_DEFS.LV6] = ITEMS_LV6


--- 随机生成物品数量
--- 例如物品等级为 5, 那么最多生成 2^(6-5) = 2个，  最少生成 6-5 = 1 个
--- 例如物品等级为 3, 那么最多生成 2^(6-3) = 8个，  最少生成 6-3 = 3 个
--- 例如物品等级为 1, 那么最多生成 2^(6-1) = 32个， 最少生成 6-1 = 5 个
local function randomItemNum(item_lv)
    local num = 2
    local m =  math.max(MAX_LV - item_lv, 0)
    local max = num^m
    local min = math.min(MAX_LV - item_lv, max)
    min = math.max(min, 1)
    return math.random(min, max)
end


--- 随机生成一些物品
--- @param task_lv 任务难度等级
--- @return 名称，等级，数量
local function randomNormalItem(task_lv)
    local lv = task_lv and task_lv or math.random(MAX_LV)
    lv = math.max(1, lv)
    lv = math.min(MAX_LV, lv)

    local items = NORMAL_ITMES[lv] 
    local index = math.random(#items)
    local name = items[index]
    local num = randomItemNum(lv)
    return name, lv, num
end



local REWADS_ITEMS = {}

REWADS_ITEMS.randomNormlItem = randomNormalItem


return REWADS_ITEMS