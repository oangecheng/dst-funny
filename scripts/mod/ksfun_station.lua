
--- @param doer table
local function canEnhant(doer, target, material)
    local enhantable = target and target.components.ksfun_enhantable
    if enhantable and doer then
        return enhantable:CanEnhant(doer, material)
    end
    return false
end


local function canBreak(doer, target, material)
    local breakable = target and target.components.ksfun_breakable
    if doer and breakable then
        return breakable:CanBreak(doer, material)
    end
    return false
end


local function getCanForgPower(doer, target, material )
    local system = target and target.components.ksfun_power_system
    if system then
        local powers = system:GetAllPowers()
        for k, v in pairs(powers) do
            local forgable = v.components.ksfun_forgable
            if forgable and forgable:CanForg(doer, material) then
                return v
            end
        end
    end
    return nil
end



local function startRefine(inst, doer, callback)
    local duration = 0
    local target   = inst.components.container:GetItemInSlot(1)
    local material = inst.components.container:GetItemInSlot(2)

    if target == nil or material == nil then
        return 0
    end

    local duration = 0

    if canBreak(doer, target, material)  then
        local cnt = target.components.ksfun_breakable:GetCount()
        duration = math.max(60, cnt * KSFUN_TUNING.TIME_SEG)
        target.components.ksfun_breakable:Break(doer, material)
        return duration
    end

    if canEnhant(doer, target, material) then
        duration = 60
        target.components.ksfun_enhantable:Enhant(doer, material)
        return duration
    end
   
    local power = getCanForgPower(doer, target, material)
    if power then
        duration = 5
        power.components.ksfun_forgable:Forg(doer, material)
        return duration
    end

    return 0
end


AddPrefabPostInit("dragonflyfurnace", function(inst)
    if inst.components.container == nil then
        inst:AddComponent("container")
    end
    inst.components.container:WidgetSetup("dragonflyfurnace")
    inst.components.container.onopenfn = nil
    inst.components.container.onclosefn = nil
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    if inst.components.timer == nil then
        inst:AddComponent("timer")
    end

    local function onTimeDone(inst, data)
        inst.components.container.canbeopened = true
    end

    inst:ListenForEvent("timerdone", onTimeDone)

    inst.startWork = function(chest, doer)
        local time = startRefine(chest, doer)
        time = KSFUN_TUNING.DEBUG and 1 or time 
        if  time > 0 then
            chest.components.container:Close(doer)
            chest.components.timer:StartTimer("ksfun_refine", time)
            chest.components.container.canbeopened = false
        end
    end
end)
