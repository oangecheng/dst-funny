

local function forg(self, item, maxcount)
    -- 成功次数
    local successcount = 0

    local itemcount = 1
    if item.components.stackable then
        itemcount = item.components.stackable:StackSize()
    end
    -- 锻造次数
    local forgcount = math.min(maxcount or 1, itemcount)
    for i = 1, forgcount do
        local r = math.random(100)
        if r > self.ratio * 100 then
            successcount = successcount + 1
        end       
    end

    return {
        item = item,
        count = forgcount,
        success = successcount
    }
end



local KSFUN_FORGABLE = Class(function(self, inst)
    self.inst = inst
    self.forgitems = {}
    self.ratio = 0.8

    --- 锻造成功
    self.onForgSuccessFunc = nil
    --- 不可锻造
    self.onForgInvalidFunc = nil
    --- 锻造失败
    self.onForgFailFunc = nil
end)


function KSFUN_FORGABLE:SetForgSuccessRatio(ratio)
    self.ratio = ratio
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
                self.onForgInvalidFunc(self.inst, {item = item, msg = STRINGS.KSFUN_FORG_FAIL_MSG_2})
            end
            return
        end

        local data = forg(self, item, maxcount)
        if data.success > 0 then
            if self.onForgSuccessFunc then
                self.onForgSuccessFunc(self.inst, data)
            end
        else
            if self.onForgFailFunc then
                self.onForgFailFunc(self.inst, data)
            end
        end
    else
        if self.onForgInvalidFunc then
            self.onForgInvalidFunc(self.inst, {item = item, msg = STRINGS.KSFUN_FORG_FAIL_MSG_1})
        end
    end
end


function KSFUN_FORGABLE:AddForgItem(itemprefab)
    if not table.contains(self.forgitems, itemprefab) then
        table.insert(self.forgitems, itemprefab)
    end
end


function KSFUN_FORGABLE:IsForgItem(item)
    return table.contains(self.forgitems, item)
end



function KSFUN_FORGABLE:OnSave()
    return { forgitems = self.forgitems }
end


function KSFUN_FORGABLE:OnLoad(data)
    self.forgitems = data.forgitems or {}
    self.ratio = data.ratio or 0.8
end


return KSFUN_FORGABLE