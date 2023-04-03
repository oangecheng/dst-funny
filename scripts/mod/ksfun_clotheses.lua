local HAT_DEFS = {
    "beefalohat",
    "eyebrellahat",
    "walrushat",
}

local DAPPERNESS_RATIO = TUNING.DAPPERNESS_MED / 3


local function  cacheOriginData(inst)
    local ksfun_clothes = inst.components.ksfun_clothes
    -- 脑残
    ksfun_clothes.origin_dapperness = 0
    if inst.componenst.equippable then
        ksfun_clothes.origin_dapperness = inst.components.equippable.dapperness
    else
    -- 保暖
    ksfun_clothes.origin_insulation_w = 0
    ksfun_clothes.origin_insulation_s = 0
    if inst.components.insulator then
        local ins = inst.components.insulator.insulation
        local is_summer = inst.components.insulator:IsType(SEASONS.SUMMER)
        ksfun_clothes.origin_insulation_w = is_summer and 0 or ins
        ksfun_clothes.origin_insulation_s = is_summer and ins or 0   
    end
    -- 防水
    ksfun_clothes.origin_waterproofer = 0
    if inst.components.waterproofer then
        ksfun_clothes.origin_waterproofer = inst.components.waterproofer:GetEffectiveness()
    else
end


local function updateDapperness(inst)
    local equippable = inst.componenst.equippable
    local ksfun_clothes = inst.components.ksfun_clothes
    if not (equippable and ksfun_clothes.dapperness.enable) then return end
    -- 更新属性
    if ksfun_clothes.locked then
        equippable.dapperness = 0
    else
        local d = ksfun_clothes.dapperness.lv * DAPPERNESS_RATIO
        equippable.dapperness = ksfun_clothes.origin_dapperness + d
    end
end


local function updateClothesState(inst)
    if inst.components.ksfun_clothes:IsProtected() then
        inst.Remove = function()
            inst.components.Lock(true)
        end
    end
    updateDapperness(inst)
end




local function initPrefab(inst)
    inst:AddComponent("ksfun_clothes")
    inst.components.ksfun_clothes.onStateChangeFunc = updateClothesState

    -- 存下原始数据
    cacheOriginData(inst)


    local oldLoad = inst.OnLoad
    inst.OnLoad = function(inst)
        updateClothesState(inst)
        if oldLoad then
            oldLoad(inst)
        end
    end
end


if TheWorld.ismastersim then
    for i,v in ipairs(HAT_DEFS) do
        AddPrefabPostInit(v, initPrefab)
    end
end