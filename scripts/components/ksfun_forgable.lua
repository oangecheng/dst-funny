

local function forg(self, item, maxcount)
    -- 成功次数
    local successcount = 0

    local itemcount = 1

    local stackable = item.components.stackable
    if stackable then
        itemcount = stackable:StackSize()
    end
    -- 锻造次数
    local forgcount = math.min(maxcount or 1, itemcount)
    for i = 1, forgcount do
        local r = math.random(100)
        if r > self.ratio * 100 then
            successcount = successcount + 1
        end       
    end

    if stackable then
        local size = stackable:StackSize()
        local left = size - forgcount
        if left > 0 then
            stackable:SetStackSize(left)
        else
            item:Remove()
        end
    else
        item:Remove()
    end

    return successcount
end



local KSFUN_FORGABLE = Class(function(self, inst)
    self.inst = inst
    self.forgitems = {}
    self.ratio = 1

    --- 锻造成功
    self.onSuccessFunc = nil
    --- 不可锻造
    self.onInvalidFunc = nil
    --- 锻造失败
    self.onFailFunc = nil
end)


function KSFUN_FORGABLE:SetSuccessRatio(ratio)
    self.ratio = ratio
end


function KSFUN_FORGABLE:SetOnSuccessFunc(func)
    self.onSuccessFunc = func
end

function KSFUN_FORGABLE:SetOnFailFunc(func)
    self.onFailFunc = func
end

function KSFUN_FORGABLE:SetOnInvalidFunc(func)
    self.onInvalidFunc = func
end

--- 尝试锻造，支持批量
--- @param item 物品inst
--- @param maxcount 最大锻造次数，不设置默认为1
function KSFUN_FORGABLE:Forg(item)
    if self:IsForgItem(item.prefab) then

        local maxcount = 1
        if self.inst.components.ksfun_level then
            maxcount = self.inst.components.ksfun_level:GetLeftUpCount()
        end
        -- 可升级次数为0时，不可锻造，直接通知
        if maxcount == 0 then
            if self.onForgInvalidFunc then
                self.onInvalidFunc(self.inst, {item = item, msg = STRINGS.KSFUN_FORG_FAIL_MSG_2})
            end
            return
        end

        local successcount = forg(self, item, maxcount)
        if successcount > 0 then
            if self.onForgSuccessFunc then
                self.onSuccessFunc(self.inst, {successcount = successcount})
            end
        else
            if self.onForgFailFunc then
                self.onFailFunc(self.inst)
            end
        end
    else
        if self.onForgInvalidFunc then
            self.onInvalidFunc(self.inst, {item = item, msg = STRINGS.KSFUN_FORG_FAIL_MSG_1})
        end
    end
end


function KSFUN_FORGABLE:AddForgItem(itemprefab)
    if not table.contains(self.forgitems, itemprefab) then
        table.insert(self.forgitems, itemprefab)
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