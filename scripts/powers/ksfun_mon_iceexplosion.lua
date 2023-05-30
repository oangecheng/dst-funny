--- 怪物死亡时造成冰冻效果


local NAME = KSFUN_TUNING.MONSTER_POWER_NAMES.ICE_EXPLOSION

local FREEZABLE_TAGS = { "freezable" }
local NO_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }



--- 升级到下一级所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (self.lv + 1) * 100
end


local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
    end
end



local function doIceExplosion(inst, area, coldness)
    --- 不知道这个效果有没有
    if inst.components.freezable == nil then
        MakeMediumFreezableCharacter(inst, "body")
    end
    inst.components.freezable:SpawnShatterFX()
    inst:RemoveComponent("freezable")

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, area, FREEZABLE_TAGS, NO_TAGS)

    for i, v in pairs(ents) do
        if v.components.freezable ~= nil then
            v.components.freezable:AddColdness(coldness)
        end
    end

    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/icehound_explo")
end


--- 死亡时有20%概率造成范围冰冻，冰冻范围和效果受等级影响
--- 冰冻范围 [2, 4]
--- 冰冻效果 [1, 2]
local function onDeath(inst)
    local power = inst.components.ksfun_power_system:GetPower(NAME)
    local hit = math.random(100) < (KSFUN_TUNING.DEBUG and 100 or 20)
    if hit and power and power.components.ksfun_power:IsEnable() then
        local lv = power.components.ksfun_level:GetLevel()
        local area = 2 + 2 * lv/10
        local coldness = 1 + lv/10
        doIceExplosion(inst, area, coldness)
    end
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    inst.target:ListenForEvent("death", onDeath)
    -- 最大等级10
    setUpMaxLv(inst, 10)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    inst.target:RemoveEventCallback("death", onDeath)
    inst.target = nil
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
}

local level = {
    nextLvExpFunc = nextLvExpFunc,
}


local p = {}

p.data = {
    power = power,
    level = level,
}


return p