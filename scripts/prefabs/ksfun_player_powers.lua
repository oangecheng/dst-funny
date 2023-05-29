


local helper = require("powers/ksfun_power_helper")


local function MakePower(name, data)

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
        inst.components.ksfun_power:SetOnAttachFunc(data.power.onAttachFunc)
        inst.components.ksfun_power:SetOnDetachFunc(data.power.onDetachFunc)
        inst.components.ksfun_power:SetOnExtendFunc(data.power.onExtendFunc)
        inst.components.ksfun_power:SetOnGetDescFunc(data.power.onGetDescFunc)
        inst.components.ksfun_power.keepondespawn = true


        inst:ListenForEvent("ksfun_level_changed", function(ent, data)
            local target = ent.components.ksfun_power.target
            if target then
                target.components.ksfun_power_system:SyncData()
            end
        end)


        -- 可升级的
        if data.level then
            inst:AddComponent("ksfun_level")
            inst.components.ksfun_level:SetOnLvChangeFunc(data.level.onLvChangeFunc)
            inst.components.ksfun_level:SetOnStateChangeFunc(data.level.onStateChangeFunc)
            inst.components.ksfun_level:SetNextLvExpFunc(data.level.nextLvExpFunc)

            if data.breakable then
                inst:AddComponent("ksfun_breakable")
                -- 有突破组件时，需要设置等级的初始上限
                inst.components.ksfun_level:SetMax(data.breakable.initMaxLv)
                inst.components.ksfun_breakable:Enable()
                inst.components.ksfun_breakable:SetOnBreakFunc(data.breakable.onBreakFunc)
            end

            -- 锻造功能依赖等级
            if data.forgable then
                inst:AddComponent("ksfun_forgable")
                inst.components.ksfun_forgable:SetForgItems(data.forgable.items)
            end
        end


        -- 添加临时属性
        if data.duration and data.duration > 0 then
            inst:AddComponent("timer")
            inst.components.timer:StartTimer("powerover", data.duration)
            inst:ListenForEvent("timerdone", function(inst, data)
            end)
        end

        inst.OnLoad = function(inst, d)
            if data.power.onLoadFunc then
                data.power.onLoadFunc(inst, d)
            end
        end

        inst.OnSave = function(inst, d)
            if data.power.onSaveFunc then
                data.power.onSaveFunc(inst, d)
            end
        end

        return inst
    end

    return Prefab("ksfun_power_"..name, fn, nil, prefabs)
end



local powers = {}
for k,v in pairs(KSFUN_TUNING.ITEM_POWER_NAMES) do
    local data = helper.MakeItemPower(v)
    table.insert( powers, MakePower(v, data))
end


for k,v in pairs(KSFUN_TUNING.PLAYER_POWER_NAMES) do
    local data = helper.MakePlayerPower(v)
    table.insert( powers, MakePower(v, data))
end


for k,v in pairs(KSFUN_TUNING.MONSTER_POWER_NAMES) do
    local data = helper.MakeMonsterPower(v)
    table.insert( powers, MakePower(v, data))
end



return unpack(powers)