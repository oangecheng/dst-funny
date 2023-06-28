
local DEFAULT_MAX_HEALTH = 120
local EVENTS = KSFUN_TUNING.EVENTS

local ITEMS_DEF = require "defs/ksfun_items_def"



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
   
    player:ListenForEvent(EVENTS.TASK_FINISH, function(inst, data)
        inst.components.ksfun_task_system:RemoveTask(data.name)
    end)
end)

