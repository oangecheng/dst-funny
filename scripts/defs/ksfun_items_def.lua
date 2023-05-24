
local NAMES = KSFUN_TUNING.ITEM_POWER_NAMES


local itemsdef = {
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
local powernames = {}
local function setItemHantableNames(list, names)
    for i, v in ipairs(list) do
        powernames[v] = names
    end
end
setItemHantableNames(itemsdef.weapon, {NAMES.DAPPERNESS})
setItemHantableNames(itemsdef.hat,    {NAMES.DAPPERNESS, NAMES.WATER_PROOFER, NAMES.INSULATOR})
setItemHantableNames(itemsdef.armor,  {NAMES.DAPPERNESS, NAMES.WATER_PROOFER, NAMES.INSULATOR})



--- 定义哪些物品能够给目标物品添加词缀
local enhantitems = {}
local function setItemHantableItems(list, itemprefabs)
    for i, v in ipairs(list) do
        enhantitems[v] = itemprefabs
    end
end
setItemHantableItems(itemsdef.weapon, {"opalpreciousgem"})
setItemHantableItems(itemsdef.hat,    {"opalpreciousgem"})
setItemHantableItems(itemsdef.armor,  {"opalpreciousgem"})


local items = {}

items.powernames = powernames
items.enhantitems = enhantitems

return items