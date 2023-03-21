-- 刷新角色的最大饥饿值 

local HUNGER_RATE_TOKEN = "ksfun_hunger_rate"
local HUNGER_WORK_TOKEN = "ksfun_hunger_work"


local function need_hook_speed(self)
    if TheWorld.ismastersim then
        if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then return false end
        if self.inst.components.ksfun_hunger == nil then return false end
        return self.inst.components.ksfun_hunger.level > 100 or false
    else
        if self.inst.replica.rider and self.inst.replica.rider:IsRiding() then return false end
        if self.inst.replica.ksfun_hunger == nil then return false end
        return self.inst.replica.ksfun_hunger.level > 100 or false
    end
end


local function hook_carry_heavy_speed(self)
    local oldGetSpeedMultiplier = self.GetSpeedMultiplier
	if TheWorld.ismastersim then
		self.GetSpeedMultiplier = function(self)
			if need_hook_speed(self) then
				local mult = self:ExternalSpeedMultiplier()
				if self.inst.components.inventory ~= nil then
					for k, v in pairs(self.inst.components.inventory.equipslots) do
						if v.components.equippable ~= nil then
							local item_speed_mult = v.components.equippable:GetWalkSpeedMult()
							mult = mult * math.max(item_speed_mult, 1)
						end
					end
				end
				return mult * (self:TempGroundSpeedMultiplier() or self.groundspeedmultiplier) * self.throttle
			elseif oldGetSpeedMultiplier then
				return oldGetSpeedMultiplier(self)
			end
		end
	else
		self.GetSpeedMultiplier = function(self)
			if need_hook_speed(self) then
				local mult = self:ExternalSpeedMultiplier()
				local inventory = self.inst.replica.inventory
				if inventory ~= nil then
					for k, v in pairs(inventory:GetEquips()) do
						local inventoryitem = v.replica.inventoryitem
						if inventoryitem ~= nil then
							local item_speed_mult = inventoryitem:GetWalkSpeedMult()
							mult = mult * math.max(item_speed_mult,1)
						end
					end
				end
				return mult * (self:TempGroundSpeedMultiplier() or self.groundspeedmultiplier) * self.throttle
			elseif oldGetSpeedMultiplier then
				return oldGetSpeedMultiplier(self)
			end
		end
	end
end


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

    -- 升级可以提升角色的工作效率
    -- 吃得多力气也越大
    if inst.components.workmultiplier then
        local multi = lv / 100 + 1
        inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, multi,  HUNGER_WORK_TOKEN)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE, multi, HUNGER_WORK_TOKEN)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, multi, HUNGER_WORK_TOKEN)
    end 
end


-- 升级触发事件
local function on_hunger_up(player, gain_exp)
    if gain_exp then
        player.components.talker:Say("吃的越多，肚子越大！")
    end
    update_hunger_status(player)
    GLOBAL.TheWorld.components.ksfun_world_player:CachePlayerStatus(player)
end


-- 计算食物能够获得的经验值
local function calcu_food_exp(eater, food)
    if food == nil or food.components.edible == nil then return 0 end
    local hunger = food.components.edible:GetHunger(eater)
    local health = food.components.edible:GetHealth(eater)
    local sanity = food.components.edible:GetSanity(eater)
    return (0 * hunger + health * 0.4 + sanity * 0.6) * 20
end

-- 初始化组件
local function init_player(player)
    if not TheWorld.ismastersim then return end

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
end

AddPlayerPostInit(init_player)
AddComponentPostInit("locomotor", hook_carry_heavy_speed)