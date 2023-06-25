
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES
local KSFUN_ITEM_TYPES = REWARD_TYPES.KSFUN_ITEM_TYPES


--- 属性奖励
--- @param player 玩家
--- @param 奖励的具体data
local function rewardPower(player, data)
    local powername = data and data.power or nil

    -- 属性奖励有提示
    local power = KsFunGetPowerNameStr(powername)
    KsFunShowNotice(player.name..STRINGS.KSFUN_GAIN..power..STRINGS.KSFUN_REWARD)

    KsFunLog("rewardPower", powername)
    if powername then
        player.components.ksfun_power_system:AddPower(powername)
    end
end


--- 属性等级奖励
--- @param player 玩家
--- @param 奖励的具体data
local function rewardPowerLv(player, data)
    local powername = data and data.power or nil
    KsFunLog("rewardPowerLv", powername)
    if powername then
        local power = player.components.ksfun_power_system:GetPower(powername)
        if power then
            power.components.ksfun_level:Up(data.num)
            -- xx(属性)获得xx经验奖励
            local str = STRINGS.KSFUN_TASK_WIN..","..KsFunGetPowerNameStr(powername)..STRINGS.KSFUN_REWARD_LV
            if player.components.talker then
                player.components.talker:Say(str)
            end
        end
    end
end


--- 属性经验奖励
--- @param player 玩家
--- @param 奖励的具体data
local function rewardPowerExp(player, data)
    local powername = data and data.power or nil
    KsFunLog("rewardPowerExp", powername)
    KsFunPowerGainExp(player, powername, data.num)
    -- xx(属性)获得xx经验奖励
    local str = STRINGS.KSFUN_TASK_WIN..","..KsFunGetPowerNameStr(powername)..STRINGS.KSFUN_REWARD_EXP
    if player.components.talker then
        player.components.talker:Say(str)
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
                if player.components.talker then
                    player.components.talker:Say(STRINGS.KSFUN_TASK_WIN..","..STRINGS.KSFUN_GAIN..STRINGS.KSFUN_REWARD)
                end
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
                if ent.components.ksfun_item_forever then
                    ent.components.ksfun_item_forever:Enable()
                    ent.components.ksfun_breakable:Enable()
                    ent.components.ksfun_enhantable:Enable()
                end

                local notice = player.name..STRINGS.KSFUN_REWARD_ITEM
                KsFunShowNotice(notice)
            
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