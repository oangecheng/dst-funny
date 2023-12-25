local EVENTS = KSFUN_EVENTS
local playersdef = require "defs/ksfun_players_def" 


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


local function initPowerSystem(player)
    player:AddComponent("ksfun_power_system")

    local function istemp(p)
        return p.components.ksfun_power:IsTemp()
    end
    
    local system = player.components.ksfun_power_system

    system:SetOnLostPowerFunc(function(inst, data)
        -- 临时属性不统计
        if istemp(data.power) then return end
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
    player.components.ksfun_task_system:SetOnListener(function (_, tasks)
        
    end)

    -- 任务结束，从任务列表当中移除
    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)
    end)

    player:WatchWorldState("cycles", function(inst)
       
    end)
end



AddPlayerPostInit(function(player)
    --- 只支持原生角色
    local config = playersdef.playerconfig(player)
    if config ~= nil then
        initPowerSystem(player)
        initTaskSystem(player)
    end
end)



---------------------------------------------------------------- 怪物增强 ----------------------------------------------------------------
local MONSTER_NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES

--- 计算附加属性概率
local function shouldAddPower(inst, defaultratio)
    return math.random() < defaultratio * KsFunMultiNegative(inst)
end


local function reinforceMonster(inst, limit, blacklist, whitelist)
    local worldmonster = TheWorld.components.ksfun_world_monster
    local lv = worldmonster and worldmonster:GetMonsterLevel(inst.prefab)
    inst.components.ksfun_level:SetLevel(lv)
    if lv and lv > 10 then
        --- 10级之后才会附加属性
        --- 100级之后，怪物100%附加属性
        if not shouldAddPower(inst, lv/100) then return end

        --- 每增加50级，怪物有概率多获得一个属性，但不超过属性上限, 至少有1个属性
        local seed = math.min(math.floor(lv/50 + 0.5), limit) 
        local num  = math.random(math.max(1, seed))

        local powernames = {}

        -- 如果有白名单，用白名单数据
        local illegnames = whitelist and whitelist or MONSTER_NAMES
    
        for k,v in pairs(illegnames) do
            -- 有些怪物不能加部分属性，比如克劳斯会有血量上限的变化
            ---@diagnostic disable-next-line: undefined-field
            if blacklist == nil or (not table.contains(blacklist, v)) then
                table.insert(powernames, v)
            end
        end

        num = math.min(#powernames, num)
        -- 随机取几个属性
        local powers = PickSome(num, powernames)
        for i,v in ipairs(powers) do
            local ent = inst.components.ksfun_power_system:AddPower(v)
            if ent then
                local powerlv = KSFUN_TUNING.DEBUG and 100 or math.random(lv)
                ent.components.ksfun_level:SetLevel(powerlv)
                inst.components.ksfun_power_system:SyncData()
            end
        end

    end    
end


local function test(inst)
    inst.components.ksfun_level:SetLevel(100)
    if inst.prefab == "spider" then
        for _,v in pairs(MONSTER_NAMES) do
            local ent = inst.components.ksfun_power_system:AddPower(v)
            if ent then
                ent.components.ksfun_level:SetLevel(100)
            end
        end
    end
end


--- 怪物死亡时，会获得经验来提升自己的世界等级
local function onMonsterDeath(inst)
    if inst.components.health then
        local exp = inst.components.health.maxhealth * 0.2 * KsFunMultiNegative(inst)
        TheWorld.components.ksfun_world_monster:GainMonsterExp(inst.prefab, exp)
    end
end


local monsters = require("defs/ksfun_monsters_def").reinforceMonster()
for k,v in pairs(monsters) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("ksfun_power_system")
        inst:AddComponent("ksfun_level")
        if KSFUN_TUNING.DEBUG then
            test(inst)
        else
            reinforceMonster(inst, v.pnum, v.pblacks, v.pwhites)
        end
        inst:ListenForEvent("death", onMonsterDeath)
    end)
end




-- 世界初始化
AddPrefabPostInit("world", function(inst)
    inst:AddComponent("ksfun_world_monster")
    inst:AddComponent("ksfun_world_player")
end)











------------------ 物品强化 ---------------------------------
local itemsdef = require("defs/ksfun_items_def")

local function initEquipments(inst)
    inst.ksfun_activatable = true

    inst:AddComponent("ksfun_enchant")
    inst:AddComponent("ksfun_power_system")


    local level = inst:AddComponent("ksfun_level")
    level:SetOnStateChange(function ()
        inst.components.ksfun_power_system:SyncData()
    end)

    local god =  inst:AddComponent("ksfun_god")
    god:SetOnGodFn(function (_, lv)
        level:SetMax(lv)
    end)


    local repairable = inst:AddComponent("ksfun_repairable")
    repairable:SetEnableFn(function ()
        if inst.ksfun_activatable then
            inst.ksfun_activatable = false
            inst.components.ksfun_enchant:Enable()
            god:Enable()
        end
    end)


    local oldLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        inst.components.ksfun_power_system:SyncData()
        if oldLoad then
            oldLoad(inst, data)
        end
    end
end


local function getCanForgPower(doer, target, material)
    local system = target.components.ksfun_power_system
    if system then
        local powers = system:GetAllPowers()
        for k, v in pairs(powers) do
            local forgable = v.components.ksfun_forgable
            if forgable and forgable:CanForg(doer, material) then
                return v
            end
        end
    end
    return nil
end


local function startRefine(inst, doer)
    local target = inst.components.container:GetItemInSlot(1)
    local item   = inst.components.container:GetItemInSlot(2)

    if target and item then
        -- 进阶武器
        local god = target.components.ksfun_god
        if god and god:Upgrade() then
            item:Remove()
            return 10
        end

        -- 附魔武器
        local enchant = target.components.ksfun_enchant
        if enchant and enchant:Enchant(item, doer) then
            item:Remove()
            return 10
        end

        -- 强化某个属性
        local power = getCanForgPower(doer, target, item)
        if power then
            power.components.ksfun_forgable:Forg(doer, item)
            return 3
        end
    end
    return 0
end


local function onStationWorkFinish(inst, data)
    if data.name == "refine" then
        inst.components.container.canbeopened = true
    end
end


local function delayOpenFn(chest, doer)
    local time = KSFUN_TUNING.DEBUG and 1
        or startRefine(chest, doer)
    if time > 0 then
        chest.components.container:Close(doer)
        chest.components.timer:StartTimer("refine", time)
        chest.components.container.canbeopened = false
    end
end


local function initStation(inst)
    local cotainer = inst.components.container
        or inst:AddComponent("container")
    cotainer:WidgetSetup("dragonflyfurnace")
    cotainer.onopenfn = nil
    cotainer.onclosefn = nil
    cotainer.skipclosesnd = true
    cotainer.skipopensnd = true
    if inst.components.timer == nil then
        inst:AddComponent("timer")
    end
    inst:ListenForEvent("timerdone", onStationWorkFinish)
    inst.startWork = delayOpenFn
end


AddPrefabPostInit("dragonflyfurnace", initStation)
for k, _ in pairs(itemsdef.ksfunitems) do
    AddPrefabPostInit(k, initEquipments)
end
