


local helper = require("powers/ksfun_power_helper")


local function MakePower(name, data)

    -- 统一绑定target
    local function onAttachFunc(inst, target, name)
        inst.target = target
        if data.onattach then 
            data.onattach(inst, target, name) 
        end
    end


    -- 统一解绑target
    local function onDetachFunc(inst, target, name)
        if inst.target == nil then return end
        local func = data.ondetach  
        if func then 
            func(inst, target, name) 
        end
    end


    local function onGetDescFunc(inst, target, name)
        if inst.target == nil then return end
        local func = data.ondesc  
        local str = func and func(inst, target, name) or "default"
        return str
    end


    local function onLvChangeFunc(inst, d)
        if inst.target == nil then return end
        local func = data.onstatechange
        if d.lv < 0 then
            -- <0 属性失效，移除 
            inst.target:PushEvent(KSFUN_EVENTS.POWER_REMOVE, { name = name })
        elseif func then
            func(inst, d)
        end             
    end


    local function onLoadFunc(inst, d)
        local func=  data.onload
        if func then 
            func(inst, d) 
        end
    end


    local function onSaveFunc(inst, d)
        local func = data.onsave
        if func then 
            func(inst, d) 
        end
    end


    local function onExtendFunc(inst, target, name)
        if inst.target == nil then return end
        local timer = inst.components.timer
        if timer and data.duration then
            timer:StopTimer("ksfun_power_over")
            timer:StartTimer("ksfun_power_over", data.duration)
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

        local power = inst:AddComponent("ksfun_power")
        power:SetOnAttachFunc(onAttachFunc)
        power:SetOnDetachFunc(onDetachFunc)
        power:SetOnExtendFunc(onExtendFunc)
        power:SetOnGetDescFunc(onGetDescFunc)
        power.keepondespawn = true

        inst.isgod = false

    
        inst:AddComponent("ksfun_level")
        inst.components.ksfun_level:SetOnLvChangeFunc(onLvChangeFunc)
        inst:ListenForEvent("ksfun_level_changed", function(p, d)
            if inst.target then
                inst.target.components.ksfun_power_system:SyncData()
            end
        end)


        -- 锻造功能，提升属性值
        if data.forgable then
            inst:AddComponent("ksfun_forgable")
            inst.components.ksfun_forgable:SetForgItems(data.forgable.items)
            inst.components.ksfun_forgable:SetOnForg(data.forgable.onsuccess)
            if data.forgable.ontest then
                inst.components.ksfun_forgable:SetForgTest(data.forgable.ontest)
            end
        end


        if data.onbreak then
            inst:AddComponent("ksfun_breakable")
            inst.components.ksfun_breakable:Enable()
            inst.components.ksfun_breakable:SetOnStateChange(function(p, count, isgod)
                if data.onbreak then
                    data.onbreak(p, count, isgod)
                end
                if inst.target then
                    inst.target.components.ksfun_power_system:SyncData()
                end
            end)
        end


        -- 添加临时属性
        if data.duration and data.duration > 0 then
            inst.components.ksfun_power:SetTemp()
            inst:AddComponent("timer")
            inst.components.timer:StartTimer("ksfun_power_over", data.duration)
            inst:ListenForEvent("timerdone", function(p, _)
                local pname = p.components.ksfun_power:GetName()
                p.target:PushEvent(KSFUN_EVENTS.POWER_REMOVE, { name = pname })
            end)
        end

        inst.OnLoad = onLoadFunc
        inst.OnSave = onSaveFunc

        return inst
    end

    return Prefab("ksfun_power_"..name, fn, nil, nil)
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

-- 负面属性
for k,v in pairs(KSFUN_TUNING.NEGA_POWER_NAMES) do
    local data = helper.MakeNegaPower(v)
    table.insert(powers, MakePower(v, data))
end


return unpack(powers)