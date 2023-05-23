local ksfunitems = require("defs/ksfun_items_def")


local function addKsFunComponents(inst)
  
end


local function initHantable(inst)
    local items = ksfunitems.hantitems[inst.prefab]
    local names = ksfunitems.names[inst.prefab]
    if items and names then
        inst.components.ksfun_enhantable:SetItems(items)
        inst.components.ksfun_enhantable:SetOnEnhantFunc(function(inst, item)
            KsFunLog("onEnhant", item.prefab)
            local system = inst.components.ksfun_power_system
            system:AddPower(KSFUN_TUNING.DEBUG and "item_water_proofer" or names[1])
        end)
    end
end


local function initBreakable(inst)
    inst.components.ksfun_breakable:SetItems({"goldnugget"})
    inst.components.ksfun_breakable:SetOnBreakFunc(function(ent, item)
        if inst.components.ksfun_level then
            inst.components.ksfun_level:Up(1)
        end
    end)
end



local function initLevel(inst)
    inst.components.ksfun_level:SetLevel(1)
    local onLvChangeFunc = function(inst, lv, notice)
    end
end


local function MakeKsFunItem(prefab)
    local inst = SpawnPrefab(prefab)
    if inst then
        addKsFunComponents(inst)

        initLevel(inst)
        initBreakable(inst)
        initHantable(inst)
    end

    return inst
end


local maker = {}

maker.MakeKsFunItem = MakeKsFunItem

return maker