
local DEFAULT_MAX_HEALTH = 120
local EVENTS = KSFUN_TUNING.EVENTS

local HELPER = require("tasks/ksfun_task_helper")
local ksfunitemsmaker = require("mod/ksfun_items_maker")
local ksfunitems = require("defs/ksfun_items_def")


for k,v in pairs(ksfunitems.hantitems) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("ksfun_item")
        inst:AddComponent("ksfun_level")
        inst:AddComponent("ksfun_enhantable")
        inst:AddComponent("ksfun_breakable")
        inst:AddComponent("ksfun_power_system")
    end)
end




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

local function onOpen(inst)
    inst.SoundEmitter:PlaySound("saltydog/common/saltbox/open")


end
local function onClose(inst)
    inst.SoundEmitter:PlaySound("saltydog/common/saltbox/close")

    local item1 = inst.components.container:GetItemInSlot(1)
    local item2 = inst.components.container:GetItemInSlot(2)
    if item1 and item2 then
        if item2.prefab == "goldnugget" then
            item1.components.ksfun_breakable:Break(item2)
        elseif item2.prefab == "opalpreciousgem" then
            item1.components.ksfun_enhantable:Enhant(item2)
        elseif item2.prefab == "pigskin" then
            local power = item1.components.ksfun_power_system:GetPower("item_water_proofer")
            power.components.ksfun_forgable:Forg(item2)
        end
        
    end
end



AddPrefabPostInit("researchlab", function(inst)
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("researchlab")
    inst.components.container.onopenfn = onOpen
    inst.components.container.onclosefn = onClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
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
        local e = ksfunitemsmaker.MakeKsFunItem("walrushat")
        inst.components.inventory:GiveItem(e, nil, player:GetPosition())
        -- HELPER.addTask(inst, KSFUN_TUNING.TASK_NAMES.KILL)

    end)

    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)
    end)
end)