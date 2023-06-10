
local DEFAULT_MAX_HEALTH = 120
local EVENTS = KSFUN_TUNING.EVENTS

local HELPER = require("tasks/ksfun_task_helper")


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


-- 初始化角色
AddPlayerPostInit(function(player)
    --- 修改角色基础血量
    local percent = player.components.health:GetPercent()
    player.components.health.maxhealth = getInitMaxHealth()
    player.components.health:SetPercent(percent)

    player:AddComponent("ksfun_power_system")
    player:AddComponent("ksfun_task_system")

    
    -- test code
    player:ListenForEvent("oneat", function(inst)

        for k,v in pairs(KSFUN_TUNING.PLAYER_POWER_NAMES) do
            player.components.ksfun_power_system:AddPower(v)
        end


        local ent = SpawnPrefab("spear")
        if ent then
            ent.components.ksfun_item_forever:Enable()
            ent.components.ksfun_breakable:Enable()
            ent.components.ksfun_enhantable:Enable()
            if ent.components.finiteuses then
                ent.components.finiteuses:SetPercent(0.01)
            end

            ent.components.ksfun_power_system:AddPower(KSFUN_TUNING.ITEM_POWER_NAMES.MAXUSES)

            inst.components.inventory:GiveItem(ent, nil, player:GetPosition())

        end
        HELPER.addTask(inst, KSFUN_TUNING.TASK_NAMES.KILL)
    end)

    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)
    end)


    --- 击杀怪物增加怪物的世界等级
    player:ListenForEvent("killed", function(inst, data)
        KsFunLog("kill spider")
        TheWorld.components.ksfun_world_monster:KillMonster(data.victim.prefab, 1000)
    end)

end)


local monsters = {
    "spider"
}


for i,v in ipairs(monsters) do
    AddPrefabPostInit(v, function(inst)
        inst:AddComponent("ksfun_power_system")
        local wordmonster = TheWorld.components.ksfun_world_monster
        if wordmonster then
            if wordmonster:GetMonsterLevel(v) > 10 then
                -- local name = KsFunRandomValueFromKVTable(KSFUN_TUNING.MONSTER_POWER_NAMES)
                local name = KSFUN_TUNING.MONSTER_POWER_NAMES.LOCOMOTOR
                inst.components.ksfun_power_system:AddPower(name)
                local p = inst.components.ksfun_power_system:GetPower(name)
                p.components.ksfun_level:SetLevel(100)
            end
        end
    end)
end

