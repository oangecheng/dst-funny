local itemsdef = require("defs/ksfun_items_def")


--- 触发附魔机制
--- @param inst 装备物品
--- @param item 材料
--- @return true 成功 false 失败
local function onEnhantFunc(inst, doer, item)
    KsFunLog("onEnhantFunc", item.prefab)
    local enhantname = itemsdef.enhantitems[item.prefab]
    local powernames = itemsdef.ksfunitems[inst.prefab].names

    if enhantname and table.contains(powernames, enhantname) then
        local system = inst.components.ksfun_power_system
        local level  = inst.components.ksfun_level
        if system and level then
            local powercount = system:GetPowerNum()
            local existed = system:GetPower(enhantname)

            if existed then
                if doer.components.talker then
                    doer.components.talker:Say(STRINGS.KSFUN_ENHANT_FAIL_1)
                end
            -- 判定，装备1级只能附加一个属性，2级2个 ...
            elseif powercount >= level:GetLevel() then
                if doer.components.talker then
                    doer.components.talker:Say(STRINGS.KSFUN_ENHANT_FAIL_2)
                end
            else
                 -- 显示提示
                 local ret = system:AddPower(enhantname)
                 local username = doer.name or STRINGS.NAMES[string.upper(doer.prefab)] or ""
                 local instname = STRINGS.NAMES[string.upper(inst.prefab)]
                 local pname    = STRINGS.NAMES[string.upper(ret.prefab)]
                 local msg  = string.format(STRINGS.KSFUN_ENHANT_SUCCESS, username, instname, pname)
                 KsFunShowNotice(doer, msg)
 
                 if doer.components.talker then
                     doer.components.talker:Say(msg)
                 end
                 return true
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



--- 物品等级突破，这里突破之后等级也随之提升一级
local function onBreakFunc(inst, item)
    KsFunLog("onBreakFunc", item.prefab)
    -- 彩虹宝石可以提升物品的等级上限
    local items = {"opalpreciousgem"}
    if table.contains(items, item.prefab) then
        local level  = inst.components.ksfun_level
        if level then
            KsFunLog("onBreakFunc", level.lv)
            level:UpMax(1)
            level:Up(1)
            return true
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
for k,v in pairs(itemsdef.ksfunitems) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("ksfun_item_forever")
        inst:AddComponent("ksfun_level")
        inst:AddComponent("ksfun_enhantable")
        inst:AddComponent("ksfun_breakable")
        inst:AddComponent("ksfun_power_system")
        
        initLevel(inst)
        initBreakable(inst)
        initEnhantable(inst)

        inst:ListenForEvent("ksfun_level_changed", function(ent, data)
            inst.components.ksfun_power_system:SyncData()
        end)

        local oldLoad = inst.OnLoad
        inst.OnLoad = function(inst, data)
            inst.components.ksfun_power_system:SyncData()
            if oldLoad then
                oldLoad(inst, data)
            end
        end
        
    end)
end    