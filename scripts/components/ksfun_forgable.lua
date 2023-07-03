
local function forg(self, doer, item)
    -- 没有升级组件，强化失效
    KsFunLog("forg", item.prefab)
    local ksfunlv = self.inst.components.ksfun_level
    if ksfunlv == nil then return end

    local stackable = item.components.stackable
    local count = stackable and stackable:StackSize() or 1
    local exp = self.items[item.prefab] or 1
    local left = count

    for i = 1, count do
        if not ksfunlv:IsMax() then
            left = left - 1
            ksfunlv:GainExp(exp)
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

    self.onforgtest = nil
    self.onforgsuccess = nil
end)


--- 尝试锻造，支持批量
--- @param item 物品inst
function KSFUN_FORGABLE:Forg(doer, item)
    if self:IsForgItem(item.prefab) then
        -- 如果有前置判断，先判断能否进行升级
        if self.onforgtest == nil or self.onforgtest(doer, item) then
            forg(self, doer, item)
            -- 通知锻造成功
            if self.onforgsuccess then
                self.onforgsuccess(doer, item)
            end
            return true
        end
    end
    return false
end


function KSFUN_FORGABLE:SetOnForgTestFunc(func)
    self.onforgtest = func
end


function KSFUN_FORGABLE:SetOnForgSuccessFunc(func)
    self.onforgsuccess = func
end

function KSFUN_FORGABLE:SetForgItems(itemprefabs)
    self.items = itemprefabs
end


function KSFUN_FORGABLE:IsForgItem(itemprefab)
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