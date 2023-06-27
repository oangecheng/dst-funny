local NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES
local monsterpowers = {}


--- 计算属性等级上限，四舍五入
local function calcPowerLvWidthDiffculty(defaultlv)
    return math.floor((1 + KSFUN_TUNING.DIFFCULTY) * defaultlv + 0.5) 
end


--- 计算怪物特殊攻击命中概率
local function canHit(defaultratio)
    local r =  KSFUN_TUNING.DEBUG and 1 or (1 + KSFUN_TUNING.DIFFCULTY) * defaultratio
    return math.random(100) < r * 100
end



--- 设置属性上限
--- @param defaultlv 默认的上限
--- @param max 部分属性需要有限制，超过上限会出现问题
local function setPowerMaxLv(inst, defaultlv, max)
    local lv =  calcPowerLvWidthDiffculty(defaultlv)
    lv = max and math.min(lv, max) or lv
    inst.components.ksfun_level:SetMax(lv)
end






------ 怪物额外减伤 ----------------------------------------------------------------------------------------
local function updateAbsorbStatus(inst)
    local health = inst.target.components.health  
    local lv = inst.components.ksfun_level:GetLevel()
    if health then
        health.externalabsorbmodifiers:SetModifier("ksfun_power", lv * 0.01)
    end
end

local absorb = {
    power = {
        onAttachFunc = function(inst, target, name)
            -- 最多减伤30%，最高难度50%
            setPowerMaxLv(inst, 30, 50)
            updateAbsorbStatus(inst)
        end
    },
    level = {
        onLvChangeFunc = updateAbsorbStatus
    }
}







------ 怪物冰爆属性 ----------------------------------------------------------------------------------------
local FREEZABLE_TAGS = { "freezable" }
local NO_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }

local function doIceExplosion(inst, area, coldness)
    --- 不知道这个效果有没有
    if inst.components.freezable == nil then
        MakeMediumFreezableCharacter(inst, "body")
    end
    inst.components.freezable:SpawnShatterFX()
    inst:RemoveComponent("freezable")

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, area, FREEZABLE_TAGS, NO_TAGS)
    for i, v in pairs(ents) do
        if v.components.freezable ~= nil then
            v.components.freezable:AddColdness(coldness)
        end
    end
    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/icehound_explo")
end

--- 死亡时有20%概率造成范围冰冻，冰冻范围和效果受等级影响
--- 冰冻范围 [2, 4]
--- 冰冻效果 [1, 2]
local function onDeath(inst)
    local power = inst.components.ksfun_power_system:GetPower(NAMES.ICE_EXPLOSION)
    local hit = canHit(0.2)
    if hit and power and power.components.ksfun_power:IsEnable() then
        local lv = power.components.ksfun_level:GetLevel()
        local area = 2 + 2 * lv/10
        local coldness = 1 + lv/10
        doIceExplosion(inst, area, coldness)
    end
end


local iceexplosion = {
    power = {
        onAttachFunc = function(inst, target, name)
            if target.prefab ~= "icehound" then
                target:ListenForEvent("death", onDeath)
                setPowerMaxLv(inst, 10, 20)
            end
        end
    },
    level = {}
}







------ 怪物降智光环增强 ----------------------------------------------------------------------------------------
local delta = TUNING.SANITYAURA_SMALL / 25

local function updateSanityauraStatus(inst)
    local power = inst.components.ksfun_power
    local data  = power:GetData()
    if data and inst.target then
        if inst.target.components.sanityaura then
            local lv = inst.components.ksfun_level:GetLevel()
            inst.target.components.sanityaura.aura = data.aura - lv * delta
        end
    end
end

local sanityaura = {
    power = {
        onAttachFunc = function(inst, target, name)
            if target.components.sanityaura == nil then
                target:AddComponent("sanityaura")
            end
            inst.components.ksfun_power:SetData( {aura = target.components.sanityaura.aura} )
            -- 最高不超过巨鹿
            setPowerMaxLv(inst, 50, 100)
            updateSanityauraStatus(inst)
        end
    },
    level = {
        onLvChangeFunc = updateSanityauraStatus
    }
}





