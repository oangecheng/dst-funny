
local DEFAULT_MAX_HEALTH = 120
local EVENTS = KSFUN_TUNING.EVENTS



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
    if inst.components.ksfun_powers then
        inst.components.ksfun_powers:SyncData()
    end
end


--- 获取角色的初始血量
--- @return 血量
local function getInitMaxHealth()
    return DEFAULT_MAX_HEALTH
end


-- 初始化角色
AddPlayerPostInit(function(player)
    --- 修改角色基础血量
    local percent = player.components.health:GetPercent()
    player.components.health.maxhealth = getInitMaxHealth()
    player.components.health:SetPercent(percent)

    player:AddComponent("ksfun_task_system")
    player:AddComponent("ksfun_powers")

    player:ListenForEvent("ksfun_task_finish", onTaskStateChange)
    player:ListenForEvent(EVENTS.PLAYER_STATE_CHANGE, onPlayerPowerChange)

    --- 添加饱食度属性，testcode
    if KSFUN_TUNING.DEBUG then
        local name = KSFUN_TUNING.PLAYER_POWER_NAMES.HUNGER
        local prefab = "ksfun_power_"..name
        inst.components.ksfun_powers:AddPower(name, prefab)
    end
end)