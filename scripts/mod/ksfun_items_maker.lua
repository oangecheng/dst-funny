local ksfunitems = require("defs/ksfun_items_def")


local function addKsFunComponents(inst)
    inst:AddComponent("ksfun_level")
    inst:AddComponent("ksfun_enhantable")
    inst:AddComponent("ksfun_breakable")
    inst:AddComponent("ksfun_power_system")
end


local function initHantable(inst)
    local items = ksfun_items.hantitems[inst.prefab]
    local names = ksfun_items.names[inst.prefab]
    if items and names then
        inst.components.ksfun_enhantable:SetItems(items)
        inst.components.ksfun_enhantable:SetOnEnhantFunc(function(inst)
            local system = inst.components.ksfun_power_system
            system:AddPower(names[1])
        end)
    end
end


local function initBreakable(inst)
    inst.components.ksfun_breakable:SetItems({"goldnugget"})
    inst.components.ksfun_breakable:SetOnBreakFunc(function(ent, item)
        if inst.components.ksfun_level then
            inst.components.ksfun_level:UpMax(1)
        end
    end)
end




local function initLevel(inst)
    inst.components.ksfun_level:SetMax(1)
    local onLvChangeFunc = function(inst, lv, notice)
    end
end


local function MakeKsFunItem(prefab)
    local inst = SpawnPrefab(prefab)
    if inst then
        addKsFunComponents(inst)

        initLevel()
        initBreakable()
        initHantable()
    end

    return inst
end


local maker = {}

maker.MakeKsFunItem = MakeKsFunItem

return maker