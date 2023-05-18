
local ITEMS_LV1 = {
    "goldnugget", -- 金块
    "charcoal", -- 木炭
    "flint", -- 燧石
    "cutgrass",  -- 草
    "marble", -- 大理石
    "nitre", -- 硝石
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
NORMAL_ITMES[1] = ITEMS_LV1
NORMAL_ITMES[2] = ITEMS_LV2
NORMAL_ITMES[3] = ITEMS_LV3
NORMAL_ITMES[4] = ITEMS_LV4
NORMAL_ITMES[5] = ITEMS_LV5
NORMAL_ITMES[6] = ITEMS_LV6

--- 普通物品的最大等级
local NORMAL_ITME_MAX_LV = #NORMAL_ITMES


local KSFUN_ITMES = {
    WEAPON = {
        "spear", -- 长矛
        "spear_wathgrithr", -- 战斗长矛
        "ruins_bat", -- 铥矿棒，可升级的铥矿棒
        "nightsword", -- 暗影剑
        "hambat", -- 火腿棒
    },
    HAT = {
        "beefalohat",
        "eyebrellahat",
        "walrushat",
        "alterguardianhat",
    },
    ARMOR = {
        "armorwood",
        "armorruins",
    },
    -- 还没支持，熔炼系统
    MELT = {

    },
}


--- 随机生成物品数量
--- 例如任务等级为 6 物品等级为 6, 那么最多生成 2^(6-5) = 2个，  最少生成 6-5 = 1 个
--- 例如任务等级为 7 物品等级为 6, 那么最多生成 2^(6-6) = 1个，  最少生成 6-5 = 1 个， 等级附加1个，总共2个
local function randomItemNum(task_lv, item_lv)
    local max_lv = NORMAL_ITME_MAX_LV
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
local function randomNormalItem(player, task_lv)

    local r = task_lv or NORMAL_ITME_MAX_LV
    local item_lv = math.random(r) 
    item_lv = math.max(item_lv, NORMAL_ITME_MAX_LV)

    local items = NORMAL_ITMES[item_lv] 
    local index = math.random(#items)
    local name = items[index]
    local num = randomItemNum(task_lv, item_lv)
    local item_type = KSFUN_TUNING.TASK_REWARD_TYPES.ITEM.NORMAL
    return {
        type = item_type,
        data = {
            item = name,
            num = num,
            lv = item_lv,
        }
    }
end


--- 随机获取一个熔炼相关物品
local function randomKsFunItem(player, task_lv)
     local types = KSFUN_TUNING.TASK_REWARD_TYPES.KSFUN_ITMES
    local item_type = KsFunRandomValueFromKVTable(types)

    local list = nil
    local num = 1
    if item_type == types.WEAPON then
        list =  KSFUN_ITMES.WEAPON
    elseif item_type == types.HAT then
        list = KSFUN_ITMES.HAT
    elseif item_type == types.ARMOR then
        list = KSFUN_ITMES.ARMOR
    else
        list = KSFUN_ITMES.MELT
        -- 熔炼物品1-2个
        num = math.random(2)
    end
    
    -- 随机一个物品
    local name = KsFunRandomValueFromList(list)
    -- 随机一个品质，做任务最高奖励品质是蓝色
    -- 任务等级越高，获得蓝色品质的概率越大
    local max_quality = KSFUN_TUNING.ITEM_QUALITY.BLUE
    local quality = math.random(math.max(1, task_lv - 2))
    local quality = math.min(quality, max_quality)

    return {
        type = item_type,
        data = {
            name = name,
            num = num,
            quality = quality,
        }   
    }
end



local REWADS_ITEMS = {}

REWADS_ITEMS.randomNormalItem = randomNormalItem
REWADS_ITEMS.randomKsFunItem = randomKsFunItem


return REWADS_ITEMS