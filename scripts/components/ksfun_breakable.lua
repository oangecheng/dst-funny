
local KSFUN_BREAKABLE = Class(function(self, inst)
    self.inst = inst
    self.breakitems = {}

    self.onBreakFunc = nil
end)


function KSFUN_BREAKABLE:SetOnBreakFunc(func)
    self.onBreakFunc = func
end


function KSFUN_BREAKABLE:Break(item)
    if self:IsBreakItem(item.prefab) then
        if self.onBreakFunc then
            self.onBreakFunc(self.inst, item)
            item:DoTaskInTime(0, item:Remove())
        end
    end
end


function KSFUN_BREAKABLE:SetItems(itemprefabs)
    self.breakitems = itemprefabs
end


function KSFUN_BREAKABLE:AddBreakItem(itemprefab)
    if not table.contains(self.breakitems, itemprefab) then
        table.insert(self.breakitems, itemprefab)
    end
end


--- 判断是否是可突破材料
function KSFUN_BREAKABLE:IsBreakItem(itemprefab)
    return table.contains(self.breakitems, itemprefab)
end


function KSFUN_BREAKABLE:OnSave()
    return {
        breakitems = self.breakitems,
    }
end


function KSFUN_BREAKABLE:OnLoad(data)
    self.breakitems = data.breakitems or {}
end


return KSFUN_BREAKABLE 