
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
--- 定义可升级物品的配置
--- @param list 可以升级的物品列表
--- @param powernames 物品能够获取哪些能力
--- @param enhantitems 附魔需要的材料，现在统一使用的彩虹宝石
--- 附魔材料后面可以按照不同的属性定义不同的材料，比如锋锐需要犀牛角
local function initKsFunItems(list, powernames, enhantitems)
    for i, v in ipairs(list) do
        ksfunitems[v] = {
            names = powernames,
            items = enhantitems,
        }
    end
end


---在这里定义武器能具备哪些属性
local weaponnames = {
    NAMES.DAMAGE,
    NAMES.CHOP, 
    NAMES.MINE, 
    NAMES.LIFESTEAL,
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
}

---武器拥有，加攻，砍树，挖矿，生命窃取
initKsFunItems(itemsdef.weapon, weaponnames,  {"opalpreciousgem"})
---帽子拥有，保暖，防水，恢复精神
initKsFunItems(itemsdef.hat, hatnames, {"opalpreciousgem"})
---帽子拥有，保暖，防水，恢复精神
initKsFunItems(itemsdef.armor, armornames, {"opalpreciousgem"})


itemsdef.ksfunitems = ksfunitems

return itemsdef