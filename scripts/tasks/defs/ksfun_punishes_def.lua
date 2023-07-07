
local TYPES = KSFUN_PUNISHES
local prefabsdef = require("defs/ksfun_prefabs_def")


local function powerLvLose(player, tasklv)
    local system = player.components.ksfun_power_system
    if system then
        local powers = system:GetAllPowers()
        if next(powers) ~= nil then
            local name, power = GetRandomItemWithIndex(powers)
            local v = tasklv * 0.5
            if player.components.ksfun_lucky then
               v = v - 2 * player.components.ksfun_lucky:GetRatio()
            end
            -- 四舍五入
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
            local v = math.random(tasklv) * 10

            if player.components.ksfun_lucky then
                v = v - 100 * player.components.ksfun_lucky:GetRatio()
            end

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
    local list = prefabsdef.punishmon
    local monsters = nil
    local num = 1

    local lucky = 0
    if player.components.ksfun_lucky then
        lucky = player.components.ksfun_lucky:GetRatio()
    end

    if r < 0.1 then
        monsters = list["L"]
    elseif r < 0.3 then
        monsters = list["M"]
    else
        monsters = list["S"]
        num = math.random(tasklv) + 3
    end

    -- 运气差的时候，可能刷出两倍的怪，boss也可能是两个
    num = math.floor(num * (1 - lucky) + 0.5)
    num = math.max(1, num)

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


punish.random = function(player, tasklv)
    local r = math.random()
    local lucky = 0
    if player.components.ksfun_lucky then
        lucky = player.components.ksfun_lucky:GetRatio()
    end

    -- 100幸运值时，有20%概率没有任何惩罚
    if r < lucky * 0.2 then
        return nil
    end

    -- 幸运值加成不超过0.2
    r = r + math.min(lucky * 0.2, 0.2)
    local punish = nil

    -- 20% 概率遭受属性等级削弱
    -- 如果你的幸运等级超过100了，就不会触发等级降低
    if r < 0.2 then
        punish = powerLvLose(player, tasklv)
    end
    if punish == nil and r < 0.5 then
        punish = powerExpLose(player, tasklv)
    end

    if punish == nil then
        local ismon = math.random() < 0.5
        if ismon then
            punish = punishMonster(player, tasklv)
        end
    end

    return punish
end


return punish