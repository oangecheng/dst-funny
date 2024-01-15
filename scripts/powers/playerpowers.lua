local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local BLUEPRINTS_KEY = "KSFUN_BLUEPRINTS"
local GOD_STEP = 20 


local recipes = require "defs/ksfun_recipes_defs"


---comment 计算等阶
---@param lv integer 等级
---@return integer 当前等阶
local function getGodLv(lv)
    return math.min(math.floor(lv * 0.05) + 1, 6)
end



---comment 执行属性所有的升级函数
---@param fns table 函数列表
---@param power table 属性实体
---@param target table 绑定对象，这里就是玩家
local function updatePowerLvFn(fns, power, target)
    local lv = power.components.ksfun_level:GetLevel()
    local godlv = getGodLv(lv)
    local size  = GetTableSize(fns)
    KsFunLog("onLevelChange", power.prefab, lv, godlv)
    for i = 1, godlv do
        if i <= size then
            local data = fns[i]
            if data then
                data.fn(power, target, lv, data.excuted)
                data.excuted = true
            end
        end
    end
end



---comment 尝试给予蓝图
---@param target table 玩家
---@param name string 属性名
local function tryGiveBlueprint(target, name)
    if name and target then
        local r = KsFunGetPowerData(target, name, BLUEPRINTS_KEY)
        local hit = r and math.random() < r or false
        local drops = recipes[name]
        if hit and drops and target.components.builder and target.components.inventory then
            for k, v in pairs(drops) do
                if not target.components.builder:KnowsRecipe(k) then
                    local item = SpawnPrefab(k.."_blueprint")
                    if item then
                        target.components.inventory:GiveItem(item)
                    end
                end
            end
        end
    end
end




------------------------------------------------------------------------------------------- 精神值 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---comment 精神值一阶，提升精神值上限 
local function sanity1Fn(inst, target, lv, excuted)
    local maxsanity = inst.maxsanity or 100
    local sanity = target.components.sanity
    if sanity then
        local percent = sanity:GetPercent()
        sanity.max = math.floor(maxsanity * (1 + lv * 0.01) + 0.5)
        sanity:SetPercent(percent)
    end
end


---comment 精神值二阶，快速建造，女工科技
local function sanity2Fn(inst, target, lv, excuted)
    KsFunAddTag(target, "handyperson")
    KsFunAddTag(target, "fastbuilder")
    if not excuted then
        target:PushEvent("refreshcrafting")
    end
end


---comment 精神值三阶，读书、制作书，
---等级提升能够降低读书精神消耗，最高减少50%
local function sanity3Fn(inst, target, lv, excuted)
    KsFunAddTag(target, "bookbuilder")
    KsFunAddComponent(target, "reader")
    local reader = target.components.reader
    if reader then
        --缓存下原始值
        inst.pmcache = inst.pmcache or reader:GetSanityPenaltyMultiplier()
        local r = math.max(1 - (lv - 20) * 0.01, 0.5)
        KsFunLog("sanity3", r)
        reader:SetSanityPenaltyMultiplier(inst.pmcache * r)
    end
    if not excuted then
        target:PushEvent("refreshcrafting")
    end
end


---comment 精神值四阶，触发蓝图掉落，等级越高概率越大，最高25%
local function sanity4Fn(inst, target, lv, excuted)
    local ratio = math.min((lv - GOD_STEP * 3) * 0.01, 0.25)
    KsFunSetPowerData(target, NAMES.SANITY,
        BLUEPRINTS_KEY, ratio)
end


---comment 计算负面精神效果翻转
---@param power table 属性
---@return float 倍率
local function negSanityAbsorbFn(power)
    -- 等级一定要实时获取
    local l = power.components.ksfun_level:GetLevel()
    return math.max((l - GOD_STEP * 4) * 0.025,
        TUNING.ARMOR_HIVEHAT_SANITY_ABSORPTION)
end


