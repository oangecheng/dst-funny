
local NAMES = KSFUN_TUNING.TASK_NAMES

local rewards = require("tasks/utils/ksfun_rewards")
local demands = require("tasks/utils/ksfun_demands")


--- 初始化任务数据
--- 这个步骤只生成了任务的要求
--- @param name 任务名称，唯一性
--- @return 任务数据
local function initTaskData()
    local data = {}
    data.name = KSFUN_TUNING.DEBUG and NAMES.KILL or KsFunRandomValueFromKVTable(NAMES)
    data.tasklv = math.random(KSFUN_TUNING.TASK_LV_DEFS.MAX)
    local demand = demands.generateDemand(data.name, data.tasklv)
    data.demand = demand
    return data
end


--- 填充任务数据
--- 这里会补齐任务的奖励以及惩罚
--- @param player 奖励或者惩罚都需要角色
--- @param data   已经包含任务要求的数据
--- @return 任务数据
local function fillTaskData(player, data)
    local reward =  rewards.generateReward(player, data.tasklv)
    data.reward = reward
    return data
end


--- 给角色绑定任务
local function addTask(player, data)
    if data and data.name and player.components.ksfun_task_system then
        player.components.ksfun_task_system:AddTask(data.name, data)
    end
end



local kill    = require("tasks/ksfun_task_kill")
local reward  = require("tasks/ksfun_task_reward")
local punish  = require("tasks/ksfun_task_punish")
local handlers = {
    [NAMES.KILL] = kill,
}
--- 创建task相关数据
--- @param name 任务类型
local function generateTaskHanlder(name)
    local handler = handlers[name]
    return {
        onAttachFunc = handler.onAttachFunc,
        onDetachFunc = handler.onDetachFunc,
        descFunc     = handler.descFunc,

        onWinFunc    = reward.onWinFunc,
        onLoseFunc   = punish.onLoseFunc,
    }
end


local chain = {}
chain.addTask = addTask
chain.initTaskData = initTaskData
chain.fillTaskData = fillTaskData
chain.generateTaskHanlder = generateTaskHanlder

return chain