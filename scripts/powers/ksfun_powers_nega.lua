local NAMES = KSFUN_TUNING.NEGA_POWER_NAMES


--------------------------------------------------------腹泻------------------------------------------------------------
--- 吃东西降低收益至50%, 
local mult = 0.5
local diarrhea = {
    -- 持续一天
    duration = KSFUN_TUNING.DEBUG and 30 or KSFUN_TUNING.TOTAL_DAY_TIME,

    onattach = function(inst, target)        
        local eater = target.components.eater
        if eater then
            inst.health = eater.healthabsorption
            inst.hunger = eater.hungerabsorption
            inst.sanity = eater.sanityabsorption 
            eater:SetAbsorptionModifiers(mult * inst.health, mult * inst.hunger, mult * inst.sanity)
        end
        
        local interval = KSFUN_TUNING.DEBUG and 5 or 25
        inst.shitask = inst:DoPeriodicTask(interval, function(inst)
            if target.components.lootdropper then
                target.components.lootdropper:SpawnLootPrefab("poop")
            else
                local x,y,z = target.Transform:GetWorldPosition()
                if x == nil then return end
                local poop = SpawnPrefab("poop")
                poop.Transform:SetPosition(x,y,z)
            end
        end)
    end,
    ondetach = function(inst, target)
        local eater = target.components.eater
        if eater and inst.health then
            eater:SetAbsorptionModifiers(inst.health, inst.hunger, inst.sanity)
        end
        if inst.shitask then
            inst.shitask:Cancel()
            inst.shitask = nil
        end 
    end,

}





--------------------------------------------------------倒霉------------------------------------------------------------
local unlucky = {
    duration = KSFUN_TUNING.DEBUG and 60 or KSFUN_TUNING.TOTAL_DAY_TIME,
    onattach = function(inst, target)
        target.unlucky = -1
    end,
    ondetach = function(inst, target)
        target.unlucky = nil
    end,
}






--------------------------------------------------------虚弱------------------------------------------------------------
-- 攻击-20%，受到的伤害 +20%， 持续30s
local weak = {
    duration = KSFUN_TUNING.DEBUG and 30 or KSFUN_TUNING.TIME_SEG,
    onattach = function(inst, target)
        if target.components.combat then
            target.components.combat.externaldamagemultipliers:SetModifier(inst, 0.8)
        end
        if target.components.health ~= nil then
            target.components.health.externalabsorbmodifiers:SetModifier("ksfun_powers_nega_weak", -0.2)
        end
    end,
    ondetach = function(inst, target)
        if target.components.combat then
            target.components.combat.externaldamagemultipliers:RemoveModifier(inst)
        end
        if target.components.health ~= nil then
            target.components.health.externalabsorbmodifiers:RemoveModifier("ksfun_powers_nega_weak")
        end
    end,
}












local negapowers = {
    [NAMES.DIARRHEA] = diarrhea,
    [NAMES.UNLUCKY]  = unlucky,
    [NAMES.WEAK]     = weak,
}

return negapowers