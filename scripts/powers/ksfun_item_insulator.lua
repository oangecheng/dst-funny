local NAME = KSFUN_TUNING.ITEM_POWER_NAMES.INSULATOR

local forgitems = {}
forgitems["trunk_winter"] = 20
forgitems["trunk_summer"] = 20
forgitems["silk"] = 1
forgitems["beardhair"] = 5


-- 紫宝石切换模式
local switchitem = "purplegem"


local function updateInsulation(inst)
    local insulator = inst.target and inst.target.components.insulator or nil
    local level = inst.components.ksfun_level
    if insulator then
        insulator:SetInsulation(inst.origininsulation + level.lv)
        local type = inst.type or inst.origintype or insulator.type
        if type == SEASONS.SUMMER then
            insulator:SetSummer()
        elseif type  == SEASONS.WINTER then
            insulator:SetWinter()
        end
    end
end



local function onAcceptTest(target, item, giver)
    if item.prefab == switchitem then
        local system = target.components.ksfun_power_system
        local power = system and system:GetPower(NAME) or nil
        return power and power.switch 
    end
    return false
end



local function onItemGiven(target, item, giver)
    if item.prefab == switchitem then
        local system = target.components.ksfun_power_system
        local power = system and system:GetPower(NAME) or nil
        if power then
            power.type = (power.type == SEASONS.SUMMER) and SEASONS.WINTER or SEASONS.SUMMER
            updateInsulation(power)
            -- 提示一下
            giver.components.talker:Say(STRINGS.KSFUN_CHANGE_INSULATOR_NOTICE)        
        end
    end
end



--- 升级
local function onLvChangeFunc(inst, lv, notice)
    updateInsulation(inst)

    --- 月圆之夜概率触发事件
    if (not inst.switch) and inst.target and TheWorld.state.isfullmoon then
        local r = math.random(1000)
        if lv > r then
            inst.switch = true
            if inst.target.components.trader == nil then
                inst.target:AddComponent(trader)
            end

            inst.components.trader.onaccept = onItemGiven
            local oldFunc = inst.target.components.trader.abletoaccepttest
            inst.target.components.trader:SetAbleToAcceptTest(function(inst, item, giver)
                return onAcceptTest(inst, item, giver) or (oldFunc and oldFunc(inst, item, giver))
            end)
        end
    end
end


--- 下一级保暖隔热所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (lv + 1)
end


--- 绑定对象
local function onAttachFunc(inst, item, name)
    if inst.components.insulator == nil then
        inst:AddComponent("insulator")
    end
    local insulator = inst.components.insulator

    inst.target = item
    if not inst.origininsulation_w then
        local insulation, type = insulator:GetInsulation()
        inst.origintype = type
        inst.origininsulation = insulation
    end

    if inst.type == nil then
        inst.type = inst.origintype
    end

    if inst.switch == nil then
        inst.switch = false
    end

    updateInsulation(inst)
end


--- 解绑对象
local function onDetachFunc(inst, item, name)
    local insulator = inst.components.insulator
    if insulator and inst.origininsulation then
        insulator.type = inst.origintype
        insulator:SetInsulation(inst.origininsulation)
    end
    inst.origintype = nil
    inst.origininsulation = nil
end



local function onLoad(inst, data)
    inst.type = data.type or nil
    inst.switch = data.switch or nil
end


local function onSave(inst, data)
    if inst.type and inst.switch then
        data.type = inst.type
        data.switch = inst.switch
    end
end



local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
    onLoadFunc   = onLoad,
    onSaveFunc   = onSave,
}


local level = {
    onLvChangeFunc = onLvChangeFunc,
    nextLvExpFunc = nextLvExpFunc,
}


local forg = {
    forgitems = forgitems
}


local ksfuninsulator = {}

ksfuninsulator.data = {
    power = power,
    level = level,
    forg = forg
}

return ksfuninsulator
