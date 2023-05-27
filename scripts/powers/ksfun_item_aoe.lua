local forgitems = {}
forgitems["minotaurhorn"] = 5

local EXCLUDE_TAG_DEFS = {
	"INLIMBO",
	"companion", 
	"wall",
	"abigail", 
}

local maxlv = 10


local function updatPowerStatus(inst)
    
end


--- 监听等级提升
--- @param inst power实例
--- @param lv  等级
local function onLvChangeFunc(inst, lv)
    updatPowerStatus(inst)
end


--- 等级变更，包括经验值
local function onStateChangeFunc(inst)
    
end


--- 升级到下一级所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (10 * (lv + 1))
end


local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
    end
end


-- 判断是否为仆从
local function isFollower(inst, target)
	if inst.components.leader ~= nil then
		return inst.components.leader:IsFollower(target)
	end
	return false
end


local function getAoeProperty(power)
    local lv = power.components.ksfun_level:GetLevel()
    -- 初始 50% 范围伤害，满级80%
    -- 初始 1 范围， 满级3范围
    local multi = 0.5 + 0.3 * (lv/maxlv)
    local area = 1 + 2 * (lv/maxlv)
    return multi, area
end


--- 攻击回血
--- 需要有生命值的生物
local function onAttack(power, weapon, attacker, target)
    local lv = power.components.ksfun_level:GetLevel()
    -- 初始 50% 范围伤害，满级80%
    -- 初始 1 范围， 满级3范围
    local multi, area = getAoeProperty(power)

    local combat = attacker.components.combat
    local x,y,z = target.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, area, { "_combat" }, EXCLUDE_TAG_DEFS)
    for i, ent in ipairs(ents) do
        if ent ~= target and ent ~= attacker and combat:IsValidTarget(ent) and (not isFollower(attacker, ent)) then
            attacker:PushEvent("onareaattackother", { target = ent, weapon = weapon, stimuli = nil })
            local damage = combat:CalcDamage(ent, weapon, 1) * multi
            ent.components.combat:GetAttacked(attacker, damage, weapon, nil)
        end
    end
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target

    local weapon = target.components.weapon
    if weapon then
        -- 缓存原函数
        inst.ksfunOldOnAttack = weapon.onattack
        weapon:SetOnAttack(function(ent, attacker, victim)
            onAttack(inst, ent, attacker, victim)
            if inst.ksfunOldOnAttack then
                inst.ksfunOldOnAttack(ent, attacker, victim)
            end
        end)
    end

    setUpMaxLv(inst, maxlv)
    -- updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    local weapon = target.components.weapon
    -- 恢复onAttack函数
    if weapon then
        weapon:SetOnAttack(inst.ksfunOldOnAttack)
        inst.ksfunOldOnAttack = nil
    end
    inst.target = nil
end


local function onBreakFunc(inst, data)
end


local function onGetDescFunc(inst)
    local level = inst.components.ksfun_level
    local multi,area = getAoeProperty(inst)
    local desc = "[造成范围"..area.."以内"..(multi*100).."%溅射伤害]"
    if level:IsMax() then
        return "已满级  "..desc
    else
        local lv  = level:GetLevel()
        local exp = level:GetExp()
        return "等级: ["..lv.."]  经验: ["..exp.."]  "..desc
    end
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
    onGetDescFunc= onGetDescFunc
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
    nextLvExpFunc = nextLvExpFunc,
}


local forgable = {
    items = forgitems
}

local breakable = {
    initMaxLv = 10,
    onBreakFunc = onBreakFunc,
}

local p = {}

p.data = {
    power = power,
    level = level,
    forgable = forgable,
    -- breakable = breakable,
}


return p