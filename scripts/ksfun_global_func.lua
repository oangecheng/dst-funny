
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS


--- 日志
local LOG_TAG = "KsFunLog: "
GLOBAL.KsFunLog  = function(info, v1, v2, v3)
    print(LOG_TAG..info.." "..tostring(v1 or "").." "..tostring(v2 or "").." "..tostring(v3 or ""))
end


--- 获取物品名称
--- 有自定义名称的，修改一下
--- @param prefab 物品代码
GLOBAL.KsFunGetPrefabName = function(prefab)
    local name = STRINGS.KSFUN_NAMES[prefab]
    return name or STRINGS.NAMES[string.upper(prefab)]
end



--- 获取属性的显示名称
--- 例如攻击增强..
--- @param powername 不带前缀的属性名称
GLOBAL.KsFunGetPowerNameStr = function(powername)
    return KsFunGetPrefabName("ksfun_power_"..powername) or ""
end



--- 获取属性的描述性文字
GLOBAL.KsFunGetPowerDescExtra = function(powerprefab)
    return STRINGS.KSFUN_POWER_DESC[string.upper(powerprefab)] or ""
end




--- 全局提示
--- @param msg 消息
GLOBAL.KsFunShowNotice = function(msg)
	TheNet:Announce(msg)
end



--- 角色升级时提示一下
GLOBAL.KsFunSayPowerNotice = function(doer, powerprefab)
    if doer.components.talker then
        local name = KsFunGetPrefabName(powerprefab)
        local msg  = string.format(STRINGS.KSFUN_POWER_LEVEL_UP_NOTICE, name)
        doer.components.talker:Say(msg)
    end
end



--- 查找对应的能力获取经验值
--- @param name 属性名称，不包含前缀
--- @param exp 经验
GLOBAL.KsFunPowerGainExp = function(inst, name, exp)
    if exp == 0 then return end
    if inst.components.ksfun_power_system then
        local power = inst.components.ksfun_power_system:GetPower(name)
        if power and power.components.ksfun_level then
            power.components.ksfun_level:GainExp(exp)
        end
    end
end



function KsFunGetAoeProperty(aoepower)
    local level = aoepower.components.ksfun_level
    -- 初始 50% 范围伤害，满级80%
    -- 初始 1.2 范围， 满级3范围
    local percent = level:GetLevel() / level:GetMax()
    local multi = 0.5 + 0.3 * percent
    local area  = 1.2 + 1.8 * percent
    return multi, area
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




GLOBAL.KsFunIsValidVictim = function(victim)
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




GLOBAL.KsFunGeneratePowerDefaultDesc = function(lv, exp)
    return "LV=["..lv.."]   ".."EXP=["..exp.."]"
end




GLOBAL.KsFunGetPowerDesc = function(power, extradesc)
    local level = power.components.ksfun_level
    local extra = extradesc and "    "..extradesc.."" or ""

    if level:IsMax() then
        return STRINGS.KSFUN_POWER_LEVEL_MAX.."  "..extra
    else
        local lv  = level:GetLevel()
        local exp = level:GetExp()
        local def = KsFunGeneratePowerDefaultDesc(lv, exp)
        return def..extra
    end
end





function KsFunGeneratTaskDesc(taskdata)
    local function getKillTaskDesc(demand)
        -- 先从自定义的名称里面拿，有些怪物的名称是一样的，所以要区分一下
        local victimname = KsFunGetPrefabName(demand.data.victim)
        local num = demand.data.num
        local KILL_TYPES = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL
        if victimname then
            local str = string.format(STRINGS.KSFUN_TASK_KILL_DESC, tostring(num), tostring(victimname))
            -- 击杀1只蜘蛛
            if demand.type == KILL_TYPES.NORMAL then
                return str
            -- 击杀1只蜘蛛(限制:480秒)
            elseif demand.type == KILL_TYPES.TIME_LIMIT then
                return str..string.format(STRINGS.KSFUN_TASK_TIME_LIMIT, tostring(demand.duration))
            -- 击杀1只蜘蛛(限制:无伤)
            elseif demand.type == KILL_TYPES.ATTACKED_LIMIT then
                return str..STRINGS.KSFUN_TASK_NO_HURT
            end
        end
        return nil
    end

    if taskdata.name == KSFUN_TUNING.TASK_NAMES.KILL then
        return getKillTaskDesc(taskdata.demand)
    end
    return nil
end




--- 添加可交易组件
GLOBAL.KsFunAddTrader = function(inst, testfunc, acceptfunc)
    if inst.components.trader == nil then
        inst:AddComponent("trader")
    end
    local trader = inst.components.trader

    local oldTradeTest = trader.abletoaccepttest
    trader:SetAbleToAcceptTest(function(inst, item, giver)
        if testfunc(inst, item, giver) then
            return true
        end
        if oldTradeTest and oldTradeTest(inst, item, giver) then
            return true
        end
        return false
    end)

    local oldaccept = trader.onaccept
    trader.onaccept = function(inst, giver, item)
        acceptfunc(inst, item, giver)
        if oldaccept ~= nil then
            oldaccept(inst, giver, item)
        end
        giver.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    end
end



GLOBAL.KsFunHookCaclDamage = function(inst, attacker, canhitfunc)
    if attacker.components.combat == nil then return end
    inst.ksfun_originCalcDamage = attacker.components.combat.CalcDamage
    if inst.ksfun_originCalcDamage then
        attacker.components.combat.CalcDamage = function(targ, weapon, mult)
            local hit    = canhitfunc and canhitfunc(0.2) or 0.2
            local lv     = inst.components.ksfun_level:GetLevel()
            local ratio  = hit and (lv/100 + 1) or 1
            local dmg    = inst.ksfun_originCalcDamage(targ, weapon, mult)
            return dmg * ratio
        end
    end
end



GLOBAL.KsFunFormatTime  = KsFunFormatTime
GLOBAL.KsFunRandomPower = KsFunRandomPower
GLOBAL.KsFunGeneratTaskDesc = KsFunGeneratTaskDesc
GLOBAL.KsFunGetAoeProperty = KsFunGetAoeProperty