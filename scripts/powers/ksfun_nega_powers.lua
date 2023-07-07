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
        if target.components.ksfun_lucky then
            target.components.ksfun_lucky:AddModifier("power_unlucky", -100)
        end
    end,
    ondetach = function(inst, target)
        if target.components.ksfun_lucky then
            target.components.ksfun_lucky:RemoveModifier("power_unlucky")
        end
    end,
}




local negapowers = {
    [NAMES.DIARRHEA] = diarrhea,
    [NAMES.UNLUCKY]  = unlucky,
}

return negapowers