-- 怪物增强


local NAMES = KSFUN_TUNING.MONSTER_POWER_NAMES


local function getMonsterConfig(powerlimit, blacklist, whitelist)
    return { powerlimit = powerlimit, blacklist = blacklist, whitelist = whitelist }
end


local monsters = {

    ["butterfly"] = getMonsterConfig(1, nil, { NAMES.HEALTH }),

    -- 普通小怪
    ["frog"]             = getMonsterConfig(5),
    ["mosquito"]         = getMonsterConfig(5),
    ["killerbee"]        = getMonsterConfig(5),
    ["bee"]              = getMonsterConfig(5),
    ["hound"]            = getMonsterConfig(5),
    ["firehound"]        = getMonsterConfig(5),
    ["icehound"]         = getMonsterConfig(5, { NAMES.ICE_EXPLOSION }),
    ["spider"]           = getMonsterConfig(5),
    ["spider_warrior"]   = getMonsterConfig(5), 
    ["spider_hider"]     = getMonsterConfig(5),
    ["spider_spitter"]   = getMonsterConfig(5),

    -- 中大型怪物
    ["spat"]             = getMonsterConfig(8),
    ["warg"]             = getMonsterConfig(8),
    ["beefalo"]          = getMonsterConfig(8),
    ["koalefant_summer"] = getMonsterConfig(8),
    ["koalefant_winter"] = getMonsterConfig(8),
    ["tentacle"]         = getMonsterConfig(8, { NAMES.LOCOMOTOR }),  -- 触手移速没意义
    ["knight"]           = getMonsterConfig(8),
    ["bishop"]           = getMonsterConfig(8),
    ["rook"]             = getMonsterConfig(8),
    ["tallbird"]         = getMonsterConfig(8),
    ["slurtle"]          = getMonsterConfig(8),

    -- boss
    ["leif"]             = getMonsterConfig(10),
    ["leif_sparse"]      = getMonsterConfig(10),
    ["bearger"]          = getMonsterConfig(10),
    ["spiderqueen"]      = getMonsterConfig(10),
    ["malbatross"]       = getMonsterConfig(10), -- 邪天翁
    ["minotaur"]         = getMonsterConfig(10), -- 远古守护者
    ["antlion"]          = getMonsterConfig(10, { NAMES.LOCOMOTOR }), -- 蚁狮
    ["dragonfly"]        = getMonsterConfig(10), -- 龙蝇
    ["deerclops"]        = getMonsterConfig(10), -- 巨鹿
    ["moose"]            = getMonsterConfig(10), -- 大鹅
    ["toadstool"]        = getMonsterConfig(10, nil, { NAMES.LOCOMOTOR, NAMES.HEALTH, NAMES.ABSORB, NAMES.SANITY_AURA }), -- 蛤蟆
    ["toadstool_dark"]   = getMonsterConfig(10, nil, { NAMES.LOCOMOTOR, NAMES.HEALTH, NAMES.ABSORB, NAMES.SANITY_AURA }), -- 悲惨蛤蟆
    ["beequeen"]         = getMonsterConfig(10), -- 蜂后
}


--- 计算附加属性概率
local function isHit(defaultratio)
    local r =  KSFUN_TUNING.DEBUG and 1 or (1 + KSFUN_TUNING.DIFFCULTY) * defaultratio
    return math.random(100) < r * 100
end


local function reinforceMonster(inst, limit, blacklist, whitelist)
    local worldmonster = TheWorld.components.ksfun_world_monster
    local lv = worldmonster and worldmonster:GetMonsterLevel(inst.prefab)
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
    if table.containskey(inst.prefab) then
        if inst.components.health then
            local exp = inst.components.health.maxhealth * 0.2
            TheWorld.components.ksfun_world_monster:GainMonsterExp(inst.prefab, exp)
        end
    end
end


for k,v in pairs(monsters) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("ksfun_power_system")
        reinforceMonster(inst, v.powerlimit, v.blacklist, v.whitelist)
        inst:ListenForEvent("death", onMonsterDeath)
    end)
end