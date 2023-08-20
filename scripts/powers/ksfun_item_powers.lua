--- 不需要format的属性描述可以使用这个
local NAMES = KSFUN_TUNING.ITEM_POWER_NAMES

local function getPowerDesc(inst)
    local extra = KsFunGetPowerDescExtra(inst.prefab)
    return KsFunGetPowerDesc(inst, extra)
end


local function onForgSuccess(inst, doer, item)
    local doername  = doer.name
    local item      = KsFunGetPrefabName(item.prefab)
    local powername = KsFunGetPrefabName(inst.prefab)
    local msg = string.format(STRINGS.KSFUN_FORG_SUCCESS_NOTICE, doername, item, powername)
    KsFunShowNotice(msg)
end



------ 吸血属性 ----------------------------------------------------------------------------------------
local lifestealmax = 100


local function canSteal(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or
                victim:HasTag("structure") or
                victim:HasTag("wall") or
                victim:HasTag("balloon") or
                victim:HasTag("groundspike") or
                victim:HasTag("smashable") or
                victim:HasTag("abigail") or
                victim:HasTag("companion"))
        and victim.components.health ~= nil
end

--- 吸血攻击
local function doLifestealAttack(attacker, victim, _, lifesteal)
    if canSteal(victim) then
        local level  = lifesteal.components.ksfun_level
        local health = attacker and attacker.components.health or nil
        if level and health then
            local delta = math.floor(level:GetLevel() * 0.05 + 1 + 0.5)
            health:DoDelta(delta, false, "ksfun_item_lifesteal")
        end
    end
end


local lifesteal = {
    onattach = function(inst)
        inst.components.ksfun_level:SetMax(lifestealmax)
        inst.doattack = doLifestealAttack
    end,
    ondesc = getPowerDesc,
    forgable = {
        items     = {["mosquitosack"] = 20, ["spidergland"] = 10},
        onsuccess = onForgSuccess,
    },
}



------- 溅射伤害 ----------------------------------------------------------------------------------------
local aoemax = 100

--- aoe需要排除对象的tag
local EXCLUDE_TAGS = {
	"INLIMBO",
	"companion", 
	"wall",
	"abigail", 
}

-- 判断是否为跟随者，比如雇佣的猪哥
local function isFollower(inst, target)
    if inst.components.leader ~= nil then
        return inst.components.leader:IsFollower(target)
    end
    return false
end


--- 获取aoe的具体属性
--- @return number multi，area 倍率 and 范围
local function getAoeProperty(aoepower)
    local level = aoepower.components.ksfun_level
    -- 初始 50% 范围伤害，满级80%
    -- 初始 1.2 范围， 满级3范围
    local lv = level:GetLevel()
    local multi = 0.5 + 0.03 * lv
    local area  = 1.2 + 0.018 * lv
    return multi, area
end


local function onGetAoeDescFunc(inst, _, _ )
    local multi,area = getAoeProperty(inst)
    local desc = string.format(STRINGS.KSFUN_POWER_DESC[string.upper(inst.prefab)], tostring(area), (multi*100).."%")
    return KsFunGetPowerDesc(inst, desc)
end


--- 触发aoe伤害
local function doAoeAttack(attacker, target, weapon, power)
    local lv = power.components.ksfun_level:GetLevel()
    -- 初始 50% 范围伤害，满级80%
    -- 初始 1.2 范围， 满级3范围
    local multi, area = getAoeProperty(power)
    local combat = attacker.components.combat
    local x,y,z = target.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, area, { "_combat" }, EXCLUDE_TAGS)
    for i, ent in ipairs(ents) do
        if ent ~= target and ent ~= attacker and combat:IsValidTarget(ent) and (not isFollower(attacker, ent)) then
            attacker:PushEvent("onareaattackother", { target = ent, weapon = weapon, stimuli = nil })
            local damage = combat:CalcDamage(ent, weapon, 1) * multi
            ent.components.combat:GetAttacked(attacker, damage, weapon, nil)
        end
    end
end


local aoe = {
    onattach = function(inst)
        inst.components.ksfun_level:SetMax(aoemax)
        inst.doattack = doAoeAttack
    end,
    ondesc   = onGetAoeDescFunc,
    forgable = {
        onsuccess = onForgSuccess,
        items     = {["minotaurhorn"] = 1000}, --犀牛角
    }
}



