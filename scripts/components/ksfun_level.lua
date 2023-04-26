
-- 升级需要多少经验值
local function defaultExpFunc(level)
    return (level + 1) * 100
end


local KSFUN_LEVEL = Class(function(self, inst)
    self.lv = 0
    self.exp = 0

    self.onLvUpFunc = nil
    self.onExpChangeFunc = nil
    self.nextLvExpFunc = nil
end)


function KSFUN_LEVEL:SetLvUpFunc(func)
    self.onLvUpFunc = func
end

function KSFUN_LEVEL:SetExpChangeFunc(func)
    self.onExpChangeFunc = func
end

function KSFUN_LEVEL:SetNextLvExpFunc(func)
    self.nextLvExpFunc = func
end


function KSFUN_LEVEL:SetLevel(lv, notice)
    if self.onLvUpFunc then
        self.onLvUpFunc(self.inst, lv, notice)
    end
end


function KSFUN_LEVEL:GainExp(exp)
    self.exp = self.exp + exp

    local expFun = nil
    if self.nextLvExpFunc then
        expFun = self.nextLvExpFunc
    else
        expFun = defaultExpFunc
    end

     -- 计算可以升的级数
     local delta = 0
     while self.exp > expFun(self.level) do
         delta = delta + 1 
         self.exp = self.exp - expFun(self.level)
         self.level = self.level + 1
     end
 
     -- 大于0表示可以升级，触发升级逻辑
     if delta > 0 then
         self:SetLevel(self.level, true)
     end

end


function KSFUN_LEVEL:OnSave()
    return {
        lv = self.lv,
        exp = self.exp,
    }
end


function KSFUN_LEVEL:OnLoad(data)
    self.lv = data.lv or 0
    self.exp = data.exp or 0
end


return KSFUN_LEVEL