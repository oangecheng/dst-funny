

local assets =
{
	Asset("ANIM" , "anim/ksfun_task_reel.zip"),
    Asset("IMAGE", "images/ksfun_task_reel.tex"),
    Asset("ATLAS", "images/ksfun_task_reel.xml"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)


    inst.AnimState:SetBank("ksfun_task_reel")
    inst.AnimState:SetBuild("ksfun_task_reel")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("ksfun_task")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("ksfun_task_demand")
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("tradable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/ksfun_task_reel.xml"

    -- 任务卷轴2分钟之后自动移除
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("disappear", 120)
    inst:ListenForEvent("timerdone", function(inst, data)
        inst:DoTaskInTime(0, inst:Remove())
    end)

    return inst
end

return Prefab("ksfun_task_reel", fn, assets)
