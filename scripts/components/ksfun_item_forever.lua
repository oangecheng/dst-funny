
local itemsdef = {
    "goldnugget"
}


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
        if item.prefab == itemsdef[1] then
            return true
        end
    end
    return false
end


local function onAccept(self, giver, item)
    local finiteuses = self.inst.components.finiteuses
    KsFunLog("onAccept", item.prefab)
    if self.enable and finiteuses then
        if item.prefab == itemsdef[1] then
            local percent = finiteuses:GetPercent() + 0.2
            KsFunLog("onAccept", percent)
            finiteuses:SetPercent(percent)
            setItemEnable(self, true)
        end
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

    
end)


function FOREVER:Enable()
    self.enable = true

    --- 启用时，物品不会被移除
    if self.inst.components.finiteuses then
        self.inst.components.finiteuses:SetOnFinished(function(inst)
            setItemEnable(self, false)
        end)
    end
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
    if self.enable then
        self:Enable()
    end
end



return FOREVER