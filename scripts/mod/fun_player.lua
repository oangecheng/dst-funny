-- 刷新角色的最大饥饿值
local function value(inst)
    local lv = inst.components.ksfun_hunger.level
	local hunger_percent = inst.components.hunger:GetPercent()
	inst.components.hunger.max = 100 + lv*2
	inst.components.hunger:SetPercent(hunger_percent)
end


local function player_hunger_up(player, delta)
    player.components.talker:Say("饱食度升级了")
    value(player)
end


-- 初始化角色
AddPlayerPostInit(function(player)
    player:AddComponent("ksfun_hunger")
    player.components.ksfun_hunger:SetHungerUpFunc(player_hunger_up)

    player:ListenForEvent("oneat", function(inst, data)
        if data and data.food then
            hunger = data.food.components.edible:GetHunger()
            inst.components.ksfun_hunger:GainExp(hunger) 
        end
    end)

    player.OnLoad = function(inst)
        value(inst) 
    end
end)