


local helper = require("powers/ksfun_power_helper")


local function MakePower(name, data)

    -- 统一绑定target
    local function onAttachFunc(inst, target, name)
        inst.target = target
        if data.power.onAttachFunc then
            data.power.onAttachFunc(inst, target, name)
        end
    end


    -- 统一解绑target
    local function onDetachFunc(inst, target, name)
        if data.power.onDetachFunc then
            data.power.onDetachFunc(inst, target, name)
        end
        inst.target = nil
    end


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
        inst.components.ksfun_power:SetOnAttachFunc(onAttachFunc)
        inst.components.ksfun_power:SetOnDetachFunc(onDetachFunc)
        inst.components.ksfun_power:SetOnGetDescFunc(data.power.onGetDescFunc)
        inst.components.ksfun_power.keepondespawn = true


        inst:ListenForEvent("ksfun_level_changed", function(ent, data)
            if inst.target then
                inst.target.components.ksfun_power_system:SyncData()
            end
        end)


        -- 可升级的
        if data.level then
            inst:AddComponent("ksfun_level")
            inst.components.ksfun_level:SetOnLvChangeFunc(data.level.onLvChangeFunc)

            --- 可突破，用来提升等级上限
            if data.breakable then
                inst:AddComponent("ksfun_breakable")
                inst.components.ksfun_breakable:Enable()
                inst.components.ksfun_breakable:SetOnBreakFunc(data.breakable.onBreakFunc)
            end

            -- 锻造功能，提升属性值
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
-- 物品
for k,v in pairs(KSFUN_TUNING.ITEM_POWER_NAMES) do
    local data = helper.MakeItemPower(v)
    table.insert( powers, MakePower(v, data))
end
-- 玩家
for k,v in pairs(KSFUN_TUNING.PLAYER_POWER_NAMES) do
    local data = helper.MakePlayerPower(v)
    table.insert( powers, MakePower(v, data))
end
-- 怪物
for k,v in pairs(KSFUN_TUNING.MONSTER_POWER_NAMES) do
    local data = helper.MakeMonsterPower(v)
    table.insert( powers, MakePower(v, data))
end


return unpack(powers)