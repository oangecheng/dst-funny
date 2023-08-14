local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES



--- 不需要format的属性描述可以使用这个
local function getPowerDesc(inst)
    local extra = KsFunGetPowerDescExtra(inst.prefab)
    return KsFunGetPowerDesc(inst, extra)
end


--- 尝试更新属性的最大值
local function updatePowerMax(inst, delta)
    if inst.components.ksfun_breakable then
        local count = inst.components.ksfun_breakable:GetCount()
        local maxlv = (count + 1) * (delta or 10)
        inst.components.ksfun_level:SetMax(maxlv)
    end
end



---------------------------------------------------------------------------------------------- 血量增强 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local HEALTH_KEY = "maxhealth"
--- @param inst table
--- @param reset boolean
local function updateHealthStatus(inst, reset)
    local lv = inst.components.ksfun_level:GetLevel()
    local health = inst.target.components.health
    local maxhealth = inst.components.ksfun_power:GetData(HEALTH_KEY) or 100
    if health then
        local percent = health:GetPercent()
        local max = reset and maxhealth or maxhealth + lv
        health:SetMaxHealth(max)
        health:SetPercent(percent)
    end
end

--- 击杀怪物后，范围10以内的角色都可以获得血量升级的经验值
--- 范围内只有一个人时，经验值为100%获取
--- 人越多经验越低，最低50%
--- @param killer 击杀者 data 受害者数据集
local function onKillOther(killer, data)
    KsFunLog("health event onkillother", data.victim.prefab)
    local victim = data.victim
    if victim == nil then return end
    if victim.components.health == nil then return end

    if victim.components.freezable or victim:HasTag("monster") then
        -- 所有经验都是10*lv 因此血量也需要计算为1/10
        local exp = math.max(victim.components.health.maxhealth / 10, 1)
        -- 击杀者能够得到满额的经验
        KsFunPowerGainExp(killer, NAMES.HEALTH, exp)
        -- 非击杀者经验值计算，范围10以内其他玩家
        local x,y,z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x,y,z, 10, {"player"})
        if players == nil then return end
        local players_count = #players
        -- 单人模式经验100%，多人经验获取会减少，最低50%
        local exp_multi = math.max((6 - players_count) * 0.2, 0.5)
        for i, player in ipairs(players) do
            -- 击杀者已经给了经验了
            if player ~= killer then
                KsFunPowerGainExp(player, NAMES.HEALTH, math.max(exp * exp_multi, 1))
            end
        end
    end
end

local health = {
    onattach = function(inst, target, name)
        local h = target.components.health
        -- 记录原始数据
        inst.components.ksfun_power:SaveData(HEALTH_KEY, h.maxhealth)
        if inst.percent then
            h:SetPercent(inst.percent)
        end
        updatePowerMax(inst, 20)
        updateHealthStatus(inst, false)
        -- 玩家杀怪可以升级
        target:ListenForEvent("killed", onKillOther)
    end,

    ondetach = function(inst, target)
        target:RemoveEventCallback("killed", onKillOther)
        updateHealthStatus(inst, true)
    end,

    onstatechange = function(inst)
        updateHealthStatus(inst, false)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 20)
    end,

    ondesc = getPowerDesc,

    onsave = function(inst, data)
        if inst.target then
            data.percent = inst.target.components.health:GetPercent()
        end
    end,

    onload = function(inst, data)
        inst.percent = data.percent or nil
    end,

}








---------------------------------------------------------------------------------------------- 饱食度 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local HUNGER_KEY = "maxhunger"
-- 更新角色的状态
-- 设置最大饱食度和饱食度的下降速率
-- 肚子越大，饿的越快
local function updateHungerStatus(inst, reset)
    local maxhunger = inst.components.ksfun_power:GetData(HUNGER_KEY) or 100
    local lv     = inst.components.ksfun_level:GetLevel()
    local hunger = inst.target.components.hunger

    if hunger then
        local percent = hunger:GetPercent()
        hunger.max = reset and maxhunger or maxhunger + lv
        hunger:SetPercent(percent)
    end
end


--- 计算食物能够获得的经验值
--- 经验系数 饱食0.2  生命值0.3 精神值0.5
--- 如果是某一项为负值，此次获得的经验值可能为负数
local function calcFoodExp(eater, food)
    if food == nil or food.components.edible == nil then return 0 end
    local hunger = food.components.edible:GetHunger(eater)
    local health = food.components.edible:GetHealth(eater)
    local sanity = food.components.edible:GetSanity(eater)
    return 0.2 * hunger + health * 0.3 + sanity * 0.5
