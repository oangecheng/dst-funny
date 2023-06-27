
local MONSTER_LV1 = {
    "butterfly",
    "killerbee",
    "mosquito",
    "frog",
    "hound",
    "firehound",
    "icehound",
    "spider"
}


local MONSTER_LV2 = {
    "spider_warrior",
    "spider_hider",
    "spider_spitter",
    "crawlingnightmare",
    "nightmarebeak",
    "krampus",
    "pigman",
    "merm",
    "bunnyman",
}


local MONSTER_LV3 = {
    "beefalo",
    "lightninggoat",
    "spat",
    "warg",
    "koalefant_summer",
    "koalefant_winter",
    "tentacle",
    "knight",
    "bishop",
    "rook",
    "tallbird",
}


local MONSTER_LV4 = {
    "leif",
    "leif_sparse",
    "spiderqueen",
}


local MONSTER_LV5 = {
    "malbatross", -- 邪天翁
    "minotaur", -- 远古守护者
    "antlion", -- 蚁狮
    "bearger", -- 熊大
    "dragonfly", -- 龙蝇
    "deerclops", -- 巨鹿
    "moose", -- 大鹅
}


local MONSTER_LV6 = {
    "toadstool", -- 蛤蟆
    "beequeen", -- 蜂后
    "klaus", -- 克劳斯
    "crab_king", -- 帝王蟹
    "alterguardian_phase3", -- 天体英雄3阶
}


local MOSTER = {}


local MONSTER_DEFS = {
    [1] = MONSTER_LV1,
    [2] = MONSTER_LV2,
    [3] = MONSTER_LV3,
    [4] = MONSTER_LV4,
    [5] = MONSTER_LV5,
    [6] = MONSTER_LV6,
}



local function randomMonsterNum(monster_lv)
    local num = 1
    if monster_lv > 3 then
        num = 1
    elseif monster_lv == 3 then
        num = math.random(2)
    elseif monster_lv == 2 then
        num = math.random(4)
    else
        num = math.random(8)
    end
    return num
end


--- 生成一个随机的目标等级的怪物
--- @param moster_lv 怪物等级，无就随机等级
--- @return 怪物代码 名称/等级/数量
local function randomMonster()
    local lv = math.random(6)
    local monsters = MONSTER_DEFS[lv] 
    local index = math.random(#monsters)
    local name = monsters[index]
    local num = randomMonsterNum(lv)
    return name, lv, num
end



MOSTER.randomMonster = randomMonster


return MOSTER

