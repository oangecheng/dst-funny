


local function MakePower(name, data)

    -- 统一绑定target
    local function onAttachFunc(inst, target, name)
        inst.target = target
        if inst.target and data.onattach then 
            data.onattach(inst, target, name) 
        end
        
        local breakable = inst.components.ksfun_breakable
        if data.onbreak and breakable then
            inst.isgod = breakable:IsMax()
            data.onbreak(inst, breakable:GetCount(), breakable:IsMax())
        end

        -- 首次绑定刷新下状态
        if data.onstatechange then
            data.onstatechange(inst)
        end
    end


    local function onStateChange(inst, lvdelta)
        if inst.target then
            inst.target.components.ksfun_power_system:SyncData()
            if inst.components.ksfun_level:GetLevel() < 0 then
                inst.target:PushEvent(KSFUN_EVENTS.POWER_REMOVE, { name = name })
            else
                if lvdelta and data.onstatechange then
                    -- 等级变更时刷新状态
                    data.onstatechange(inst)
                    KsFunSayPowerNotice(inst.target, inst.prefab)
                end
            end
        end  
    end


    -- 统一解绑target
    local function onDetachFunc(inst, target, name)
        if inst.target and data.ondetach then
            data.ondetach(inst, target, name)
        end
    end

    local function onLoadFunc(inst, d)
        if data.onload then 
            data.onload(inst, d) 
        end
    end


    local function onSaveFunc(inst, d)
        if data.onsave then 
            data.onsave(inst, d) 
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

    
    local function onBreakChange(inst, count, isgod)
        inst.isgod = isgod
        if data.onbreak then
            data.onbreak(inst, count, isgod)
        end
        if inst.target then
            inst.target.components.ksfun_power_system:SyncData()
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
        power.keepondespawn = true

        inst.isgod = false

    
        inst:AddComponent("ksfun_level")
        inst.components.ksfun_level:SetOnStateChange(onStateChange)

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
            inst.components.ksfun_breakable:SetOnStateChange(onBreakChange)
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

local powersdef = MergeMaps(
    require("powers/ksfun_powers_item"),
    require("powers/ksfun_powers_player"),
    require("powers/ksfun_powers_mon"),
    require("powers/ksfun_powers_nega")
)
for k,v in pairs(powersdef) do
    table.insert(powers, MakePower(k, v))
end

return unpack(powers)