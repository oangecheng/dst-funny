

local NAME = KSFUN_TUNING.MONSTER_POWER_NAMES.REAL_DAMAGE


--- 升级到下一级所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (self.lv + 1) * 100
end


local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
    end
end


local function onAttackOther(attacker, data)
    local power = attacker.components.ksfun_power_system:GetPower(NAME)
    -- 20% 的概率造成属性等级点的额外真实伤害，不计算护甲
    local hit = math.random(100) < (KSFUN_TUNING.DEBUG and 100 or 20)
    if hit and power and power.components.ksfun_power:IsEnable() and data.target then
        local lv = power.components.ksfun_level:GetLevel()
        local health = data.target.components.health
        if health then
            health:DoDelta(-lv, nil, nil, true, nil, true)
        end
    end
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    -- { target = targ, weapon = weapon, projectile = projectile, stimuli = stimuli }
    inst.target:ListenForEvent("onattackother", onAttackOther)
    -- 最高造成10点真实伤害
    setUpMaxLv(inst, 10)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    inst.target:RemoveEventCallback("onattackother", onAttackOther)
    inst.target = nil
end


local function onBreakFunc(inst, data)
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