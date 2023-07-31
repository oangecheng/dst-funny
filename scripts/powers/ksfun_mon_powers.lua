local NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES
local MAXLV = 100


--- 计算属性等级上限，四舍五入
local function calcPowerLvWidthDiffculty(defaultlv)
    return math.floor((1 + KSFUN_TUNING.DIFFCULTY * 0.5) * defaultlv + 0.5) 
end


--- 计算怪物特殊攻击命中概率
local function canHit(defaultratio)
    return KsFunCanHit(false, defaultratio)
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
        health.externalabsorbmodifiers:SetModifier("ksfun_power", lv * 0.003)
    end
end

local absorb = {
    onattach = function(inst)
        -- 最多减伤30%，最高难度60%
        setPowerMaxLv(inst, MAXLV, MAXLV*2)
        updateAbsorbStatus(inst)
    end,
    onstatechange = updateAbsorbStatus
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
    if hit and power then
        local lv = power.components.ksfun_level:GetLevel()
        local area = 2 + 2 * lv * 0.01
        local coldness = 1 + lv * 0.01
        doIceExplosion(inst, area, coldness)
    end
end


local iceexplosion = {
    onattach = function(inst, target)
        if target.prefab ~= "icehound" then
            target:ListenForEvent("death", onDeath)
            setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        end
    end,
}







------ 怪物降智光环增强 ----------------------------------------------------------------------------------------
local delta = TUNING.SANITYAURA_SMALL / 25
local SANITYAURA_KEY = "sanityaura"

local function updateSanityauraStatus(inst)
    local power = inst.components.ksfun_power
    local aura = power:GetData(SANITYAURA_KEY) or 0
    if inst.target then
        if inst.target.components.sanityaura then
            local lv = inst.components.ksfun_level:GetLevel()
            inst.target.components.sanityaura.aura = aura - lv * delta
        end
    end
end

local sanityaura = {
    onattach = function(inst, target, name)
        if target.components.sanityaura == nil then
            target:AddComponent("sanityaura")
        end
        inst.components.ksfun_power:SaveData(SANITYAURA_KEY,target.components.sanityaura.aura)
        -- 最高不超过巨鹿
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        updateSanityauraStatus(inst)
    end,
    onstatechange = updateSanityauraStatus
}





------ 怪物额外真实伤害 ----------------------------------------------------------------------------------------
local function realdamageAttack(attacker, data)
    local power = attacker.components.ksfun_power_system:GetPower(NAMES.REAL_DAMAGE)
    -- 20% 的概率造成属性等级*0.03点的额外真实伤害，不计算护甲
    local hit = canHit(0.2)
    if hit and power and data.target then
        local lv = power.components.ksfun_level:GetLevel()
        local health = data.target.components.health
        if health then
            health:DoDelta(-lv * 0.03, nil, nil, true, nil, true)
        end
    end
end

local realdamage = {
    onattach = function(inst, target)
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        target:ListenForEvent("onattackother", realdamageAttack)
    end,
}





------ 怪物伤害倍率 ----------------------------------------------------------------------------------------
local function updateDamageStatus(inst)
    local combat = inst.target and inst.target.components.combat
    if combat then
        local lv = inst.components.ksfun_level:GetLevel()
        combat.externaldamagemultipliers:SetModifier("ksfun_monster_damage", 1 + lv /100)
    end
end

local damage = {
    onattach = function(inst)
        -- 默认最大2倍攻击，最大3倍攻击
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        updateDamageStatus(inst)
    end,
    onstatechange = updateDamageStatus,
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
    onattach = function(inst)
        -- 默认最大2倍移速，最高3倍移速
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        updateLocomotorStatus(inst)
    end,
    onstatechange = updateLocomotorStatus,
}





------ 怪物暴击 ----------------------------------------------------------------------------------------
local critdamage = {
    onattach = function(inst, target)
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
    end,
}





------ 怪物血量提升 ----------------------------------------------------------------------------------------
local HEALTH_KEY = "maxhealth"
-- 按照百分比提升
local function updateHealthStatus(inst)
    local lv = inst.components.ksfun_level.lv
    local health = inst.target.components.health
    local max = inst.components.ksfun_power:GetData(HEALTH_KEY) or 100
    if health then
        local percent = health:GetPercent()
        health:SetMaxHealth(math.floor(max * (1 + lv * 0.01) + 0.5))
        health:SetPercent(percent)
    end
end

local health = {
    onattach = function(inst, target, name)
        local h = target.components.health
        -- 记录原始数据
        inst.components.ksfun_power:SaveData(HEALTH_KEY, h.maxhealth)
        if inst.percent then
            h:SetMaxHealth(h.maxhealth)
            h:SetPercent(inst.percent)
        end
        updateHealthStatus(inst)
    end,
    onstatechange = updateHealthStatus,
    onload = function(inst, data)
        inst.percent = data.percent or nil
    end,
    onsave = function(inst, data)
        data.percent = inst.target.components.health:GetPercent()
    end
}





------ 怪物击退 ----------------------------------------------------------------------------------------
local function onKnockback(attacker, data)
    local power = attacker.components.ksfun_power_system:GetPower(NAMES.KNOCK_BACK)
    -- 20% 的概率击退
    local hit = canHit(0.2)
    if hit and power and data.target then
        local lv = power.components.ksfun_level:GetLevel()
        local radius = 0.2 + math.min(0.8, lv * 0.01 )
        if data.target:HasTag("player") then
            data.target:PushEvent("knockback", {knocker = attacker, radius = radius})
        end
    end
end

local knockback = {
    onattach = function(inst, target)
        target:ListenForEvent("onattackother", onKnockback)
    end
}






------ 怪物攻击掉落物品 ----------------------------------------------------------------------------------------
local function onSteal(attacker, data)
    local power = attacker.components.ksfun_power_system:GetPower(NAMES.STEAL)
    -- 20% 的概率击落物品
    if power and data.target and data.target:HasTag("player") then
        local lv = power.components.ksfun_power:GetLevel()
        local multi = math.min(2, lv * 0.01 + 1)
        local hit = canHit(0.2 * mult)
        if attacker.components.thief then
            attacker.components.thief:StealItem(data.target)
        end
    end
end

local steal = {
    onattach = function(inst, target)
        if target.components.thief == nil then
            target:AddComponent("thief")
        end
        target:ListenForEvent("onattackother", onSteal)
    end
}







local monsterpowers = {
    [NAMES.ABSORB]        = absorb,
    [NAMES.ICE_EXPLOSION] = iceexplosion,
    [NAMES.SANITY_AURA]   = sanityaura,
    [NAMES.REAL_DAMAGE]   = realdamage,
    [NAMES.DAMAGE]        = damage,
    [NAMES.LOCOMOTOR]     = locomotor,
    [NAMES.CRIT_DAMAGE]   = critdamage,
    [NAMES.HEALTH]        = health,
    [NAMES.KNOCK_BACK]    = knockback,
    [NAMES.STEAL]         = steal,
}

return monsterpowers