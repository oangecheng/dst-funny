local ksfunitems = require("defs/ksfun_items_def")
local POWERS = KSFUN_TUNING.ITEM_POWER_NAMES


local function handKsFunItem(ksfunitem, material)
    --- 尝试附魔，增加额外属性，例如保暖
    if ksfunitem.components.ksfun_enhantable then
        if ksfunitem.components.ksfun_enhantable:Enhant(material) then 
            return true
        end
    end
    --- 尝试突破，提升等级上限，等级1的物品，只能添加一种额外属性，等级2可以添加2种，类推
    if ksfunitem.components.ksfun_breakable then
        if ksfunitem.components.ksfun_breakable:Break(material) then 
            return true
        end
    end

    --- 尝试升级，提示属性值，保暖值可以获得提升
    local system = ksfunitem.components.ksfun_power_system
    if system then
        local powers = system:GetAllPowers()
        for k, v in pairs(powers) do
            local forgable = v.components.ksfun_forgable
            if forgable and forgable:Forg(material) then
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
local function onClose(inst, doer)
    local item1 = inst.components.container:GetItemInSlot(1)
    local item2 = inst.components.container:GetItemInSlot(2)

    if item1 and item2 then
        if table.containskey(ksfunitems.enhantitems, item1.prefab) then
            if handKsFunItem(item1, item2) then
                doer.components.talker:Say("当前材料无法进行强化！")
            end
        else
            doer.components.talker:Say("位置1的物品无法被强化!")
        end
    end
end


AddPrefabPostInit("researchlab", function(inst)
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("researchlab")
    inst.components.container.onopenfn = onOpen
    inst.components.container.onclosefn = onClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
end)
