
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


function KsFunFormatTime(time)
    if time < 0 then return "--:--" end
	local min = math.floor(time/60)
    local sec = math.floor(time%60)
    if min < 10 then min = "0"..min end
    if sec < 10 then sec = "0"..sec end
    return min .. ":" .. sec
end


GLOBAL.KsFunPowerGainExp = KsFunPowerGainExp
GLOBAL.KsFunRemoveTargetFromTable = KsFunRemoveTargetFromTable
GLOBAL.KsFunFormatTime = KsFunFormatTime