---comment 精神值五阶，降智光环翻转，效果类似蜂王冠
local function sanity5Fn(inst, target, lv, excuted)
    --- 需要监听蜂王冠的佩戴
    local sanity = target.components.sanity
    sanity.neg_aura_absorb = negSanityAbsorbFn(inst)
    if not excuted then
        target:ListenForEvent("equip", function(_, data)
            if data.item and data.item.prefab == "hivehat" then
                sanity.neg_aura_absorb = TUNING.ARMOR_HIVEHAT_SANITY_ABSORPTION
            end
        end)
        target:ListenForEvent("unequip", function(_, data)
            if data.item and data.item.prefab == "hivehat" then
                sanity.neg_aura_absorb = negSanityAbsorbFn(inst)
            end
        end)
    end
end


---comment 精神值六阶，制作物品材料减半
local function sanity6Fn(inst, target, lv, excuted)
    KsFunAddTag(target, "ksfun_god_"..NAMES.SANITY)
    local builder = target.components.builder
    builder.ingredientmod = .5
    --- 需要监听绿色护符佩戴
    if not excuted then
        target:ListenForEvent("equip", function(_, data)
            if data.item and data.item.prefab == "greenamulet" then
                builder.ingredientmod = .5
            end
        end)
        target:ListenForEvent("unequip", function(_, data)
            if data.item and data.item.prefab == "greenamulet" then
                builder.ingredientmod = .5
            end
        end)
    end
end


local function onBuildFn(player, multiplier)
    local exp = math.random(3, 5) * (multiplier or 1)
    KsFunPowerGainExp(player, NAMES.SANITY, exp)
    tryGiveBlueprint(player, NAMES.SANITY)
end

---comment 精神绑定
local function onSanityAttachFn(inst, target)
    local sanity = target.components.sanity
    inst.sanitymax = sanity and sanity.max or nil
    if inst.percent then
        sanity:SetPercent(inst.percent)
    end

    target:ListenForEvent("builditem", function(player)
        onBuildFn(player, 1)
    end)
    target:ListenForEvent("buildstructure", function(player)
        onBuildFn(player, 2)
    end)
    target:ListenForEvent("unlockrecipe", function(player)
        KsFunPowerGainExp(player, NAMES.SANITY, 20)
    end)
end

local sanityfns = {
    { fn = sanity1Fn,  excuted = false },
    { fn = sanity2Fn,  excuted = false },
    { fn = sanity3Fn,  excuted = false },
    { fn = sanity4Fn,  excuted = false },
    { fn = sanity5Fn,  excuted = false },
    { fn = sanity6Fn,  excuted = false },
}
local sanity = {
    onattach = onSanityAttachFn,
    onstatechange = function (inst, target) updatePowerLvFn(sanityfns, inst, target) end,
    onsave = function (inst, data) data.percent = inst.target and inst.target.components.sanity:GetPercent() end,
    onload = function (inst, data) inst.percent = data.percent or nil end
}






------------------------------------------------------------------------------------------- 饱食度 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---comment 饱食度一阶 增加饱食上限
local function hunger1Fn(power, target, lv, excuted)
    local maxhunger = power.maxhunger or 100
    local hunger = target.components.hunger
    if hunger then
        local percent = hunger:GetPercent()
        hunger.max = math.floor(maxhunger * (1 + 0.01 * lv) + 0.5)
        hunger:SetPercent(percent)
    end
end


---comment 饱食度二阶，增加工作效率
---每级新增1%的饱食度下降,最大不超过25%
---升级可以提升角色的工作效率,无上限
local function hunger2Fn(power, target, lv, excuted)
    local hunger_multi = math.min((lv - 20) * 0.01 + 1, 1.25)
    target.components.hunger.burnratemodifiers:SetModifier("ksfun_power_player_hunger", hunger_multi)
    local workmultiplier = target.components.workmultiplier
    if workmultiplier then
        local work_multi = lv * 0.01 + 1
        workmultiplier:AddMultiplier(ACTIONS.CHOP  , work_multi, power)
        workmultiplier:AddMultiplier(ACTIONS.MINE  , work_multi, power)
        workmultiplier:AddMultiplier(ACTIONS.HAMMER, work_multi, power)
    end