end


local function onEat(eater, data)
    local hunger = eater.components.ksfun_power_system:GetPower(NAMES.HUNGER)
    if data and data.food and hunger then
        local hunger_exp = calcFoodExp(eater, data.food)
        hunger.components.ksfun_level:GainExp(hunger_exp) 
    end
end


local hunger = {
    onattach = function(inst, target, name)
        local h = target.components.hunger
        -- 记录原始数据
        inst.components.ksfun_power:SaveData(HUNGER_KEY, h.max)
        if inst.percent then
            h:SetPercent(inst.percent)
        end

        updatePowerMax(inst, 20)
        updateHungerStatus(inst)
        target:ListenForEvent("oneat", onEat)
    end,

    ondetach = function(inst, target)
        target:RemoveEventCallback("oneat", onEat)
        updateHungerStatus(inst, true)
    end,

    onstatechange = function(inst)
        updateHungerStatus(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 20)
    end,

    ondesc = getPowerDesc,

    onsave = function(inst, data)
        if inst.target then
            data.percent = inst.target.components.hunger:GetPercent()
        end
    end,

    onload = function(inst, data)
        inst.percent = data.percent or nil
    end,
}









------------------------------------------------------------------------------------------- 精神值 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local SANITY_KEY = "maxsanity"
-- 各科技等级经验值倍率
--- SCIENCE 1,2,3
--- MAGIC 6,7,  (SCIENCE最大倍率x2)
--- ANCIENT 14,15,16 (MAGIC最大倍率x2)
--- CELESTIAL 14,16, (同ANCIENT, 月岛科技等级只有1和3)
--- SHADOWFORGING 15, 16
local BUILD_ITEM_EXP_MULTI_DEFS = {
    SCIENCE = 0,
    MAGIC = 4,
    ANCIENT = 12,
    CELESTIAL = 13,
    LUNARFORGING = 13,
    SHADOWFORGING = 14,
}


local function updateSanityStatus(inst, reset)
    local maxsanity = inst.components.ksfun_power:GetData(SANITY_KEY) or 100
    local sanity = inst.target.components.sanity
    local lv = inst.components.ksfun_level:GetLevel()

    if sanity then
        local percent = sanity:GetPercent()
        sanity.max = reset and maxsanity or maxsanity + lv
        sanity:SetPercent(percent)
    end
end


--- 根据物品等级计算经验倍率
--- 远古和魔法从等级2开始
local function getExpMultiByRecipeLevel(recipe_level)
    local multi = 2
    if recipe_level == nil then return multi end
    if recipe_level.SCIENCE ~= 0 then
        multi = tonumber(recipe_level.SCIENCE)      + BUILD_ITEM_EXP_MULTI_DEFS.SCIENCE  
    elseif recipe_level.MAGIC ~= 0 then
        multi = tonumber(recipe_level.MAGIC)        + BUILD_ITEM_EXP_MULTI_DEFS.MAGIC
    elseif recipe_level.ANCIENT ~= 0 then
        multi = tonumber(recipe_level.ANCIENT)      + BUILD_ITEM_EXP_MULTI_DEFS.ANCIENT
    elseif recipe_level.CELESTIAL ~= 0 then
        multi = tonumber(recipe_level.CELESTIAL)    + BUILD_ITEM_EXP_MULTI_DEFS.CELESTIAL
    elseif recipe_level.LUNARFORGING ~= 0 then
        multi = tonumber(recipe_level.LUNARFORGING) + BUILD_ITEM_EXP_MULTI_DEFS.LUNARFORGING
    elseif recipe_level.SHADOWFORGING ~= 0 then
        multi = tonumber(recipe_level.SHADOWFORGING) + BUILD_ITEM_EXP_MULTI_DEFS.SHADOWFORGING
    end
    multi = math.max(1, multi)
    return multi
end

--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data table 物品数据
local function onBuildItemFunc(player, data)
    local recipe_level = data.recipe.level
    local multi = getExpMultiByRecipeLevel(recipe_level)
    local exp = multi * 10
    KsFunPowerGainExp(player, NAMES.SANITY, exp)
end


--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data table 建筑数据
local function oBuildStructureFunc(player, data)
    local recipe_level = data.recipe.level
    local multi = getExpMultiByRecipeLevel(recipe_level)
    local exp = multi * 20
    KsFunPowerGainExp(player, NAMES.SANITY, exp)
end


