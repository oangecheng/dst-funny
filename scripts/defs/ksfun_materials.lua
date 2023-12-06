local ITEM_NAMES =  KSFUN_TUNING.ITEM_POWER_NAMES

--- 修复材料
local REPAIRITEMS = {
    goldnugget = 0.2
}


---- 强化材料
local FORGITEMS = {}
FORGITEMS[ITEM_NAMES.LIFESTEAL]  = { mosquitosack = 20, spidergland = 10 }
FORGITEMS[ITEM_NAMES.AOE]        = { minotaurhorn = 1000}
FORGITEMS[ITEM_NAMES.MINE]       = { marble = 50, nitre = 100,  flint = 10, rocks = 10}
FORGITEMS[ITEM_NAMES.CHOP]       = { livinglog = 50, log = 10,}
FORGITEMS[ITEM_NAMES.MAXUSES]    = { dragon_scales = 20, }
FORGITEMS[ITEM_NAMES.DAMAGE]     = { houndstooth = 5, stinger = 5 }
FORGITEMS[ITEM_NAMES.INSULATOR]  = { trunk_winter = 100, trunk_summer = 80, silk = 5, beefalowool = 5 }
FORGITEMS[ITEM_NAMES.DAPPERNESS] = { nightmarefuel = 5, spiderhat = 10,  walrushat = 30 }
FORGITEMS[ITEM_NAMES.WATER]      = { pigskin = 1, tentaclespots = 10 }
FORGITEMS[ITEM_NAMES.SPEED]      = { walrus_tusk = 300 }
FORGITEMS[ITEM_NAMES.ABSORB]     = { steelwool = 20 }



--- 附魔宝石, k = 宝石， v = 属性名称
local GEMS = {}
for _, v in pairs(ITEM_NAMES) do
    GEMS["ksfun_power_gem_"..v] = v
end








local defs = {}


---comment 获取强化属性的材料
---@param name string|nil 属性名称,不传name会返回整个列表
---@return table 材料列表
defs.GetForgItems = function (name)
    if name then
        return FORGITEMS[name]
    end
    local map = {}
    for _, v in pairs(FORGITEMS) do
        MergeMaps(map, v)
    end
    return map
end


---comment 获取所有修理材料
---@return table 材料列表
defs.GetRepairItems = function ()
    return REPAIRITEMS
end

---comment 获取材料能够维修的值，返回nil则不是可用的材料
---@param material table 材料
---@param target table 目标
---@return number|nil 维修值
defs.GetRepairItem = function (material, target)
    return material and REPAIRITEMS[material.prefab] or nil
end



---comment 查找能够附魔的属性
---@param gem table 宝石
---@param target table 目标装备
---@return nil|string 属性名称
defs.GetGemEnchantPower = function (gem, target)
    return gem and GEMS[gem.prefab] or nil
end




return defs
