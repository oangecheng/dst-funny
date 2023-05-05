
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS


--- 查找对应的能力获取经验值
function KsFunPowerGainExp(inst, name, exp)
    if inst.components.ksfun_powers then
        local power = inst.components.ksfun_powers:GetPower(name)
        if power and power.components.ksfun_level then
            power.components.ksfun_level:GainExp(exp)
        end
    end
end


GLOBAL.KsFunPowerGainExp = KsFunPowerGainExp