end


---comment 饱食度三阶
---烹饪加速
---晾晒加速
local function hunger3Fn(power, target, lv, excuted)
    local multi = 1 - math.min ((lv - GOD_STEP * 2) * 0.025, 0.5)
    KsFunSetPowerData(target, NAMES.HUNGER, "DRY_MULTI", multi)
    KsFunSetPowerData(target, NAMES.HUNGER, "COOK_MULTI", multi)
end


---comment 饱食度四阶
---加厨师的一堆标签
local function hunger4Fn(power, target, lv, excuted)
    KsFunAddTag(target,"masterchef")--大厨标签
	KsFunAddTag(target,"professionalchef")--调料站
	KsFunAddTag(target,"expertchef")--熟练烹饪标签
    if not excuted then
        target:PushEvent("refreshcrafting")
    end
end


---comment 饱食度五阶, 每次进入夜晚时，当饱食度>60%时，每3s消耗2饱食度转换成1生命值
local function hunger5Fn(power, target, lv, excuted)
    if not excuted then

        local function cancelTask()
            if target.hungertask then
                target.hungertask:Cancel()
                target.hungertask = nil
            end
        end

        target:WatchWorldState("isnight", function (inst, isnight)
            if not isnight then
                cancelTask()
            else
                local health = inst.components.health
                local hunger = inst.components.hunger
                if hunger and health  then
                    local dhunger = (hunger:GetPercent() - 0.6) * hunger.max
                    local dhealth = health:GetMaxWithPenalty() - (health.currenthealth or 0)
                    if dhunger > 0 and dhealth > 0 then
                        local cnt = math.floor(math.min(dhunger * 0.5, dhealth))
                        inst.hungertask = inst:DoPeriodicTask(3, function ()
                            if cnt > 0 then
                                hunger:DoDelta(2)
                                health:DoDelta(1, nil, power.prefab)
                                cnt = cnt - 1
                            else
                                cancelTask()
                            end
                        end)
                    end
                end
            end
        end)
    end
end


---comment 饱食度六阶，制作传说中的厨具
local function hunger6Fn(power, target, lv, excuted)
    KsFunAddTag(target, "ksfun_god_"..NAMES.HUNGER)
end



---comment 计算食物能够获得的经验值
---经验系数 饱食0.2  生命值0.3 精神值0.5
---如果是某一项为负值，此次获得的经验值可能为负数
local function onEat(eater, data)
    local edible = data.food and data.food.components.edible
    if not edible then
        return
    end
    local hungerexp = edible:GetHunger(eater)
    local healthexp = edible:GetHealth(eater)
    local sanityexp = edible:GetSanity(eater)
    local exp = 0.2 * hungerexp + healthexp * 0.3 + sanityexp * 0.5
    KsFunPowerGainExp(eater, NAMES.HUNGER, exp)
end


---comment 饱食绑定
local function onHungerAttachFn(power, target)
    target:ListenForEvent("oneat", onEat)
    local hunger = target.components.hunger
    power.maxhunger = hunger.max
    if power.percent then
        hunger:SetPercent(power.percent)
    end
end

local hungerfns = {
    { fn = hunger1Fn, excuted = false },
    { fn = hunger2Fn, excuted = false },
    { fn = hunger3Fn, excuted = false },
    { fn = hunger4Fn, excuted = false },
    { fn = hunger5Fn, excuted = false },
    { fn = hunger6Fn, excuted = false },

}
local hunger = {
    onattach = onHungerAttachFn,
    onstatechange = function (power, target) updatePowerLvFn(hungerfns, power, target) end,
    onsave = function (inst, data) data.percent = inst.target and inst.target.components.hunger:GetPercent() end,
    onload = function (inst, data) inst.percent = data.percent or nil end
}






