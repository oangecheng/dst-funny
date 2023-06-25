

local POWERS = KSFUN_TUNING.PLAYER_POWER_NAMES
local REWARD_TYPES = KSFUN_TUNING.TASK_REWARD_TYPES


local function randomPower(player, existed)
    local temp = {}

    -- 随机排序
    for k, v in pairs(POWERS) do
        local i = math.random(1 + #temp)
        table.insert(temp, i, v)
    end

    local system = player and player.components.ksfun_power_system or nil

    if system then
        for i,v in ipairs(temp) do
            -- 找到第一个不存在的属性返回， 找不到返回nil
            local p = system:GetPower(v)
            if existed then
                if p ~= nil then
                    return v
                end
            else
                if p == nil then
                    return v
                end
            end
        end
    end

    return nil
end


local reward_powers = {}


--- 随机给予一个数据奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a}
reward_powers.randomNewPower = function(player, task_lv)
    local power = randomPower(player, false)
    if power then
        return {
            type = REWARD_TYPES.PLAYER_POWER,
            data = {
                power = power
            }
        }
    end
    return nil
end


--- 随机查找一个存在的属性给予等级奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a, num = b}
reward_powers.randomPowerLv = function(player, task_lv)
    local power = randomPower(player, true)
    local lv = math.random(3)
    if power then
        return {
            type = REWARD_TYPES.PLAYER_POWER_LV,
            data = {
                power = power,
                num = lv,
            }
        }
    end
    return nil
end


--- 随机一个属性给予一定的经验值奖励
--- @param player 角色
--- @param task_lv 等级
--- data = {power = a, num = b}
reward_powers.randomPowerExp = function(player, task_lv)
    local power = randomPower(player, true)
    local exp = math.random(task_lv) * 10
    if power then
        return {
            type = REWARD_TYPES.PLAYER_POWER_EXP,
            data = {
                power = power,
                num = exp,
            }
        }
    end
    return nil
end


return reward_powers