local function defaultValue()
    return  {
        state = 0,
        lv = 0,
        exp = 0,
    }
end

--- 更新组件各个属性的状态
--- @param clothes 组件
--- @param ability 对应能力
--- @param state 状态
local function changeState(clothes, ability, state)
    if ability == 1 then clothes.dapperness.state = state end
    if ability == 2 then clothes.waterproofer.state = state end
    if ability == 3 then clothes.insulation_win.state = state end
    if ability == 4 then clothes.insulation_summer.state = state end
end


--- 判断组件状态大于某个值
--- @param clothes 组件
--- @param ability 对应能力
--- @param state 状态
local function isStateAbove(clothes, ability, state)
    if ability == 1 then return clothes.dapperness.state > state end
    if ability == 2 then return clothes.waterproofer.state > state end
    if ability == 3 then return clothes.insulation_win.state > state end
    if ability == 4 then return clothes.insulation_summer.state > state end
    return false
end


-- 升级需要的经验值
local function requireExp(lv)
    return (lv + 1) * 100
end


local KSFUN_CLOTHES= Class(function(self, inst)
    self.inst = inst
    self.locked = false

    -- 精神/防水/保暖/隔热
    self.dapperness = defaultValue()
    self.waterproofer = defaultValue()
    self.insulation_win =  defaultValue()
    self.insulation_summer =  defaultValue()

    -- 回调
    self.onLockFunc = nil
    self.onStateChangeFunc = nil
    self.onLevelUpEnabledFunc = nil

end)


--- 启用可升级升级能力
--- 启用能力之后可以使用物品解锁升级对应的能力
--- @param ability int 精神1 防水2 保暖3 隔热4
function KSFUN_CLOTHES:EnableLevelUp(ability)
    changeState(self, 1)
    if self.onLevelUpEnabledFunc then
        self.onLevelUpEnabledFunc(self.inst, ability)
    end
end


--- 判断升级能力是否开启
--- @param ability int 精神1 防水2 保暖3 隔热4
function KSFUN_CLOTHES:IsLevelUpEnabled(ability)
    return isStateAbove(self, ability, 0)
end


--- 解锁升级能力
function KSFUN_CLOTHES:EnableAbility(ability)
    changeState(self, ability,  2)
end


--- 判断对应能力是否已经解锁 
function KSFUN_CLOTHES:IsAbilityEnabled(ability)
    return isStateAbove(self, ability, 1)
end


-- 锁定，比如耐久为0时，需要移除所有效果
function KSFUN_CLOTHES:Lock(locked)
    self.locked = locked
    if self.onLockFunc then
        self.onLockFunc(self.locked)
    end
end


--- 判断当前物品是否被锁定
--- 被锁定的物品失去保暖/隔热/防水/精神恢复等效果
--- @return bool
function KSFUN_CLOTHES:IsLocked()
    return self.locked
end


-- 精神值获取经验
function KSFUN_CLOTHES:GainDappernessExp(exp)
    local data = self.dapperness
    if not (data and self:IsAbilityEnabled(1)) then return end
    data.exp = data.exp + exp
    local delta = 0
    if data.exp >= requireExp(data.lv) then
        data.exp = data.exp - requireExp(data.lv)
        data.lv = data.lv + 1
        delta = delta + 1
    end

    if (delta > 0) and self.onStateChangeFunc then
        self.onStateChangeFunc(self.inst)
    end
end


-- 防水获取经验
function KSFUN_CLOTHES:GainWaterprooferExp(exp)
    local data = self.waterproofer
    if not (data and self:IsAbilityEnabled(2)) then return end
    data.lv = data.lv + exp
    if (exp > 0) and self.onStateChangeFunc then
        self.onStateChangeFunc(self.inst)
    end
end



-- 保暖获取经验
function KSFUN_CLOTHES:GainInsulatorWinExp(exp)
    local data = self.insulation_win
    if not (data and self:IsAbilityEnabled(3)) then return end
    data.exp = data.exp + exp
    local delta = 0
    if data.exp >= requireExp(data.lv) then
        data.exp = data.exp - requireExp(data.lv)
        data.lv = data.lv + 1
        delta = delta + 1
    end

    if (delta > 0) and self.onStateChangeFunc then
        self.onStateChangeFunc(self.inst)
    end
end


-- 隔热获取经验
function KSFUN_CLOTHES:GainInsulatorSummerExp(exp)
    local data = self.insulation_summer
    if not (data and self:IsAbilityEnabled(4)) then return end
    data.exp = data.exp + exp
    local delta = 0
    if data.exp >= requireExp(data.lv) then
        data.exp = data.exp - requireExp(data.lv)
        data.lv = data.lv + 1
        delta = delta + 1
    end

    if (delta > 0) and self.onStateChangeFunc then
        self.onStateChangeFunc()
    end
end



-- 是否开启了升级
-- 开启升级之后物品被保护，不会消失，只会失去效果
function KSFUN_CLOTHES:IsProtected()
    return self:IsLevelUpEnabled(1) or self:IsLevelUpEnabled(2) or
        self:IsLevelUpEnabled(3) or self:IsLevelUpEnabled(4)
end


-- save
function KSFUN_CLOTHES:OnSave()
    return {
        locked = self.locked,
        dapperness  = self.dapperness,
        waterproofer = self.waterproofer,
        insulation = self.insulation,
    }
end


-- load
function KSFUN_CLOTHES:OnLoad(data)
    self.locked = data.locked or false
    self.dapperness = data.dapperness or defaultValue()
    self.waterproofer = data.waterproofer or defaultValue()
    self.insulation = data.insulation or defaultValue()
end


return KSFUN_CLOTHES