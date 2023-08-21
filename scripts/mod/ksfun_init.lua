local EVENTS = KSFUN_EVENTS
local playersdef = require "defs/ksfun_players_def" 


local function initAchievements(inst, config)
    inst:AddComponent("ksfun_achievements")
    if config.achievements then
        inst.components.ksfun_achievements:SetValue(config.achievements)
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
    -- 任务结束，从任务列表当中移除
    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)
        local delta = 0
        if data.iswin then
            delta = 2 ^ (data.lv or 0)
        end
        if player.components.ksfun_achievements then
            player.components.ksfun_achievements:DoDelta(delta)
        end
    end)

    player:WatchWorldState("cycles", function(inst)
       
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

    local ITEMS_DEF  = require "defs/ksfun_items_def"
    for _,v in ipairs(ITEMS_DEF.ksfunitems["spear"].names) do
        ent.components.ksfun_power_system:AddPower(v)
    end
    inst.components.inventory:GiveItem(ent, nil, inst:GetPosition())
    inst.components.ksfun_achievements:SetValue(10000)
end


AddPlayerPostInit(function(player)
    --- 只支持原生角色
    local config = playersdef.playerconfig(player)
    if config ~= nil then
        initAchievements(player, config)
        initPowerSystem(player)
        initTaskSystem(player)
        --- 测试代码
        if KSFUN_TUNING.DEBUG then
            player:ListenForEvent("oneat", testFunc)
        end
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