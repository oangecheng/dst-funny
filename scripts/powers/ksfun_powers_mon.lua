local NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES
local MAXLV = 100


--- 计算属性等级上限，四舍五入
local function calcPowerLvWidthDiffculty(power, defaultlv)
    return defaultlv * KsFunMultiPositive(power.target)
end



--- 设置属性上限
--- @param inst table
--- @param defaultlv number 默认的上限
--- @param max number 部分属性需要有限制，超过上限会出现问题
local function setPowerMaxLv(inst, defaultlv, max)
    local lv =  calcPowerLvWidthDiffculty(inst, defaultlv)
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
    end,
    onstatechange = updateAbsorbStatus,
}







------ 怪物冰爆属性 ----------------------------------------------------------------------------------------
local FREEZABLE_TAGS = { "freezable", "player" }
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

--- 死亡时造成范围冰冻，冰冻范围和效果受等级影响
--- 冰冻范围 [2, 4]
--- 冰冻效果 [1, 2]
local function onDeath(inst)
    local power = inst.components.ksfun_power_system:GetPower(NAMES.ICE_EXPLOSION)
    if power then
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
local sanityaura = {
    onattach = function(inst, target, name)
        if target.components.sanityaura == nil then
            target:AddComponent("sanityaura")
        end
    end,
}





------ 怪物额外真实伤害 ----------------------------------------------------------------------------------------
local function realdamageAttack(attacker, target, _, power)
    if power then
        local lv = power.components.ksfun_level:GetLevel()
        local health = target.components.health
        if health then
            local v = math.max(5, lv * 0.3)
            health:DoDelta(-v, nil, nil, true, nil, true)
        end
    end
end


local realdamage = {
    onattach = function(inst, target)
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        inst.doattack = realdamageAttack
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
    end,
    onstatechange = updateLocomotorStatus,
}





------ 怪物暴击 ----------------------------------------------------------------------------------------
local function critHookCombat(doer, target, _, power)
    if KsFunAttackCanHit(doer, target, 0.3, "mon critdamage") then
        local lv = power.components.ksfun_level:GetLevel()
        return math.min(3, 2 + lv * 0.01)
    end
    return 1
end


local critdamage = {
    onattach = function(inst, target)
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        inst.hookcombat = critHookCombat
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
        local v = math.floor(max * (lv * 0.01) + 0.5)
        v = math.max(1, v) + max
        health:SetMaxHealth(v)
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
local function onKnockback(attacker, target, _, power)
    -- 30% 的概率击退
    local hit = KsFunAttackCanHit(attacker, target, 0.3, "onKnockback")
    if hit and power then
        local lv = power.components.ksfun_level:GetLevel()
        local radius = 0.2 + math.min(0.8, lv * 0.01 )
        target:PushEvent("knockback", {knocker = attacker, radius = radius})
    end
end

local knockback = {
    onattach = function(inst, target)
        inst.doattack = onKnockback
    end
}






------ 怪物攻击掉落物品 ----------------------------------------------------------------------------------------
local function onSteal(attacker, target, _, power)
    -- [20%, 50%] 的概率击落物品
    if power then
        local lv = power.components.ksfun_level:GetLevel()
        local hit = KsFunAttackCanHit(attacker, target, 0.5 + lv * 0.005, "onSteal")
        if hit and attacker.components.thief then
            attacker.components.thief:StealItem(target)
        end
    end
end

local steal = {
    onattach = function(inst, target)
        if target.components.thief == nil then
            target:AddComponent("thief")
        end
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        inst.doattack = onSteal
    end
}







------ 怪物攻击恢复生命值 ----------------------------------------------------------------------------------------
local function onLifeSteal(attacker, _, _, power)
    if power then
        local lv = power.components.ksfun_level:GetLevel()
        if attacker.components.health then
            local v = math.floor(attacker.components.health.maxhealth * lv * 0.005)
            attacker.components.health:DoDelta(math.max(5, v))
        end
    end
end

local lifesteal = {
    onattach = function(inst, target)
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        inst.doattack = onLifeSteal
    end
}





------ 怪物荆棘，反伤 ----------------------------------------------------------------------------------------
--- 伤害移除，不计算护甲
local function onbramble(attacker, target, weapon, power)
    local lv = KsFunGetPowerLv(target, NAMES.BRAMBLE)
    if lv and attacker.components.health then
        local dmg = math.floor(5 + math.floor(0.1 * lv) + 0.5)
        attacker.components.health:DoDelta(-dmg, nil, nil, true, nil, true)
        attacker:PushEvent("thorns")
    end
end

local bramble = {
    onattach = function(inst, target)
        setPowerMaxLv(inst, MAXLV, MAXLV * 2)
        inst.onattacked = onbramble
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
    [NAMES.LIFESTEAL]     = lifesteal,
    [NAMES.BRAMBLE]       = bramble,
}

return monsterpowers