-- 刷新角色的最大饥饿值 

local HUNGER_RATE_TOKEN = "ksfun_hunger"


-- 更新角色的状态
-- 设置最大饱食度和饱食度的下降速率
-- 肚子越大，饿的越快
local function update_hunger_status(inst)
    local lv = inst.components.ksfun_hunger.level
	inst.components.hunger.max = 100 + lv
    local hunger_percent = inst.components.hunger:GetPercent()
	inst.components.hunger:SetPercent(hunger_percent)
    -- 100级之后每级新增千分之5的饱食度下降
    local multi = math.max(0 , lv - 100) * 0.005 + 1
    inst.components.hunger.burnratemodifiers:SetModifier(HUNGER_RATE_TOKEN, multi)
end


-- 升级触发事件
local function on_hunger_up(player, gain_exp)
    if gain_exp then
        player.components.talker:Say("吃的越多，肚子越大！")
    end
    update_hunger_status(player)
    GLOBAL.TheWorld.components.ksfun_data:CachePlayerStatus(player)
end


-- 计算食物能够获得的经验值
local function calcu_food_exp(eater, food)
    if food == nil or food.components.edible == nil then return 0 end
    local hunger = food.components.edible:GetHunger(eater)
    local health = food.components.edible:GetHealth(eater)
    local sanity = food.components.edible:GetSanity(eater)
    return (0 * hunger + health * 0.4 + sanity * 0.6) * 20
end


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