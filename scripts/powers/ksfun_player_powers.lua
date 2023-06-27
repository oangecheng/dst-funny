local playerpowers = {}


local function canHit(defaultratio)
    local r =  KSFUN_TUNING.DEBUG and 1 or defaultratio
    return math.random(100) < r * 100
end



------ 伤害倍率 ----------------------------------------------------------------------------------------
local function updateDamageStatus(inst)
    local combat = inst.target and inst.target.components.combat
    if combat then
        local lv = inst.components.ksfun_level:GetLevel()
        combat.externaldamagetakenmultipliers:SetModifier("ksfun_power", 1 + lv /100)
    end
end

local damage = {
    power = {
        onAttachFunc = function(inst, target, name)
            inst.components.ksfun_level:SetMax(50)
            updateDamageStatus(inst)
        end,
    },
    level = {
        onLvChangeFunc = updateDamageStatus
    },
}







------ 移动速度 ----------------------------------------------------------------------------------------
local function updateLocomotorStatus(inst)
    if inst.target and inst.target.components.locomotor then
        local lv = inst.components.ksfun_level:GetLevel()
        local mult = 1 + lv / 100
        inst.target.components.locomotor:SetExternalSpeedMultiplier(inst, "ksfun_power", mult)
    end
end

local locomotor = {
    power = {
        onAttachFunc = function(inst, target, name)
            inst.components.ksfun_level:SetMax(50)
            updateLocomotorStatus(inst)
        end,
    },
    level = {
        onLvChangeFunc = updateLocomotorStatus
    },
}






------ 暴击 ----------------------------------------------------------------------------------------
local critdamage = {
    power = {
        onAttachFunc = function(inst, target, name)
            inst.components.ksfun_level:SetMax(100)
            KsFunHookCaclDamage(inst, attacker, canHit)
        end
    },
    level = {},
}



playerpowers.damage       = { data = damage }
playerpowers.locomotor    = { data = locomotor }
playerpowers.critdamage   = { data = critdamage }


return playerpowers