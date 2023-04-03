local function defaultValue()
    return  {
        enable = false,
        lv = 0,
        exp = 0,
    }
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

end)


-- 锁定，比如耐久为0时，需要移除所有效果
function KSFUN_CLOTHES:Lock(locked)
    self.locked = locked
    if self.onLockFunc then
        self.onLockFunc(self.locked)
    end
end


-- 精神值获取经验
function KSFUN_CLOTHES:GainDappernessExp(exp)
    local data = self.dapperness
    if not (data and data.enable) then return end
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
function KSFUN_CLOTHES:GainWaterprooferLv(value)
    local data = self.waterproofer
    if not (data and data.enable) then return end
    data.lv = data.lv + value
    if (value > 0) and self.onStateChangeFunc then
        self.onStateChangeFunc(self.inst)
    end
end



-- 保暖获取经验
function KSFUN_CLOTHES:GainWaterprooferLv(exp)
    local data = self.insulation_win
    if not (data and data.enable) then return end
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
function KSFUN_CLOTHES:GainWaterprooferLv(exp)
    local data = self.insulation_summer
    if not (data and data.enable) then return end
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
    return (self.dapperness and self.dapperness.enable) 
    or (self.waterproofer and self.waterproofer.enable)
    or (self.insulation_win and self.insulation_win.enable)
    or (self.insulation_summer and self.insulation_summer.enable)
end


-- save
function KSFUN_CLOTHES:OnSave()
    return {
        dapperness  = self.dapperness,
        waterproofer = self.waterproofer,
        insulation = self.insulation,
    }
end


-- load
function KSFUN_CLOTHES:OnLoad(data)
    self.dapperness = data.dapperness or defaultValue()
    self.waterproofer = data.waterproofer or defaultValue()
    self.insulation = data.insulation or defaultValue()
end


return KSFUN_CLOTHES