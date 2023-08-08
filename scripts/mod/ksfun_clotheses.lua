
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

-- 给所有物品添加 tradable 组件
if GLOBAL.TheNet:GetIsServer() then
	local items = ENABLE_ITEM_DEFS
	-- 没有添加可交易组件的物品，添加上
	for i=1, #items do
		AddPrefabPostInit(items[i], function(inst) 
			if inst.components.tradable == nil then
				inst:AddComponent("tradable")
			end
		end)
	end
end


--- 
local DAPPERNESS_ITEM_DEFS = {
    "goldnugget",
}



local function cacheOriginData(inst)
    if inst.components.equippable then
        inst.origin_dapperness = inst.components.equippable.dapperness
    end
    if inst.components.insulator then
        if inst.components.insulator:IsType(SEASONS.WINTER) then
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
    end
    updateDapperness(inst)
    updateInsulation(inst)
    updateWaterproof(inst) 
end


--- 物品锁定
--- @param inst  true or false
local function onClothesLock(inst)
    updateDapperness(inst)
    updateInsulation(inst)
    updateWaterproof(inst)
end





local function onAcceptTest(inst, item, giver)
    local clothes = inst.components.ksfun_clothes
    if clothes then
        if clothes:IsLevelUpEnabled(1) then
            if clothes:IsAbilityEnabled(1) then
                ---@diagnostic disable-next-line: undefined-field
                if table.contains(DAPPERNESS_ITEM_DEFS, item.prefab) then
                    return true
                end
            else
                if item.prefab == ENABLE_ITEM_DEFS.dapperness then
                    return true
                end
            end
        end
    end

    return false
end



local function onLevelUpEnabledFunc(inst, ability)
    if ability == 1 then
    elseif ability == 2 then
    elseif ability == 3 then
    elseif ability == 4 then
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

    inst:AddComponent("ksfun_item_quality")
    inst.components.ksfun_item_quality.onQualityChangeFun = onQualityChangeFun
    

    -- 添加可交易组件
    if inst.components.trader == nil then
        inst:AddComponent("trader")
    end
    local oldFunc = inst.components.trader.abletoaccepttest
    inst.components.trader:SetAbleToAcceptTest(function(inst, item, giver)
        return onAcceptTest(inst, item, giver) or (oldFunc and oldFunc(inst, item, giver))
    end)


    -- 存下原始数据
    cacheOriginData(inst)


    local oldLoad = inst.OnLoad
    inst.OnLoad = function(inst)
        onStateChangeFunc(inst)
        if oldLoad then
            oldLoad(inst)
        end
    end
end


local function net(inst)
    inst.ksfunchangename = GLOBAL.net_bool(inst.GUID, "ksfunchangename", "ksfunchangenamedirty")
    inst:ListenForEvent("ksfunchangenamedirty", function(inst)
		if inst.ksfunchangename:value() then
			inst.displaynamefn = function(aaa)
				return subfmt(STRINGS.NAMES["KSFUN_ITEM"], { item = STRINGS.NAMES[string.upper(inst.prefab)], quality = "绿" })
			end
		end
	end)
end


for i,v in ipairs(HAT_DEFS) do
    AddPrefabPostInit(v, function(inst)
        net(inst)
        if GLOBAL.TheNet:GetIsServer() then
            initPrefab(inst)
        end
    end)
 end


