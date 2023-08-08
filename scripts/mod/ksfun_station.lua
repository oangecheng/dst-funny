local ksfunitems_def = require("defs/ksfun_items_def")
local POWERS = KSFUN_TUNING.ITEM_POWER_NAMES


local function handKsFunItem(doer, ksfunitem, material)
    --- 尝试附魔，增加额外属性，例如保暖
    if ksfunitem.components.ksfun_enhantable then
        if ksfunitem.components.ksfun_enhantable:Enhant(doer, material) then 
            return true
        end
    end
    --- 尝试突破，提升等级上限，等级1的物品，只能添加一种额外属性，等级2可以添加2种，类推
    if ksfunitem.components.ksfun_breakable then
        if ksfunitem.components.ksfun_breakable:Break(doer, material) then 
            return true
        end
    end

    --- 尝试升级，提示属性值，保暖值可以获得提升
    local system = ksfunitem.components.ksfun_power_system
    if system then
        local powers = system:GetAllPowers()
        for k, v in pairs(powers) do
            local forgable = v.components.ksfun_forgable
            if forgable and forgable:Forg(doer, ksfunitem, material) then
                return true
            end
        end
    end
    
    return false
end


local function onOpen(inst)

end


--- 第一个位置放被强化的物品
--- 第二个位置放强化需要的的材料
--- 强化的顺序一次是  附魔 ——> 突破 ——> 升级
--- 第3个格子放入10个以上的金子且可以放弃当前任务
local function onClose(inst, doer)

    local item1 = inst.components.container:GetItemInSlot(1)
    local item2 = inst.components.container:GetItemInSlot(2)
    local item3 = inst.components.container:GetItemInSlot(3)


    if item1 and item2 and item1.prefab == "ksfun_potion" then
        local enhant = item1.components.ksfun_enhantable:Enhant(doer, item2)
        if not enhant then
            item1.components.ksfun_breakable:Break(doer, item2)
        end
        return
    end


    if item3 and item2 == nil and item1 == nil then
        if item3.prefab == "goldnugget" and item3.components.stackable:StackSize() >= 10 then
            local task = doer.components.ksfun_task_system:GetTask()
            if task then
                task.components.ksfun_task:Lose()
                item3:DoTaskInTime(0, item3:Remove())
                return
            end
        end
    end

    if item1 and item2 then
        ---@diagnostic disable-next-line: undefined-field
        if table.containskey(ksfunitems_def.ksfunitems, item1.prefab) then
            if handKsFunItem(doer, item1, item2) then
                -- doer.components.talker:Say("强化成功！")
            else
                KsFunShowTip(doer, STRINGS.KSFUN_REINFORCE_INVALID_ITEM)
            end
        else
            KsFunShowTip(doer, STRINGS.KSFUN_REINFORCE_INVALID_TARGET)
        end
    end
end



AddPrefabPostInit("dragonflyfurnace", function(inst)
    if inst.components.container == nil then
        inst:AddComponent("container")
    end
    inst.components.container:WidgetSetup("dragonflyfurnace")
    inst.components.container.onopenfn = nil
    inst.components.container.onclosefn = nil
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    if inst.components.timer == nil then
        inst:AddComponent("timer")
    end

    local function onTimeDone(inst, data)
        inst.components.container.canbeopened = true
        if inst.ksfun_refine_doer then
            onClose(inst, inst.ksfun_refine_doer)
        end
    end

    inst:ListenForEvent("timerdone", onTimeDone)

    inst.startWork = function(inst, doer)
        inst.components.container:Close(doer)
        local duration = 10
        inst.components.timer:StartTimer("ksfun_refine", duration)
        inst.ksfun_refine_doer = doer
        inst.components.container.canbeopened = false
    end
end)
