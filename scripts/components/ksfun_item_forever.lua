
local itemsdef = {
    "goldnugget"
}


local function isValidItem(self, item)
    if item.prefab == itemsdef[1] then
        return true
    end
    return false
end


local function setItemEnable(self, enable)
    local weapon = self.inst.components.weapon
    if weapon then
        if enable then
            weapon:SetDamage(self.data.damage)
        else
            weapon:SetDamage(0)
        end
    end

    local system = self.inst.components.ksfun_power_system
    if system then
        system:SetEnable(enable)
    end
end


local function traderTest(self, item, giver)
    if self.enable then
        if isValidItem(self, item) then
            return true
        end
    end
    return false
end



local function onAccept(self, giver, item)
    KsFunLog("onAccept", item.prefab, self.enable)

    if not self.enable then return end
    if not isValidItem(self, item) then return end

    local finiteuses = self.inst.components.finiteuses
    local armor = self.inst.components.armor

    -- 武器
    if finiteuses then
        local percent = finiteuses:GetPercent() + 0.2
        finiteuses:SetPercent(percent)
    -- 盔甲
    elseif armor then
        local percent = armor:GetPercent() + 0.2
        armor:SetPercent(percent)
    end
    -- 衣服帽子用针线包吧（虽然修复材料有点廉价），但是不想单独兼容了
end


--- 初始化交易组件，和其他mod兼容
local function initTrader(self)
    local trader = self.inst.components.trader
    local oldTradeTest = trader.abletoaccepttest
    trader:SetAbleToAcceptTest(function(inst, item, giver)
        if traderTest(self, item, giver) then
            return true
        end
        if oldTradeTest and oldTradeTest(inst, item, giver) then
            return true
        end
        return false
    end)

    local oldaccept = trader.onaccept
    trader.onaccept = function(inst, giver, item)
        onAccept(self, giver, item)
        if oldaccept ~= nil then
            oldaccept(inst, giver, item)
        end
        giver.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    end
end



local FOREVER = Class(function(self, inst)
    self.inst = inst
    self.enable = false

    self.data = {}

    -- 武器数据缓存
    if inst.components.weapon then
        self.data.damage = inst.components.weapon.damage
    end
 

    ---加上交易组件
    if inst.components.trader == nil then
        inst:AddComponent("trader")
    end
    initTrader(self)


    -- 监听装备时间，缓存owner
    self.inst:ListenForEvent("equipped", function(inst, data)
        self.inst.ksfunitemowner = data.owner
    end)

    --- 修改官方函数容易引发bug，所以这里采用耐久小于10%时自动卸下装备的机制，避免物品被移除
    --- 如果一不小心弄没了，回档吧大宝贝
    self.inst:ListenForEvent("percentusedchange", function(inst, data)
        if self.enable and data.percent <= 0.05 and inst.components.equippable then
            local inventory = self.inst.ksfunitemowner and self.inst.ksfunitemowner.components.inventory or nil
            if inventory then
                local slot = inventory:IsItemEquipped(inst)
                if slot then
                    local item = inventory:Unequip(slot)
                    inventory:GiveItem(item)
                end 
            end
        end
    end)
end)


function FOREVER:Enable()
    self.enable = true

    -- 物品耐久为0不消失，不采用这种方式，修改官方api
    -- --- 启用时，物品不会被移除，这里只修改可升级的武器
    -- if self.inst.components.finiteuses then
    --     self.inst.components.finiteuses:SetOnFinished(function(inst)
    --         setItemEnable(self, false)
    --     end)
    -- end

    -- --- 由于官方机制设定，护甲类型的物品耐久为0会被移除
    -- --- 修改官方函数容易引发bug，所以这里采用耐久小于10%时自动卸下装备的机制，避免损坏
    -- if self.inst.components.armor then
    --     self.inst:ListenForEvent("percentusedchange", function(inst, data)
    --         if data.percent <= 0.1 and inst.components.equippable then
    --             if self.inst.ksfunitemowner then
    --                 inst.components.equippable:Unequip(self.inst.ksfunitemowner)
    --             end
    --         end
    --     end)
    -- end

    -- if self.inst.components.fueled then
    --     self.inst.components.fueled:SetDepletedFn(function(inst)
    --         setItemEnable(self, false)
    --     end)
    -- end
end


function FOREVER:OnSave()
    return {
        enable = self.enable,
        data   = self.data,
    }
end


function FOREVER:OnLoad(data)
    self.enable = data.enable
    self.data   = data.data
end



return FOREVER