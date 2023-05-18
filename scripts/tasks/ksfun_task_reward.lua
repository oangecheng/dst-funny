

local function onWinFunc(inst, player, name)
    player.components.talker:Say("任务成功")
    local task_data = inst.components.ksfun_task:GetTaskData()
    if task_data.reward then
        if task_data.reward.type == REWARD_TYPES.ITEM.NORMAL then
            for i=1, task_data.reward.data.num do
                local item = SpawnPrefab(task_data.reward.data.item)
                player.components.inventory:GiveItem(item, nil, player:GetPosition())
            end
        end
    end
end


local REWARD = {}


REWARD.onWinFunc = onWinFunc



return REWARD