
local DAPPERNESS_RATIO = TUNING.DAPPERNESS_MED / 3


local HAT_DEFS = {
    "beefalohat",
    "eyebrellahat",
    "walrushat",
}


--- 解锁能力物品定义
local ENABLE_ITEM_DEFS = {
    dapperness = "shadowheart",
    waterproofer = "deerclops_eyeball",
    insulation_win = "bearger_fur",
    insulation_summer = "townportaltalisman"
}


--- 
local DAPPERNESS_ITEM_DEFS = {
    { name = "walrushat", exp = 200},
}



local function cacheOriginData(inst)
    if inst.components.equippable then
        inst.origin_dapperness = inst.components.equippable.dapperness
    end
    if inst.components.insulator then
        if inst.insulator:IsType(SEASONS.WINTER) then
            inst.origin_insulation_w = inst.components.insulator.insulation
        else
            inst.origin_insulation_s = inst.components.insulator.insulation
        end
    end
    if inst.components.waterproofer then
        inst.origin_waterproofer = inst.components.waterproofer:GetEffectiveness()
    end
end


--- 更新物品的精神恢复
local function updateDapperness(inst)
    local equippable = inst.components.equippable
    local clothes = inst.components.ksfun_clothes

    if equippable and clothes and clothes.enable then
        -- 锁定，恢复精神为0
        if clothes:IsLocked() then
            equippable.dapperness = 0
        else
            -- 获取物品精神值的原始值 + 等级增加值
            local origin_v = inst.origin_dapperness or 0
            local delta = clothes.dapperness.lv * DAPPERNESS_RATIO
            equippable.dapperness = origin_v + delta
        end
    end
end


--- 更新物品的保暖/隔热效果
local function updateInsulation(inst)
    local insulator = inst.components.insulator
    local clothes = inst.components.ksfun_clothes
    if insulator and clothes and clothes.enable then
        if clothes:IsLocked() then
            insulator.insulation = 0
        else
            local multi = 20
            if insulator:IsType(SEASONS.WINTER) then
                local origin_v = inst.origin_insulation_w or 0
                insulator.insulation = origin_v + clothes.insulation_win.lv * multi
            else
                local origin_v = inst.origin_insulation_s or 0
                insulator.insulation = origin_v + clothes.insulation_summer.lv * multi
            end
        end
    end
end


-- 更新物品的防水值
local function updateWaterproof(inst)
    local waterproofer = inst.components.waterproofer
    local clothes = inst.components.ksfun_clothes
    if waterproofer and clothes and clothes.enable then
        if clothes:IsLocked() then
            waterproofer:SetEffectiveness(0)
        else
            local origin_v = inst.origin_waterproofer or 0
            local effectiveness = origin_v + clothes.waterproofer.lv * 0.01 
            waterproofer:SetEffectiveness(effectiveness)
        end
    end
end


--- 物品属性变更
local function onStateChangeFunc(inst)
    if inst.components.ksfun_clothes:IsProtected() then
        inst.Remove = function()
            inst.components.Lock(true)
        end
    end
    updateDapperness(inst)
    updateInsulation(inst)
    updateWaterproof(inst)
end


--- 物品锁定
--- @param lock  true or false
local function onClothesLock(lock)
    updateDapperness(inst)
    updateInsulation(inst)
    updateWaterproof(inst)
end





local function onAcceptTest()
end



local function onLevelUpEnabledFunc(inst, ability)
    if ability == 1 then
    elseif ability == 2 then
    elseif ability == 3 then
    elseif ability == 4 then
    end
    
    if inst.components.trader == nil then
        inst:AddComponent("trader")
    end
    if inst.components.ksfun_quality then
        inst.components.ksfun_quality:SetQuality(KSFUN_TUNING.QUALITY.GREEN)
    end    
end


local function onQualityChangeFun(inst)
    if inst.ksfunchangename then
        inst.ksfunchangename:set(true)
    end
end


local function initPrefab(inst)
    inst:AddComponent("ksfun_clothes")
    inst.components.ksfun_clothes.onStateChangeFunc = onStateChangeFunc
    inst.components.ksfun_clothes.onLockFunc = onClothesLock
    inst.components.ksfun_clothes.onLevelUpEnabledFunc = onLevelUpEnabledFunc

    inst:AddComponent("ksfun_quality")
    inst.components.ksfun_quality.onQualityChangeFun = onQualityChangeFun
    inst.ksfunchangename = GLOBAL.net_bool(inst.GUID, "ksfunchangename", "ksfunchangenamedirty")
    inst:ListenForEvent("ksfunchangenamedirty", function(inst)
		if inst.ksfunchangename:value() then
			inst.displaynamefn = function(aaa)
				return subfmt(STRINGS.NAMES["KSFUN_ITEM"], { backpack = STRINGS.NAMES[string.upper(inst.prefab)] }, {num = "绿色"})
			end
		end
	end)


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