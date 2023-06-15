local ITEM_POWER_NAMES = KSFUN_TUNING.ITEM_POWER_NAMES


local assets = {
    Asset("ANIM" , "anim/ksfun_power_gem.zip"),	
}

--- 属性宝石前缀
local prefix = "ksfun_power_gem_"


for k,v in ipairs(ITEM_POWER_NAMES) do
    if v ~= ITEM_POWER_NAMES.AOE then
        table.insert( assets, Asset("ATLAS", "images/inventoryitems/ksfun_power_gem_"..v..".tex"))
        table.insert( assets, Asset("IMAGE", "images/inventoryitems/ksfun_power_gem_"..v..".xml"))
    end
end


local function MakePowerGem(name, lv)
    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
    
        MakeInventoryPhysics(inst)
    
        inst.AnimState:SetBank(prefix)
        inst.AnimState:SetBuild(prefix)
        inst.AnimState:PlayAnimation(name)
    
        inst.entity:SetPristine()
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst:AddComponent("inspectable")

        -- 添加等级组件
        if lv ~= nil then
            inst:AddComponent("ksfun_level")
            inst.components.ksfun_level:SetLevel(lv)
        end


        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryitems/ksfun_power_gem_item_maxuses.xml"
    
        return inst
    end

    return Prefab("ksfun_power_gem_item_maxuses", fn, assets)
end


local gems = {}
for k,v in ipairs(ITEM_POWER_NAMES) do
    if v ~= ITEM_POWER_NAMES.AOE then
        table.insert( gems, MakePowerGem(v))
    end
end


return unpack(gems)