----- 挖矿 ----------------------------------------------------------------------------------------
local minemax = 10
local function updateMineStatus(inst)
    local lv = inst.components.ksfun_level:GetLevel()
    local m = math.max(minemax - lv * 0.1, 1)
    inst.target.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
    local multi = math.floor(minemax/m + 0.5)
    inst.target.components.tool:SetAction(ACTIONS.MINE, multi)
end

local mine = {
    onattach = function(inst, target)
        if target.components.tool == nil then target:AddComponent("tool") end
        inst.components.ksfun_level:SetMax(100)
        updateMineStatus(inst)  
    end,
    ondesc = getPowerDesc,
    onstatechange = updateMineStatus,
    -- 使用大理石或者硝石进行升级
    forgable = {
        items = { ["marble"] = 50, ["nitre"]  = 100, ["flint"] = 10, ["rocks"] = 10},
        onsuccess = onForgSuccess,
    }
}



----- 伐木 ----------------------------------------------------------------------------------------
local chopmax = 15
local function updateChopStatus(inst)
    local lv = inst.components.ksfun_level:GetLevel()
    local m = math.max(chopmax - lv * 0.15, 1)
    inst.target.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
    local multi = math.floor(chopmax/m + 0.5)
    inst.target.components.tool:SetAction(ACTIONS.CHOP, multi)
end

local chop = {
    onattach = function(inst, target)
        if target.components.tool == nil then target:AddComponent("tool") end
        inst.components.ksfun_level:SetMax(100)
        updateChopStatus(inst)  
    end,
    ondesc = getPowerDesc,
    onstatechange = updateChopStatus,
    -- 使用活木升级
    forgable = {
        items = { ["livinglog"] = 50, ["log"] = 10, },
        onsuccess = onForgSuccess,
    }
}




----- 最大使用次数 ----------------------------------------------------------------------------------------
local MAXUSE_KEY = "maxuse"

local function updateMaxusesStatus(inst)
    local oldmax = inst.components.ksfun_power:GetData(MAXUSE_KEY)
    local lv   = inst.components.ksfun_level:GetLevel()

    -- 武器每次提升100的耐久
    local finiteuses = inst.target.components.finiteuses
    if finiteuses and oldmax then
        local percent = finiteuses:GetPercent()
        finiteuses:SetMaxUses(oldmax*(1 + lv * 0.5))
        finiteuses:SetPercent(percent)
    end

    -- 护甲每次提升300的耐久
    local armor = inst.target.components.armor
    if armor and oldmax then
        local percent = armor:GetPercent()
        armor.maxcondition = oldmax * (1 + lv * 0.5)
        armor:SetPercent(percent)
    end
end

local maxuses = {
    onattach = function(inst, target)
        if target.components.armor then
            inst.components.ksfun_power:SaveData(MAXUSE_KEY, target.components.armor.maxcondition)
        end
        if target.components.finiteuses then
            inst.components.ksfun_power:SaveData(MAXUSE_KEY, target.components.finiteuses.total)
        end
        updateMaxusesStatus(inst)
    end,
    onstatechange = updateMaxusesStatus,
    ondesc = getPowerDesc,
    forgable = {
        items = {["dragon_scales"] = 20, }, -- 龙鳞提升耐久
        onsuccess = onForgSuccess,
    }
}




----- 武器基础伤害 ----------------------------------------------------------------------------------------
local DAMAGE_KEY = "damage"
local function updateDamageStatus(inst, l, n)
    local power = inst.components.ksfun_power
    local damage = power:GetData(DAMAGE_KEY) or 0
    if inst.target and inst.target.components.weapon then
        local level = inst.components.ksfun_level:GetLevel()
        inst.target.components.weapon:SetDamage(damage + level)
    end
end

local damage = {
    onattach = function(inst, target)
        if target.components.weapon then
            local d = target.components.weapon.damage
            inst.components.ksfun_power:SaveData(DAMAGE_KEY, d)
            updateDamageStatus(inst)
        end
    end,
    onstatechange = updateDamageStatus,
    ondesc = getPowerDesc,
    forgable = {
        onsuccess = onForgSuccess,
        -- 铥矿棒/狗牙/蜂刺升级
        items = {
            ["ruins_bat"]   = 100,
            ["tentaclespike"] = 10,
            ["houndstooth"] = 1,
            ["stinger"]     = 1,
        }
    }
}





