
local function onLvUpFunc(inst, lv, notice)
    if inst.onLvUpFunc then
        inst.onLvUpFunc(inst, lv, notice)
    end
end


local function onExpChangeFunc(inst, exp)
    if inst.onExpChangeFunc then
        inst.onExpChangeFunc(inst, exp)
    end
end


local function nextLvExpFunc(lv)
    if inst.nextLvExpFunc then
        return inst.nextLvExpFunc(lv)
    end
    return 100 
end



local function MakePower(data)
    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:AddTransform()
        inst.entity:Hide()
        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("ksfun_power")
        inst.components.ksfun_power:SetOnAttachFunc(data.onAttachFunc)
        inst.components.ksfun_power:SetOnDetachFunc(data.onDetachFunc)
        inst.components.ksfun_power:SetOnExtendFunc(data.onExtendFunc)
        inst.components.ksfun_power:SetOnGetDescFun(data.onGetDescFunc)
        inst.components.ksfun_power.keepondespawn = true

        inst:AddComponent("ksfun_level")
        inst.components.ksfun_level:SetLvUpFunc(onLvUpFunc)
        inst.components.ksfun_level:SetExpChangeFunc(onExpChangeFunc)
        inst.components.ksfun_level:SetNextLvExpFunc(nextLvExpFunc)


        if data.duration and data.duration > 0 and data.onTimeDoneFunc then
            inst:AddComponent("timer")
            inst.components.timer:StartTimer("powerover", data.duration)
            inst:ListenForEvent("timerdone", data.onTimeDoneFunc)
        end

        return inst
    end

    return Prefab("ksfun_power_"..data.name, fn, nil, prefabs)
end

local test = require("powers/ksfun_player_health")

MakePower(test.data)