

local assets = {
	Asset("ANIM" , "anim/ksfun_potion.zip"),
    Asset("IMAGE", "images/ksfun_potion.tex"),
    Asset("ATLAS", "images/ksfun_potion.xml"),
}

local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES


local itemsdef = {
    ["butter"]        = NAMES.HEALTH,
    ["meat_dried"]    = NAMES.HUNGER,
    ["nightmarefuel"] = NAMES.SANITY,
    ["berries"]       = NAMES.PICK,
    ["dragonfruit"]   = NAMES.FARM,
}


local function abletoaccepttest(inst, item, giver)
    return inst.power == nil and table.containskey(itemsdef, item.prefab)
end


local function onitemgive(inst, giver, item)
    inst.power = itemsdef[item.prefab]
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
        inst:DoTaskInTime(0, ins:Remove())
    end   
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

    inst:AddTag("ksfun_item")
    inst.entity:SetPristine()

    inst.displaynamefn = function(aaa)
        return "魔法药水"
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(abletoaccepttest)
    inst.components.trader.onaccept = onitemgive

    inst:AddComponent("ksfun_useable")
    inst.components.ksfun_useable:SetOnUse(onuse)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/ksfun_potion.xml"

    inst.OnLoad = function(inst, data)
        inst.power = data.power or nil
    end
    inst.OnSave = function(inst, data)
        data.power = inst.power or nil
    end


    return inst
end

return Prefab("ksfun_potion", fn, assets)