----- 保暖/隔热属性 ----------------------------------------------------------------------------------------
local INSULATION_KEY = "insulation"
local INSULATION_TYPE_KEY = "type"
local INSULATION_SWITCH = "switchable"
local INSULATION_TYPE = "currenttype"


local function getInsulationType(inst)
    local type = inst.components.ksfun_power:GetData(INSULATION_TYPE_KEY)
    local currenttype = inst.components.ksfun_power:GetData(INSULATION_TYPE)
    return currenttype or type or inst.target.components.insulator.type
end

local function updateInsulatorStatus(inst)
    local insulator = inst.target and inst.target.components.insulator or nil
    local lv    = inst.components.ksfun_level:GetLevel()
    local insu  = inst.components.ksfun_power:GetData(INSULATION_KEY)
    inst.target.ksfunswitchable = inst.components.ksfun_power:GetData(INSULATION_SWITCH)
    KsFunLog("updateInsulatorStatus", lv, inst.switchable)
    if insulator then
        insulator:SetInsulation(insu + lv)
        local type = getInsulationType(inst)
        if type == SEASONS.SUMMER then
            insulator:SetSummer()
        elseif type  == SEASONS.WINTER then
            insulator:SetWinter()
        end
    end
end

local function acceptTestFunc(inst, item, giver)
    KsFunLog("acceptTestFunc", inst.ksfunswitchable, item.prefab)
    if inst.ksfunswitchable then
        if item.prefab == "redgem" or item.prefab == "bluegem" then
            return true
        end
    else
        if  item.prefab == "opalpreciousgem" then
            return true
        end
    end
    return false
end

local function onItmeGive(inst, item, giver)
    local power = inst.components.ksfun_power_system:GetPower(NAMES.INSULATOR)
    if power == nil then
        return
    end
    if item.prefab == "opalpreciousgem" then
        power.components.ksfun_power:SaveData(INSULATION_SWITCH, true)
        updateInsulatorStatus(power)
    elseif item.prefab == "redgem" then
        power.components.ksfun_power:SaveData(INSULATION_TYPE, SEASONS.WINTER)
        updateInsulatorStatus(power)
    elseif item.prefab == "bluegem" then
        power.components.ksfun_power:SaveData(INSULATION_TYPE, SEASONS.SUMMER)
        updateInsulatorStatus(power)
    end
end


local insulator = {
    onattach = function(inst, target)
        if target.components.insulator == nil then
            target:AddComponent("insulator")
        end
        local ins, t = target.components.insulator:GetInsulation()
        inst.components.ksfun_power:SaveData(INSULATION_KEY, ins)
        inst.components.ksfun_power:SaveData(INSULATION_TYPE_KEY, t)
        updateInsulatorStatus(inst)
        KsFunAddTrader(target, acceptTestFunc, onItmeGive)
    end,
    ondesc = getPowerDesc,
    onstatechange = updateInsulatorStatus,
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["trunk_winter"] = 100, -- 冬日象鼻
            ["trunk_summer"] = 80, -- 夏日象鼻
            ["silk"] = 2, -- 蜘蛛网
            ["beardhair"] = 5, -- 胡须
            ["goose_feather"] = 10 -- 鹅毛
        }
    },
}




----- 精神恢复 ----------------------------------------------------------------------------------------
local DAPPERNESS_RATIO = TUNING.DAPPERNESS_MED / 3
local DAPPERNESS_KEY = "dapperness"
local function updateDappernessStatus(inst)
    local dapperness = inst.components.ksfun_power:GetData(DAPPERNESS_KEY) or 0
    local equippable = inst.target and inst.target.components.equippable or nil
    local level = inst.components.ksfun_level
    if equippable then
        equippable.dapperness = dapperness + DAPPERNESS_RATIO * level:GetLevel()
    end
end

