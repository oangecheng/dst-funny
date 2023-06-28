local EVENTS = KSFUN_TUNING.EVENTS
local ITEMS_DEF = require "defs/ksfun_items_def"



local function testFunc(inst)
    for k,v in pairs(KSFUN_TUNING.PLAYER_POWER_NAMES) do
        local ent = inst.components.ksfun_power_system:AddPower(v)
    end
    local ent = SpawnPrefab("spear")
    ent.components.ksfun_item_forever:Enable()
    ent.components.ksfun_breakable:Enable()
    ent.components.ksfun_enhantable:Enable()
    if ent.components.finiteuses then
        ent.components.finiteuses:SetPercent(0.01)
    end
    for i,v in ipairs(ITEMS_DEF.ksfunitems["spear"].names) do
        ent.components.ksfun_power_system:AddPower(v)
    end
    inst.components.inventory:GiveItem(ent, nil, inst:GetPosition())
end



--- 初始化角色的各项属性
local function initPlayerProperty(inst)
    -- 机器人血量上限可以变化，也就无法附加血量变更的属性
    if inst.prefab ~= "wx78" then
        local v = inst.components.health.maxhealth
        inst.components.health:SetMaxHealth(math.floor(v * 0.8))
    end
end



AddPlayerPostInit(function(player)

    KsFunLog("player init", player.prefab)

    player:AddComponent("ksfun_power_system")
    player:AddComponent("ksfun_task_system")

    initPlayerProperty(player)


    
    -- 每天开始给个任务卷轴
    player:WatchWorldState("cycles", function(inst)
        if player.components.ksfun_task_system:GetTaskNum() < 1 then
            local ent = SpawnPrefab("ksfun_task_reel")
            inst.components.inventory:GiveItem(ent, nil, inst:GetPosition())
        end
    end)

    -- 任务结束，从任务列表当中移除
    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)
    end)

    --- 测试代码
    if KSFUN_TUNING.DEBUG then
        player:ListenForEvent("oneat", testFunc)
    end

end)