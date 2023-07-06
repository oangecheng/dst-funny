
local TYPES = KSFUN_PUNISHES


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



local punish = {}


punish.randomPunish = function(player, tasklv)
    local punishtype = GetRandomItem(TYPES)
    local data = nil
    if punishtype == TYPES.POWER_LV_LOSE then
        data = powerLvLose(player, tasklv)
    elseif punishtype == TYPES.POWER_EXP_LOSE then
        data = powerExpLose(player, tasklv)
    end
    return data
end


return punish