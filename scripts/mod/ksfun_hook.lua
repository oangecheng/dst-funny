
----------------------------------------------------------------------饱食度对移速的hook--------------------------------------------------------------------------------------------------
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





----------------------------------------------------------------------肥力hook--------------------------------------------------------------------------------------------------


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
    if not TheWorld.ismastersim then
        return
    end
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
AddComponentPostInit("deployable", hookOnDeploy)


--- 鼠标移动到位置上显示任务内容
AddClassPostConstruct("widgets/hoverer", function(self)
    local old_SetString = self.text.SetString
    self.text.SetString = function(text, str)
        local target = TheInput:GetHUDEntityUnderMouse()
        if target ~= nil then
            target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item
        else
            target = TheInput:GetWorldEntityUnderMouse()
        end
        if target and target.entity ~= nil then
            if target.prefab ~= nil then
                if target.prefab == "ksfun_task_reel" and target.replica.ksfun_task_demand then
                    local content = target.replica.ksfun_task_demand:GetContent()
                    if content then
                        str = str .. "\n" .. "----" .. content
                    end
                end
            end
        end
        return old_SetString(text, str)
    end
end)





--------------------------------------------------攻击属性hook-----------------------------------------------------------
---- 吸血
---- 溅射

local ITEMS_DEF = require "defs/ksfun_items_def"
local ITEM_NAMES = KSFUN_TUNING.ITEM_POWER_NAMES


local EXCLUDE_TAG_DEFS = {
	"INLIMBO",
	"companion", 
	"wall",
	"abigail", 
}



-- 判断是否为仆从
local function isFollower(inst, target)
    if inst.components.leader ~= nil then
        return inst.components.leader:IsFollower(target)
    end
    return false
end



--- aoe伤害处理
local function doAoeAttack(aoepower, weapon, attacker, target)
    local lv = aoepower.components.ksfun_level:GetLevel()
    -- 初始 50% 范围伤害，满级80%
    -- 初始 1.2 范围， 满级3范围
    local multi, area = KsFunGetAoeProperty(aoepower)

    local combat = attacker.components.combat
    local x,y,z = target.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, area, { "_combat" }, EXCLUDE_TAG_DEFS)
    for i, ent in ipairs(ents) do
        if ent ~= target and ent ~= attacker and combat:IsValidTarget(ent) and (not isFollower(attacker, ent)) then
            attacker:PushEvent("onareaattackother", { target = ent, weapon = weapon, stimuli = nil })
            local damage = combat:CalcDamage(ent, weapon, 1) * multi
            ent.components.combat:GetAttacked(attacker, damage, weapon, nil)
        end
    end
end



--- 吸血攻击
local function doLifestealAttack(lifesteal, attacker, victim)
    if KsFunIsValidVictim(victim) then
        local level  = lifesteal.components.ksfun_level
        local health = attacker and attacker.components.health or nil
        if level and health then
            health:DoDelta(level:GetLevel(), false, "ksfun_item_lifesteal")
        end
    end
end



local function onAttack(inst, attacker, victim)
    local system = inst.components.ksfun_power_system
    if system == nil then return end

    -- 吸血
    local lifesteal = system:GetPower(ITEM_NAMES.LIFESTEAL)
    if lifesteal then
       doLifestealAttack(lifesteal, attacker, victim)
    end

    -- 溅射
    local aoe = system:GetPower(ITEM_NAMES.AOE)
    if aoe then
        doAoeAttack(aoe, inst, attacker, victim)
    end

end


local function hookAttackFunc(inst)
    if not TheWorld.ismastersim then return end
    local weapon = inst.components.weapon
    if weapon then
        weapon.ksfunOldOnAttack = weapon.onattack
        weapon:SetOnAttack(function(ent, attacker, victim)
            -- 执行mod攻击函数
            onAttack(ent, attacker, victim)
            -- 执行原始函数
            if weapon.ksfunOldOnAttack then
                weapon.ksfunOldOnAttack(ent, attacker, victim)
            end
        end)
    end
end


for i,v in ipairs(ITEMS_DEF.weapon) do
    AddPrefabPostInit(v, hookAttackFunc)
end





-----------------------------------------------------------------其他逻辑处理--------------------------------------------------------------------------------------

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