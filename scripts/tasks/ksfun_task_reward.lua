
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES


local function onWinFunc(inst, player, name)
    local str = ""

    local task_data = inst.components.ksfun_task:GetTaskData()
    if task_data.reward then

        local t = task_data.reward.type

        if t == REWARD_TYPES.ITEM.NORMAL then
            for i=1, task_data.reward.data.num do
                local item = SpawnPrefab(task_data.reward.data.item)
                player.components.inventory:GiveItem(item, nil, player:GetPosition())
            end
        end

        if t == REWARD_TYPES.KSFUN_ITEM.WEAPON then
            str = "武器奖励"
        elseif t == REWARD_TYPES.KSFUN_ITEM.HAT then
            str = "帽子奖励"
        elseif t == REWARD_TYPES.KSFUN_ITEM.ARMOR then
            str = "盔甲奖励"
        elseif t == REWARD_TYPES.KSFUN_ITEM.MELT then
            str = "材料奖励"
        elseif t == REWARD_TYPES.PLAYER_POWER.NORMAL then
            str = "属性奖励"
        elseif t == REWARD_TYPES.PLAYER_POWER_UP.NORMAL then
            str = "属性等级奖励"
        elseif t == REWARD_TYPES.PLAYER_POWER_EXP.NORMAL then
            str = "属性经验奖励"
        end

        player.components.talker:Say("任务成功"..str)

    end
end


local REWARD = {}


REWARD.onWinFunc = onWinFunc



return REWARD