------ 怪物额外真实伤害 ----------------------------------------------------------------------------------------
local function realdamageAttack(attacker, data)
    local power = attacker.components.ksfun_power_system:GetPower(NAMES.REAL_DAMAGE)
    -- 20% 的概率造成属性等级点的额外真实伤害，不计算护甲
    local hit = canHit(0.2)
    if hit and power and data.target then
        local lv = power.components.ksfun_level:GetLevel()
        local health = data.target.components.health
        if health then
            health:DoDelta(-lv, nil, nil, true, nil, true)
        end
    end
end

local realdamage = {
    power = {
        onAttachFunc = function(inst, target, name)
            setPowerMaxLv(inst, 20, 50)
            inst.target:ListenForEvent("onattackother", realdamageAttack)
        end
    },
    level = {}
}





------ 怪物伤害倍率 ----------------------------------------------------------------------------------------
local function updateDamageStatus(inst)
    local combat = inst.target and inst.target.components.combat
    if combat then
        local lv = inst.components.ksfun_level:GetLevel()
        combat.externaldamagetakenmultipliers:SetModifier("ksfun_monster_damage", 1 + lv /100)
    end
end

local damage = {
    power = {
        onAttachFunc = function(inst, target, name)
            -- 默认最大2倍攻击，最大3倍攻击
            setPowerMaxLv(inst, 100, 200)
            updateDamageStatus(inst)
        end,
    },
    level = {
        onLvChangeFunc = updateDamageStatus
    },
}







------ 怪物移动速度 ----------------------------------------------------------------------------------------
local function updateLocomotorStatus(inst)
    if inst.target and inst.target.components.locomotor then
        local lv = inst.components.ksfun_level:GetLevel()
        local mult = 1 + lv / 100
        inst.target.components.locomotor:SetExternalSpeedMultiplier(inst, "ksfun_monster_locomotor", mult)
    end
end

local locomotor = {
    power = {
        onAttachFunc = function(inst, target, name)
            -- 默认最大1.5倍移速，最高2倍移速
            setPowerMaxLv(inst, 50, 100)
            updateLocomotorStatus(inst)
        end,
    },
    level = {
        onLvChangeFunc = updateLocomotorStatus
    },
}





------ 怪物暴击 ----------------------------------------------------------------------------------------
local critdamage = {
    power = {
        onAttachFunc = function(inst, target, name)
            setPowerMaxLv(inst, 100, 200)
            KsFunHookCaclDamage(inst, attacker, canHit)
        end
    },
    level = {},
}





------ 怪物血量提升 ----------------------------------------------------------------------------------------
-- 按照百分比提升
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

local health = {
    power = {
        onAttachFunc = function(inst, target, name)
            local h = target.components.health
            -- 记录原始数据
            inst.components.ksfun_power:SetData({health = h.maxhealth, percent = h:GetPercent()})
            if inst.percent then
                local data = inst.components.ksfun_power:GetData()
                h:SetMaxHealth(data.health)
                h:SetPercent(inst.percent)
            end
            updateHealthStatus(inst)
        end,

        onLoadFunc = function(inst, data)
            inst.percent = data.percent or nil
        end,

        onSaveFunc = function(inst, data)
            data.percent = inst.target.components.health:GetPercent()
        end

    },
    level = {
        onLvChangeFunc = updateHealthStatus
    }
}








monsterpowers.absorb       = { data = absorb } 
monsterpowers.iceexplosion = { data = iceexplosion }
monsterpowers.sanityaura   = { data = sanityaura }
monsterpowers.realdamage   = { data = realdamage }
monsterpowers.damage       = { data = damage }
monsterpowers.locomotor    = { data = locomotor }
monsterpowers.critdamage   = { data = critdamage }
monsterpowers.health       = { data = health }


return monsterpowers