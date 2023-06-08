local forgitems = {
    ["dragon_scales"] = 10
}



local function updatPowerStatus(inst)
    local data = inst.components.ksfun_power:GetData()
    local finiteuses = inst.target and inst.target.components.finiteuses or nil
    if finiteuses and data then
        local lv = inst.components.ksfun_level:GetLevel()
        local percent = finiteuses:GetPercent()
        finiteuses:SetMaxUses(data.maxuses * (lv + 1))
        finiteuses:SetPercent(percent)
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
    if target.components.finiteuses then
        inst.components.ksfun_power:SetData({maxuses = target.components.finiteuses.total})
    end

    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    local data = inst.components.ksfun_power:GetData()
    local finiteuses = target.components.finiteuses
    if finiteuses and data then
        local percent = finiteuses:GetPercent()
        finiteuses:SetMaxUses(data.maxuses)
        finiteuses:SetPercent(percent)
    end
    inst.target = nil
end




local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
    onGetDescFunc= nil,
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
}


local forgable = {
    items = forgitems
}

local p = {}

p.data = {
    power = power,
    level = level,
    forgable = forgable
}


return p