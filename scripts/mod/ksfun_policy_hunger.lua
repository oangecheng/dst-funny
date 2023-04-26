-- 刷新角色的最大饥饿值 

local HOOK_SPEED_LEVEL = 100


-- 计算饥饿速率
-- 100级之后每级新增千分之5的饱食度下降，最大不超过50%
local function calc_hunger_multi(lv)
    return math.max(math.max(0 , lv - 100) * 0.005 + 1, 1.5)
end


-- 计算工作效率
-- 每一级新增1%的工作效率，暂时不设置上限
local function calc_work_multi(lv)
    return lv / 100 + 1
end


-- 更新角色的状态
-- 设置最大饱食度和饱食度的下降速率
-- 肚子越大，饿的越快
local function update_hunger_status(inst)
    local ksfun_hunger = inst.components.ksfun_hunger
    if ksfun_hunger == nil then return end

    local lv = ksfun_hunger.level
	inst.components.hunger.max = 100 + lv
    local hunger_percent = inst.components.hunger:GetPercent()
	inst.components.hunger:SetPercent(hunger_percent)

    -- 100级之后每级新增千分之5的饱食度下降
    local hunger_multi = calc_hunger_multi(lv)
    inst.components.hunger.burnratemodifiers:SetModifier(ksfun_hunger, hunger_multi)

    -- 升级可以提升角色的工作效率
    -- 吃得多力气也越大
    if inst.components.workmultiplier then
        local work_multi = calc_work_multi(lv)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, work_multi, ksfun_hunger)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE, work_multi, ksfun_hunger)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, work_multi, ksfun_hunger)
    end 
end



-- 饱食等级提升
local function on_hunger_up(player, gain_exp)
    if gain_exp then
        player.components.talker:Say("吃的越多，肚子越大！")
    end
    update_hunger_status(player)
    GLOBAL.TheWorld.components.ksfun_world_player:CachePlayerStatus(player)
end


-- 饱食等级下降
local function on_hunger_down(player)
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


-- 死亡降低饱食等级
local function on_death(inst, data)
    if inst.components.ksfun_hunger then
        inst.components.ksfun_hunger:Downgrade(1)
    end
end


-- 吃东西获得经验
local function on_eat(inst, data)

    local task = SpawnPrefab("ksfun_task_test")
    inst.components.ksfun_task_system:Attach(task)
    inst.components.ksfun_task_system:Start()

    local name = KSFUN_TUNING.PLAYER_POWER_NAMES.HEALTH
    local prefab = "ksfun_power_"..name
    inst.components.ksfun_powers:AddPower(name, prefab)

    if data and data.food then
        hunger_exp = calcu_food_exp(inst, data.food)
        inst.components.ksfun_hunger:GainExp(hunger_exp) 
    end
end


-- 初始化组件
local function init_player(player)
    if not TheWorld.ismastersim then return end

    player:AddComponent("ksfun_hunger")
    player.components.ksfun_hunger:SetHungerUpFunc(on_hunger_up)
    player.components.ksfun_hunger:SetHungerDownFunc(on_hunger_down)

    player:ListenForEvent("oneat", on_eat)
    player:ListenForEvent("death", on_death)

    local old_on_load = player.OnLoad
    player.OnLoad = function(inst)
        update_hunger_status(inst) 
        if old_on_load ~= nil then
            old_on_load(inst)
        end
    end
end

-- 角色初始化
AddPlayerPostInit(init_player)





-- 判断是否需要hook移速组件
-- 非骑行状态 & 饱食度等级 > 100
local function need_hook_speed(self, ismastersim)
    if ismastersim then
        if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then return false end
        if self.inst.components.ksfun_hunger == nil then return false end
        return self.inst.components.ksfun_hunger.level > HOOK_SPEED_LEVEL or false
    else
        if self.inst.replica.rider and self.inst.replica.rider:IsRiding() then return false end
        if self.inst.replica.ksfun_hunger == nil then return false end
        return self.inst.replica.ksfun_hunger.level > HOOK_SPEED_LEVEL or false
    end
end


-- hook移动速度组件
-- 当角色的饱食度等级超过100时，角色搬运中午时不减少移动速度
local function hook_carry_heavy_speed(self)
    local oldGetSpeedMultiplier = self.GetSpeedMultiplier
	if TheWorld.ismastersim then
		self.GetSpeedMultiplier = function(self)
			if need_hook_speed(self, true) then
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
			if need_hook_speed(self, false) then
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

AddComponentPostInit("locomotor", hook_carry_heavy_speed)