local sanity = {
    onattach = function(inst, target, name)
        local s = target.components.sanity
        -- 记录原始数据
        inst.components.ksfun_power:SaveData(SANITY_KEY, s.max)
        if inst.percent then
            s:SetPercent(inst.percent)
        end

        updatePowerMax(inst, 20)
        updateSanityStatus(inst)
        target:ListenForEvent("builditem", onBuildItemFunc)
        target:ListenForEvent("buildstructure", oBuildStructureFunc)
    end,

    ondetach = function(inst, target, name)
        target:RemoveEventCallback("builditem", onBuildItemFunc)
        target:RemoveEventCallback("buildstructure", oBuildStructureFunc)
        updateSanityStatus(inst, true)
    end,

    onstatechange = function(inst)
        updateSanityStatus(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 20)
    end,

    ondesc = getPowerDesc,

    onsave = function(inst, data)
        if inst.target then
            data.percent = inst.target.components.sanity:GetPercent()
        end
    end,

    onload = function(inst, data)
        inst.percent = data.percent or nil
    end,
}






------------------------------------------------------------------------------------------- 采集(非农作物) --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 可多倍采集的物品定义
local PICKABLE_DEFS = require("defs/ksfun_prefabs_def").pickable

--- 计算倍率
--- 升级到30级大概需要采集400多个草
--- 0级的时候有 10% 概率双倍
local function calcPickMulti(power)
    local lv = math.floor(power.components.ksfun_level:GetLevel() * 0.1)

    if lv < 1 then 
        return (math.random(100) < 10)  and 1 or 0
    end

    local r = math.random(1024) 

    --- lv=1时，50%双倍
    --- lv=2时，25%三倍采集，50%双倍
    --- 以此类推
    for i=lv, 1, -1 do
        local ratio = 1024 / (2^i)
        if r <= ratio then
            return i 
        end
    end
    return 0
end


local function onPickSomeThing(player, data)
    local obj = data.object
    local exp = (PICKABLE_DEFS[obj.prefab] or 0)
    if exp <= 0 then 
        return 
    end

    local power = player.components.ksfun_power_system:GetPower(NAMES.PICK)
    if power == nil then
        return
    end

    -- 处理特殊case，目前支持多汁浆果
    if obj and data.prefab then
        if exp > 0 then
            KsFunPowerGainExp(player, NAMES.PICK, exp)
            local num = calcPickMulti(power)
            if num> 0 and obj.components.lootdropper then
                local pt = obj:GetPosition()
                pt.y = pt.y + (obj.components.pickable.dropheight or 0)
                for i=1,num * data.num do
                    obj.components.lootdropper:SpawnLootPrefab(data.prefab, pt)
                end
            end
        end
        return
    end

    -- 正常采集
    local loot = data and data.loot or nil
    if not (power and loot and obj) then 
        return 
    end

    -- 农作物不支持多倍采集，由其他属性支持
    if data.object:HasTag("farm_plant") then
        return
    end

    KsFunPowerGainExp(player, NAMES.PICK, exp)

    --- 单个物品
    if loot.prefab ~= nil then
         -- 根据等级计算可以额外掉落的数量
        local num = calcPickMulti(power)
        if num > 0 then
            for i = 1, num do
                local item = SpawnPrefab(loot.prefab)
                player.components.inventory:GiveItem(item, nil, player:GetPosition())
            end       
        end
    
    -- 多物品掉落(好像没走这个逻辑，确认下是不是农场作物掉落, 暂时保留)
    elseif not IsTableEmpty(loot) then
        -- 额外掉落物
        local extraloot = {}
        local lootdropper = obj.components.lootdropper
        local num = calcPickMulti(power)
        local dropper = lootdropper:GenerateLoot()
        if (not IsTableEmpty(dropper)) and num > 0 then
            for _, prefab in ipairs(dropper) do
                for i = 1, num do
                    table.insert(extraloot, lootdropper:SpawnLootPrefab(prefab))
                end
            end
            -- 给予玩家物品
            for _, item in ipairs(extraloot) do
                player.components.inventory:GiveItem(item, nil, player:GetPosition())
            end 
        end
    end

    -- 仙人掌花单独处理
    if obj.has_flower and (obj.prefab == "cactus" or obj.prefab == "oasis_cactus") then
        local n = calcPickMulti(power)
        for i = 1, n do
            local flower = SpawnPrefab("cactus_flower")
            player.components.inventory:GiveItem(flower, nil, player:GetPosition())
        end
     end
end


