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
    KsFunAddTag(target, "ksfun_god"..NAMES.SANITY)
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
---加厨师的一堆标签
---烹饪加速
local function hunger3Fn(power, target, lv, excuted)
    KsFunAddTag(target,"masterchef")--大厨标签
	KsFunAddTag(target,"professionalchef")--调料站
	KsFunAddTag(target,"expertchef")--熟练烹饪标签
end



local function hunger4Fn(power, target, lv, excuted)
    
    
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
}
local hunger = {
    onattach = onHungerAttachFn,
    onstatechange = function (power, target) updatePowerLvFn(hungerfns, power, target) end,
    onsave = function (inst, data) data.percent = inst.target and inst.target.components.hunger:GetPercent() end,
    onload = function (inst, data) inst.percent = data.percent or nil end
}


return {
    [NAMES.SANITY] = sanity,
    [NAMES.HUNGER] = hunger,
}