local itemsdef = require("defs/ksfun_items_def")


local function onBreakTest(inst, doer, item)
    local items = {"opalpreciousgem"}
    ---@diagnostic disable-next-line: undefined-field
    if table.contains(items, item.prefab) then
        return true
    end
    return false
end



--- 物品等级突破，这里突破之后等级也随之提升一级
local function onBreakChange(inst, count, isgod)
    inst.components.ksfun_level:SetLevel(count)
end



--- 给特殊物品添加组件
for k, v in pairs(itemsdef.ksfunitems) do
    AddPrefabPostInit(k, function(inst)

        inst:AddComponent("ksfun_repairable")
        inst:AddComponent("ksfun_level")
        inst:AddComponent("ksfun_enchant")
        inst:AddComponent("ksfun_breakable")
        inst:AddComponent("ksfun_power_system")

        inst.components.ksfun_level:SetOnStateChange(function (inst, d)
            inst.components.ksfun_power_system:SyncData()
        end)

        inst.components.ksfun_breakable:SetOnStateChange(onBreakChange)
        inst.components.ksfun_breakable:SetBreakTest(onBreakTest)

        local oldLoad = inst.OnLoad
        inst.OnLoad = function(inst, data)
            inst.components.ksfun_power_system:SyncData()
            if oldLoad then
                oldLoad(inst, data)
            end
        end
        
    end)
end    