
local function forg(self, item)
    -- 没有升级组件，强化失效
    local ksfunlv = self.inst.components.ksfun_level
    if ksfunlv == nil then return end

    local stackable = item.components.stackable
    local count = stackable and stackable:StackSize() or 1
    local exp = self.forgitems[item.prefab]
    local left = count

    for i = 1, count do
        if not ksfunlv:IsMax() then
            left = left - 1
            local r = math.random(100)
            if r > self.ratio * 100 then
                ksfunlv:GainExp(exp)
            end
        end
    end
    
    if left > 0 then
        if stackable then
            stackable:SetStackSize(left)
        end
    else
        item:Remove()
    end
end


local KSFUN_FORGABLE = Class(function(self, inst)
    self.inst = inst
    self.forgitems = {}
    self.ratio = 1

    --- 锻造成功
    self.onForgFunc = nil
    self.onFailFunc = nil
end)


function KSFUN_FORGABLE:SetSuccessRatio(ratio)
    self.ratio = ratio
end


function KSFUN_FORGABLE:SetOnForgFunc(func)
    self.onForgFunc = func
end


function KSFUN_FORGABLE:SetOnFailFunc(func)
    self.onFailFunc = func
end


--- 尝试锻造，支持批量
--- @param item 物品inst
function KSFUN_FORGABLE:Forg(item)
    if self:IsForgItem(item.prefab) then
        forg(self, item)
    end
end


--- 添加强化材料
--- @param itemprefab 物品代码
--- @param exp 物品经验值
--- forgitems = {name = exp}
function KSFUN_FORGABLE:AddForgItem(itemprefab, exp)
    if not table.contains(self.forgitems, itemprefab) then
        self[itemprefab] = exp
    end
end


function KSFUN_FORGABLE:SetForgItems(itemprefabs)
    self.forgitems = itemprefabs
end


function KSFUN_FORGABLE:IsForgItem(item)
    return table.contains(self.forgitems, item)
end



function KSFUN_FORGABLE:OnSave()
    return { 
        forgitems = self.forgitems,
        ratio = self.ratio
     }
end


function KSFUN_FORGABLE:OnLoad(data)
    self.forgitems = data.forgitems or {}
    self.ratio = data.ratio or 1
end


return KSFUN_FORGABLE