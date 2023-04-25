
local REWARD = {}

local REWARD_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES
local LV_DEFS = KSFUN_TUNING.TASK_REWARD_LEVELS
local ITEM_QUALITY = KSFUN_TUNING.ITEM_QUALITY

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
local clothes = require("ksfun_clothes_defs")
for i = 1, #clothes do
    table.insert(ITEMS_LV6, clothes[i])
end
local weapon = require("ksfun_weapon_defs")
for i = 1, #clothes do
    table.insert(ITEMS_LV6, weapon[i])
end


--- 通过等级获取物品代码
--- @param lv 物品等级
--- @return 对应等级的物品
local function getRandomItemByLv(lv)
    local items = nil
    if lv == LV_DEFS.LV1 then items = ITEMS_LV1
    elseif lv == LV_DEFS.LV2 then items = ITEMS_LV2 
    elseif lv == LV_DEFS.LV3 then items = ITEMS_LV3 
    elseif lv == LV_DEFS.LV4 then items = ITEMS_LV4 
    elseif lv == LV_DEFS.LV5 then items = ITEMS_LV5 
    elseif lv == LV_DEFS.LV6 then items = ITEMS_LV6 
    else items = ITEMS_LV1 end
    local index = math.random(#items)
    return items[index]
end


--- 根据任务难度获取一个物品名称
--- @param demand_lv 任务难度
--- @return 物品代码 & 物品等级
local function getItemByDemandLv(demand_lv)
    local max_lv = LV_DEFS.LV_MAX
    local demand_multi = demand_lv / max_lv
    
    -- 奖励等级的计算规则，奖励的最大等级划分区间，假如为10，那每个等级的区间就是100/10 = 10
    -- 任务难度越高，奖励的比值也越大，计算公式（demand_multi = 任务难度等级/奖励等级）
    -- 如果任务难度等级是10, 那么概率区间值就是 10 * 1 = 10 也就是10%的概率 
    -- 如果任务难度等级是5, 那么概率区间值就是 10 * 0.5 = 5 也就是5%的概率 
    local seed = 100
    local multi = seed / (max_lv + 1)
    local ratios = {}
    -- 这里要倒序，命中高等级的物品，优先取
    for i = max_lv, 1, -1 do
        table.insert(ratios, multi *(max_lv - i + 1) * demand_multi)
    end

    local r = math.random(seed)
    local items_lv = LV_DEFS.LV1
    for i,v in ipairs(ratios) do
        if r < v then
            items_lv = i
            break
        end
    end
    
    local item = getRandomItemByLv(items_lv)
    return item, items_lv
end


--- 获取物品的数量
--- @param item_lv 物品等级
local function getItemNumByLv(item_lv)
    local num = 1
    -- 一级物品单独计算
    if item_lv == LV_DEFS.LV1 then num = math.max(5, math.random(20))
    else num = math.random(LV_DEFS.LV_MAX - item_lv + 1) end
    return num
end


--- 物品被生成之后执行
local function onRewardItemFunc(inst)
    if inst and inst.components.ksfun_item_quality then
        local quality = math.random(ITEM_QUALITY.MAX)
        inst.components.ksfun_item_quality:SetQuality(quality)
    end
end 


--- 创建一个物品类型的奖励
--- @param demand_lv 任务难度
function createItemReward(demand_lv)
    local item, item_lv = getItemByDemandLv(demand_lv)
    local count = getItemNumByLv(item_lv)
    return {
        type = REWARD_TYPES.ITEM,
        level = item_lv,
        data = {
            item = item,
            num = count
        },
        onRewardFun = onRewardItemFunc
    }
end


REWARD.createRewardByType = function(reward_type, demand_lv)
    if reward_type == REWARD_TYPES.ITEM then return createItemReward(demand_lv)
    else return nil end
end 


return REWARD