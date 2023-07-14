-- 怪物增强


local NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES
local monsters = require("defs/ksfun_monsters_def").reinforceMonster()


--- 计算附加属性概率
local function isHit(defaultratio)
    local r =  KSFUN_TUNING.DEBUG and 1 or (1 + KSFUN_TUNING.DIFFCULTY) * defaultratio
    return math.random(100) < r * 100
end


local function reinforceMonster(inst, limit, blacklist, whitelist)
    local worldmonster = TheWorld.components.ksfun_world_monster
    local lv = worldmonster and worldmonster:GetMonsterLevel(inst.prefab)
    inst.components.ksfun_level:SetLevel(lv)
    if lv and lv > 10 then
        --- 10%概率附加属性
        if not isHit(lv/100) then return end

        --- 每增加50级，怪物有概率多获得一个属性，但不超过属性上限, 至少有1个属性
        local seed = math.min(math.floor(lv/50 + 0.5), limit) 
        local num  = math.random(math.max(1, seed))

        local powernames = {}

        -- 如果有白名单，用白名单数据
        local illegnames = whitelist and whitelist or NAMES
    
        for k,v in pairs(illegnames) do
            -- 有些怪物不能加部分属性，比如克劳斯会有血量上限的变化
            if blacklist == nil or (not table.contains(blacklist, v)) then
                table.insert(powernames, v)
            end
        end

        num = math.min(#powernames, num)
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
    if inst.components.health then
        local exp = inst.components.health.maxhealth * 0.2
        TheWorld.components.ksfun_world_monster:GainMonsterExp(inst.prefab, exp)
    end
end


for k,v in pairs(monsters) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("ksfun_power_system")
        inst:AddComponent("ksfun_level")
        reinforceMonster(inst, v.pnum, v.pblacks, v.pwhites)
        inst:ListenForEvent("death", onMonsterDeath)
    end)
end