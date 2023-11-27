local itemsdef = require("defs/ksfun_items_def")


local function enhantTest(inst, doer, item)
    local enhantname = itemsdef.enhantitems[item.prefab]
    local powernames = itemsdef.ksfunitems[inst.prefab].names
    local canEnhant = false

    ---@diagnostic disable-next-line: undefined-field
    if enhantname and table.contains(powernames, enhantname) then
        local system = inst.components.ksfun_power_system
        local level  = inst.components.ksfun_level
        if system and level then
            local powercount = system:GetPowerNum()
            local existed = system:GetPower(enhantname)
            if not existed and powercount >= level:GetLevel() then
                KsFunShowTip(doer, STRINGS.KSFUN_ENHANT_FAIL_1)
            else
                canEnhant = true
            end
        end
    end
    return canEnhant
end


--- 触发附魔机制
--- @param inst table 装备物品
--- @param item table 材料
local function onEnhantFunc(inst, doer, item)
    local enhantname = itemsdef.enhantitems[item.prefab]
    local existed = inst.components.ksfun_power_system:GetPower(enhantname)

    if not existed then
        local ret = inst.components.ksfun_power_system:AddPower(enhantname)
        local username = doer.name or STRINGS.NAMES[string.upper(doer.prefab)] or ""
        local instname = STRINGS.NAMES[string.upper(inst.prefab)]
        local pname    = STRINGS.NAMES[string.upper(ret.prefab)]
        local msg  = string.format(STRINGS.KSFUN_ENHANT_SUCCESS, username, instname, pname)
        KsFunShowNotice(msg)
    else
        local level = existed.components.ksfun_level
        level:DoDelta(1)
    end
end


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
for k,v in pairs(itemsdef.ksfunitems) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("ksfun_item_forever")
        inst:AddComponent("ksfun_activatable")

        inst:AddComponent("ksfun_level")
        inst:AddComponent("ksfun_enhantable")
        inst:AddComponent("ksfun_breakable")
        inst:AddComponent("ksfun_power_system")

        inst.components.ksfun_level:SetOnStateChange(function (inst, d)
            inst.components.ksfun_power_system:SyncData()
        end)

        inst.components.ksfun_activatable:SetOnActivate(function(inst, doer, item)
            inst.components.ksfun_item_forever:Enable()
            inst.components.ksfun_enhantable:Enable()
            inst.components.ksfun_breakable:Enable()
        end)

        inst.components.ksfun_breakable:SetOnStateChange(onBreakChange)
        inst.components.ksfun_breakable:SetBreakTest(onBreakTest)
        
        inst.components.ksfun_enhantable:SetEnhantTest(enhantTest)
        inst.components.ksfun_enhantable:SetOnEnhantFunc(onEnhantFunc)

        local oldLoad = inst.OnLoad
        inst.OnLoad = function(inst, data)
            inst.components.ksfun_power_system:SyncData()
            if oldLoad then
                oldLoad(inst, data)
            end
        end
        
    end)
end    