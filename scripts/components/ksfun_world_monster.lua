
local function nextLvExp(currentlv)
    return KSFUN_TUNING.DEBUG and 1 or (currentlv + 1) * 10
end


local MONSTER = Class(function(self, inst)
    self.inst = inst
    self.monsterdata = {}
end)


--- 击杀怪物会提升怪物等级
function MONSTER:GainMonsterExp(prefab, exp)    
    local data = self.monsterdata[prefab] or {lv = 0, exp = 0}
    data.exp = data.exp + exp
    -- 计算可以升的级数
    while data.exp >= nextLvExp(data.lv) do
        data.exp = data.exp - nextLvExp(data.lv)
        data.lv = data.lv + 1
    end
    self.monsterdata[prefab] = data
end



function MONSTER:GetMonsterLevel(prefab)
    local data = self.monsterdata[prefab]
    return data and data.lv or 0
end


function MONSTER:OnSave()
    return {
        monsterdata = self.monsterdata
    }
end


function MONSTER:OnLoad(data)
    self.monsterdata = data.monsterdata or {}
end


return MONSTER