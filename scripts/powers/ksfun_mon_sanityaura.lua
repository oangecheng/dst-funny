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


local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
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
    onLvChangeFunc = onLvChangeFunc,
}


local p = {}

p.data = {
    power = power,
    level = level,
}


return p