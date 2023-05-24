
local forgitems = {}
forgitems["houndstooth"] = 1
forgitems["stinger"] = 1
forgitems["ruins_bat"] = 10





local function updatPowerStatus(inst)
    if inst.target and inst.damage then
        local level = inst.components.ksfun_level:GetLevel()
        inst.target.components.weapon:SetDamage(inst.damage + level)
    end
end


--- 监听等级提升
--- @param inst power实例
--- @param lv  等级
local function onLvChangeFunc(inst, lv)
    updatPowerStatus(inst)
end


--- 等级变更，包括经验值
local function onStateChangeFunc(inst)
    
end


--- 下一级饱食度所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or 20 * (lv + 1)
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    if not inst.damage then
        inst.damage = target.components.weapon.damage
    end
    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    inst.target = nil
    inst.damage = nil
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
    onStateChangeFunc = onStateChangeFunc,
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
