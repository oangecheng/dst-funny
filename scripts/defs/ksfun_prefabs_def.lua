


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
    ["mandrake_berry"] = 2, -- 勋章曼德拉果
}



-- 可以额外采集的
local pickabledefs = MergeMaps(taskpicklist, extra)



--------------------------------------------- 烹调任务定义 -------------------------------------
local foodsdef = require("preparedfoods")
--- 食物定义
local foods = {}
for k, v in pairs(foodsdef) do
    foods[v.name] = 2 
end
--- 原材料难得的难度高一点
foods["jellybean"]     = 3  -- 糖豆
foods["lobsterbisque"] = 3  -- 龙虾汤
foods["waffles"]       = 3  -- 华夫饼
foods["lobsterdinner"] = 3  -- 龙虾正餐





--------------------------------------------- 钓鱼任务定义---------------------------------------------------------------------
local oceanfishes = require("prefabs/oceanfishdef")
-- 鱼类定义
local taskfishes = {
    ["wobster_moonglass"]      = 3,
    ["wobster_sheller"]        = 3,
    ["eel"]                    = 2,
}

--- 任意一种海鱼的难度都是4
for k, v in pairs(oceanfishes.fish) do
    taskfishes[k] = 4
end


-- 池塘定义
local taskponds = {
    ["pond"] = 1, 
    ["pond_cave"] = 1, 
    ["pond_mos"] = 1, 
    ["oasislake"] = 2,
}



--- 矿石定义
local taskrocks = {
    ["rock1"] = 1,
    ["rock2"] = 1,
    ["rock_ice"] = 1,
    ["rock_moon"] = 2,
    ["saltstack"] = 3,
}



--- 树木tag定义
local tasktreetags = {
    ["tree"] = 1,
    ["deciduoustree"] = 2,
    ["evergreens"] = 2,
}



local taskdryitems = {
    ["monstermeat_dried"] = 1,
    ["smallmeat_dried"] = 1,
    ["meat_dried"] = 2,
    ["kelp_dried"] = 1,
}




--- 突破等级上限物品定义
local breakitemsdef = {
    ["goldnugget"] = 1,
    ["moonrocknugget"] = 2,
    ["redgem"] = 3,
    ["bluegem"] = 4,
    ["purplegem"] = 5,
    ["thulecite"] = 6,
    ["greengem"] = 7,
    ["orangegem"] = 8,
    ["yellowgem"] = 9,
    ["opalpreciousgem"] = 10
}





