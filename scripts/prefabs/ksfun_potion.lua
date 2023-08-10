

local assets = {
	Asset("ANIM" , "anim/ksfun_potion.zip"),
    Asset("IMAGE", "images/inventoryitems/ksfun_potion.tex"),
    Asset("ATLAS", "images/inventoryitems/ksfun_potion.xml"),
}

local MAX = 10
local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local prefabsdef = require("defs/ksfun_prefabs_def")


local itemsdef = {
    ["dragonfruit"]   = NAMES.HEALTH,
    ["meat_dried"]    = NAMES.HUNGER,
    ["green_cap"]     = NAMES.SANITY,
    ["berries"]       = NAMES.PICK,
    ["seeds"]         = NAMES.FARM,
    ["cactus_meat"]   = NAMES.LOCOMOTOR,
    ["monstermeat"]   = NAMES.KILL_DROP,
    ["butter"]        = NAMES.LUCKY,
    ["charcoal"]      = NAMES.COOKER,
}


--- 更新客户端魔药显示的名称
local function updateDisplayName(inst)
    if inst.ksfunchangename then
        local name = KsFunGetPrefabName(inst.prefab)
        local lv = inst.components.ksfun_level:GetLevel()
        name = lv..STRINGS.KSFUN_BREAK_COUNT..name
        if inst.power then
            local powername = KsFunGetPowerNameStr(inst.power)
            name = name.."("..powername..")"
        end
        inst.ksfunchangename:set(name)
    end
end


--- 给玩家使用药剂
--- @return boolean success 是否成功使用了药剂
local function usePotionForPlayer(inst, doer, target)
    local system = target.components.ksfun_power_system
    if not (inst.power and system) then
       return false
    end
    local ent = system:GetPower(inst.power)
    -- 还没有拥有，首次是添加该属性
    if ent == nil then
        local scuccess = KsFunAddPlayerPower(target, inst.power)
        -- 成功公屏提示
        if scuccess then
            local p = KsFunGetPowerNameStr(inst.power)
            local msg = string.format(STRINGS.KSFUN_POWER_GAIN_NOTICE, target.name, p)
            KsFunShowNotice(msg)
        end
        return scuccess
    end

    -- 已经拥有了，尝试突破等级上限
    if ent.components.ksfun_breakable then
        local level = ent.components.ksfun_level
        if level and level:IsMax() then
            local cnt = ent.components.ksfun_breakable:GetCount()
            if inst.components.ksfun_level:GetLevel() > cnt then
                ent.components.ksfun_breakable:Break(doer, inst)
                return true
            end 
        end               
    end

    return false
end


--- 给物品使用药剂
--- @return boolean success 是否成功使用了药剂
local function usePotionForItem(inst, doer, target)
    local activatable = target.components.ksfun_activatable
    if (not inst.power) and activatable then
        if activatable:CanActivate() then
            activatable:DoActivate(doer, inst)
            local itemname = KsFunGetPrefabName(target.prefab)
            local msg = string.format(STRINGS.KSFUN_ITEM_ACTIVATE_NOTICE, doer.name, itemname)
            KsFunShowNotice(msg)
            return true
        end
    end
    return false
end


--- 使用药剂
--- @return boolean success 是否成功使用了药剂
local function usePostion(inst, doer, target)
    local used = false
    if target:HasTag("player") then
        used = usePotionForPlayer(inst, doer, target)
    else
        used = usePotionForItem(inst, doer, target)
    end

    if used then
        inst:DoTaskInTime(0, inst:Remove())
    end
    return used   
end



local function onEnhant(inst, doer, item)
    local powername = itemsdef[item.prefab]
    if powername ~= nil then
        inst.power = powername
        updateDisplayName(inst)
        KsFunShowTip(doer, STRINGS.KSFUN_POTION_ENHANT_SUCCESS)
    end
end



local function enhantTest(inst, doer, item)
    if not inst.power then
       return itemsdef[item.prefab] ~= nil
    end
    return false
end



local function onBreak(inst, doer, item)
    local itemlv = prefabsdef.getBreakLv(item.prefab)
    local avalue = doer.components.ksfun_achievements:GetValue()
    if avalue >= 2^itemlv then
        doer.components.ksfun_achievements:DoDelta(-2^itemlv)
        inst.components.ksfun_level:SetLevel(itemlv)
        updateDisplayName(inst)
    end
end


local function breakTest(inst, doer, item)
    local itemlv = prefabsdef.getBreakLv(item.prefab)
    if itemlv == 0 then
        return false
    end
    local lv = inst.components.ksfun_level:GetLevel()
    if lv <= itemlv then
        local avalue = doer.components.ksfun_achievements:GetValue()
        if avalue >= 2^itemlv then
            return true
        end
    end
    return false
end



local function net(inst)
    inst.ksfunchangename = net_string(inst.GUID, "ksfunchangename", "ksfun_itemdirty")
    inst:ListenForEvent("ksfun_itemdirty", function(potion)
        local newname = potion.ksfunchangename:value()
		if newname then
			potion.displaynamefn = function(aaa)
				return newname
			end
		end
	end)
end



local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ksfun_potion")
    inst.AnimState:SetBuild("ksfun_potion")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("CLASSIFIED")
    inst:AddTag("ksfun_item")
    inst.entity:SetPristine()

    net(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")


    inst:AddComponent("ksfun_useable")
    inst.components.ksfun_useable:SetOnUse(usePostion)

    inst:AddComponent("ksfun_level")
    inst.components.ksfun_level:SetMax(10)

    inst:AddComponent("ksfun_enhantable")
    inst.components.ksfun_enhantable:Enable()
    inst.components.ksfun_enhantable:SetEnhantTest(enhantTest)
    inst.components.ksfun_enhantable:SetOnEnhantFunc(onEnhant)

    inst:AddComponent("ksfun_breakable")
    inst.components.ksfun_breakable:Enable()
    inst.components.ksfun_breakable:SetBreakTest(breakTest)
    inst.components.ksfun_breakable:SetOnBreakFunc(onBreak)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryitems/ksfun_potion.xml"

    inst.OnLoad = function(potion, data)
        potion.power = data and data.power or nil
        updateDisplayName(potion)
    end
    inst.OnSave = function(potion, data)
        data.power = potion.power or nil
    end


    return inst
end

return Prefab("ksfun_potion", fn, assets)