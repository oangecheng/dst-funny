
local NAMES = KSFUN_TUNING.ITEM_POWER_NAMES


local itemsdef = {
    weapon = {
        "spear", -- 长矛
        "spear_wathgrithr", -- 战斗长矛
        "ruins_bat", -- 铥矿棒，可升级的铥矿棒
        "nightsword", -- 暗影剑
        "glasscutter", -- 玻璃刀
    },
    hat = {
        "eyebrellahat",
        "walrushat",
        -- "alterguardianhat",  -- 暂时不开，有bug
    },
    armor = {
        "armorwood",
        "armorruins",
    },
    gems = {}
}

itemsdef.enhantitems = {}

-- 属性宝石
for k,v in pairs(NAMES) do
    table.insert(itemsdef.gems, "ksfun_power_gem_"..v)
    itemsdef.enhantitems["ksfun_power_gem_"..v] = v
end



--- 定义每种类型的物品能添加哪些属性
local ksfunitems = {}
--- 定义可升级物品的配置
--- @param list 可以升级的物品列表
--- @param powernames 物品能够获取哪些能力
local function initKsFunItems(list, powernames)
    for i, v in ipairs(list) do
        ksfunitems[v] = {
            names = powernames,
        }
    end
end


local function initKsFunPowerEnhantItems()
    itemsdef.enhantitems = {}
    for i,v in ipairs(NAMES) do
        itemsdef.enhantitems[v] = "ksfun_power_gem_"..v 
    end
end


---在这里定义武器能具备哪些属性
local weaponnames = {
    NAMES.DAMAGE,
    NAMES.CHOP, 
    NAMES.MINE, 
    NAMES.LIFESTEAL,
    NAMES.AOE,
    NAMES.MAXUSES,
    NAMES.SPEED,
}

local hatnames = {
    NAMES.DAPPERNESS, 
    NAMES.WATER_PROOFER, 
    NAMES.INSULATOR,
}

local armornames = {
    NAMES.DAPPERNESS, 
    NAMES.WATER_PROOFER, 
    NAMES.INSULATOR,
    NAMES.MAXUSES,
    NAMES.ABSORB,
}

---武器拥有，加攻，砍树，挖矿，生命窃取
initKsFunItems(itemsdef.weapon, weaponnames)
---帽子拥有，保暖，防水，恢复精神
initKsFunItems(itemsdef.hat, hatnames)
---护甲拥有，保暖，防水，恢复精神
initKsFunItems(itemsdef.armor, armornames)


itemsdef.ksfunitems = ksfunitems

return itemsdef