local pick = {
    onattach = function(inst, target, name)
        updatePowerMax(inst, 10)
        target:ListenForEvent("picksomething", onPickSomeThing)
        target:ListenForEvent("ksfun_picksomething", onPickSomeThing)
    end,

    ondetach = function(inst, target)
        target:RemoveEventCallback("picksomething", onPickSomeThing)
        target:RemoveEventCallback("ksfun_picksomething", onPickSomeThing)
    end,

    onstatechange = function(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 10)
    end,

    ondesc = getPowerDesc,
}








------------------------------------------------------------------------------------------- 采集农作物 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- 计算倍率
local function calcFarmPlantMulti(power)
    local lv = math.floor(power.components.ksfun_level:GetLevel() / 20 )
    if lv < 1 then 
        return (math.random(100) < 10)  and 1 or 0
    end

    local r = math.random(1024) 

    --- lv=1时，50%双倍
    --- lv=2时，25%三倍采集，50%双倍
    --- 以此类推
    for i=lv, 1, -1 do
        local ratio = 1024 / (2^i)
        if r <= ratio then
            return i 
        end
    end
    return 0
end


--- 计算多倍采集
local function onPickFarmPlant(player, data)
    if data and data.loot then
        --采摘的是农场作物
        if data.object and data.object:HasTag("farm_plant") then
            local prefab = data.loot[1] and data.loot[1].prefab--获取采摘的预置物名
            -- 采摘巨大作物即可获得经验
            if prefab and string.find(prefab, "oversized") then
                KsFunPowerGainExp(player, NAMES.FARM, 10)
            end

            local lootdropper = data.object.components.lootdropper
            local power = player.components.ksfun_power_system:GetPower(NAMES.FARM)

            -- 额外掉落物
            if power and lootdropper then
                local num = calcFarmPlantMulti(power)
                local loot = lootdropper:GenerateLoot()
                if num <= 0 or IsTableEmpty(loot) then return end
                local extraloot = {}
                for _, prefab in ipairs(loot) do
                    for i = 1, num do
                        table.insert(extraloot, lootdropper:SpawnLootPrefab(prefab))
                    end
                end
         
                 -- 给予玩家物品
                for _, item in ipairs(extraloot) do
                    player.components.inventory:GiveItem(item, nil, player:GetPosition())
                end 
            end
        end
    end
end


local farm = {
    onattach = function(inst, target, name)
        updatePowerMax(inst, 10)
        target:ListenForEvent("picksomething", onPickFarmPlant)
    end,

    ondetach = function(inst, target)
        target:RemoveEventCallback("picksomething", onPickFarmPlant)
    end,

    onstatechange = function(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    ondesc = getPowerDesc,

    onbreak = function(inst)
        updatePowerMax(inst, 10)
    end,
}






---------------------------------------------------------------------------------------------- 击杀掉落 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function killItemDrop(inst, data)
    local victim = data.victim
   
    if victim.components.freezable or victim:HasTag("monster") then
        local dropper = victim.components.lootdropper
        if dropper == nil then
            return
        end

        local power = inst.components.ksfun_power_system:GetPower(NAMES.KILL_DROP)
        if power == nil then
            return
        end
        local lv = power.components.ksfun_level:GetLevel()
        -- 双倍掉落初始10%，满级100%
        local ratio = (lv + 10) / 100
        local rd = math.random()

        -- 三倍掉落概率更低，为两倍概率的1/5
        if rd < ratio / 5 then 
            dropper:DropLoot()
            dropper:DropLoot()
        elseif rd < ratio then
            dropper:DropLoot() 
        end

        -- 击杀大于血量1000的怪物能够升级属性
        if victim.components.health then
            local max = victim.components.health.maxhealth
            if max >= 1000 then
                KsFunPowerGainExp(inst, NAMES.KILL_DROP, max/100)
            end 
        end
    end
end


local killdrop = {
    onattach = function(inst, target, name)
        updatePowerMax(inst, 10)
        target:ListenForEvent("killed", killItemDrop)
    end,

    ondetach = function(inst, target)
        target:RemoveEventCallback("killed", killItemDrop)
    end,

    onstatechange = function(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 10)
    end,

    ondesc = getPowerDesc,
}






---------------------------------------------------------------------------------------------- 移动速度 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function updateLocomotorStatus(inst, reset)
    local locomotor = inst.target.components.locomotor
    if locomotor then
        if reset then
            locomotor:RemoveExternalSpeedMultiplier(inst, "ksfun_power_locomotor")
        else
            local lv = inst.components.ksfun_level:GetLevel()
            local mult = 1 + lv * 0.01
            locomotor:SetExternalSpeedMultiplier(inst, "ksfun_power_locomotor", mult)
        end
    end
end

local locomotor = {

    onattach = function(inst, target)
        updatePowerMax(inst, 10)
        updateLocomotorStatus(inst)
    end,

    ondetach = function(inst, target)
        updateLocomotorStatus(inst, true)
    end,

    onstatechange = function(inst)
        updateLocomotorStatus(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 10)
    end,

    ondesc = getPowerDesc,
}




---------------------------------------------------------------------------------------------- 幸运 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function onTaskFinish(inst, data)
    if data.iswin then
        local exp = 2 ^ data.lv
        KsFunPowerGainExp(inst, NAMES.LUCKY, exp)
    end
end

local lucky = {
    onattach = function(inst, target)
        updatePowerMax(inst, 10)
        target:ListenForEvent(KSFUN_EVENTS.TASK_FINISH, onTaskFinish)
    end,

    ondetach = function(inst, target)
        target:RemoveEventCallback(KSFUN_EVENTS.TASK_FINISH, onTaskFinish)
    end,

    onstatechange = function(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 10)
    end,

    ondesc = getPowerDesc,
}





------------------------------------------------------------------------------------------- 巨人 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function updateGiantStatus(inst, reset)
    local lv = inst.components.ksfun_level:GetLevel()
    -- 每级新增1%的饱食度下降，最大不超过50%
    local hunger = inst.target.components.hunger
    if reset then
        hunger.burnratemodifiers:RemoveModifier("ksfun_power_player_hunger")
    else
        local hunger_multi = math.max((lv - 100) * 0.01 + 1, 1.5)
        hunger.burnratemodifiers:SetModifier("ksfun_power_player_hunger", hunger_multi)
    end

    -- 升级可以提升角色的工作效率
    local workmultiplier = inst.target.components.workmultiplier
    if workmultiplier then
        if reset then
            workmultiplier:RemoveMultiplier(ACTIONS.CHOP,   inst)
            workmultiplier:RemoveMultiplier(ACTIONS.MINE,   inst)
            workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)
        else
            local work_multi = lv / 100 + 1
            workmultiplier:AddMultiplier(ACTIONS.CHOP,   work_multi,   inst)
            workmultiplier:AddMultiplier(ACTIONS.MINE,   work_multi,   inst)
            workmultiplier:AddMultiplier(ACTIONS.HAMMER, work_multi,   inst)
        end
    end 
