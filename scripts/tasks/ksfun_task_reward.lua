
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES
local KSFUN_ITEM_TYPES = REWARD_TYPES.KSFUN_ITEM_TYPES


--- 属性奖励
--- @param player 玩家
--- @param 奖励的具体data
local function rewardPower(player, data)
    local power_name = data and data.power or nil
    KsFunLog("rewardPower", power_name)
    if power_name then
        player.components.ksfun_power_system:AddPower(power_name)
    end
end


--- 属性等级奖励
--- @param player 玩家
--- @param 奖励的具体data
local function rewardPowerLv(player, data)
    local power_name = data and data.power or nil
    KsFunLog("rewardPowerLv", power_name)
    if power_name then
        local power = player.components.ksfun_power_system:GetPower(power_name)
        if power then
            power.components.ksfun_level:Up(data.num)
        end
    end
end


--- 属性经验奖励
--- @param player 玩家
--- @param 奖励的具体data
local function rewardPowerExp(player, data)
    local power_name = data and data.power or nil
    KsFunLog("rewardPowerExp", power_name)
    if power_name then
        local power = player.components.ksfun_power_system:GetPower(power_name)
        if power then
            power.components.ksfun_level:GainExp(data.num)
        end
    end
end


--- 普通物品奖励
local function rewardNomralItem(player, data)
    local item = data and data.item or nil
    KsFunLog("rewardNomralItem", item, data.num)
    if item then
        for i=1, data.num do
            local ent = SpawnPrefab(item)
            if ent then
                player.components.inventory:GiveItem(ent, nil, player:GetPosition())
            end
        end
    end
end


--- 特殊物品奖励
--- 给物品赋予等级
local function rewardKsFunItem(player, data)
    local item = data and data.item or nil
    KsFunLog("rewardKsFunItem", item, data.num, data.lv)
    if item then
        for i=1, data.num do
            local ent = SpawnPrefab(item)
            if ent then
                ent.components.ksfun_breakable:Enable()
                ent.components.ksfun_enhantable:Enable()
                player.components.inventory:GiveItem(ent, nil, player:GetPosition())
            end
        end
    end
end


local function onWinFunc(inst, player, name, task)
    KsFunLog("onTaskWin", name)
    local reward = task and task.reward or nil
    --- 根据奖励的不同进行分发
    if reward then
        KsFunLog("onTaskWin reward", reward.type)
        if     reward.type == REWARD_TYPES.ITEM             then rewardNomralItem(player, reward.data)
        elseif reward.type == REWARD_TYPES.KSFUN_ITEM       then rewardKsFunItem(player, reward.data)
        elseif reward.type == REWARD_TYPES.PLAYER_POWER     then rewardPower(player, reward.data)
        elseif reward.type == REWARD_TYPES.PLAYER_POWER_LV  then rewardPowerLv(player, reward.data)
        elseif reward.type == REWARD_TYPES.PLAYER_POWER_EXP then rewardPowerExp(player, reward.data)
        end
    end
end


local REWARD = {}


REWARD.onWinFunc = onWinFunc



return REWARD