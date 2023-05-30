--- 怪物降智光环，兼容showme显示
local delta = TUNING.SANITYAURA_SMALL / 25

local function updatPowerStatus(inst)
    local power = inst.components.ksfun_power
    local data  = power:GetData()
    if data and inst.target then
        if inst.target.components.sanityaura then
            local lv = inst.components.ksfun_level:GetLevel()
            inst.target.components.sanityaura.aura = data.aura - lv * delta
        end
    end
end


local function onLvChangeFunc(inst, lv, notice)
    updatPowerStatus(inst)
end


--- 升级到下一级所需经验值
--- 怪物的等级都是直接设定的，这里实际没啥用
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (self.lv + 1) * 100
end


local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
    end
end


--- 死亡时有20%概率造成范围冰冻，冰冻范围和效果受等级影响
--- 冰冻范围 [2, 4]
--- 冰冻效果 [1, 2]
local function onDeath(inst)
    local power = inst.components.ksfun_power_system:GetPower(NAME)
    local hit = math.random(100) < (KSFUN_TUNING.DEBUG and 100 or 20)
    if hit and power and power.components.ksfun_power:IsEnable() then
        local lv = power.components.ksfun_level:GetLevel()
        local area = 2 + 2 * lv/10
        local coldness = 1 + lv/10
        doIceExplosion(inst, area, coldness)
    end
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target

    if target.components.sanityaura == nil then
        target:AddComponent("sanityaura")
    end

    local power = inst.components.ksfun_power
    power:SetData( {aura = target.components.sanityaura.aura} )


    -- 最大等级10
    setUpMaxLv(inst, 10)
    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    local data = inst.components.ksfun_power:GetData()
    if data and target.components.sanityaura then
        target.components.sanityaura.aura = data.aura
    end
    inst.target = nil
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
}

local level = {
    nextLvExpFunc = nextLvExpFunc,
    onLvChangeFunc = onLvChangeFunc,
}


local p = {}

p.data = {
    power = power,
    level = level,
}


return p