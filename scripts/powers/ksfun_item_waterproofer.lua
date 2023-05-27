
local KSFUN_WATER_PROOFER = {}

local forgitems = {}
forgitems["pigskin"] = 20
forgitems["tentaclespots"] = 100


local function updateWaterproof(inst)
    local waterproofer = inst.target and inst.target.components.waterproofer or nil
    local level = inst.components.ksfun_level
    if waterproofer and level and inst.originWaterProofer then
        waterproofer:SetEffectiveness(inst.originWaterProofer + level.lv * 0.01)
    end
end


--- 升级
local function onLvChangeFunc(inst, lv, notice)
    updateWaterproof(inst)
end


--- 下一级防水所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 10 or (20 + lv)
end


--- 绑定对象
local function onAttachFunc(inst, item, name)

    inst.target = item

    -- 没有防水组件，添加
    if item.components.waterproofer == nil then
        item:AddComponent("waterproofer")
        item.components.waterproofer:SetEffectiveness(0)
    end

    

    if not inst.originWaterProofer then
        inst.originWaterProofer = item.components.waterproofer:GetEffectiveness()
    end

    updateWaterproof(inst)
end


--- 解绑对象
local function onDetachFunc(inst, item, name)
    if inst.originWaterProofer and item.components.waterproofer then
        item.components.waterproofer:SetEffectiveness(inst.originWaterProofer)
    end
    inst.originWaterProofer = nil
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


KSFUN_WATER_PROOFER.data = {
    power = power,
    level = level,
    forgable = forg
}

return KSFUN_WATER_PROOFER
