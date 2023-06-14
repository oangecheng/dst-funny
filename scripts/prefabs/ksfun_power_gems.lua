

local assets = {
    Asset("ANIM" , "anim/ksfun_power_gem.zip"),	
    Asset("ATLAS", "images/inventoryitems/ksfun_power_gem_item_maxuses.xml"),
    Asset("IMAGE", "images/inventoryitems/ksfun_power_gem_item_maxuses.tex"),
}

local name_prefix = "ksfun_melt_stone_"


local function makeMeltStone(name, lv)
    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
    
        MakeInventoryPhysics(inst)
    
        inst.AnimState:SetBank("ksfun_power_gem")
        inst.AnimState:SetBuild("ksfun_power_gem")
        inst.AnimState:PlayAnimation("item_maxuses")
    
        inst.entity:SetPristine()
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst:AddComponent("inspectable")
        -- --- 设置等级
        -- inst:AddComponent("ksfun_level")
        -- inst.components.ksfun_level:SetLevel(lv)

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryitems/ksfun_power_gem_item_maxuses.xml"
    
        return inst
    end

    return Prefab("ksfun_power_gem_item_maxuses", fn, assets)
end


return makeMeltStone()







