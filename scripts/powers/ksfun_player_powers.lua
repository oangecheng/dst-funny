local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES



local playerpowers = {}


--- 不需要format的属性描述可以使用这个
local function getPowerDesc(inst)
    local extra = KsFunGetPowerDescExtra(inst.prefab)
    return KsFunGetPowerDesc(inst, extra)
end


local function canHit(defaultratio)
    local r =  KSFUN_TUNING.DEBUG and 1 or defaultratio
    return math.random(100) < r * 100
end







---------------------------------------------------------------------------------------------- 血量增强 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function updateHealthStatus(inst)
    local lv = inst.components.ksfun_level.lv
    local health = inst.target.components.health
    local data = inst.components.ksfun_power:GetData()
    if health and data then
        local percent = health:GetPercent()
        health:SetMaxHealth(math.floor(data.health * (1 + lv * 0.01) + 0.5))
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
        inst.components.ksfun_power:SetData({health = h.maxhealth, percent = h:GetPercent()})
        if inst.percent then
            h:SetPercent(inst.percent)
        end
        updateHealthStatus(inst)
        -- 玩家杀怪可以升级
        target:ListenForEvent("killed", onKillOther)
    end,

    onstatechange = function(inst)
        updateHealthStatus(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    ondesc = getPowerDesc,

    onsave = function(inst, data)
        data.percent = inst.target.components.health:GetPercent()
    end,

    onload = function(inst, data)
        inst.percent = data.percent or nil
    end,
}








---------------------------------------------------------------------------------------------- 饱食度 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function getHungerPercent(inst)
   inst.target.components.hunger:GetPercent()
end


-- 更新角色的状态
-- 设置最大饱食度和饱食度的下降速率
-- 肚子越大，饿的越快
local function updateHungerStatus(inst)
    local data   = inst.components.ksfun_power:GetData()
    local lv     = inst.components.ksfun_level:GetLevel()
    local hunger = inst.target.components.hunger

    if hunger and data then
        local percent = hunger:GetPercent()
        hunger.max = data.maxhunger + lv
        hunger:SetPercent(percent)
    end

    -- 100级之后每级新增千分之5的饱食度下降，最大不超过50%
    if lv > 100  then
        local hunger_multi = math.max(math.max(0 , lv - 100) * 0.005 + 1, 1.5)
        hunger.burnratemodifiers:SetModifier("ksfun_power_player_hunger", hunger_multi)
    end

    
    -- 升级可以提升角色的工作效率
    -- 吃得多力气也越大
    local workmultiplier = inst.target.components.workmultiplier
    if workmultiplier then
        local work_multi = lv / 100 + 1
        workmultiplier:AddMultiplier(ACTIONS.CHOP,   work_multi,   inst)
        workmultiplier:AddMultiplier(ACTIONS.MINE,   work_multi,   inst)
        workmultiplier:AddMultiplier(ACTIONS.HAMMER, work_multi,   inst)
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
        inst.components.ksfun_power:SetData({ maxhunger = h.max, percent = h:GetPercent() })
        if inst.percent then
            h:SetPercent(inst.percent)
        end
        updateHungerStatus(inst)
        target:ListenForEvent("oneat", onEat)
    end,

    onstatechange = function(inst)
        updateHungerStatus(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    ondesc = getPowerDesc,

    onsave = function(inst, data)
        data.percent = inst.target.components.hunger:GetPercent()
    end,

    onload = function(inst, data)
        inst.percent = data.percent or nil
    end,
}









------------------------------------------------------------------------------------------- 精神值 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 各科技等级经验值倍率
--- SCIENCE 1,2,3
--- MAGIC 6,7,  (SCIENCE最大倍率x2)
--- ANCIENT 14,15,16 (MAGIC最大倍率x2)
--- CELESTIAL 14,16, (同ANCIENT, 月岛科技等级只有1和3)
local BUILD_ITEM_EXP_MULTI_DEFS = {
    SCIENCE = 0,
    MAGIC = 4,
    ANCIENT = 12,
    CELESTIAL = 13,
    LUNARFORGING = 13,
}

local function updateSanityStatus(inst)
    local data = inst.components.ksfun_power:GetData()

    local sanity = inst.target and inst.target.components.sanity or nil
    local level = inst.components.ksfun_level
    if sanity and level and data then
        local percent = sanity:GetPercent()
        sanity.max = data.sanity + level.lv
        sanity:SetPercent(percent)
    end
