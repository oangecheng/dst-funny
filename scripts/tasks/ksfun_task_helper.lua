local NAMES = KSFUN_TUNING.TASK_NAMES
local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL


local KILL   = require("tasks/ksfun_task_kill")
local REWARD = require("tasks/ksfun_task_reward")
local PUNISH = require("tasks/ksfun_task_punish")


--- 创建task相关数据
--- @param name 任务类型
local function creaetTask(name)
    if name == NAMES.KILL then
        return {
            onAttachFunc = KILL.onAttachFunc,
            onDetachFunc = KILL.onDetachFunc,
            descFunc     = KILL.descFunc,
            onWinFunc    = REWARD.onWinFunc,
            onLoseFunc   = PUNISH.onLoseFunc, 
        }
    end
end



----------------------------------------------我是分割线------------------------------------------------


local REWARDS_UTIL = require("tasks/utils/ksfun_rewards")
local DEMANDS_UTIL = require("tasks/utils/ksfun_demands")


-- 普通任务
local function killDemand(task_lv)
    local kill_type = KsFunRandomValueFromKVTable(KILL_TYPES)
    return DEMANDS_UTIL.generateDemand(NAMES.KILL, task_lv, kill_type)
end


local function createTaskData(player, name)
    local task_lv = math.random(KSFUN_TUNING.TASK_LV_DEFS.MAX)

    local demand = killDemand( task_lv)
    local reward = REWARDS_UTIL.generateReward(player, task_lv)
    local punish = nil

    return {
        name   = name,
        demand = demand,
        reward = reward,
        punish = nil
    }
end


local function createDemand()
    local task_lv = math.random(KSFUN_TUNING.TASK_LV_DEFS.MAX)
    local demand = killDemand(task_lv)
    return demand
end



-----------------------------------------------我是分割线-----------------------------------------------------
local function addTask(player, name)
    local system = player and player.components.ksfun_task_system or nil
    if system then
        if system:GetTask(name) == nil then
            local data = createTaskData(player, name)
            system:AddTask(name, data)
        end
    end
end






local HELPER = {}

HELPER.createTaskData = createTaskData
HELPER.createTask = creaetTask
HELPER.addTask = addTask
HELPER.createDemand = createDemand


return HELPER