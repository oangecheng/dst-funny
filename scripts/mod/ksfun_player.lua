
local DEFAULT_MAX_HEALTH = 120
local EVENTS = KSFUN_TUNING.EVENTS

local HELPER = require("tasks/ksfun_task_helper")



-- 任务状态变更
local function onTaskStateChange(inst, task)
    if not (task and task.target and task.inst) then return end
    local task_system = task.target.components.ksfun_task_system
    if task_system then
        task_system:Detach(task.inst)
    end
end


--- 角色属性变化, 等级，经验值这些
--- 用来更新面板数据
local function onPlayerPowerChange(inst)
    print(KSFUN_TUNING.LOG_TAG.."ksfun_player onPlayerPowerChange")
    if inst.components.ksfun_power_system then
        inst.components.ksfun_power_system:SyncData()
    end
end


--- 获取角色的初始血量
--- @return 血量
local function getInitMaxHealth()
    return DEFAULT_MAX_HEALTH
end


AddPrefabPostInit("researchlab", function(inst)
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("forgstation")
end)


-- 初始化角色
AddPlayerPostInit(function(player)
    --- 修改角色基础血量
    local percent = player.components.health:GetPercent()
    player.components.health.maxhealth = getInitMaxHealth()
    player.components.health:SetPercent(percent)

    player:AddComponent("ksfun_power_system")
    player:AddComponent("ksfun_task_system")

    player:ListenForEvent(EVENTS.PLAYER_STATE_CHANGE, onPlayerPowerChange)
    player:ListenForEvent("oneat", function(inst)
        HELPER.addTask(inst, KSFUN_TUNING.TASK_NAMES.KILL)
    end)

    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)
    end)
end)