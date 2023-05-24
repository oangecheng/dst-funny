local ksfunitems = require("defs/ksfun_items_def")


--- 触发附魔机制
--- @param inst 装备物品
--- @param item 材料
--- @return true 成功 false 失败
local function onEnhantFunc(inst, item)
    KsFunLog("onEnhantFunc", item.prefab)
    local items = ksfunitems.enhantitems[inst.prefab]
    local powernames = ksfunitems.powernames[inst.prefab]

    if table.contains(items, item.prefab) then
        local system = inst.components.ksfun_power_system
        local level  = inst.components.ksfun_level
        if level and system then
            local powercount = system:GetPowerNum()
            KsFunLog("onEnhantFunc", powercount, #powernames, level.lv)
            if powercount < #powernames and powercount <= level.lv then
                local name = KsFunRandomPower(inst, powernames, false)
                KsFunLog("onEnhantFunc", name)
                if name ~= nil then
                    system:AddPower(name)
                    return true
                end
            end
        end
    end

    return false
end


--- 给附魔组件添加属性
--- 附魔成功能够给物品添加一条新的属性
local function initEnhantable(inst)
    inst.components.ksfun_enhantable:SetOnEnhantFunc(onEnhantFunc)
end



local function onBreakFunc(inst, item)
    KsFunLog("onBreakFunc", item.prefab)
    local items = {"goldnugget"}
    if table.contains(item.prefab) then
        local level  = inst.components.ksfun_level
        if level then
            KsFunLog("onBreakFunc", level.lv)
            level:UpMax(1)
            level:Up(1)
        end
    end
    return false
end



local function initBreakable(inst)
    inst.components.ksfun_breakable:SetOnBreakFunc(onBreakFunc)
end



local function initLevel(inst)
    inst.components.ksfun_level:SetMax(1)
    inst.components.ksfun_level:SetLevel(1)
end


--- 给特殊物品添加组件
if TheWorld.ismastersim then
    for k,v in pairs(ksfunitems.enhantitems) do
        AddPrefabPostInit(k, function(inst)
            inst:AddComponent("ksfun_level")
            inst:AddComponent("ksfun_enhantable")
            inst:AddComponent("ksfun_breakable")
            inst:AddComponent("ksfun_power_system")
            
            initLevel(inst)
            initBreakable(inst)
            initEnhantable(inst)
            
        end)
    end
end