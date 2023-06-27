-- 怪物增强


local NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES

local monsters = {
    -- 普通小怪
    ["spider"]  = { exp = 2,   powerlimit = 5,  powerexclude = nil },
    ["hound"]   = { exp = 5,   powerlimit = 5,  powerexclude = nil },

    -- boss
    ["bearger"] = { exp = 100, powerlimit = 10, powerexclude = nil },
}


--- 计算附加属性概率
local function isHit(defaultratio)
    local r =  KSFUN_TUNING.DEBUG and 1 or (1 + KSFUN_TUNING.DIFFCULTY) * defaultratio
    return math.random(100) < r * 100
end


local function reinforceMonster(inst, limit, exclude)
    local worldmonster = TheWorld.components.ksfun_world_monster
    local lv = worldmonster and worldmonster:GetMonsterLevel(inst.prefab)
    if lv and lv > 10 then
        --- 10%概率附加属性
        if not isHit(lv/100) then return end

        --- 每增加50级，怪物有概率多获得一个属性，但不超过属性上限, 至少有1个属性
        local seed = math.min(math.floor(lv/50 + 0.5), limit) 
        local num  = math.random(math.max(1, seed))

        local powernames = {}
        for k,v in pairs(NAMES) do
            -- 有些怪物不能加部分属性，比如克劳斯会有血量上限的变化
            if exclude == nil or (not table.contains(exclude, v)) then
                table.insert(powernames, v)
            end
        end

        num = math.max(#powernames, num)
        -- 随机取几个属性
        local powers = PickSome(num, powernames)
        for i,v in ipairs(powers) do
            local ent = inst.components.ksfun_power_system:AddPower(v)
            if ent then
                local powerlv = KSFUN_TUNING.DEBUG and 100 or math.random(lv)
                ent.components.ksfun_level:SetLevel(powerlv)
            end
        end

    end    
end


--- 怪物死亡时，会获得经验来提升自己的世界等级
local function onMonsterDeath(inst)
    local exp = monsters[inst.prefab].exp
    TheWorld.components.ksfun_world_monster:GainMonsterExp(inst.prefab, exp)
    TheNet:Announce("怪物等级提升了！")
end


for k,v in pairs(monsters) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("ksfun_power_system")
        reinforceMonster(inst, v.powerlimit, v.powerexclude)
        inst:ListenForEvent("death", onMonsterDeath)
    end)
end