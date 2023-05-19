

local assets = {
    Asset("ANIM", "anim/moonrock_nugget.zip"),
}

local name_prefix = "ksfun_melt_stone_"

local function makeMeltStone(name, lv)
    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
    
        MakeInventoryPhysics(inst)
    
        inst.AnimState:SetRayTestOnBB(true)
        inst.AnimState:SetBank("moonrocknugget")
        inst.AnimState:SetBuild("moonrock_nugget")
        inst.AnimState:PlayAnimation("idle")
    
        inst.entity:SetPristine()
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst:AddComponent("inspectable")
        --- 设置等级
        inst:AddComponent("ksfun_level")
        inst.components.ksfun_level:SetLevel(lv)

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetSinks(true)
    
    
        MakeHauntableLaunchAndSmash(inst)
    
        return inst
    end

    return Prefab(name, fn, assets)
end


--- 熔炼石有十个等级
local stones = {}
for i =1, 10 do
    local lv_str = tostring(i)
    local name = name_prefix..lv_str
    local name_upper = string.upper(name)
    STRINGS.NAMES[name_upper] = lv_str.."级熔炼石"
    table.insert(stones, makeMeltStone(name, i))
end

return unpack(stones)







