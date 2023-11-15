
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

-- 不添加这个属性，更换成其他的了
-- AddComponentPostInit("locomotor", hookCarryHeavySpeed)





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
                if target.prefab == "ksfun_task_reel" then
                    local content = target.demandcontent
                    if content then
                        str = str .. "\n" .. "要求:" .. content
                    end
                end

                if target.replica.ksfun_level then
                    local lv = target.replica.ksfun_level:GetLevel()
                    if lv and lv > 0 then
                        local desc = "lv"..lv
                        if target.replica.ksfun_power_system then
                            local names = target.replica.ksfun_power_system:GetPowerNames()
                            if names ~= "" then
                                desc = desc.."  "..names
                            end
                        end
                        str = str.."\n"..desc
                    end
                end
            end     
        end

       

        return old_SetString(text, str)
    end
end)






-----------------------------------------------------------------一些组件的hook-------------------------------------------------------------------------------------
--修改海钓竿组件
AddComponentPostInit("oceanfishingrod", function(self)
	local oldCatchFish = self.CatchFish
	self.CatchFish = function(self)
		if self.target ~= nil and self.target.components.oceanfishable ~= nil then
			self.fisher:PushEvent(KSFUN_EVENTS.FISH_SUCCESS, { fish = self.target, isocean = true } )
		end
		if oldCatchFish then
			oldCatchFish(self)
		end
	end
end)


--修改普通鱼竿组件
AddComponentPostInit("fishingrod", function(fishingrod)
	local oldCollect = fishingrod.Collect
	fishingrod.Collect = function(self)
		if self.caughtfish and self.fisherman and self.target then
			self.fisherman:PushEvent(KSFUN_EVENTS.FISH_SUCCESS, {fish = self.caughtfish, pond = self.target} )
		end
		if oldCollect then
			oldCollect(self)
		end
	end
end)




local function cookTimeMulti(doer)
    local lv = KsFunGetPowerLv(doer, KSFUN_TUNING.PLAYER_POWER_NAMES.COOKER)
    return lv and math.max(1 - lv * 0.005, 0.5) or 1
end

--修改烹饪组件,在锅中收获自己做的料理的时候推送事件
AddComponentPostInit("stewer", function(self)
	local oldHarvest = self.Harvest
	self.Harvest = function(self, harvester)
		if self.done and harvester ~= nil and self.chef_id == harvester.userid and self.product then
			harvester:PushEvent(KSFUN_EVENTS.HARVEST_SELF_FOOD, { food = self.product })
		end
		return oldHarvest and oldHarvest(self, harvester) or nil
	end

    -- hook烹饪时间
    local oldStartCooking = self.StartCooking
    self.StartCooking = function(self, doer)
        local oldmulti = self.cooktimemult
        self.cooktimemult = oldmulti * cookTimeMulti(doer)
        if oldStartCooking then
            oldStartCooking(self, doer)
        end
        self.cooktimemult = oldmulti
    end
end)


--- hook晾肉架组件
AddComponentPostInit("dryer", function (self)
    local oldHarvest = self.Harvest
    self.Harvest = function (self, harvester)
        local success = oldHarvest(self, harvester)
        if success then
            harvester:PushEvent(KSFUN_EVENTS.HARVEST_DRY, { product = self.product })
        end
        return success
    end
end)




AddComponentPostInit("edible", function(self)
    local oldGetSanity = self.GetSanity
    local oldGetHunger = self.GetHunger
    local oldGetHealth = self.GetHealth

    local function isDiarrhea(eater)
        if eater and eater.components.ksfun_power_system then
            return eater.components.ksfun_power_system:GetPower(KSFUN_TUNING.NEGA_POWER_NAMES.DIARRHEA) ~= nil
        end
    end

    self.GetSanity = function(self, eater)
        local v = oldGetSanity(self, eater)
        if v and isDiarrhea(eater) then
            return v * 0.5
        else
            return v
        end
    end
    
    self.GetHealth = function(self, eater)
        local v = oldGetHealth(self, eater)
        if v and isDiarrhea(eater) then
            return v * 0.5
        else
            return v
        end
    end
    
    self.GetHunger = function(self, eater)
        local v = oldGetHunger(self, eater)
        if v and isDiarrhea(eater) then
            return v * 0.5
        else
            return v
        end
    end
end)





--- 降智光环hook
local SANITYAURA_DELTA = TUNING.SANITYAURA_SMALL / 25
AddComponentPostInit("sanityaura", function(self)
    local oldGetAura = self.GetAura
    self.GetAura = function (_, observer)
        -- 先记下之前的值，计算完之后再还原
        local aura = self.aura
        local lv = KsFunGetPowerLv(self.inst, KSFUN_TUNING.MONSTER_POWER_NAMES.SANITY_AURA)
        if lv and aura <= 0 then
           self.aura = self.aura - SANITYAURA_DELTA * lv
        end
        local v = oldGetAura(self, observer)
        self.aura = aura
        return v
    end
end)







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









---战斗体系相关的属性比较多
---这里单独使用一个文件去处理玩家战斗相关的逻辑
---避免处理方式不一致导致后续的维护问题