------------------------------------------------------------------------------------------- 血量 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---comment 血量一阶，增加血量上限
local function health1Fn(power, target, lv, excuted)
    local maxhealth = power.maxhealth or 100
    local healthcom = target.components.health
    if healthcom then
        local percent = healthcom:GetPercent()
        local max = math.floor(maxhealth * (1 + lv * 0.01) + 0.5)
        KsFunLog("health1Fn", maxhealth, max, percent)
        healthcom.maxhealth = max
        healthcom:SetPercent(percent)
    end
end


---comment 血量二阶，增加防御，增加攻击
local function health2Fn(power, target, lv, excuted)
    local combat = target.components.combat
    if combat then
        local v = math.min((lv - GOD_STEP) * 0.01, 0.25)
        combat.externaldamagemultipliers:SetModifier(power.prefab, v + 1)
        combat.externaldamagetakenmultipliers:SetModifier(power.prefab, 1 - v)
    end
end


---comment 血量三阶，多个减免
---击飞抗性
---吸血抗性
---反伤抗性
---真伤抗性
local function health3Fn(power, target, lv, excuted)
    local v = math.min((lv - GOD_STEP * 2) * 0.05, 1)
    local n = NAMES.HEALTH
    KsFunSetPowerData(target, n, KSFUN_RESISTS.STEAL, v)
    KsFunSetPowerData(target, n, KSFUN_RESISTS.KNOCK, v)
    KsFunSetPowerData(target, n, KSFUN_RESISTS.BRAMBLE, v)
    KsFunSetPowerData(target, n, KSFUN_RESISTS.REALITY, v)
end



---comment 血量四阶
---位面伤害&减伤
---暗影增伤&减伤
local function health4Fn(power, target, lv, excuted)
    KsFunAddTag(target, "player_lunar_aligned")
    KsFunAddTag(target, "player_shadow_aligned")
    local v = math.min((lv - GOD_STEP * 3) * 0.01, 0.2)
    local persist = target.components.damagetyperesist
    if persist then
        persist:AddResist("shadow_aligned", target, 1 - v, power.prefab)
        persist:AddResist("lunar_aligned", target, 1 - v, power.prefab)
    end
    local bouns = target.components.damagetypebonus
    if bouns then
        bouns:AddBonus("lunar_aligned", target, 1 + v, power.prefab)
        bouns:AddBonus("shadow_aligned", target, 1 + v, power.prefab)
    end
end



---comment 血量5阶，僵直抗性
local function health5Fn(power, target, lv, excuted)
    local v = math.min((lv - GOD_STEP * 4) * 0.05, 1)
    KsFunSetPowerData(target, NAMES.HEALTH, KSFUN_RESISTS.STIFF, v)
end




---comment 血量6阶，成神技能
--- 永生，死亡后3s复活
local function health6Fn(power, target, lv, excuted)
    KsFunAddTag(target, "ksfun_god_"..NAMES.HEALTH)

    local function respawnfn(inst)
        if inst.respawntask then
           inst.respawntask:Cancel()
           inst.respawntask = nil
        end
        inst.respawntask = inst:DoTaskInTime(3, function ()
            inst.respawntask = nil
            if inst:HasTag("playerghost") then
                inst:PushEvent("respawnfromghost")
            end
        end)       
    end
    if target:HasTag("playerghost") then
        respawnfn(target)
    end
    if not excuted then
        target:ListenForEvent("ms_becameghost", function (inst)
            respawnfn(inst)
        end)
    end
end




