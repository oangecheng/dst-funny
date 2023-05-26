local forgitems = {}
forgitems["mosquitosack"] = 2


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


--- 攻击回血
--- 需要有生命值的生物
local function onAttack(power, weapon, attacker, target)
    if KsFunIsValidVictim(target) then
        local level  = power.components.ksfun_level
        local health = attacker and attacker.components.health or nil
        if level and health then
            health:DoDelta(level:GetLevel(), false, "ksfun_item_lifesteal")
        end
    end 
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target

    local weapon = target.components.weapon
    if weapon then
        -- 缓存原函数
        weapon.ksfunOldOnAttack = weapon.onattack
        weapon:SetOnAttack(function(ent, attacker, victim)
            onAttack(inst, ent, attacker, victim)
            if weapon.ksfunOldOnAttack then
                weapon.ksfunOldOnAttack(ent, attacker, victim)
            end
        end)
    end

    setUpMaxLv(inst, 5)
    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    local weapon = target.components.weapon
    -- 恢复onAttack函数
    if weapon then
        weapon:SetOnAttack(weapon.ksfunOldOnAttack)
        weapon.ksfunOldOnAttack = nil
    end
    inst.target = nil
end


local function onBreakFunc(inst, data)
end



local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
    onStateChangeFunc = onStateChangeFunc,
    nextLvExpFunc = nextLvExpFunc,
}


local forgable = {
    items = forgitems
}

local lifesteal = {}

lifesteal.data = {
    power = power,
    level = level,
    forgable = forgable,
}


return lifesteal