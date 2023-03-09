-- 刷新角色的最大饥饿值 


local function update_hunger_status(inst)
    local lv = inst.components.ksfun_hunger.level
	inst.components.hunger.max = 100 + lv
    local hunger_percent = inst.components.hunger:GetPercent()
	inst.components.hunger:SetPercent(hunger_percent)
end


local function player_hunger_up(player, gain_exp)
    if gain_exp then
        player.components.talker:Say("吃的越多，肚子越大！")
    end
    update_hunger_status(player)
    GLOBAL.TheWorld.components.ksfun_data:CachePlayerStatus(player)
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
        update_hunger_status(inst) 
    end
end)