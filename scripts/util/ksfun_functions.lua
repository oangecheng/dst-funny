
local require = require
local STRINGS = STRINGS


--- 日志
KsFunLog = function(info, v1, v2, v3)
    if KSFUN_TUNING.PRINT_LOG then
        print("KsFunLog: "..info.." "..tostring(v1).." "..tostring(v2).." "..tostring(v3))
    end
end


--- 获取物品名称
--- 有自定义名称的，修改一下
--- @param prefab string 物品代码
KsFunGetPrefabName = function(prefab)
    local name = STRINGS.KSFUN_NAMES[prefab]
    return name or STRINGS.NAMES[string.upper(prefab)]
end



--- 获取属性的显示名称
--- 例如攻击增强..
--- @param powername 不带前缀的属性名称
KsFunGetPowerNameStr = function(powername)
    return KsFunGetPrefabName("ksfun_power_"..powername) or ""
end



--- 获取属性的描述性文字
KsFunGetPowerDescExtra = function(powerprefab)
    return STRINGS.KSFUN_POWER_DESC[string.upper(powerprefab)] or ""
end




--- 全局提示
--- @param msg string 消息
KsFunShowNotice = function(msg)
	TheNet:Announce(msg)
end


KsFunShowTip = function(player, msg)
    if player.components.talker and msg then
        player.components.talker:Say(msg)
    end
end


--- 角色升级时提示一下
KsFunSayPowerNotice = function(doer, powerprefab)
    if doer.components.talker then
        local name = KsFunGetPrefabName(powerprefab)
        local msg  = string.format(STRINGS.KSFUN_POWER_LEVEL_UP_NOTICE, name)
        doer.components.talker:Say(msg)
    end
end



--- 查找对应的能力获取经验值
--- @param inst table
--- @param name string 属性名称，不包含前缀
--- @param exp  number 经验
KsFunPowerGainExp = function(inst, name, exp)
    if exp == 0 then return end
    if inst.components.ksfun_power_system then
        local power = inst.components.ksfun_power_system:GetPower(name)
        if power and power.components.ksfun_level then
            power.components.ksfun_level:GainExp(math.floor(exp + 0.5))
        end
    end
end


KsFunGetPowerLv = function(inst, name)
    if inst.components.ksfun_power_system then
        local power = inst.components.ksfun_power_system:GetPower(name)
        if power then
            return power.components.ksfun_level:GetLevel()
        end
    end
    return nil
end



KsFunGetAoeProperty  = function(aoepower)
    local level = aoepower.components.ksfun_level
    -- 初始 50% 范围伤害，满级80%
    -- 初始 1.2 范围， 满级3范围
    local lv = level:GetLevel()
    local multi = 0.5 + 0.03 * lv
    local area  = 1.2 + 0.018 * lv
    return multi, area
end



KsFunIsValidVictim = function(victim)
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




KsFunGeneratePowerDefaultDesc = function(lv, exp)
    return "LV=["..lv.."]  ".."EXP=["..exp.."]"
end




KsFunGetPowerDesc = function(power, extradesc)
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


--- 添加可交易组件
KsFunAddTrader = function(inst, testfunc, acceptfunc)
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



--- 绑定任务卷轴
KsFunBindTaskReel = function(inst, player, data)
    local system = player.components.ksfun_task_system

    local msg    = nil
    if not (data and data.name and data.demand) then
        msg = "invalid"
    elseif not system:CanAddMoreTask() then
        msg = STRINGS.KSFUN_TASK_LIMIT_NUM
    elseif not system:CanAddTaskByName(data.name) then
        msg = STRINGS.KSFUN_TASK_LIMIT_NAME
    end

    -- 非法卷轴直接移除吧
    if msg == "invalid" then
        inst:DoTaskInTime(0, inst:Remove())
        return
    end

    -- 有提示
    if msg then
        if player.components.talker then
            player.components.talker:Say(msg)
        end
        return
    end
    -- 绑定之后移除物品
    system:AddTask(data.name, data)
    inst:DoTaskInTime(0, inst:Remove())
end



--- 在玩家周围生成带有敌意的怪物
KsFunSpawnHostileMonster = function(player, monstername, num)
    local count = num and num or 1
    for i=1, count do
        local mon = SpawnPrefab(monstername)
        if mon then
            local x,y,z = player.Transform:GetWorldPosition()
            if x == nil then break end
            local r  = math.random(6)
            local dx = math.random(r)
            local dz = math.random(r)
            mon.Transform:SetPosition(x+dx, 0, z+dz)
            if mon.components.combat then
                mon.components.combat:SuggestTarget(player)
            end
        end
    end
