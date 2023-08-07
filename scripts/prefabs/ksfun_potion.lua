

local assets = {
	Asset("ANIM" , "anim/ksfun_potion.zip"),
    Asset("IMAGE", "images/inventoryitems/ksfun_potion.tex"),
    Asset("ATLAS", "images/inventoryitems/ksfun_potion.xml"),
}

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
}


local function updateDisplayName(inst)
    if inst.ksfunchangename then
        local name = KsFunGetPrefabName(inst.prefab)
        local lv = inst.components.ksfun_level:GetLevel()
        name = lv.."阶"..name
        if inst.power then
            local powername = KsFunGetPowerNameStr(inst.power)
            name = name.." "..powername
        end
        inst.ksfunchangename:set(name)
    end
end


local function onuse(inst, doer, target)
    local used = false
    if target:HasTag("player") then
        local system = target.components.ksfun_power_system
        if inst.power and system and system:GetPower(inst.power) == nil then
            system:AddPower(inst.power)
            used = true
        end
    else
        local activatable = target.components.ksfun_activatable
        if (not inst.power) and activatable then
            if activatable:CanActivate() then
                activatable:DoActivate(doer, inst)
                used = true
            end
        end
    end
    if used then
        inst:DoTaskInTime(0, inst:Remove())
    end
    return used   
end



local function onEnhant(inst, doer, item)
    if not inst.power then
        local powername = itemsdef[item.prefab]
        if powername ~= nil then
            inst.power = powername
            updateDisplayName(inst)
            return true
        else
            KsFunShowTip("当前材料无法调制魔药!")
        end
    else
        KsFunShowTip("已经是调制过的魔药了!")
    end
    return false
end



local function onBreak(inst, doer, item)
    local nextlv = inst.components.ksfun_level:GetLevel() + 1
    if nextlv < prefabsdef.getBreakLv(item.prefab) then
        local avalue = inst.components.ksfun_achievements:GetValue()
        if avalue >= 2^nextlv then
            inst.components.ksfun_achievements:DoDelta(-2^nextlv)
            inst.components.ksfun_level:DoDelta(1)
            updateDisplayName(inst)
            return true
        else
            KsFunShowTip(doer, "成就点数不足!")
        end
    else
        KsFunShowTip(doer, "当前材料等级太低!")
    end
    return false
end



local function net(inst)
    inst.ksfunchangename = GLOBAL.net_bool(inst.GUID, "ksfunchangename", "ksfun_itemdirty")
    inst:ListenForEvent("ksfun_itemdirty", function(inst)
        local newname = inst.ksfunchangename:value()
		if newname then
			inst.displaynamefn = function(aaa)
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

    net()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")


    inst:AddComponent("ksfun_useable")
    inst.components.ksfun_useable:SetOnUse(onuse)

    inst:AddComponent("ksfun_level")
    inst.components.ksfun_level:SetMax(10)

    inst:AddComponent("ksfun_enhantable")
    inst.components.ksfun_enhantable:Enable()
    inst.components.ksfun_enhantable:SetOnEnhantFunc(onEnhant)

    inst:AddComponent("ksfun_breakable")
    inst.components.ksfun_breakable:Enable()
    inst.components.ksfun_breakable:SetOnBreakFunc(onBreak)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryitems/ksfun_potion.xml"

    inst.OnLoad = function(inst, data)
        inst.power = data and data.power or nil
    end
    inst.OnSave = function(inst, data)
        data.power = inst.power or nil
    end


    return inst
end

return Prefab("ksfun_potion", fn, assets)