end


local function onHungerChange(inst, data)
    local max = 1
    if data.newpercent and data.newpercent >= 0.75 then
        local pgiant = inst.components.ksfun_power_system:GetPower(NAMES.GIANT)
        if pgiant then
            local lv  = pgiant.components.ksfun_level:GetLevel()
            max = 1 + 0.01 * math.min(50, lv) 
        end
    end
    inst.AnimState:SetScale(max, max, max)
end


local giant = {
    onattach = function(inst, target)
        updatePowerMax(inst, 10)
        updateGiantStatus(inst, false)
        target:ListenForEvent("hungerdelta", onHungerChange)
    end,

    ondetach = function(inst, target)
        target:RemoveEventCallback("hungerdelta", onHungerChange)
        target.AnimState:SetScale(1, 1, 1)
        updateGiantStatus(inst, true)
    end,

    onstatechange = function(inst)
        updateGiantStatus(inst, false)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 10)
    end,

    ondesc = getPowerDesc,
    
}






------------------------------------------------------------------------------------------- 厨子 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function onHarvestFood(inst, data)
    if data.food  then
        KsFunPowerGainExp(inst, NAMES.COOKER, 10)
    end
end


local cooker = {
    onattach = function(inst, target)
        updatePowerMax(inst, 10)
        target:ListenForEvent(KSFUN_EVENTS.HARVEST_SELF_FOOD, onHarvestFood)
    end,

    ondetach = function(inst, target)
        target:RemoveEventCallback(KSFUN_EVENTS.HARVEST_SELF_FOOD, onHarvestFood)
    end,

    onbreak = function(inst)
        updatePowerMax(inst, 10)
    end,

    ondesc = getPowerDesc,
}






local playerpowers = {
    [NAMES.HUNGER]      = hunger,
    [NAMES.SANITY]      = sanity,
    [NAMES.HEALTH]      = health,
    [NAMES.PICK]        = pick,
    [NAMES.FARM]        = farm,
    [NAMES.KILL_DROP]   = killdrop,
    [NAMES.LOCOMOTOR]   = locomotor,
    [NAMES.LUCKY]       = lucky,
    [NAMES.GIANT]       = giant,
    [NAMES.COOKER]      = cooker,
}


return playerpowers