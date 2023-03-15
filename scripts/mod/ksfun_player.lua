


-- 初始化角色
AddPlayerPostInit(function(player)
    player:AddComponent("ksfun_hunger")
    player.components.ksfun_hunger:SetHungerUpFunc(on_hunger_up)

    player:ListenForEvent("oneat", function(inst, data)
        if data and data.food then
            hunger_exp = calcu_food_exp(inst, data.food)
            inst.components.ksfun_hunger:GainExp(hunger_exp) 
        end
    end)

    local old_on_load = player.OnLoad
    player.OnLoad = function(inst)
        update_hunger_status(inst) 
        if old_on_load ~= nil then
            old_on_load(inst)
        end
    end
end)