---战斗体系相关的属性比较多
---这里单独使用一个文件去处理玩家战斗相关的逻辑
---避免处理方式不一致导致后续的维护问题


---- hook combat CalcDamage 组件
local function hookCalcDamage(inst, target, weapon)
    local doersystem = inst and inst.components.ksfun_power_system
    local doerpowers = doersystem and doersystem:GetAllPowers()

    local multiplier = 1

    --- attacker属性计算, 一般都是>1的，伤害倍乘
    if doerpowers then
        for _, value in pairs(doerpowers) do
            if value.hookcombat then
                multiplier = multiplier * value.hookcombat(inst, target, weapon, value)
            end
        end
    end

    local targetsystem = target and target.components.ksfun_power_system
    local targetpowers = targetsystem and targetsystem:GetAllPowers()
    if  targetpowers then
        for _, value in pairs(targetpowers) do
            if value.hookcombat then
                multiplier = multiplier * value.hookcombat(inst, target, weapon, value)
            end
        end
    end

    local weaponsystem = weapon and weapon.components.ksfun_power_system
    local weaponpowers = weaponsystem and weaponsystem:GetAllPowers()
    if weaponpowers then
        for _, value in pairs(weaponpowers) do
            if value.hookcombat then
                multiplier = multiplier * value.hookcombat(inst, target, weapon, value)
            end
        end
    end

    return multiplier
end


--- hook combat 组件
--- 伤害计算使用这个函数hook
--- 给power的inst添加 hookcombat 函数完成hook
--- 怪物之间战斗的伤害结算也是计算属性的，因为hook的是组件
AddComponentPostInit("combat", function(self)
    local oldCaclDamage = self.CalcDamage
    self.CalcDamage = function(_, target, weapon, multiplier)
        -- 计算原始伤害
        local dmg, spdmg = oldCaclDamage(self, target, weapon, multiplier)
        if self.inst then
            local multi = hookCalcDamage(self.inst, target, weapon)
            dmg = dmg * multi
            spdmg = spdmg * multi
        end
        return dmg, spdmg
    end
end)





--- 这里hook玩家的攻击系统
--- 怪物和怪物之间的战斗不会触发任何战斗效果
local function hookAttack(doer, target, weapon)
    local doersystem = doer and doer.components.ksfun_power_system
    local doerpowers = doersystem and doersystem:GetAllPowers()

    --- 玩家攻击回调，触发属性 onattack
    if doerpowers then
        for _, value in pairs(doerpowers) do
            if value.doattack then
                value.doattack(doer, target, weapon, value)
            end
        end
    end

    --- 玩家攻击回调，触发武器属性 onattack
    local weaponsystem = weapon and weapon.components.ksfun_power_system
    local weaponpowers = weaponsystem and weaponsystem:GetAllPowers()
    if weaponpowers then
        for _, value in pairs(weaponpowers) do
            if value.doattack then
                value.doattack(doer, target, weapon, value)
            end
        end
    end

    -- 被攻击方触发被攻击，触发被动机制，例如反伤等
    local targetsystem = target and target.components.ksfun_power_system
    local targetpowers = targetsystem and targetsystem:GetAllPowers()
    if  targetpowers then
        for _, value in pairs(targetpowers) do
            if value.onattacked then
                value.onattacked(doer, target, weapon, value)
            end
        end
    end
end


--- hook玩家攻击和被攻击的事件
--- 一般执行属性效果使用这个hook
AddPlayerPostInit(function (player)
    player:ListenForEvent("onattackother", function (inst, data)
        hookAttack(inst, data.target, data.weapon)
    end)

    player:ListenForEvent("attacked", function (inst, data)
        hookAttack(data.attacker, inst, data.weapon)
    end)
end)