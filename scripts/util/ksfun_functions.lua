
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


