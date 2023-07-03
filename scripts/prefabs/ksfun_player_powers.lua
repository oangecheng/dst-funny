


local helper = require("powers/ksfun_power_helper")


local function MakePower(name, data)

    -- 统一绑定target
    local function onAttachFunc(inst, target, name)
        inst.target = target
        local func = data.power and data.power.onAttachFunc or data.onattach  
        if func then 
            func(inst, target, name) 
        end
    end


    -- 统一解绑target
    local function onDetachFunc(inst, target, name)
        local func = data.power and data.power.onDetachFunc or data.ondetach  
        if func then 
            func(inst, target, name) 
        end
        inst.target = nil
    end


    local function onGetDescFunc(inst, target, name)
        local func = data.power and data.power.onGetDescFunc or data.ondesc  
        local str = func and func(inst, target, name) or "default"
        return str
    end


    local function onLvChangeFunc(inst, data)
        local func = data.level and data.level.onLvChangeFunc or data.onstatechange
        if data.lv < 0 then
            -- <0 属性失效，移除 
            inst.target:PushEvent(KSFUN_EVENTS.POWER_REMOVE, { name = name })
        elseif func then
            func(inst, data)
        end             
    end


    local function onLoadFunc(inst, d)
        local func = data.power and data.power.onLoadFunc or data.onload
        if func then 
            func(inst, d) 
        end
    end


    local function onSaveFunc(inst, d)
        local func = data.power and data.power.onSaveFunc or data.onsave
        if func then 
            func(inst, d) 
        end
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
        inst.components.ksfun_power:SetOnGetDescFunc(onGetDescFunc)
        inst.components.ksfun_power.keepondespawn = true


        inst:ListenForEvent("ksfun_level_changed", function(ent, data)
            if inst.target then
                inst.target.components.ksfun_power_system:SyncData()
            end
        end)

        inst:AddComponent("ksfun_level")
        inst.components.ksfun_level:SetOnLvChangeFunc(onLvChangeFunc)


        -- 锻造功能，提升属性值
        if data.forgable then
            inst:AddComponent("ksfun_forgable")
            inst.components.ksfun_forgable:SetForgItems(data.forgable.items)
            inst.components.ksfun_forgable:SetOnSuccessFunc(data.forgable.onsuccess)
            if data.forgable.ontest then
                inst.components.ksfun_forgable:SetOnTestFunc(data.forgable.ontest)
            end
        end


        -- 添加临时属性
        if data.duration and data.duration > 0 then
            inst:AddComponent("timer")
            inst.components.timer:StartTimer("powerover", data.duration)
            inst:ListenForEvent("timerdone", function(inst, data)
            end)
        end

        inst.OnLoad = onLoadFunc
        inst.OnSave = onSaveFunc

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