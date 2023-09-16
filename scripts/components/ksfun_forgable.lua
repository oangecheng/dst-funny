
local function forg(self, doer, item)
    -- 没有升级组件，强化失效
    local ksfunlv = self.inst.components.ksfun_level
    if ksfunlv == nil then return end

    local stackable = item.components.stackable
    local count = stackable and stackable:StackSize() or 1
    local exp = self.items[item.prefab] or 1
    local left = count

    for i = 1, count do
        if not ksfunlv:IsMax() then
            left = left - 1
            ksfunlv:DoExpDelta(exp)
        end
    end
    
    if left > 0 then
        if stackable then
            stackable:SetStackSize(left)
        end
    else
        item:DoTaskInTime(0, item:Remove())
    end
end


local KSFUN_FORGABLE = Class(function(self, inst)
    self.inst = inst
    self.items = {}

    self.forgTest = nil
    self.onForg = nil
end)


function KSFUN_FORGABLE:SetForgTest( func )
    self.forgTest = func
end


function KSFUN_FORGABLE:SetOnForg( func )
    self.onForg = func
end


function KSFUN_FORGABLE:CanForg(doer, material)
    if self:IsForgItem(material.prefab) then
       return self.forgTest == nil and true or self.forgTest(self.inst, doer, material)
    end
    return false
end


--- 尝试锻造，支持批量
--- @param item table 物品inst
function KSFUN_FORGABLE:Forg(doer, item)
    if self:CanForg(doer, item) then
        forg(self, doer, item)
        if self.onForg then
            self.onForg(self.inst, doer, item)
        end
    end
end


function KSFUN_FORGABLE:SetForgItems(itemprefabs)
    self.items = itemprefabs
end


function KSFUN_FORGABLE:IsForgItem(itemprefab)
    ---@diagnostic disable-next-line: undefined-field
    return table.containskey(self.items, itemprefab)
end


function KSFUN_FORGABLE:OnSave()
    return { 
        items  = self.items,
     }
end


function KSFUN_FORGABLE:OnLoad(data)
    self.items = data.items or {}
end


return KSFUN_FORGABLE