
local POWERS = KSFUN_TUNING.PLAYER_POWER_NAMES

local ksfun_rewards = {}




--------------------------------------------- 普通物品相关奖励 ---------------------------------------------------------------------
local prefabsdef = require("defs/ksfun_prefabs_def")

--- 普通物品的最大等级
local maxitemlv = 7


local function calcItemLv(player, tasklv, multi)
    if tasklv >= maxitemlv then
        return maxitemlv
    end
    -- 即使很低等级的任务，也有小概率获得最高等级奖励
    for i = maxitemlv, tasklv, -1 do
        local r = math.random(2 ^ i)
        if r <= (2 ^ tasklv) * (multi or 1) then
            return i
        end
    end
    return tasklv
end


--- 智商等级>50有10%的概率获得蓝图奖励
local function checkSanityReward(player, rewardsdata)
    local sanity = player.components.ksfun_power_system:GetPower(POWERS.SANITY)
    if sanity ~= nil then
        local lvlimt, ratio = KSFUN_TUNING.DEBUG and 1, 1 or 50, 0.1
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
--- @param  tasklv 任务难度等级
--- @return 名称，等级，数量，类型
local function randomNormalItem(player, tasklv)
    local r  = math.random()
    -- 计算奖励物品等级
    local multi = KsFunMultiPositive(player)
    local lv = calcItemLv(player, tasklv, multi)
    local name,num = prefabsdef.getItemsByLv(lv)
    local delta = math.max(0, tasklv - maxitemlv)
    --- 最大不超过3倍
    local maxnum = num * 3
    num = math.clamp(num * multi + delta, 1, maxnum)
    num = math.floor(num + 0.5)

    local data = {}
    table.insert(data, {item = name, num = num})
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
    local worlddata = TheWorld.components.ksfun_world_data

    local max = 0
    if KSFUN_TUNING.MODE == 1 then max = 2
    elseif KSFUN_TUNING.MODE == 2 then max = 1
    end

    if max~=0 and worlddata then
        for i,v in ipairs(itemlist) do
            if worlddata:GetWorldItemCount(v) < max then
                table.insert(temp, v)
            end
        end
    else
        temp = itemlist
    end
    
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


--- 计算是否命中特殊奖励
--- 和幸运值&难度绑定
local function canRewardSpecial(player, tasklv)
    local r = math.random(1024)
    local multi = KsFunMultiPositive(player)
    return r <= 2^tasklv * multi * 100
end


local function maxpotionnum()
    local s1 = GetTableSize(KSFUN_TUNING.PLAYER_POWER_NAMES)
    local s2 = 3
    local s = s1 + s2
    if KSFUN_TUNING.MODE == 1 then return s * 2
    elseif KSFUN_TUNING.MODE == 2 then return s
    else return -1 end
end


local randomRewardItem = function(player, tasklv)
    local reward = nil
    if canRewardSpecial(player, tasklv) then
        
        if math.random() <= 0.5 then
            local max = maxpotionnum()
            local item = "ksfun_potion"
            if max < 0 or TheWorld.components.ksfun_world_data:GetWorldItemCount(item) < max then
                reward = {
                    type = KSFUN_REWARD_TYPES.POTION,
                    data = {
                        item = item,
                        num = 1
                    }
                }
            end
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