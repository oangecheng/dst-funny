local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES



local function giveBlueprint()
    
end

local function onbuilditemfn(player)
    local exp = math.random(3, 5)
    KsFunPowerGainExp(player, NAMES.SANITY, exp)
end

local function onbuildstructurefn(player)
    local exp = math.random(6, 10)
    KsFunPowerGainExp(player, NAMES.SANITY, exp)

end


local function updatefn(inst, target)
    local maxsanity = inst.maxsanity or 100
    local sanity = target.components.sanity
    local lv = inst.components.ksfun_level:GetLevel()

    if lv > 0 and sanity then
        local percent = sanity:GetPercent()
        sanity.max = math.floor(maxsanity * (1 + lv * 0.01) + 0.5)
        sanity:SetPercent(percent)
    end

    if lv > 20 then
        KsFunAddTag(target,"handyperson")--女工科技
		KsFunAddTag(target,"fastbuilder")--快速建造
    end

    if lv > 40 then
        KsFunAddTag(target, "bookbuilder")
        KsFunAddComponent(target, "reader")
        local reader = target.components.reader
        if inst.penaltymulti ~= nil and reader then
            inst.penaltymulti = reader:GetSanityPenaltyMultiplier()
        end
        if inst.penaltymulti then
            --初始0.8倍消耗
            local m = math.max(1 - (lv - 20) * 0.01, 0.5)
            reader:SetSanityPenaltyMultiplier(inst.penaltymulti * m)
        end
    end

    if lv > 60 then
        
    end

    if lv > 20 then
        target:PushEvent("refreshcrafting")--更新制作栏
    end
end


local sanity = {
    attachfn = function (inst, target, name)
        target:ListenForEvent("builditem", onbuilditemfn)
        target:ListenForEvent("buildstructure", onbuildstructurefn)
        local sanity = target.components.sanity
        inst.sanitymax = sanity and sanity.max or nil
        if inst.percent then
            sanity:SetPercent(inst.percent)
        end
    end,

    detachfn = function (inst, target, name)
        target:RemoveEventCallback("builditem", onbuilditemfn)
        target:RemoveEventCallback("buildstructure", onbuildstructurefn)
    end,

    updatefn = function (inst, target, name)
        
    end,

    savefn = function (inst, target, data)
        data.percent = target.components.sanity:GetPercent()
    end,

    loadfn = function (inst, target, data)
        inst.percent = data.percent or nil
    end
}