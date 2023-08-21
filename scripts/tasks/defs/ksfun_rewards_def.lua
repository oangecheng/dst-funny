
local POWERS = KSFUN_TUNING.PLAYER_POWER_NAMES


--- 计算是否命中特殊奖励
--- 和幸运值&难度绑定
--- @param player table 玩家实体
--- @param tasklv number 任务等级
--- @return boolean true 给予
local function canRewardSpecial(player, tasklv)

    local seed = 0
    if tasklv == 1 then
        seed = 0.01
    elseif tasklv == 2 then
        seed = 0.03
    elseif tasklv == 3 then
        seed = 0.06
    elseif tasklv == 4 then
        seed = 0.1
    elseif tasklv == 5 then
        seed = 0.15
    elseif tasklv == 6  then 
        seed = 0.25
    elseif tasklv == 7  then
        seed = 0.4
    elseif tasklv == 8  then
        seed = 0.6
    elseif tasklv == 9 then 
        seed = 0.8
    else
        seed = 1
    end

    --- 幸运值附加倍率，最高2倍
    --- 难度值附加倍率，最简单难度2倍
    local hit = math.random() <= seed * KsFunMultiPositive(player)
    if KSFUN_TUNING.DEBUG then
        hit = true
    end

    --- 概率命中优先触发
    if hit  then
        return true
    end

    --- 兜底策略
    if player.components.achievements then
        if player.components.achievements:Consume() then
            return true
        end
    end
    return false
end


--- 计算是否命中特殊奖励
--- 和幸运值&难度绑定
--- @param player table 玩家实体
--- @param tasklv number 任务等级
--- @return number 返回计算后的物品等级
local function calcRewardNormalLv(player, tasklv)
    local m = KsFunMultiPositive(player)
    -- 附加等级，最大不超过2
    local addlv = m > 1 and math.min(math.floor(m + 0.5), 2) or 0
    return tasklv + addlv
end







--------------------------------------------- 普通物品相关奖励 ---------------------------------------------------------------------
local prefabsdef = require("defs/ksfun_prefabs_def")

--- 普通物品的最大等级
local maxitemlv = 7


--- 智商等级>50有10%的概率获得蓝图奖励
local function checkSanityReward(player, rewardsdata)
    local sanity = player.components.ksfun_power_system:GetPower(POWERS.SANITY)
    if sanity ~= nil then
        local lvlimt = KSFUN_TUNING.DEBUG and 1 or 50
        local ratio  = KSFUN_TUNING.DEBUG and 1 or 0.1
        if sanity.components.ksfun_level:GetLevel() >= lvlimt and math.random() <= ratio then
            local list = prefabsdef.getLostRecipes()
            for i,v in ipairs(list) do
                if player.components.builder and not player.components.builder:KnowsRecipe(v) then
                    table.insert(rewardsdata, { item = v.."_blueprint" , num = 1, special = true })
                    return
                end
            end
        end
    end
end


--- 随机生成一些物品
--- 任务等级越高，奖励越丰富，同时附加幸运值策略
--- @param tasklv number 任务难度等级
--- @return 名称，等级，数量，类型
local function randomNormalItem(player, tasklv)
    local itemlv = calcRewardNormalLv(player, tasklv)
    itemlv = math.min(maxitemlv, itemlv)
    local name, num = prefabsdef.getItemsByLv(itemlv)
    local extra = math.max(0, tasklv - itemlv)
    num = num + extra

    local data = {}
    table.insert(data, {item = name, num = num})

    --- 当任务等级 > 1 时，有概率获得基础资源的奖励
    if tasklv > 1 and math.random() <= 0.1 * tasklv then
        local item, cnt = prefabsdef.getItemsByLv(1)
        table.insert(data, { item = item, num = cnt })
    end

    checkSanityReward(player, data)

    return {
        type = KSFUN_REWARD_TYPES.ITEM,
        data = data
    }
end





--------------------------------------------- 特殊物品奖励 ---------------------------------------------------------------------
local ksfunitems = require("defs/ksfun_items_def")


--- 随机获取一个特殊物品奖励
local function randomKsFunGem(player, task_lv)
    local temp = {}
    local itemlist = ksfunitems.gems
    temp = itemlist
    
    if next(temp) ~= nil then
        local name = GetRandomItem(temp)
        return {
            -- 主类别
            type = KSFUN_REWARD_TYPES.GEM,
            data = {
                item = name,
                num = 1,
            }   
        }
    end
    return nil
end



local randomRewardItem = function(player, tasklv)
    local reward = nil
    if canRewardSpecial(player, tasklv) then
        -- 50%概率获得药剂奖励，50%概率宝石奖励
        if math.random() <= 0.5 then
            local item = "ksfun_potion"
            reward = {
                type = KSFUN_REWARD_TYPES.POTION,
                data = {
                    item = item,
                    num = 1
                }
            }
        end

        if reward == nil then
            reward = randomKsFunGem(player, tasklv)
        end
    end

    if reward == nil then
        reward = randomNormalItem(player, tasklv)
    end

    return reward
end



local rewardsfunc = {
    random = randomRewardItem
}

return rewardsfunc