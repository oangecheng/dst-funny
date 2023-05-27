
local forgitems = {}
forgitems["houndstooth"] = 1
forgitems["stinger"] = 1
forgitems["ruins_bat"] = 10




local function updatPowerStatus(inst)
    local power = inst.components.ksfun_power
    local data  = power:GetData()
    if power:IsEnable() and data then
        local damage = data.damage or 0
        if inst.target and inst.target.components.weapon then
            local level = inst.components.ksfun_level:GetLevel()
            inst.target.components.weapon:SetDamage(damage + level)
        end
    end
end


--- 监听等级提升
--- @param inst power实例
--- @param lv  等级
local function onLvChangeFunc(inst, lv)
    updatPowerStatus(inst)
end


--- 下一级饱食度所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or 20 * (lv + 1)
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target

    if target.components.weapon then
        local d = target.components.weapon.damage
        inst.components.ksfun_power:SetData({ damage = d})
    end

    inst.components.ksfun_power:SetOnEnableChangedFunc(function(enable)
        updatPowerStatus(inst)
    end)

    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    inst.target = nil
end


local function onBreakFunc(inst, data)
    inst.components.ksfun_level:UpMax(10)
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
    nextLvExpFunc = nextLvExpFunc,
}


local forgable = {
    items = forgitems
}

local breakable = {
    initMaxLv = 10,
    onBreakFunc = onBreakFunc,
}

local damage = {}

damage.data = {
    power = power,
    level = level,
    forgable = forgable,
    -- breakable = breakable,
}


return damage
