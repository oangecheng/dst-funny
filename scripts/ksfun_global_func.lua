
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS


--- 查找对应的能力获取经验值
function KsFunPowerGainExp(inst, name, exp)
    if exp == 0 then return end
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


function KsFunRandomValueFromKVTable(target)
    local values = {}
    for k,v in pairs(target) do
        table.insert(values, v)
    end
    local index = math.random(#values)
    return values[index]
end


function KsFunRandomValueFromList(target)
    local index = math.random(#target)
    return target[index]
end


function KsFunFormatTime(time)
    if time < 0 then return "--:--" end
	local min = math.floor(time/60)
    local sec = math.floor(time%60)
    if min < 10 then min = "0"..min end
    if sec < 10 then sec = "0"..sec end
    return min .. ":" .. sec
end


local LOG_TAG = "KsFunLog: "
function KsFunLog(info, v1, v2, v3)
    print(LOG_TAG..info.." "..tostring(v1).." "..tostring(v2).." "..tostring(v3))
end


function KsFunRandomPower(inst, powers, existed)
    local temp = {}

    -- 随机排序
    for k, v in pairs(powers) do
        local i = math.random(1 + #temp)
        table.insert(temp, i, v)
    end

    local system = inst and inst.components.ksfun_power_system or nil

    if system then
        for i,v in ipairs(temp) do
            -- 找到第一个不存在的属性返回， 找不到返回nil
            local p = system:GetPower(v)
            if existed then
                if p ~= nil then
                    return v
                end
            else
                if p == nil then
                    return v
                end
            end
        end
    end

    return nil
end



function KsFunIsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or
                victim:HasTag("structure") or
                victim:HasTag("wall") or
                victim:HasTag("balloon") or
                victim:HasTag("groundspike") or
                victim:HasTag("smashable") or
                victim:HasTag("abigail") or
                victim:HasTag("companion"))
        and victim.components.health ~= nil
end


function KsFunGeneratePowerDefaultDesc(lv, exp)
    return "Lv=["..lv.."]   ".."Exp=["..exp.."]"
end


function KsFunGeneratePowerDesc(power, extradesc)
    local level = power.components.ksfun_level
    local extra = extradesc and "    "..extradesc.."" or ""

    if level:IsMax() then
        return "已满级  "..extra
    else
        local lv  = level:GetLevel()
        local exp = level:GetExp()
        local def = KsFunGeneratePowerDefaultDesc(lv, exp)
        return def..extra
    end
end



local function getKillTaskDesc(demand)
    local victimname = STRINGS.NAMES[string.upper(demand.data.victim)] or nil
    local num = demand.data.num
    if victimname then
        local str = "击杀"..num.."只"..victimname 
        if     demand.type == KSFUN_TUNING.TASK_DEMAND_TYPES.KILL.NORMAL then
            return str
        elseif demand.type == KSFUN_TUNING.TASK_DEMAND_TYPES.KILL.TIME_LIMIT then
            local time = demand.data.duration
            return str.."(限制:"..time.."秒)"
        elseif demand.type == KSFUN_TUNING.TASK_DEMAND_TYPES.KILL.ATTACKED_LIMIT then
            return str.."(限制:无伤)"
        end
    end
    return nil
end


function KsFunGeneratTaskDesc(taskdata)
    if taskdata.name == KSFUN_TUNING.TASK_NAMES.KILL then
        return getKillTaskDesc(taskdata.demand)
    end
    return nil
end


function KsFunShowNotice(player, msg)
	if  player then
		local medal_tips = SpawnPrefab("medal_tips")
		medal_tips.Transform:SetPosition(player.Transform:GetWorldPosition())
		if medal_tips.medal_d_value then
			medal_tips.medal_d_value:set(msg)
		end
	end
end



GLOBAL.KsFunLog = KsFunLog
GLOBAL.KsFunPowerGainExp = KsFunPowerGainExp
GLOBAL.KsFunRemoveTargetFromTable = KsFunRemoveTargetFromTable
GLOBAL.KsFunFormatTime = KsFunFormatTime
GLOBAL.KsFunRandomValueFromKVTable = KsFunRandomValueFromKVTable
GLOBAL.KsFunRandomValueFromList = KsFunRandomValueFromList
GLOBAL.KsFunRandomPower = KsFunRandomPower
GLOBAL.KsFunIsValidVictim = KsFunIsValidVictim
GLOBAL.KsFunGeneratePowerDesc = KsFunGeneratePowerDesc
GLOBAL.KsFunGeneratePowerDefaultDesc = KsFunGeneratePowerDefaultDesc
GLOBAL.KsFunGeneratTaskDesc = KsFunGeneratTaskDesc
GLOBAL.KsFunShowNotice = KsFunShowNotice