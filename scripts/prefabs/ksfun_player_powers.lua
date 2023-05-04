
local function MakePower(data, level)
    local function fn()
        local inst = CreateEntity()
        inst:AddTag("ksfun_power")
        inst:AddTag("ksfun_level")

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
        inst.components.ksfun_level:SetOnLvChangeFunc(level.onLvChangeFunc)
        inst.components.ksfun_level:SetOnStateChangeFunc(level.onStateChangeFunc)
        inst.components.ksfun_level:SetNextLvExpFunc(level.nextLvExpFunc)


        if data.duration and data.duration > 0 and data.onTimeDoneFunc then
            inst:AddComponent("timer")
            inst.components.timer:StartTimer("powerover", data.duration)
            inst:ListenForEvent("timerdone", data.onTimeDoneFunc)
        end

        return inst
    end

    return Prefab("ksfun_power_"..data.name, fn, nil, prefabs)
end

local health = require("powers/ksfun_player_health")
local hunger = require("powers/ksfun_hunger")
local sanity = require("powers/ksfun_sanity")


return MakePower(health.data, health.level),
MakePower(hunger.power, hunger.level),
MakePower(sanity.power, sanity.level)