


---- hook combat CalcDamage 组件
local function hookCalcDamage(inst, target, weapon)
    local doersystem = inst and inst.components.ksfun_power_system
    local doerpowers = doersystem and doersystem:GetAllPowers()

    local multiplier = 1
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
AddComponentPostInit("combat", function(self)
    local oldCaclDamage = self.CalcDamage
    self.CalcDamage = function(_, target, weapon, multiplier)
        -- 计算原始伤害
        local dmg, spdmg = oldCaclDamage(self, target, weapon, multiplier)
        if self.inst then
            dmg = dmg * hookCalcDamage(self.inst, target, weapon)
        end
        return dmg, spdmg
    end
end)