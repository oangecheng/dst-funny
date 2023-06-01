

local NAME = KSFUN_TUNING.COMMON_POWER_NAMES.DAMAGE



local function updatePowerState(inst)
    if inst.target and inst.target.components.combat then
        local lv = inst.components.ksfun_level:GetLevel()
        inst.target.components.combat.externaldamagetakenmultipliers:SetModifier("ksfun_com_damage", 1 + lv /100)
    end
end


--- 升级到下一级所需经验值
--- 统一替换成 (lv+1) * 10
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (self.lv + 1) * 10
end


--- 攻击伤害加深
local function onLvChangeFunc(inst, lv, notice)
    updatePowerState(inst)
    if notice and inst.target then
        inst.target.components.talker:Say("血量提升！")
    end
end


--- 描述
local function onGetDescFunc(inst, target, name)
    local mult = 1 + inst.components.ksfun_level:GetLevel()/100
    local desc = "造成"..mult.."倍伤害"
    return KsFunGeneratePowerDesc(inst, desc)
end


local function setUpMaxLv(inst, target)
    if inst.components.ksfun_level then
        local max = target:HasTag("player") and 25 or 50
        inst.components.ksfun_level:SetMax(max)
    end
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    setUpMaxLv(inst, target)
    updatePowerState(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    target.components.combat.externaldamagetakenmultipliers:RemoveModifier("ksfun_com_damage")
    inst.target = nil
end



local power = {
    onAttachFunc  = onAttachFunc,
    onDetachFunc  = onDetachFunc,
    onGetDescFunc = onGetDescFunc
}

local level = {
    nextLvExpFunc  = nextLvExpFunc,
    onLvChangeFunc = onLvChangeFunc,
}


local p = {}

p.data = {
    power = power,
    level = level,
}


return p