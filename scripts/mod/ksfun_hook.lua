local HOOK_SPEED_LEVEL = 100


-- 判断是否需要hook移速组件
-- 非骑行状态 & 饱食度等级 > 100
local function needHookSpeed(self, ismastersim)
    if ismastersim then
        if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then return false end
        if self.inst.components.ksfun_power_system then
            local power = self.inst.components.ksfun_power_system:GetPower(KSFUN_TUNING.PLAYER_POWER_NAMES.HUNGER)
            if power and power.components.ksfun_level then
                return power.components.ksfun_level.lv > HOOK_SPEED_LEVEL
            end
        end
        return false
    else
        if self.inst.replica.rider and self.inst.replica.rider:IsRiding() then return false end
        if self.inst.replica.ksfun_power_system then
            local power = self.inst.replica.ksfun_power_system:GetPower(KSFUN_TUNING.PLAYER_POWER_NAMES.HUNGER)
            if power and power.lv then
                return power.lv > HOOK_SPEED_LEVEL
            end
        end
        return false
    end
end


-- hook移动速度组件
-- 当角色的饱食度等级超过100时，角色搬运中午时不减少移动速度
local function hookCarryHeavySpeed(self)
    local oldGetSpeedMultiplier = self.GetSpeedMultiplier
	if TheWorld.ismastersim then
		self.GetSpeedMultiplier = function(self)
			if needHookSpeed(self, true) then
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
			if needHookSpeed(self, false) then
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

AddComponentPostInit("locomotor", hookCarryHeavySpeed)


--多汁浆果采集是掉落
AddPrefabPostInit("berrybush_juicy",function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst.components.pickable then
			local oldpickfn=inst.components.pickable.onpickedfn
			inst.components.pickable.onpickedfn=function(inst, picker, loot)
				picker:PushEvent("ksfun_picksomething", { object = inst, prefab = "berries_juicy", num = 3})
				if oldpickfn then
					oldpickfn(inst, picker, loot)
				end
			end
		end
	end
end)






-- 计算施肥倍率
-- 每10级提升一个倍率，倍率无上限，但是施肥的最大值是 100
local function calcFertilizeMulti(deployer)
    if not deployer then return 1 end
    local farm = deployer.components.ksfun_power_system:GetPower(KSFUN_TUNING.PLAYER_POWER_NAMES.FARM)
    if farm ~= nil then
        local lv = farm.components.ksfun_level:GetLevel()
        return 1 + lv/10
    end
    -- default value
    return 1
end

-- 根据用户等级计算肥力值的倍率对肥力值进行修改
-- 并且返回原始的肥力值，如果之前的肥力值不存在，则返回nil
local function tryModifyNutrients(fertilizer, deployer)
    if not fertilizer or not deployer then return nil end
    local cacheValue = fertilizer.nutrients
    if not cacheValue then return nil end

    local multi = calcFertilizeMulti(deployer)
    local newValue = {}
    for i,v in ipairs(cacheValue) do
        -- 土地肥力值的上限就是100
        table.insert(newValue, math.min(math.floor(v * multi), 100))
    end
    fertilizer.nutrients = newValue
    return cacheValue
end

-- hook ondeploy函数
-- 在回调之前篡改肥力值，回调后恢复
local function hookOnDeploy(deployable)
    deployable.OldDeploy = deployable.Deploy
    function deployable:Deploy(pt, deployer, rot)
        local inst = self.inst
        local fertilizer = inst.components.fertilizer
        local ret = tryModifyNutrients(fertilizer, deployer)
        local deployed = deployable:OldDeploy(pt, deployer, rot)
        if ret then
            inst.components.fertilizer.nutrients = ret
        end
		return deployed
    end
end

-- 这里不处理植物人吃肥料
if TheWorld.ismastersim then
    AddComponentPostInit("deployable", hookOnDeploy)
end