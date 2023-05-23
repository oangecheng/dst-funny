
local NAMES = KSFUN_TUNING.ITEM_POWER_NAMES


local items = {
    weapon = {
        "spear", -- 长矛
        "spear_wathgrithr", -- 战斗长矛
        "ruins_bat", -- 铥矿棒，可升级的铥矿棒
        "nightsword", -- 暗影剑
        "hambat", -- 火腿棒
    },
    hat = {
        "beefalohat",
        "eyebrellahat",
        "walrushat",
        "alterguardianhat",
    },
    armor = {
        "armorwood",
        "armorruins",
    },
}


--- 定义每种类型的物品能添加哪些属性
local itemnames = {}
local function setItemHantableNames(list, names)
    for i, v in ipairs(list) do
        itemnames[v] = names
    end
end
setItemHantableNames(items.weapon, {NAMES.DAPPERNESS})
setItemHantableNames(items.hat,    {NAMES.DAPPERNESS, NAMES.WATER_PROOFER, NAMES.INSULATOR})
setItemHantableNames(items.armor,  {NAMES.DAPPERNESS, NAMES.WATER_PROOFER, NAMES.INSULATOR})



--- 定义哪些物品能够给目标物品添加词缀
local itemhantitems = {}
local function setItemHantableItems(list, hantitems)
    for i, v in ipairs(list) do
        itemhantitems[v] = hantitems
    end
end
setItemHantableItems(items.weapon, {"opalpreciousgem"})
setItemHantableItems(items.hat,    {"opalpreciousgem"})
setItemHantableItems(items.armor,  {"opalpreciousgem"})



items.names = itemnames
items.hantitems = itemhantitems

return items