local dapperness = {
    onattach = function(inst, target)
        local equippable = target.components.equippable
        inst.components.ksfun_power:SaveData(DAPPERNESS_KEY, equippable.dapperness)
        updateDappernessStatus(inst)
    end,
    onstatechange = updateDappernessStatus,
    ondesc = getPowerDesc,
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["spiderhat"] = 2, -- 蜘蛛帽
            ["walrushat"] = 20, -- 海象帽
            ["hivehat"]   = 50,
        }
    }
}





----- 防水 ----------------------------------------------------------------------------------------
local PROOF_EFFECT_KEY = "waterproof"
local function updateWaterproofStatus(inst)
    local waterproofer = inst.target.components.waterproofer
    local effect = inst.components.ksfun_power:GetData(PROOF_EFFECT_KEY) or 0
    local lv     = inst.components.ksfun_level:GetLevel()
    if waterproofer then
        waterproofer:SetEffectiveness(effect + lv * 0.01)
    end
end

local waterproofer = {
    onattach = function(inst, target)
        -- 没有防水组件，添加
        if target.components.waterproofer == nil then
            target:AddComponent("waterproofer")
            target.components.waterproofer:SetEffectiveness(0)
        end
        local effect = target.components.waterproofer:GetEffectiveness()
        inst.components.ksfun_power:SaveData(PROOF_EFFECT_KEY, effect)
        -- 计算最大等级，眼球伞的最大等级就是0，也就是不需要升级的
        -- 眼球伞应该没办法添加防水属性，后面看下怎么加酸雨防护，暂时保留
        local max = math.floor((1 - effect) / 0.01)
        inst.components.ksfun_level:SetMax(max)
        updateWaterproofStatus(inst)
    end,
    onstatechange = updateWaterproofStatus,
    ondesc = getPowerDesc,
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["pigskin"] = 20,
            ["tentaclespots"] = 100
        }
    },
}




------ 移速 ----------------------------------------------------------------------------------------
local SPEED_KEY = "speed"
local speedmax = 100
local function updateSpeedStatus(inst, l, n)
    local speed = inst.components.ksfun_power:GetData(SPEED_KEY) or 1
    local lv = inst.components.ksfun_level:GetLevel()
    if inst.target.components.equippable ~= nil then
        inst.target.components.equippable.walkspeedmult = speed + lv * 0.01
    end
end

local speed = {
    onattach = function(inst, target)
        local equippable = target.components.equippable
        inst.components.ksfun_power:SaveData(SPEED_KEY, equippable:GetWalkSpeedMult())
        inst.components.ksfun_level:SetMax(speedmax)
        updateSpeedStatus(inst)
    end,
    onstatechange = updateSpeedStatus,
    ondesc = getPowerDesc,
    -- 海象牙/步行手杖
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["walrus_tusk"] = 200,
            ["cane"] = 250,
        }
    }    
}





------ 护甲防护 ----------------------------------------------------------------------------------------
local ABSORB_KEY = "absorb"
local function updateAbsorbStatus(inst)
    local armor = inst.target.components.armor
    local absorb = inst.components.ksfun_power:GetData(ABSORB_KEY) or 0
    local lv    = inst.components.ksfun_level:GetLevel()
    if armor then
        armor:SetAbsorption(absorb + lv * 0.01)
    end
end

local absorb = {
    onattach = function(inst, target)
        local absorb = target.components.armor.absorb_percent 
        inst.components.ksfun_power:SaveData(ABSORB_KEY, absorb)
        local max = math.floor(math.max(0.9 - absorb, 0)/0.01 + 0.5)
        inst.components.ksfun_level:SetMax(max)
        updateAbsorbStatus(inst)
    end,
    onstatechange = updateAbsorbStatus,
    ondesc = getPowerDesc,
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["steelwool"] = 10, -- 钢丝绒
        }
    }
}






local itempowers = {
    [NAMES.WATER_PROOFER] = waterproofer,
    [NAMES.DAPPERNESS]    = dapperness,
    [NAMES.INSULATOR]     = insulator,
    [NAMES.DAMAGE]        = damage,
    [NAMES.CHOP]          = chop,
    [NAMES.MINE]          = mine,
    [NAMES.LIFESTEAL]     = lifesteal,
    [NAMES.AOE]           = aoe,
    [NAMES.MAXUSES]       = maxuses,
    [NAMES.SPEED]         = speed,
    [NAMES.ABSORB]        = absorb,
}

return itempowers