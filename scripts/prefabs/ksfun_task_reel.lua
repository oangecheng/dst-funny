

local assets = {
	Asset("ANIM" , "anim/ksfun_task_reel.zip"),
    Asset("IMAGE", "images/inventoryitems/ksfun_task_reel.tex"),
    Asset("ATLAS", "images/inventoryitems/ksfun_task_reel.xml"),
}

local function onuse(inst, doer, target)
    -- 没有任务系统的不支持
    if doer.components.ksfun_task_system == nil then
        return false
    end
    local taskdata = inst.components.ksfun_task_demand:GetDemand()
    if taskdata then
        local data  = deepcopy(taskdata)
        KsFunBindTaskReel(inst, doer, data)
        return true
    end
    return false
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)


    inst.AnimState:SetBank("ksfun_task_reel")
    inst.AnimState:SetBuild("ksfun_task_reel")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("ksfun_item")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("ksfun_task_demand")
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("ksfun_useable")
    inst.components.ksfun_useable:SetOnUse(onuse)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryitems/ksfun_task_reel.xml"

    -- 任务卷轴2分钟之后自动移除
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("disappear", 120)
    inst:ListenForEvent("timerdone", function(inst, data)
        inst:DoTaskInTime(0, inst:Remove())
    end)

    return inst
end

return Prefab("ksfun_task_reel", fn, assets)