local function onKill(killer, data)
    local victim = data.victim
    if victim and victim.components.health and victim.components.combat then
        -- 所有经验都是10*lv 因此血量也需要计算为1/10
        local exp = math.max(victim.components.health.maxhealth * 0.1, 1)
        KsFunLog("onKill", exp)
        -- 击杀者能够得到满额的经验
        KsFunPowerGainExp(killer, NAMES.HEALTH, exp)
        -- 非击杀者经验值计算，范围10以内其他玩家
        local x, y, z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x, y, z, 10, { "player" })
        if players then
            local players_count = #players
            -- 单人模式经验100%，多人经验获取会减少，最低50%
            local multi = math.max((6 - players_count) * 0.2, 0.5)
            for _, player in ipairs(players) do
                -- 击杀者已经给了经验了
                if player ~= killer then
                    KsFunPowerGainExp(player, NAMES.HEALTH, exp * multi)
                end
            end
        end
    end
end


local function onHealthAttach(power, target)
    target:ListenForEvent("killed", onKill)
    local healthcom = target.components.health
    power.maxhealth = healthcom.maxhealth
    if power.percent then
        healthcom:SetPercent(power.percent)
    end
end

local healthfns = {
    { fn = health1Fn, excuted = false },
    { fn = health2Fn, excuted = false },
    { fn = health3Fn, excuted = false },
    { fn = health4Fn, excuted = false },
    { fn = health5Fn, excuted = false },
    { fn = health6Fn, excuted = false },
}

local health = {
    onattach = onHealthAttach,
    onstatechange = function (power, target) updatePowerLvFn(healthfns, power, target) end,
    onsave = function (inst, data) data.percent = inst.target and inst.target.components.health:GetPercent() end,
    onload = function (inst, data) inst.percent = data.percent or nil end
}




------------------------------------------------------------------------------------------- 采集 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local PICKABLE_DEFS = require("defs/ksfun_prefabs_def").pickable
local PICK_MAX = 5  --最高额外采集数量，比如石果是3，最多能 3+5 = 8


---comment 采集一阶，多倍采集植物
local function pick1fn(power, target, lv, excuted)
    power.plantpick = true
end

---comment 采集二阶，多倍采集农作物
local function pick2fn(power, target, lv, excuted)
    power.farmpick = true 
end


---comment 采集三阶，多倍采集巨大化作物
local function pick3fn(power, target, lv, excuted)
    KsFunAddTag(target,"fastpicker")--快采标签
    power.farmpick_oversized = true
end


---comment 采集四阶，肥料仙人
local function pick4fn(power, target, lv, excuted)
    KsFunAddTag(target, KSFUN_TAGS.FERTILIZER)
    local multi = (lv - GOD_STEP * 2) * 0.05
    KsFunSetPowerData(target, NAMES.PICK, "NUTRIENTS", multi)
end



---comment 采集五阶，获得生命之种的制作配方
local function pick5fn(power, target, lv, excuted)
    KsFunAddTag(target, KSFUN_TAGS.SEEDMAKER)
    if not excuted then
        target:PushEvent("refreshcrafting")
    end
end


---comment 照料的作物全部巨大化
local function pick6fn(power, target, lv, excuted)
    KsFunAddTag(target, "ksfun_god_"..NAMES.PICK)
end


---comment 计算倍率，最高5倍采集
---@param power table 属性
---@param initlv integer 初始等级
---@return integer 额外掉落物，累加计数
local function calcPickMulti(power, initlv)
    local lv = power.components.ksfun_level:GetLevel() - initlv
    lv = math.min(math.floor(lv * 0.05), PICK_MAX)
    local seed = 2 ^ PICK_MAX
    if lv < 1 then
        return math.random() < 0.1 and 1 or 0
    end
    local r = math.random(seed)
    for i = lv, 1, -1 do
        local ratio = seed / (2 ^ i)
        if r <= ratio then
            return i
        end
    end
    return 0
end


