
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
local ksfunitems = {}
local function initKsFunItems(list, powernames, enhantitems)
    for i, v in ipairs(list) do
        ksfunitems[v] = {
            names = powernames,
            items = enhantitems,
        }
    end
end
initKsFunItems(itemsdef.weapon, {NAMES.DAMAGE, NAMES.CHOP}, {"opalpreciousgem"})
initKsFunItems(itemsdef.hat,    {NAMES.DAPPERNESS, NAMES.WATER_PROOFER, NAMES.INSULATOR}, {"opalpreciousgem"})
initKsFunItems(itemsdef.armor,  {NAMES.DAPPERNESS, NAMES.WATER_PROOFER, NAMES.INSULATOR}, {"opalpreciousgem"})


itemsdef.ksfunitems = ksfunitems

return itemsdef