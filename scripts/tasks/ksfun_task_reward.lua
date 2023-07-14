
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES
local KSFUN_ITEM_TYPES = REWARD_TYPES.KSFUN_ITEM_TYPES


--- 属性奖励
--- @param player 玩家
--- @param 奖励的具体data
local function rewardPower(player, data)
    local powername = data and data.power or nil
    -- 属性奖励有提示
    local power = KsFunGetPowerNameStr(powername)
    local msg = string.format(STRINGS.KSFUN_TASK_REWARD_POWER, player.name, power)
    KsFunShowNotice(msg)

    if powername then
        local system = player.components.ksfun_power_system
        if system:GetPower(powername) == nil then
            system:AddPower(powername)
        end 
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
            if player.components.talker then
                local power = KsFunGetPowerNameStr(powername)
                local msg = string.format(STRINGS.KSFUN_TASK_REWARD_POWER_LV, power, tostring(data.num))
                player.components.talker:Say(msg)
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
    if player.components.talker then
        local power = KsFunGetPowerNameStr(powername)
        local msg = string.format(STRINGS.KSFUN_TASK_REWARD_POWER_EXP, power, tostring(data.num))
        player.components.talker:Say(msg)
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

        if player.components.talker then
            local itemname = STRINGS.NAMES[string.upper(item)].."x"..data.num
            local msg = string.format(STRINGS.KSFUN_TASK_REWARD_ITEM_2, itemname)
            player.components.talker:Say(msg)
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

                    if ent.components.ksfun_level then
                        ent.components.ksfun_level:SetMax(data.lv)
                        ent.components.ksfun_level:SetLevel(data.lv)
                    end

                end
            
                player.components.inventory:GiveItem(ent, nil, player:GetPosition())
            end
        end

        local itemname = KsFunGetPrefabName(item)
        local notice = string.format(STRINGS.KSFUN_TASK_REWARD_ITEM, player.name, itemname, tostring(data.num))
        KsFunShowNotice(notice)
    end
end



local function onWinFunc(inst, player, task)
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