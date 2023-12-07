local REPAIRITEMS = require "defs/ksfun_materials"

-- 盔甲消耗的比较快，单独计算，20%以下就自动卸下
local function getUnequipPercent(inst)
    if inst.components.armor then return 0.2 end
    return 0.05 
end


local function autoUnequip(self)
    -- 监听装备时间，缓存owner
    self.inst:ListenForEvent("equipped", function(inst, data)
        self.inst.ksfunitemowner = data.owner
    end)

    --- 修改官方函数容易引发bug，所以这里采用耐久小于10%时自动卸下装备的机制，避免物品被移除
    --- 如果一不小心弄没了，回档吧大宝贝
    self.inst:ListenForEvent("percentusedchange", function(inst, data)
        if self.enable and data.percent <= getUnequipPercent(inst)then
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
end


local function onEnableFn(self, enable)
    if enable then
        self.inst:AddTag(KSFUN_TAGS.REPAIRABLE)
        autoUnequip(self)
        if self.onenablefn then
            self.onenablefn(self.inst)
        end
    end
end


-- 衣服帽子用针线包吧（虽然修复材料有点廉价），但是不想单独兼容了
local function doRepair(self, cnt)
    -- 武器或者工具
    local finiteuses = self.inst.components.finiteuses
    if finiteuses then
        local percent = math.min(finiteuses:GetPercent() + cnt, 1)
        finiteuses:SetPercent(percent)
    end
    
    -- 盔甲
    local armor = self.inst.components.armor
    if armor then
        local percent = math.min(armor:GetPercent() + cnt, 1)
        armor:SetPercent(percent)
    end
end




local Repairable = Class(
    function (self, inst)
        self.inst = inst
        self.enable = false
    end,
    nil,
    {
        enable = onEnableFn
    }
)


function Repairable:SetEnableFn(fn)
    self.onenablefn = fn
end

---comment 启用功能
function Repairable:Enable()
    self.enable = true
end


---comment 判断功能是否启用
---@return boolean
function Repairable:IsEnabled()
    return self.enable
end


---comment 修理物品
---@param material table 材料
---@param doer table 修理者
---@return boolean 是否修理成功
function Repairable:Repair(material, doer)
    local percent =  REPAIRITEMS.GetRepairItem(material, self.inst)
    if self:Enable() and percent then
        doRepair(self, material)
        return true
    end
    return false
end


function Repairable:OnLoad(data)
    self.enable = data.enable or false
end


function Repairable:OnSave(data)
    return {
        enable = self.enable
    }
end


return Repairable