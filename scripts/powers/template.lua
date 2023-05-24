


local function updatPowerStatus(inst)
    
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
    
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    inst.target = nil
    inst.originSanity = nil
end


local function onBreakFunc(inst, data)
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
    items = nil
}

local breakable = {
    initMaxLv = 10,
    onBreakFunc = onBreakFunc,
}

local power = {}

power.data = {
    power = power,
    level = level,
    forgable = forgable,
    breakable = breakable,
}


return power