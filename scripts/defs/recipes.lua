-- 齿轮
AddRecipe2(
    "gears",
    {Ingredient("goldnugget", 10), Ingredient("redgem", 1), Ingredient("bluegem", 1)},
    TECH.LOST,
    nil,
    {"CHARACTER"}
)

-- 彩虹宝石
AddRecipe2(
    "opalpreciousgem",
    {Ingredient("redgem", 1), Ingredient("bluegem", 1), Ingredient("purplegem", 1), 
    Ingredient("greengem", 1), Ingredient("yellowgem", 1),Ingredient("orangegem", 1)},
    TECH.LOST,
    nil,
    {"CHARACTER"}
)


local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local PREFIX = "ksfun_potion_"
local potions = {
    NAMES.PICK,
    NAMES.SANITY
}

local recipes = require("defs/ksfun_recipes_defs")
for k, v in pairs(recipes) do
    for k1, v1 in pairs(v) do
        local ingredients = {}
        for m, num in pairs(v1.materials) do
            local atlas = nil
            local image = nil
            ---@diagnostic disable-next-line: undefined-field
            if table.contains(potions, m) then
                atlas = "images/inventoryitems/ksfun_potions.xml"
                image = m..".tex"
                m = PREFIX..m
            end
            table.insert(ingredients, Ingredient(m, num, atlas, nil, image))
        end

        local placer = nil
        if v1.placer ~= 0 then
            placer = {
                altlas = "images/buildings.xml",
                image  = k1..".tex"
            }
        end
        AddRecipe2(
            k1, ingredients, TECH.LOST, placer, { "CHARACTER"}
        )
    end
end