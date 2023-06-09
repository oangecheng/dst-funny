

local assets = {
    Asset("ANIM" , "anim/ksfun_melt_stone.zip"),	
    Asset("ATLAS", "images/ksfun_melt_stone.xml"),
    Asset("IMAGE", "images/ksfun_melt_stone.tex"),
}

local name_prefix = "ksfun_melt_stone_"

-- forgging stone
local function makeMeltStone(name, lv)
    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
    
        MakeInventoryPhysics(inst)
    
        inst.AnimState:SetBank("ksfun_melt_stone")
        inst.AnimState:SetBuild("ksfun_melt_stone")
        inst.AnimState:PlayAnimation("idle")
    
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
        inst.components.inventoryitem.atlasname = "images/ksfun_melt_stone.xml"
    
        return inst
    end

    return Prefab("ksfun_melt_stone", fn, assets)
end


-- --- 熔炼石有十个等级
-- local stones = {}
-- for i =1, 10 do
--     local lv_str = tostring(i)
--     local name = name_prefix..lv_str
--     local name_upper = string.upper(name)
--     STRINGS.NAMES[name_upper] = lv_str.."级熔炼石"
--     table.insert(stones, makeMeltStone(name, i))
-- end

return makeMeltStone()