local function onPickPlant(player, data, power)
    local obj  = data.object
    local loot = data.loot
    local exp = (PICKABLE_DEFS[obj.prefab] or 0)
    if not (exp > 0 and obj) then 
        return 
    end
    KsFunPowerGainExp(player, NAMES.PICK, exp)

    if not power.plantpick then
        return
    end

    -- 处理特殊case，目前支持多汁浆果
    if data.prefab then
        local num = calcPickMulti(power, 0)
        if num > 0 and obj.components.lootdropper then
            local pt = obj:GetPosition()
            pt.y = pt.y + (obj.components.pickable.dropheight or 0)
            for _ = 1, num * data.num do
                obj.components.lootdropper:SpawnLootPrefab(data.prefab, pt)
            end
        end

    elseif loot then
        --- 单个物品
        if loot.prefab ~= nil then
            -- 根据等级计算可以额外掉落的数量
            local num = calcPickMulti(power, 0)
            if num > 0 then
                for _ = 1, num do
                    local item = SpawnPrefab(loot.prefab)
                    player.components.inventory:GiveItem(item, nil, player:GetPosition())
                end
            end

        -- 多物品掉落(好像没走这个逻辑，确认下是不是农场作物掉落, 暂时保留)
        elseif not IsTableEmpty(loot) then
            -- 额外掉落物
            local extraloot = {}
            local lootdropper = obj.components.lootdropper
            local num = calcPickMulti(power, 0)
            local dropper = lootdropper:GenerateLoot()
            if (not IsTableEmpty(dropper)) and num > 0 then
                for _, prefab in ipairs(dropper) do
                    for i = 1, num do
                        table.insert(extraloot, lootdropper:SpawnLootPrefab(prefab))
                    end
                end
                for i, item in ipairs(extraloot) do
                    player.components.inventory:GiveItem(item, nil, player:GetPosition())
                end
            end
        end

        -- 仙人掌花单独处理
        if obj.has_flower and (obj.prefab == "cactus" or obj.prefab == "oasis_cactus") then
            local n = calcPickMulti(power, 0)
            for i = 1, n do
                local flower = SpawnPrefab("cactus_flower")
                player.components.inventory:GiveItem(flower, nil, player:GetPosition())
            end
        end
    end
end


local function onPickFarmPlant(player, data, power)
    local oversized = data.object.is_oversized
    local exp = oversized and 10 or 5
    KsFunPowerGainExp(player, NAMES.FARM, exp)

    -- 巨大作物需要满足标记
    if oversized and not power.farmpick_oversized then
        return
    end

    local dropper = data.object.components.lootdropper
    -- 额外掉落物
    if dropper and power.farmpick then
        local initlv = oversized and GOD_STEP * 2 or GOD_STEP
        local num = calcPickMulti(power, initlv)
        local loot = dropper:GenerateLoot()
        if num <= 0 or IsTableEmpty(loot) then return end
        local extraloot = {}
        for _, p in ipairs(loot) do
            for i = 1, num do
                table.insert(extraloot, dropper:SpawnLootPrefab(p))
            end
        end
 
         -- 给予玩家物品
        for _, item in ipairs(extraloot) do
            player.components.inventory:GiveItem(item, nil, player:GetPosition())
        end 
    end
end

---comment 采集能够获得经验，等级提升后可以多倍采集
local function onPickSomeThing(player, data)
    local power = player.components.ksfun_power_system:GetPower(NAMES.PICK)
    if power and data and data.object then
        if data.object:HasTag("farm_plant") then
            onPickFarmPlant(player, data, power)
        else
            onPickPlant(player, data, power)
        end
    end
end


local function onPickAttach(power, target)
    target:ListenForEvent("picksomething", onPickSomeThing)
    target:ListenForEvent("ksfun_picksomething", onPickSomeThing)
end


local pickfns = {
    { fn = pick1fn, excuted = false },
    { fn = pick2fn, excuted = false },
    { fn = pick3fn, excuted = false },
    { fn = pick4fn, excuted = false },
    { fn = pick5fn, excuted = false },
    { fn = pick6fn, excuted = false },

}
local pick = {
    onattach = onPickAttach,
    onstatechange = function (power, target) updatePowerLvFn(pickfns, power, target) end,
}



return {
    [NAMES.SANITY] = sanity,
    [NAMES.HUNGER] = hunger,
    [NAMES.HEALTH] = health,
    [NAMES.PICK]   = pick,
}