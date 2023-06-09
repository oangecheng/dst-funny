

local assets =
{
	Asset("ANIM" , "anim/ksfun_task_reel.zip"),
    Asset("IMAGE", "images/ksfun_task_reel.tex"),
    Asset("ATLAS", "images/ksfun_task_reel.xml"),
}

local taskchain = require("tasks/ksfun_task_chain")


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

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("ksfun_task_demand")
    -- 随机生成一个任务数据
    local taskdata = taskchain.initTaskData()
    KsFunLog("initTaskData", taskdata.name)
    inst.components.ksfun_task_demand:SetDemand(taskdata)

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("tradable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/ksfun_task_reel.xml"

    return inst
end

return Prefab("ksfun_task_reel", fn, assets)
