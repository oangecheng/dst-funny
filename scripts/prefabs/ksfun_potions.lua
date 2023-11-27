local PLAYER_POWERS = KSFUN_TUNING.PLAYER_POWER_NAMES


local assets = {
    Asset("ANIM" , "anim/ksfun_potions.zip"),	
}

--- 属性宝石前缀
local prefix = "ksfun_potion_"


for k,v in pairs(PLAYER_POWERS) do
    table.insert( assets, Asset("ATLAS", "images/inventoryitems/ksfun_potion_"..v..".xml"))
    table.insert( assets, Asset("IMAGE", "images/inventoryitems/ksfun_potion_"..v..".tex"))
end


local function onUseFn(doer, potion)
    local system = doer.components.ksfun_power_system
    if not (potion.power and system) then
       return false
    end
    local ent = system:GetPower(potion.power)
    -- 还没有拥有，首次是添加该属性
    if ent == nil then
        if KsFunAddPlayerPower(doer, potion.power) then
            local p = KsFunGetPowerNameStr(potion.power)
            local msg = string.format(STRINGS.KSFUN_POWER_GAIN_NOTICE, doer.name, p)
            KsFunShowNotice(msg)
            return true
        end
    else
        local level = ent.components.ksfun_level
        if level and not level:IsMax() then
            level:DoDelta(1)
            KsFunLog("power up", potion.power)
            return true
        end
    end
    return false
end


local function MakePotion(name)

    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:SetPristine()

        MakeInventoryPhysics(inst)
    
        inst.AnimState:SetBank("ksfun_potion")
        inst.AnimState:SetBuild("ksfun_potion")
        inst.AnimState:PlayAnimation(name)
    
        inst:AddTag("ksfun_potion")
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst:AddComponent("ksfun_level")
        inst.components.ksfun_level:SetLevel(1)
        inst.usefn = onUseFn
        inst.power = name

        inst:AddComponent("inspectable")
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITE
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryitems/ksfun_potion_"..name..".xml"
    
        return inst
    end

    return Prefab(prefix..name, fn, assets)
end


local gems = {}
for k,v in pairs(PLAYER_POWERS) do
    table.insert(gems, MakePotion(v))
end
return unpack(gems)







