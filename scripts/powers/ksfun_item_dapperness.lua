
local DAPPERNESS_RATIO = TUNING.DAPPERNESS_MED / 3


local forgitems = {}
forgitems["flowerhat"] = 5
forgitems["walrushat"] = 20
forgitems["hivehat"]   = 50


local function updateDapperness(inst)
    local equippable = inst.target and inst.target.components.equippable or nil
    local level = inst.components.ksfun_level
    if equippable and level and inst.origindapperness then
        equippable.dapperness = inst.origindapperness + DAPPERNESS_RATIO * level.lv
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
    local equippable = item.components.equippable
    inst.target = item
    if not inst.origindapperness then
        inst.origindapperness = equippable.dapperness
    end

    updateDapperness(inst)
end


--- 解绑对象
local function onDetachFunc(inst, item, name)
    if inst.origindapperness and inst.components.equippable then
        inst.components.equippable.dapperness = inst.origindapperness
    end
    inst.origindapperness = nil
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
    forgitems = forgitems
}


local ksfundapperness = {}

ksfundapperness.data = {
    power = power,
    level = level,
    forg = forg
}

return ksfundapperness
