

--- 普通物品奖励
local function rewardNomralItem(player, data)
    local special= ""
    local saystr = ""
    if data and next(data) ~= nil then
        for i,v in ipairs(data) do
            local s = "["..KsFunGetPrefabName(v.item).."x"..v.num.."]"
            saystr = saystr..s

            if v.special then
                special = special..s
            end

            for i = 1, v.num do
                local ent = SpawnPrefab(v.item)
                if ent then
                    player.components.inventory:GiveItem(ent, nil, player:GetPosition())
                end
            end
        end
    end

    if saystr ~= "" then
        local tip = string.format(STRINGS.KSFUN_TASK_REWARD_ITEM_2, saystr)
        KsFunShowTip(player, tip)
    end

    if special ~= "" then
        local notice = string.format(STRINGS.KSFUN_TASK_REWARD_ITEM_3, player.name, special)
        KsFunShowNotice(notice)
    end

end



local function onWinFunc(inst, player, task)
    local reward = task and task.reward or nil
    --- 根据奖励的不同进行分发
    if reward then
        if reward.type == KSFUN_REWARD_TYPES.ITEM then 
            rewardNomralItem(player, reward.data)
        end
    end
end


local REWARD = {}


REWARD.onWinFunc = onWinFunc



return REWARD