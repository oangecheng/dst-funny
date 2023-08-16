local MIN_CHANCE = 0.1
local MAX_CHANCE = 2


local function luckyMulti(inst)
    local system = inst.components.ksfun_power_system
    local multi = 0
    if system then
        local lucky = system:GetPower(KSFUN_TUNING.PLAYER_POWER_NAMES.LUCKY)
        if lucky then
            multi = lucky.components.ksfun_level:GetLevel() * 0.01
        end
    end
    -- 处于不幸的debuff时，你的幸运会变成赋值
    if inst.unlucky then
        multi = inst.unlucky * multi
    end

    return multi
end

local function clamp(a, b, c)
    ---@diagnostic disable-next-line: undefined-field
    return math.clamp(a, b, c)
end


local function luckyMultiPositive(inst)
    local m = clamp(1 + luckyMulti(inst), MIN_CHANCE, MAX_CHANCE)
    KsFunLog("luckyMultiPositive", m)
    return m
end

local function luckyMultiNegative(inst)
    local m = clamp(1 - luckyMulti(inst), MIN_CHANCE, MAX_CHANCE)
    return m
end

local function diffMultiPositive()
    local m = clamp(MAX_CHANCE - KSFUN_TUNING.DIFFCULTY * 0.2, MIN_CHANCE, MAX_CHANCE)
    return m
end

local function diffMultiNegative()
    local m = clamp(KSFUN_TUNING.DIFFCULTY * 0.2, MIN_CHANCE, MAX_CHANCE)
    return m
 end

--- 计算正向倍率，比如奖励啥的
--- 幸运：越幸运，影响越大
--- 难度：值越大，影响越小
KsFunMultiPositive = function(inst)
    local m = luckyMultiPositive(inst) * diffMultiPositive()
    return m
end

--- 计算反向倍率，比如惩罚啥的
--- 幸运：越幸运，影响越小
--- 难度：值越大，影响越大
KsFunMultiNegative = function(inst)
    local m = luckyMultiNegative(inst) * diffMultiNegative()
    return m
end

--- 计算攻击命中概率
--- @param attacker table 攻击者
--- @param target table 被攻击者
--- @param defaultratio number 默认概率 下限0.1倍， 上限3倍
--- @param msg string
KsFunAttackCanHit = function(attacker, target, defaultratio, msg)
    local r = math.random()
    local attackermulti = 1
    local targetmulti = 1
    local diffmulti = 1
    
    -- 攻击者为玩家时，幸运值越大，难度越低，命中概率越高
    if attacker:HasTag("player") then
        attackermulti = luckyMultiPositive(attacker)
        diffmulti = diffMultiPositive()      
    end

    -- 被攻击者为玩家时，幸运值越大，难度越低，命中概率越低
    if target:HasTag("player") then
        targetmulti = luckyMultiNegative(target)
        diffmulti  = diffMultiNegative()
    end
    
    local v = defaultratio * attackermulti * targetmulti * diffmulti
    v = clamp(v, 0.1, 3)
    KsFunLog("KsFunAttackCanHit", v, r, msg)
    v = KSFUN_TUNING.DEBUG and 100 or v
    return r <= defaultratio * v
end



--- 计算是否命中特殊奖励
--- 和幸运值&难度绑定
--- @param player table 玩家实体
--- @param tasklv number 任务等级
--- @return boolean true 给予
function KsFunCanRewardSpecial(player, tasklv)

    local seed = 0
    if tasklv < 3 then
        seed = 0.01
    elseif tasklv < 5 then
        seed = 0.05
    elseif tasklv < 6 then
        seed = 0.1
    elseif tasklv < 7  then 
        seed = 0.2
    elseif tasklv < 8  then
        seed = 0.4
    elseif tasklv < 9  then
        seed = 0.65
    elseif tasklv < 10 then 
        seed = 0.9
    else
        seed = 1
    end

    --- 幸运值附加倍率，最高2倍
    --- 难度值附加倍率，最简单难度2倍
    local hit = math.random() <= seed * KsFunMultiPositive(player)
    if KSFUN_TUNING.DEBUG then
        hit = true
    end

    --- 概率命中优先触发
    if hit  then
        return true
    end

    --- 兜底策略
    if player.components.achievements then
        if player.components.achievements:Consume() then
            return true
        end
    end
    return false
end



--- 计算是否命中特殊奖励
--- 和幸运值&难度绑定
--- @param player table 玩家实体
--- @param tasklv number 任务等级
--- @return number 返回计算后的物品等级
function KsFunRewardNormalLv(player, tasklv)
    local m = KsFunMultiPositive(player)
    -- 附加等级，最大不超过2
    local addlv = m > 1 and math.min(math.floor(m + 0.5), 2) or 0
    return tasklv + addlv
end





