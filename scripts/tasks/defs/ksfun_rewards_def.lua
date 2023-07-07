
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
local function randomNormalItem(player, tasklv)
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
local function randomKsFunItem(player, task_lv)
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
local function randomNewPower(player, task_lv)
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
local function randomPowerLv(player, task_lv)
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
local function randomPowerExp(player, task_lv)
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



--- 任务奖励和难度绑定
local function calcRewardRatio(player, tasklv)
    local v = 0
    if KSFUN_TUNING.DIFFCULTY > 0 then
        v = tasklv * 0.5
    elseif KSFUN_TUNING.DIFFCULTY < 0 then
        v = tasklv * 2
    else
        v =  tasklv
    end

    -- 附加幸运值，幸运值倍率有可能小于0
    local lucky = player.components.ksfun_lucky
    if lucky then
        v = v * (1 + lucky:GetRatio())
    end

    return v
end



--- 任务等级越高，越容易获得特殊奖励
--- 任务等级最高基准为10，也就是高级任务有25%概率获得特殊奖励
local function randomReward(player, tasklv)
    local r = calcRewardRatio(player, tasklv)
    local v = KSFUN_TUNING.DEBUG and 1 or r/40

    local reward = nil
    if math.random() < v then
        local rewardpower = math.random() < 0.5
        --- 50%概率分配属性相关奖励
        if rewardpower then
            -- 优先分配属性奖励，再分配属性等级或者经验
            reward = randomNewPower(player, tasklv)
            -- 没命中，再去分配经验或者等级
            if not reward then
                local rewardlv = math.random() < 0.5
                if rewardlv then
                    reward = randomPowerLv(player, tasklv)
                else
                    reward = randomPowerExp(player, tasklv)
                end
            end
        end

        -- 还是没有命中，尝试分配特殊装备
        if not reward then
            reward = randomKsFunItem(player, tasklv)
        end

        if reward then
            return reward
        end
    end

    --- 兜底奖励，各种普通物品
    return randomNormalItem(player, tasklv)
end


local rewardsfunc = {
    random = randomReward
}

return rewardsfunc