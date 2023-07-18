local EVENTS = KSFUN_TUNING.EVENTS
local ITEMS_DEF  = require "defs/ksfun_items_def"
local playersdef = require "defs/ksfun_players_def" 


local function initLucky(inst, config)
    inst:AddComponent("ksfun_lucky")
    if config.lucky then
        inst.components.ksfun_lucky:SetLucky(config.lucky)
    end
end


--- 人物死亡，全属性等级随机降低
local function onPlayerDeath(inst)
    local system = inst.components.ksfun_power_system
    local powers = system:GetAllPowers()
    local downlv = KSFUN_TUNING.DEBUG and 100 or math.random(5)

    local msg = string.format(STRINGS.KSFUN_PLAYER_DEATH_NOTICE, inst.name, tostring(downlv))
    KsFunShowNotice(msg)

    for k,v in pairs(powers) do
        v.components.ksfun_level:DoDelta(-downlv)
    end
end



--- 初始化角色的各项属性
local function initPlayerProperty(inst)
    -- 机器人血量上限可以变化，也就无法附加血量变更的属性
    -- if inst.prefab ~= "wx78" then
    --     local v = inst.components.health.maxhealth
    --     inst.components.health:SetMaxHealth(math.floor(v * 0.8))
    -- end
end



local function initPowerSystem(player)
    player:AddComponent("ksfun_power_system")

    local function istemp(p)
        return p.components.ksfun_power:IsTemp()
    end
    
    local system = player.components.ksfun_power_system
    system:SetOnGainPowerFunc(function(inst, data)
        -- 临时属性不统计
        if istemp(data.power) then return end
        TheWorld.components.ksfun_world_data:AddWorldPowerCount(data.name)
    end)

    system:SetOnLostPowerFunc(function(inst, data)
        -- 临时属性不统计
        if istemp(data.power) then return end
        TheWorld.components.ksfun_world_data:RemoveWorldPowerCount(data.name)
        local msg = string.format(STRINGS.KSFUN_POWER_LOST_PLAYER, inst.name, KsFunGetPowerNameStr(data.name))
        KsFunShowNotice(msg)
    end)
    
    player:ListenForEvent("death", onPlayerDeath)
    player:ListenForEvent(KSFUN_EVENTS.POWER_REMOVE, function(inst, data)
        if data.name then
            system:RemovePower(data.name)
        end
    end)
    
end



local function initTaskSystem(player)
    player:AddComponent("ksfun_task_system")
    -- 任务结束，从任务列表当中移除
    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)

        -- 任务成功+1幸运值，失败-1
        local luckydelta = -1
        if data.iswin then
            luckydelta = 1
        end
        if player.components.ksfun_lucky then
            player.components.ksfun_lucky:DoDelta(luckydelta)
        end

    end)

    -- 每天开始给1-2个任务卷轴
    player:WatchWorldState("cycles", function(inst)
        inst:DoTaskInTime(2, function()
            local count = math.random(2)
            for i=1, count do
                local ent = KsFunSpawnTaskReel()
                if ent then
                    player.components.inventory:GiveItem(ent, nil, player:GetPosition())
                end
            end  
        end)
    end)
end



local function testFunc(inst, data)
    local system = inst.components.ksfun_power_system
    local food = data.food and data.food.prefab or nil

    if food == "bird_egg" then
        onPlayerDeath(inst)
        return
    end

    for k,v in pairs(KSFUN_TUNING.NEGA_POWER_NAMES) do
        local ent = inst.components.ksfun_power_system:AddPower(v)
    end

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


AddPlayerPostInit(function(player)
    --- 只支持原生角色
    local config = playersdef.playerconfig(player)
    if config ~= nil then
        initLucky(player, config)
        initPowerSystem(player)
        initPlayerProperty(player)
        initTaskSystem(player)
        --- 测试代码
        if KSFUN_TUNING.DEBUG then
            player:ListenForEvent("oneat", testFunc)
        end
    end
end)