--- 物品定义
local itemsdef = {
    ["cutgrass"]            = { lv = 1, rcnt = 40 },     -- 草
    ["twigs"]               = { lv = 1, rcnt = 40 },     -- 树枝
    ["rocks"]               = { lv = 1, rcnt = 40 },     -- 石头
    ["flint"]               = { lv = 1, rcnt = 20 },     -- 燧石
    ["log"]                 = { lv = 1, rcnt = 20 },     -- 木头
    ["poop"]                = { lv = 1, rcnt = 20 },     -- 便便
    ["charcoal"]            = { lv = 1, rcnt = 20 },     -- 木炭
    ["cutreeds"]            = { lv = 1, rcnt = 20 },     -- 芦苇
    ["spidergland"]         = { lv = 1, rcnt = 10 },     -- 蜘蛛胰腺
    ["silk"]                = { lv = 1, rcnt = 10 },     -- 蜘蛛丝
    ["houndstooth"]         = { lv = 1, rcnt = 10 },     -- 狗牙
    ["stinger"]             = { lv = 1, rcnt = 10 },     -- 蜂刺
    ["beefalowool"]         = { lv = 1, rcnt = 10 },     -- 牛毛  


    ["goldnugget"]          = { lv = 2, rcnt = 10 },     -- 金子
    ["saltrock"]            = { lv = 2, rcnt = 10 },     -- 盐晶
    ["marble"]              = { lv = 2, rcnt = 5  },     -- 大理石 
    ["nitre"]               = { lv = 2, rcnt = 10 },     -- 硝石
    ["boneshard"]           = { lv = 2, rcnt = 10 },     -- 骨片 
    ["dug_grass"]           = { lv = 2, rcnt = 10 },     -- 草丛，可种植的
    ["dug_sapling"]         = { lv = 2, rcnt = 10 },     -- 树苗
    ["dug_berrybush"]       = { lv = 2, rcnt = 6  },     -- 浆果丛
    ["dug_berrybush2"]      = { lv = 2, rcnt = 6  },     -- 浆果丛2
    ["dug_berrybush_juicy"] = { lv = 2, rcnt = 3  },     -- 蜜汁浆果丛
    ["bullkelp_root"]       = { lv = 2, rcnt = 5  },     -- 海带茎
    ["waterplant_planter"]  = { lv = 2, rcnt = 3  },     -- 海芽插穗


    ["waxpaper"]            = { lv = 3, rcnt = 3  },     -- 蜡纸
    ["livinglog"]           = { lv = 3, rcnt = 5  },     -- 活木
    ["nightmarefuel"]       = { lv = 3, rcnt = 5  },     -- 噩梦燃料
    ["pigskin"]             = { lv = 3, rcnt = 10 },     -- 猪皮
    ["moonrocknugget"]      = { lv = 3, rcnt = 8  },     -- 月石
    ["redgem"]              = { lv = 3, rcnt = 3  },     -- 红宝石
    ["bluegem"]             = { lv = 3, rcnt = 3  },     -- 蓝宝石
    ["lightninggoathorn"]   = { lv = 3, rcnt = 2  },     -- 电羊角
    ["honeycomb"]           = { lv = 3, rcnt = 2  },     -- 蜂巢


    ["trunk_summer"]        = { lv = 4, rcnt = 2  },     -- 夏日象鼻 
    ["trunk_winter"]        = { lv = 4, rcnt = 2  },     -- 冬日象鼻
    ["steelwool"]           = { lv = 4, rcnt = 2  },     -- 钢丝绒 
    ["walrus_tusk"]         = { lv = 4, rcnt = 2  },     -- 海象牙
    ["purplegem"]           = { lv = 4, rcnt = 3  },     -- 紫宝石
    ["fossil_piece"]        = { lv = 4, rcnt = 3  },     -- 化石碎片
    ["gears"]               = { lv = 4, rcnt = 2  },     -- 齿轮
    ["slurtlehat"]          = { lv = 4, rcnt = 2  },     -- 蜗牛头盔


    ["thulecite"]           = { lv = 5, rcnt = 2  },     -- 铥矿 
    ["greengem"]            = { lv = 5, rcnt = 2  },     -- 绿宝石
    ["orangegem"]           = { lv = 5, rcnt = 2  },     -- 橙宝石 
    ["yellowgem"]           = { lv = 5, rcnt = 2  },     -- 黄宝石


    ["greenstaff"]          = { lv = 6, rcnt = 1  },     -- 绿魔杖 
    ["orangestaff"]         = { lv = 6, rcnt = 1  },     -- 橙魔杖 
    ["yellowstaff"]         = { lv = 6, rcnt = 1  },     -- 黄魔杖
    ["orangeamulet"]        = { lv = 6, rcnt = 1  },     -- 橙护符
    ["yellowamulet"]        = { lv = 6, rcnt = 1  },     -- 黄护符 
    ["greenamulet"]         = { lv = 6, rcnt = 1  },     -- 绿护符 
    ["nightsword"]          = { lv = 6, rcnt = 1  },     -- 暗影剑
    ["armor_sanity"]        = { lv = 6, rcnt = 1  },     -- 暗影甲


 
    ["eyebrellahat"]        = { lv = 7, rcnt = 1  },     -- 眼球伞
    ["minotaurhorn"]        = { lv = 7, rcnt = 2  },     -- 犀牛角 
    ["shroom_skin"]         = { lv = 7, rcnt = 2  },     -- 蛤蟆皮 
    ["deerclops_eyeball"]   = { lv = 7, rcnt = 2  },     -- 眼球 
    ["dragon_scales"]       = { lv = 7, rcnt = 2  },     -- 龙蝇皮 
    ["shadowheart"]         = { lv = 7, rcnt = 2  },     -- 暗影之心 
    ["ruins_bat"]           = { lv = 7, rcnt = 2  },     -- 铥矿棒
    ["ruinshat"]            = { lv = 7, rcnt = 2  },     -- 铥矿帽
    ["armorruins"]          = { lv = 7, rcnt = 2  },     -- 铥矿甲
    ["hivehat"]             = { lv = 7, rcnt = 1  },     -- 峰王帽 
    ["townportaltalisman"]  = { lv = 7, rcnt = 10 },     -- 沙之石
    ["opalpreciousgem"]     = { lv = 7, rcnt = 1  },     -- 彩虹宝石 
    ["opalstaff"]           = { lv = 7, rcnt = 1  },     -- 月杖 
}



local lostrecipes = {
    "gears",
    -- "opalpreciousgem",
}



local prefabs = {
    pickable     = pickabledefs,
    taskpickable = taskpicklist,
    foods        = foods,
    fishes       = taskfishes,
    ponds        = taskponds,
    rocks        = taskrocks,
    treetags     = tasktreetags,
    dryitems  = taskdryitems,
}


prefabs.getItemsByLv = function(lv)
    local list = {}
    for k,v in pairs(itemsdef) do
        if v.lv == lv then
            table.insert(list, k)
        end
    end
    local name = GetRandomItem(list)
    local rcnt = itemsdef[name].rcnt
    return name, rcnt
end


prefabs.getLostRecipes = function()
    return lostrecipes
end


prefabs.getBreakLv = function(prefab)
    return breakitemsdef[prefab] or 0
end


return prefabs