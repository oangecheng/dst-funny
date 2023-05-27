
local DAPPERNESS_RATIO = TUNING.DAPPERNESS_MED / 3


local forgitems = {}
forgitems["flowerhat"] = 5
forgitems["walrushat"] = 20
forgitems["hivehat"]   = 50


local function updateDapperness(inst)
    local data = inst.components.ksfun_power:GetData()
    local equippable = inst.target and inst.target.components.equippable or nil
    local level = inst.components.ksfun_level
    if equippable and data then
        equippable.dapperness = data.dapperness + DAPPERNESS_RATIO * level:GetLevel()
    end
end


--- 升级
local function onLvChangeFunc(inst, lv, notice)
    updateDapperness(inst)
end


--- 下一级所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 10 or (20 + lv * 20)
end


--- 绑定对象
local function onAttachFunc(inst, item, name)
    inst.target = item
    
    local equippable = item.components.equippable
    inst.components.ksfun_power:SetData({dapperness = equippable.dapperness})

    updateDapperness(inst)
end


--- 解绑对象
local function onDetachFunc(inst, item, name)
    if inst.components.equippable then
        local data = inst.components.ksfun_power:GetData()
        if data and data.dapperness then
            inst.components.equippable.dapperness = data.dapperness
        end
    end
    inst.target = nil
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


local forg = {
    items = forgitems
}


local ksfundapperness = {}

ksfundapperness.data = {
    power = power,
    level = level,
    forgable = forg
}

return ksfundapperness
