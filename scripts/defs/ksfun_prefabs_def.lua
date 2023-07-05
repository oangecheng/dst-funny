


local taskpicklist = {
    ["grass"] = 1,   -- 草
    ["sapling"] = 1,  -- 树枝
    ["flower"] = 1, -- 花
    ["carrot_planted"] = 1, -- 胡萝卜

    ["reeds"] = 1, -- 芦苇
    ["flower_evil"] = 1,  -- 恶魔花

    ["berrybush"] = 2,  -- 浆果丛1
    ["berrybush2"] = 2, -- 浆果丛2
    ["berrybush_juicy"] = 2, -- 多汁浆果

    ["cactus"] = 2,  -- 仙人掌1
    ["oasis_cactus"] = 2, -- 仙人掌2
    ["red_mushroom"] = 2, -- 红蘑菇
    ["green_mushroom"] = 2, -- 绿蘑菇
    ["blue_mushroom"] = 2, -- 蓝蘑菇
    ["cave_fern"] = 1, -- 蕨类植物 
    ["cave_banana_tree"] = 2, -- 洞穴香蕉 
    ["lichen"] = 2,  -- 洞穴苔藓
    ["marsh_bush"] = 2, -- 荆棘丛
    ["flower_cave"] = 2, -- 荧光果
    ["flower_cave_double"] = 2, -- 荧光果2 
    ["flower_cave_triple"] = 2, -- 荧光果3 
    ["sapling_moon"] = 2, -- 月岛树枝
    ["succulent_plant"] = 2, -- 多肉植物
    ["bullkelp_plant"] = 2, -- 公牛海带
    ["wormlight_plant"] = 2, -- 荧光植物
    ["stalker_fern"] = 2, -- 蕨类植物
    ["rock_avocado_bush"] = 2, -- 石果树
    ["oceanvine"] = 2, -- 苔藓藤条
    ["bananabush"] = 2, -- 香蕉丛
}

local extra = {
    ["stalker_berry"] = 2, -- 神秘植物
    ["stalker_bulb"] = 2, -- 荧光果1，编织者召唤的
    ["stalker_bulb_double"] = 2, -- 荧光果2，编织者召唤的
    ["rosebush"] = 2, -- 棱镜蔷薇花
    ["orchidbush"] = 2, -- 棱镜兰草花
    ["lilybush"] = 2, -- 棱镜蹄莲花
    ["monstrain"] = 2, -- 棱镜雨竹
    ["shyerryflower"] = 2, -- 棱镜颤栗花
}


-- 可以额外采集的
local pickabledefs = MergeMaps(taskpicklist, extra)




local fishes = {
    ["oceanfish_small_1_inv"]  = 1,
    ["oceanfish_small_2_inv"]  = 1,
    ["oceanfish_small_3_inv"]  = 1,
    ["oceanfish_small_4_inv"]  = 1,
    ["oceanfish_small_5_inv"]  = 1,
    ["oceanfish_small_6_inv"]  = 1,
    ["oceanfish_small_7_inv"]  = 3,
    ["oceanfish_small_8_inv"]  = 3,
    ["oceanfish_small_9_inv"]  = 3,

    ["oceanfish_medium_1_inv"] = 2,
    ["oceanfish_medium_2_inv"] = 2,
    ["oceanfish_medium_3_inv"] = 2,
    ["oceanfish_medium_4_inv"] = 2,
    ["oceanfish_medium_5_inv"] = 2,
    ["oceanfish_medium_6_inv"] = 3,
    ["oceanfish_medium_7_inv"] = 3,
    ["oceanfish_medium_8_inv"] = 3,

    ["wobster_moonglass"]      = 3,
    ["wobster_sheller"]        = 3,
    ["fish"]                   = 1,
    ["eel"]                    = 2,
}


local ponds = {
    "pond", "pond_cave", "pond_mos", "oasislake"
}







local prefabs = {
    pickable     = pickabledefs,
    taskpickable = taskpicklist,
    fishes       = fishes,
    ponds        = ponds,
}

return prefabs