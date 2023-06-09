
local forgitems = {}
forgitems["largechop_certificate"] = 50
-- 使用黄金斧子测试
if KSFUN_TUNING.DEBUG then
    forgitems["goldenaxe"] = 10
end


local function updatPowerStatus(inst)
    local level = inst.components.ksfun_level
    if inst.target and inst.target.components.tool then
        local lv = level:GetLevel()
        local m = math.max(15 - lv, 1)
        inst.target.components.tool:SetAction(ACTIONS.CHOP, 15/m)
    end
end


--- 监听等级提升
--- @param inst power实例
--- @param lv  等级
local function onLvChangeFunc(inst, lv)
    updatPowerStatus(inst)
end

--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target

    if target.components.tool == nil then
        target:AddComponent("tool")
    end

    if target.components.finiteuses then
        target.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
    end

    -- 15级上限，多升级也没有意义
    inst.components.ksfun_level:SetMax(15)
    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    inst.target = nil
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
}


local forgable = {
    items = forgitems
}

local chop = {}

chop.data = {
    power = power,
    level = level,
    forgable = forgable,
}


return chop