end



--- 生成任务卷轴
KsFunSpawnTaskReel = function(initlv)
    local helper = require("tasks/ksfun_task_helper")
    local inst   = SpawnPrefab("ksfun_task_reel")
    if inst then
        local data  = helper.randomTaskData(initlv)
        local valid = inst.components.ksfun_task_demand:Bind(data)
        -- 不合法的数据，将卷轴移除
        if not valid then
            inst:DoTaskInTime(0, inst:Remove())
            return nil
        end
    end
    return inst
end



KsFunIsMedalOpen = function()
    return TUNING.FUNCTIONAL_MEDAL_IS_OPEN
end



------------------------------------概率计算相关start，绑定幸运值和难度-----------------------------------------------------
local MIN_CHANCE = 0.1
local MAX_CHANCE = 2


local function luckyMulti(inst)
    local system = inst.components.ksfun_power_system
    local multi = 0
    if system then
        local lucky = system:GetPower(KSFUN_TUNING.PLAYER_POWER_NAMES.LUCKY)
        if lucky then
            multi = lucky.components.ksfun_level:GetLevel() * 0.01
        end
    end
    -- 处于不幸的debuff时，你的幸运会变成赋值
    if inst.unlucky then
        multi = inst.unlucky * multi
    end

    return multi
end

local function clamp(a, b, c)
    ---@diagnostic disable-next-line: undefined-field
    return math.clamp(a, b, c)
end


local function luckyMultiPositive(inst)
    local m = clamp(1 + luckyMulti(inst), MIN_CHANCE, MAX_CHANCE)
    KsFunLog("luckyMultiPositive", m)
    return m
end

local function luckyMultiNegative(inst)
    local m = clamp(1 - luckyMulti(inst), MIN_CHANCE, MAX_CHANCE)
    return m
end

local function diffMultiPositive()
    local m = clamp(MAX_CHANCE - KSFUN_TUNING.DIFFCULTY * 0.2, MIN_CHANCE, MAX_CHANCE)
    return m
end

local function diffMultiNegative()
    local m = clamp(KSFUN_TUNING.DIFFCULTY * 0.2, MIN_CHANCE, MAX_CHANCE)
    return m
 end

--- 计算正向倍率，比如奖励啥的
--- 幸运：越幸运，影响越大
--- 难度：值越大，影响越小
KsFunMultiPositive = function(inst)
    local m = luckyMultiPositive(inst) * diffMultiPositive()
    return m
end

--- 计算反向倍率，比如惩罚啥的
--- 幸运：越幸运，影响越小
--- 难度：值越大，影响越大
KsFunMultiNegative = function(inst)
    local m = luckyMultiNegative(inst) * diffMultiNegative()
    return m
end

--- 计算攻击命中概率
--- @param attacker table 攻击者
--- @param target table 被攻击者
--- @param defaultratio number 默认概率 下限0.1倍， 上限3倍
--- @param msg string
KsFunAttackCanHit = function(attacker, target, defaultratio, msg)
    local r = math.random()
    local attackermulti = 1
    local targetmulti = 1
    local diffmulti = 1
    
    -- 攻击者为玩家时，幸运值越大，难度越低，命中概率越高
    if attacker:HasTag("player") then
        attackermulti = luckyMultiPositive(attacker)
        diffmulti = diffMultiPositive()      
    end

    -- 被攻击者为玩家时，幸运值越大，难度越低，命中概率越低
    if target:HasTag("player") then
        targetmulti = luckyMultiNegative(target)
        diffmulti  = diffMultiNegative()
    end
    
    local v = defaultratio * attackermulti * targetmulti * diffmulti
    v = clamp(v, 0.1, 3)
    KsFunLog("KsFunAttackCanHit", v, r, msg)
    v = KSFUN_TUNING.DEBUG and 100 or v
    return r <= defaultratio * v
end
------------------------------------概率计算相关end，绑定幸运值和难度-----------------------------------------------------



--- 给玩家添加属性，这里会判断属性黑名单
--- @param player table 玩家实体
--- @param powername string 属性名
--- @return boolean success 是否添加成功
function KsFunAddPlayerPower(player, powername)
    local config  = require("defs/ksfun_players_def").playerconfig(player)
    local system = player and player.components.ksfun_power_system
    if system then
        local pblacks = config and config.pblacks or nil
        -- 黑名单不添加，换个角色会再加回来
        ---@diagnostic disable-next-line: undefined-field
        if not (pblacks ~= nil and table.contains(pblacks, powername)) then
            system:AddPower(powername)
            return true
        end 
    end
    return false
end


