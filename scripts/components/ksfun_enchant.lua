local MATERIALS = require "defs/ksfun_materials"
local EQUIPMENTS = require "defs/ksfun_items_def"



---comment 判断属性是否能不能附加到目标上
---@param target table 目标物品
---@param power string 属性
---@return boolean 
local function isValidPower(target, power)
    local data = EQUIPMENTS.ksfunitems[target.prefab]
    if data and data.names then
         ---@diagnostic disable-next-line: undefined-field
         return table.contains(data.names, power)
    end
    return false
end



---comment 添加属性
---@param inst table 物品 
---@param power string 属性
---@param doer table 玩家
local function addNewPower(inst, power, doer)
    local ret = inst.components.ksfun_power_system:AddPower(power)
    local username = doer.name or STRINGS.NAMES[string.upper(doer.prefab)] or ""
    local instname = STRINGS.NAMES[string.upper(inst.prefab)]
    local pname    = STRINGS.NAMES[string.upper(ret.prefab)]
    local msg  = string.format(STRINGS.KSFUN_ENHANT_SUCCESS, username, instname, pname)
    KsFunShowNotice(msg)
end




local Enchant = Class(
    function (self, inst)
        self.inst = inst
        self.enable = false
    end
)



--- comment 启用功能
function Enchant:Enable()
    self.enble = true
end



function Enchant:Enchant(gem, doer)
    if not self.enble then
        return false
    end

    -- 判断是不是宝石
    local power = MATERIALS.GetGemEnchantPower(gem, doer)

    if power and isValidPower(self.inst, power) then
        local system = self.inst.components.ksfun_power_system
        local level  = self.inst.components.ksfun_level
        if system and level then
            local existed = system:GetPower(power)
            if not existed then
                local cnt = system:GetPowerNum()
                if cnt < level:GetLevel() then
                    addNewPower(self.inst, power, doer)
                    return true
                end
            else
                level:DoDelta(1)
                return true
            end
        end
    end
    return false
end



function Enchant:OnSave()
    return {
        enable = self.enble
    }
end



function Enchant:OnLoad(data)
    self.enble = data.enable
end



return Enchant