---- hook combat CalcDamage 组件
local function hookCalcDamage(inst, target, weapon)
    local doersystem = inst and inst.components.ksfun_power_system
    local doerpowers = doersystem and doersystem:GetAllPowers()

    local multiplier = 1

    --- attacker属性计算, 一般都是>1的，伤害倍乘
    if doerpowers then
        for _, value in pairs(doerpowers) do
            if value.hookcombat then
                multiplier = multiplier * value.hookcombat(inst, target, weapon, value)
            end
        end
    end

    local targetsystem = target and target.components.ksfun_power_system
    local targetpowers = targetsystem and targetsystem:GetAllPowers()
    if  targetpowers then
        for _, value in pairs(targetpowers) do
            -- 被攻击方触发被攻击，触发削减伤害机制
            if value.hookoncombat then
                multiplier = multiplier * value.hookoncombat(inst, target, weapon, value)
            end
        end
    end

    local weaponsystem = weapon and weapon.components.ksfun_power_system
    local weaponpowers = weaponsystem and weaponsystem:GetAllPowers()
    if weaponpowers then
        for _, value in pairs(weaponpowers) do
            if value.hookcombat then
                multiplier = multiplier * value.hookcombat(inst, target, weapon, value)
            end
        end
    end

    return multiplier
end


--- hook combat 组件
--- 伤害计算使用这个函数hook
--- 给power的inst添加 hookcombat 函数完成hook
--- 怪物之间战斗的伤害结算也是计算属性的，因为hook的是组件
AddComponentPostInit("combat", function(self)
    local oldCaclDamage = self.CalcDamage
    self.CalcDamage = function(_, target, weapon, multiplier)
        -- 计算原始伤害
        local dmg, spdmg = oldCaclDamage(self, target, weapon, multiplier)
        if self.inst then
            local multi = hookCalcDamage(self.inst, target, weapon)
            dmg = dmg * multi
        end
        return dmg, spdmg
    end
end)





--- 这里hook玩家的攻击系统
--- 怪物和怪物之间的战斗不会触发任何战斗效果
local function hookAttack(doer, target, weapon)
    local doersystem = doer and doer.components.ksfun_power_system
    local doerpowers = doersystem and doersystem:GetAllPowers()

    --- 玩家攻击回调，触发属性 onattack
    if doerpowers then
        for _, value in pairs(doerpowers) do
            if value.doattack then
                value.doattack(doer, target, weapon, value)
            end
        end
    end

    --- 玩家攻击回调，触发武器属性 onattack
    local weaponsystem = weapon and weapon.components.ksfun_power_system
    local weaponpowers = weaponsystem and weaponsystem:GetAllPowers()
    if weaponpowers then
        for _, value in pairs(weaponpowers) do
            if value.doattack then
                value.doattack(doer, target, weapon, value)
            end
        end
    end

    -- 被攻击方触发被攻击，触发被动机制，例如反伤等
    local targetsystem = target and target.components.ksfun_power_system
    local targetpowers = targetsystem and targetsystem:GetAllPowers()
    if  targetpowers then
        for _, value in pairs(targetpowers) do
            if value.onattacked then
                value.onattacked(doer, target, weapon, value)
            end
        end
    end
end


--- hook玩家攻击和被攻击的事件
--- 一般执行属性效果使用这个hook
AddPlayerPostInit(function (player)
    player:ListenForEvent("onattackother", function (inst, data)
        hookAttack(inst, data.target, data.weapon)
    end)

    player:ListenForEvent("attacked", function (inst, data)
        hookAttack(data.attacker, inst, data.weapon)
    end)
end)







local function taskNet(inst)
    inst.ksfuntaskdata = net_string(inst.GUID, "ksfuntaskdata", "ksfun_itemdirty")
    inst.ksfuntaskself = net_string(inst.GUID, "ksfuntaskself", "ksfun_itemdirty")
    inst:ListenForEvent("ksfun_itemdirty", function(_)
        local data = inst.ksfuntaskdata:value()
		inst.ksfuntask_panel = (data ~= nil and data ~= "") and json.decode(data) or {}
        local selfdata = inst.ksfuntaskself:value()
        inst.ksfuntask_panelself = (selfdata and selfdata ~= "") and json.decode(selfdata) or {}
	end)

    inst.ksfun_take_task = function(publisher, doer, taskid)
        if taskid ~= nil and doer ~= nil then
            if TheWorld.ismastersim then
                inst.components.ksfun_task_publisher:TakeTask(doer, taskid)
            else
                SendModRPCToServer(MOD_RPC.ksfun_rpc.taketask, doer, taskid)
            end
        end
    end

    inst.ksfun_giveup_task = function (doer, taskname)
        if doer and taskname then
            if TheWorld.ismastersim then
                local task = inst.components.ksfun_task_system:GetTask(taskname)
                if task ~= nil then
                    task.components.ksfun_task:Lose()
                end
            else
                SendModRPCToServer(MOD_RPC.ksfun_rpc.giveuptask, taskname)
            end
        end
    end
end


AddPlayerPostInit(function (inst)

    taskNet(inst)
    inst.ksfuntask_panel = {}

    if not TheWorld.ismastersim then
        return
    end

    if inst.components.ksfun_task_system then

        inst:AddComponent("ksfun_task_publisher")
        inst.components.ksfun_task_publisher:SetListener(function (_, tasks)
            local str = json.encode( tasks or {} )
            if inst.ksfuntaskdata then
                inst.ksfuntaskdata:set(str)
            end
        end)

        inst.components.ksfun_task_system:SetOnListener(function (_, tasks)
            local list = {}
            if tasks then
                for k, v in pairs(tasks) do
                    if v and v.inst then
                        local d = v.inst.components.ksfun_task:GetTaskData()
                        d.index = 0
                        list[k] = d
                    end
                end
            end
            if inst.ksfuntaskself then
                inst.ksfuntaskself:set(json.encode(list))
            end
        end)
        
        TheWorld:ListenForEvent("cycleschanged", function (_)
            inst.components.ksfun_task_publisher:CreateTasks(20)
        end)
    end
end)
