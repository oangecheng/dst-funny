
local function onLoseFunc(inst, player, taskdata)
    player.components.talker:Say("任务失败")
end



local PUNISH = {}

PUNISH.onLoseFunc = onLoseFunc


return PUNISH