local TASK_NAMES = KSFUN_TUNING.TASK_NAMES

local kills = require("tasks/defs/ksfun_demands_kill")

--- 要求定义
local demands = {}

demands[TASK_NAMES.KILL] = {
    generate = kills.generate,
    random = kills.random,
}


local DEMAND = {}


--- 生成任务需求，需要指定任务类型
--- @param name 任务名称
--- @param task_lv 任务等级
--- @param demand_type 需求的类型，比如击杀任务有自己的类型
DEMAND.generateDemand = function(name, task_lv, demand_type)
    local demand = demands[name]
    if demand ~= nil then    
        return demand.generate(task_lv, demand_type)
    end
end


--- 随机生成一个击杀需求，不指定需求类型，随机生成
--- @param task_lv 任务等级，需要指定
DEMAND.randomDemand = function(task_lv)
    local lv = task_lv 
    local name = KsFunRandomValueFromKVTable(TASK_NAMES)
    local demand = demands[name]
    if demand ~= nil then
        return demand.random(lv)
    end
end


return DEMAND