end


--- 监听等级提升
--- @param inst power实例
--- @param lv  等级
--- @param notice 是否需要说话
local function onLvChangeFunc(inst, lv, notice)
    updateSanityStatus(inst)
    KsFunSayPowerNotice(inst.target, inst.prefab)
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
    end
    multi = math.max(1, multi)
    return multi
end

--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data 物品数据
local function onBuildItemFunc(player, data)
    local recipe_level = data.recipe.level
    local multi = getExpMultiByRecipeLevel(recipe_level)
    local exp = multi * 1
    KsFunPowerGainExp(player, NAMES.SANITY, exp)
end


--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data 建筑数据
local function oBuildStructureFunc(player, data)
    local recipe_level = data.recipe.level
    local multi = getExpMultiByRecipeLevel(recipe_level)
    local exp = multi * 2
    KsFunPowerGainExp(player, NAMES.SANITY, exp)
end


local sanity = {
    onattach = function(inst, target, name)
        local s = target.components.sanity
        -- 记录原始数据
        inst.components.ksfun_power:SetData({ sanity = s.max, percent = s:GetPercent() })
        if inst.percent then
            s:SetPercent(inst.percent)
        end
        updateSanityStatus(inst)
        target:ListenForEvent("builditem", onBuildItemFunc)
        target:ListenForEvent("buildstructure", oBuildStructureFunc)
    end,

    onstatechange = function(inst)
        updateSanityStatus(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    ondesc = getPowerDesc,

    onsave = function(inst, data)
        data.percent = inst.target.components.sanity:GetPercent()
    end,

    onload = function(inst, data)
        inst.percent = data.percent or nil
    end,
}






------------------------------------------------------------------------------------------- 采集(非农作物) --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 可多倍采集的物品定义
local PICKABLE_DEFS = {
    ["cutgrass"] = 10,         -- 草
    ["twigs"] = 10,            -- 树枝
    ["petals"] = 10,           -- 花瓣
    ["lightbulb"] = 10,        -- 荧光果

    ["wormlight_lesser"] = 20, -- 小型发光浆果
    ["cutreeds"] = 20,         -- 芦苇
    ["kelp"] = 20,             -- 海带
    ["carrot"] = 20,           -- 胡萝卜
    ["berries"] = 20,          -- 浆果
    ["berries_juicy"] = 20,    -- 多汁浆果
    ["red_cap"] = 20,          -- 红蘑菇
    ["green_cap"] = 20,
    ["blue_cap"] = 20,
    ["foliage"] = 20,         -- 蕨叶
    ["cactus_meat"] = 20,     -- 仙人掌肉
    ["cutlichen"] = 20,       -- 苔藓

    ["cactus_flower"] = 40,   -- 仙人掌花
    ["petals_evil"] = 40,     -- 恶魔花瓣
    ["wormlight"] = 40,       -- 发光浆果
}


--- 计算倍率
--- 升级到30级大概需要采集400多个草
--- 0级的时候有 10% 概率双倍
local function calcPickMulti(power)
    local lv = math.floor(power.components.ksfun_level:GetLevel() / 30 )

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
    local power = player.components.ksfun_power_system:GetPower(NAMES.PICK)

    -- 处理特殊case，目前支持多汁浆果
    if data.object and data.prefab then
        local exp = PICKABLE_DEFS[data.prefab] or 0
        if exp > 0 then
            KsFunPowerGainExp(player, NAMES.PICK, exp)
            local num = calcPickMulti(power)
            if num> 0 and data.object.components.lootdropper then
                local pt = data.object:GetPosition()
                pt.y = pt.y + (data.object.components.pickable.dropheight or 0)
                for i=1,num * data.num do
                    data.object.components.lootdropper:SpawnLootPrefab(data.prefab, pt)
                end
            end
        end
        return
    end

    -- 正常采集
    local loot = data and data.loot or nil
    if not (power and loot and data.object) then 
        return 
    end

    -- 农作物不支持多倍采集，由其他属性支持
    if data.object:HasTag("farm_plant") then
        return
    end

    --- 单个物品
    if loot.prefab ~= nil then
        local exp = PICKABLE_DEFS[loot.prefab] or 0

        if exp > 0 then
            KsFunPowerGainExp(player, NAMES.PICK, exp)
            -- 根据等级计算可以多倍采集的倍率
            local num = calcPickMulti(power)
            if num > 0 then
                for i = 1, num do
                    local item = SpawnPrefab(loot.prefab)
                    player.components.inventory:GiveItem(item, nil, player:GetPosition())
                end       
            end
        end
    -- 多物品掉落
    elseif not IsTableEmpty(loot) then
        local items = {}
        for i, item in ipairs(loot) do
            local prefab = item.prefab
            local exp = PICKABLE_DEFS[prefab] or 0
            if exp > 0 then
                -- 命中白名单才有多倍
                table.insert(items, prefab)
                KsFunPowerGainExp(player, NAMES.PICK, exp)
            end
        end

        -- 额外掉落物
        local extraloot = {}
        local lootdropper = data.object.components.lootdropper

        for _, prefab in ipairs(lootdropper:GenerateLoot()) do
            -- 白名单才能生成
            if table.contains(items, prefab) then
                -- 每种物品倍率单独计算
                local num = calcPickMulti(player)
                if  num > 0 then
                    for i = 1, num do
                        table.insert(extraloot, lootdropper:SpawnLootPrefab(prefab))
                    end
                end
            end
        end

        -- 给予玩家物品
        for _, item in ipairs(extraloot) do
            player.compowers.inventory:GiveItem(item, nil, player:GetPosition())
        end 
    end
end


local pick = {
    onattach = function(inst, target, name)
        inst.components.ksfun_level:SetMax(300)
        target:ListenForEvent("picksomething", onPickSomeThing)
        target:ListenForEvent("ksfun_picksomething", onPickSomeThing)
    end,

    onstatechange = function(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
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
                local extraloot = {}
                for _, prefab in ipairs(lootdropper:GenerateLoot()) do
                    -- 每种物品倍率单独计算
                    local num = calcFarmPlantMulti(power)
                    if num > 0 then
                        for i = 1, num do
                            table.insert(extraloot, lootdropper:SpawnLootPrefab(prefab))
                        end
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
        inst.components.ksfun_level:SetMax(100)
        target:ListenForEvent("picksomething", onPickFarmPlant)
    end,

    onstatechange = function(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    ondesc = getPowerDesc,
}









---------------------------------------------------------------------------------------------- 伤害倍率 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function updateDamageStatus(inst)
    local combat = inst.target and inst.target.components.combat
    if combat then
        local lv = inst.components.ksfun_level:GetLevel()
        combat.externaldamagetakenmultipliers:SetModifier("ksfun_power", 1 + lv /100)
    end
end

local damage = {
    power = {
        onAttachFunc = function(inst, target, name)
            inst.components.ksfun_level:SetMax(50)
            updateDamageStatus(inst)
        end,

        onGetDescFunc = getPowerDesc,
    },
    level = {
        onLvChangeFunc = updateDamageStatus
    },
}







---------------------------------------------------------------------------------------------- 移动速度 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function updateLocomotorStatus(inst)
    if inst.target and inst.target.components.locomotor then
        local lv = inst.components.ksfun_level:GetLevel()
        local mult = 1 + lv / 100
        inst.target.components.locomotor:SetExternalSpeedMultiplier(inst, "ksfun_power", mult)
    end
end

local locomotor = {
    power = {
        onAttachFunc = function(inst, target, name)
            inst.components.ksfun_level:SetMax(50)
            updateLocomotorStatus(inst)
        end,

        onGetDescFunc = getPowerDesc,

    },
    level = {
        onLvChangeFunc = updateLocomotorStatus
    },
}






---------------------------------------------------------------------------------------------- 暴击 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local critdamage = {
    power = {
        onAttachFunc = function(inst, target, name)
            inst.components.ksfun_level:SetMax(100)
            KsFunHookCaclDamage(inst, target, canHit)
        end,

        onGetDescFunc = getPowerDesc,

    },
    level = {},
}







playerpowers.health       = { data = health }
playerpowers.hunger       = { data = hunger }
playerpowers.sanity       = { data = sanity }
playerpowers.pick         = { data = pick }
playerpowers.farm         = { data = farm }
playerpowers.damage       = { data = damage }
playerpowers.locomotor    = { data = locomotor }
playerpowers.critdamage   = { data = critdamage }


return playerpowers