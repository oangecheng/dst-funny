local ZxrpgExp = Class(function(self, inst)
    self.inst = inst
    self.level = 0
    self.exp = 0
    self.onlevelup = nil
end)


-- 获取下一次升级所需要的经验
local function requireExp()
    return (self.level + 1) * 100
end


local function onLevelUp()
    self.level = self.level + 1
end


function ZxrpgExp:addExp(exp)
    self.exp = self.exp + exp

    local delta = 0
    while self.exp > requireExp() do
        delta = delta + 1 
        self.exp = self.exp - requireExp()
        onLevelUp()
    end

    if delta > 0 then
        self.inst:PushEvent("zxrpg_levelup", {data = delta})
    end
end

function ZxrpgExp:getExp()
    return self.exp
end


function ZxrpgExp:OnSave() 
    return  {
        level = self.level,
        exp = self.exp
    }
end

function ZxrpgExp:OnLoad(data)
    self.level = data.level or 0
    self.exp = data.exp or 0
end

return ZxrpgExp