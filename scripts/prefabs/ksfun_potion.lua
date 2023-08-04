

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


local function onused(inst, target)
    if target:HasTag("player") then
        if inst.power and target.components.ksfun_power_system then
            target.components.ksfun_power_system:AddPower(inst.power)
            inst:DoTaskInTime(0, inst:Remove())
        end
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
    inst.components.ksfun_useable:SetOnUse(onused)

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