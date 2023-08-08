
local TYPES = KSFUN_PUNISHES
local prefabsdef  = require("defs/ksfun_prefabs_def")
local monstersdef = require("defs/ksfun_monsters_def") 
local negapowers  = KSFUN_TUNING.NEGA_POWER_NAMES


local function powerLvLose(player, tasklv)
    local system = player.components.ksfun_power_system
    if system then
        local powers = system:GetAllPowers()
        if next(powers) ~= nil then
            local name, power = GetRandomItemWithIndex(powers)
            local v = math.random(3) * KsFunMultiNegative(player)
            local delta = math.max(1, math.floor(v + 0.5))
            return {
                type = TYPES.POWER_LV_LOSE,
                data = {
                    name = name,
                    num  = delta
                }
            }
        end
    end
    return nil
end



local function powerExpLose(player, tasklv)
    local system = player.components.ksfun_power_system
    if system then
        local powers = system:GetAllPowers()
        if next(powers) ~= nil then
            local name, power = GetRandomItemWithIndex(powers)
            local v = math.random(100) * KsFunMultiNegative(player)
            local delta = math.max(10, math.floor(v + 0.5))

            return {
                type = TYPES.POWER_EXP_LOSE,
                data = {
                    name = name,
                    num  = delta
                }
            }
        end
    end
    return nil
end



local function punishMonster(player, tasklv)
    local r = math.random()
    local list = monstersdef.punishMonsters()
    local monsters = nil
    local num = 1

    if r < 0.1 then monsters = list["L"]
    elseif r < 0.3 then monsters = list["M"]
    else 
        monsters = list["S"]
        num = math.random(tasklv)
    end

    -- 不超过10个怪物
    num = math.floor(num * KsFunMultiNegative(player) + 0.5)
    ---@diagnostic disable-next-line: undefined-field
    num = math.clamp(num, 1, 10)

    local selected = {}
    for i=1, num do
        local t = GetRandomItem(monsters)
        table.insert(selected, t)
    end

    return {
        type = TYPES.MONSTER,
        data = {
            monsters = selected  -- prefab list
        }
    }
end




local function punishNegaPowers(player, tasklv)
    local name = GetRandomItem(negapowers)
    return {
        type = TYPES.NEGA_POWER,
        data = {
            name = name,
        }
    }
end




local punish = {}
local typelist = { 1, 2 }


punish.random = function(player, tasklv)

    local multi = KsFunMultiNegative(player)
    local r = math.random()

    local punish = nil
    if r < 0.1 * multi then
        punish = powerLvLose(player, tasklv)
    elseif r < 0.3 * multi then
        punish = powerExpLose(player, tasklv)
    end

    if punish == nil then
        local t = GetRandomItem(typelist)
        if t == 1 then
            return punishMonster(player, tasklv)
        elseif t == 2 then
            return punishNegaPowers(player, tasklv)
        end
    end

    return punish
end


return punish