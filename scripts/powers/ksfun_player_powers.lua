local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES



local playerpowers = {}


--- 不需要format的属性描述可以使用这个
local function getPowerDesc(inst)
    local extra = KsFunGetPowerDescExtra(inst.prefab)
    return KsFunGetPowerDesc(inst, extra)
end


local function canHit(defaultratio)
    local r =  KSFUN_TUNING.DEBUG and 1 or defaultratio
    return math.random(100) < r * 100
end





------ 血量增强 ----------------------------------------------------------------------------------------
local function updateHealthStatus(inst)
    local lv = inst.components.ksfun_level.lv
    local health = inst.target.components.health
    local data = inst.components.ksfun_power:GetData()
    if health and data then
        local percent = health:GetPercent()
        health:SetMaxHealth(math.floor(data.health * (1 + lv * 0.01) + 0.5))
        health:SetPercent(percent)
    end
end

--- 击杀怪物后，范围10以内的角色都可以获得血量升级的经验值
--- 范围内只有一个人时，经验值为100%获取
--- 人越多经验越低，最低50%
--- @param killer 击杀者 data 受害者数据集
local function onKillOther(killer, data)
    KsFunLog("health event onkillother", data.victim.prefab)
    local victim = data.victim
    if victim == nil then return end
    if victim.components.health == nil then return end

    if victim.components.freezable or victim:HasTag("monster") then
        -- 所有经验都是10*lv 因此血量也需要计算为1/10
        local exp = victim.components.health.maxhealth / 10
        -- 击杀者能够得到满额的经验
        KsFunPowerGainExp(killer, NAMES.HEALTH, exp)
        -- 非击杀者经验值计算，范围10以内其他玩家
        local x,y,z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x,y,z, 10, {"player"})
        if players == nil then return end
        local players_count = #players
        -- 单人模式经验100%，多人经验获取会减少，最低50%
        local exp_multi = math.max((6 - players_count) * 0.2, 0.5)
        for i, player in ipairs(players) do
            -- 击杀者已经给了经验了
            if player ~= killer then
                KsFunPowerGainExp(player, NAMES.HEALTH, exp * exp_multi)
            end
        end
    end
end

local health = {
    onattach = function(inst, target, name)
        local h = target.components.health
        -- 记录原始数据
        inst.components.ksfun_power:SetData({health = h.maxhealth, percent = h:GetPercent()})
        if inst.percent then
            local data = inst.components.ksfun_power:GetData()
            h:SetMaxHealth(data.health)
            h:SetPercent(inst.percent)
        end
        updateHealthStatus(inst)
        -- 玩家杀怪可以升级
        target:ListenForEvent("killed", onKillOther)
    end,

    onstatechange = function(inst)
        updateHealthStatus(inst)
        KsFunSayPowerNotice(inst.target, inst.prefab)
    end,

    ondesc = getPowerDesc,

    onsave = function(inst, data)
        data.percent = inst.target.components.health:GetPercent()
    end,

    onload = function(inst, data)
        inst.percent = data.percent or nil
    end,
}





------ 饱食度 ----------------------------------------------------------------------------------------











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

        onGetDescFunc = getPowerDesc,
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

        onGetDescFunc = getPowerDesc,

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
            KsFunHookCaclDamage(inst, target, canHit)
        end,

        onGetDescFunc = getPowerDesc,

    },
    level = {},
}


playerpowers.health       = { data = health }
playerpowers.damage       = { data = damage }
playerpowers.locomotor    = { data = locomotor }
playerpowers.critdamage   = { data = critdamage }


return playerpowers