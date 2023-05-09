
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS


--- 查找对应的能力获取经验值
function KsFunPowerGainExp(inst, name, exp)
    if inst.components.ksfun_power_system then
        local power = inst.components.ksfun_power_system:GetPower(name)
        if power and power.components.ksfun_level then
            power.components.ksfun_level:GainExp(exp)
        end
    end
end


function KsFunRemoveTargetFromTable(list, target)
    for k, v in pairs(list) do
        if v == target then
            list[k] = nil
            return v
        end
    end
end


GLOBAL.KsFunPowerGainExp = KsFunPowerGainExp
GLOBAL.KsFunRemoveTargetFromTable = KsFunRemoveTargetFromTable