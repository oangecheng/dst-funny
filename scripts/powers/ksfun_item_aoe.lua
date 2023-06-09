local forgitems = {}
forgitems["minotaurhorn"] = 5

local EXCLUDE_TAG_DEFS = {
	"INLIMBO",
	"companion", 
	"wall",
	"abigail", 
}

local maxlv = 10


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
    -- 初始 1.2 范围， 满级3范围
    local multi = 0.5 + 0.3 * (lv/maxlv)
    local area  = 1.2 + 1.8 * (lv/maxlv)
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

    -- 缓存原函数
    if not inst.ksfunOldOnAttack then
        inst.ksfunOldOnAttack = weapon.onattack
    end

    if weapon then
        weapon:SetOnAttack(function(ent, attacker, target)
            onAttack(inst, ent, attacker, target)
            if inst.ksfunOldOnAttack then
                inst.ksfunOldOnAttack(ent, attacker, target)
            end
        end)
    end

    setUpMaxLv(inst, maxlv)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    local weapon = target.components.weapon
    -- 恢复onAttack函数
    if weapon then
        weapon:SetOnAttack(inst.ksfunOldOnAttack)
    end
    inst.target = nil
end


local function onGetDescFunc(inst, target, name)
    local multi,area = getAoeProperty(inst)
    local desc = "造成范围"..area.."以内"..(multi*100).."%溅射伤害"
    return KsFunGeneratePowerDesc(inst, desc)
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onGetDescFunc= onGetDescFunc
}


local forgable = {
    items = forgitems
}

local p = {}

p.data = {
    power = power,
    level = {},
    forgable = forgable,
}


return p