
local DEFAULT_MAX_HEALTH = 120
local EVENTS = KSFUN_TUNING.EVENTS

local ITEMS_DEF = require "defs/ksfun_items_def"



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

            for i,v in ipairs(ITEMS_DEF.ksfunitems["spear"].names) do
                ent.components.ksfun_power_system:AddPower(v)
            end


            inst.components.inventory:GiveItem(ent, nil, player:GetPosition())

        end
    end)

    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)
    end)
end)

