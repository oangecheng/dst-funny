

local NAME = KSFUN_TUNING.COMMON_POWER_NAMES.CRIT_DAMAGE


--- 升级到下一级所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (self.lv + 1) * 100
end


local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
    end
end


--- 暴击倍率随等级提高而提高
--- 最高20%概率2倍暴击
local function hookCalcDamage(inst, attacker)
    if attacker.components.combat == nil then return end
    inst.ksfun_originCalcDamage = attacker.components.combat.CalcDamage
    if inst.ksfun_originCalcDamage then
        attacker.components.combat.CalcDamage = function(targ, weapon, mult)
            local hit    = math.random(100) < (KSFUN_TUNING.DEBUG and 100 or 20)
            local lv     = inst.components.ksfun_level:GetLevel()
            local ratio  = (inst.components.ksfun_power:IsEnable() and hit) and (lv/10 + 1) or 1
            local dmg    = inst.ksfun_originCalcDamage(targ, weapon, mult)
            return dmg * ratio
        end
    end
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    setUpMaxLv(inst, 10)
    hookCalcDamage(inst, target)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    inst.target = nil
    inst.ksfun_originCalcDamage = nil
end



local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
    onGetDescFunc= nil,
}

local level = {
    nextLvExpFunc = nextLvExpFunc,
}


local p = {}

p.data = {
    power = power,
    level = level,
}


return p