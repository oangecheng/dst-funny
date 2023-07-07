
local TYPES = KSFUN_PUNISHES
local prefabsdef = require("defs/ksfun_prefabs_def")


local function powerLvLose(player, tasklv)
    local system = player.components.ksfun_power_system
    if system then
        local powers = system:GetAllPowers()
        if next(powers) ~= nil then
            local name, power = GetRandomItemWithIndex(powers)
            local delta = math.random(1 + tasklv * 0.5)
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
            local delta = math.random(tasklv) * 50
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
    local list = prefabsdef.punishmon
    local monsters = nil
    local num = 1

    if r < 0.1 then
        monsters = list["L"]
    elseif r < 0.3 then
        monsters = list["M"]
    else
        monsters = list["S"]
        num = math.random(tasklv) + 3
    end

    local selected = {}
    for i=1, num do
        local t = GetRandomItem(t)
        table.insert(selected, t)
    end

    return {
        type = TYPES.MONSTER,
        data = {
            monsters = selected  -- prefab list
        }
    }
end



local punish = {}


punish.randomPunish = function(player, tasklv)
    local punishtype = GetRandomItem(TYPES)
    local data = nil
    if punishtype == TYPES.POWER_LV_LOSE then
        data = powerLvLose(player, tasklv)
    elseif punishtype == TYPES.POWER_EXP_LOSE then
        data = powerExpLose(player, tasklv)
    elseif punishtype == TYPES.MONSTER then
        data = punishMonster(player, tasklv)
    end
    return data
end


return punish