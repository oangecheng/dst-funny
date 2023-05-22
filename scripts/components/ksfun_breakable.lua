
local KSFUN_BREAKABLE = Class(function(self, inst)
    self.inst = inst
    self.breakitems = {}
end)


function KSFUN_FORGABLE:AddBreakItem(item)
    if not table.contains(self.breakitems, item) then
        table.insert(self.breakitems, item)
    end
end


--- 判断是否是可突破材料
function KSFUN_FORGABLE:IsBreakItem(item)
    return table.contains(self.breakitems, item)
end


function KSFUN_FORGABLE:OnSave()
    return {
        breakitems = self.breakitems,
    }
end


function KSFUN_FORGABLE:OnLoad(data)
    self.breakitems = data.breakitems or {}
end


return KSFUN_BREAKABLE 