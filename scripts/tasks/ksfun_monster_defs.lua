
local MOOSE = "MOOSE"
if STRINGS.NAMES[MOOSE] == nil then
    STRINGS.NAMES[MOOSE] = "麋鹿鹅" 
end


local LV_DEFS = KSFUN_TUNING.TASK_LV_DEFS


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


local function monsterCheck(monsters)
    local indexs = {}
    for i,v in ipairs(monsters) do
        if STRINGS.NAMES[string.upper(v)] == nil then
            table.insert(indexs, i)
        end
    end
    for i,v in ipairs(indexs) do
        table.remove(monsters, i)
    end
end


monsterCheck(MONSTER_LV1)
monsterCheck(MONSTER_LV2)
monsterCheck(MONSTER_LV3)
monsterCheck(MONSTER_LV4)
monsterCheck(MONSTER_LV5)
monsterCheck(MONSTER_LV6)


local MONSTER_DEFS = {}
MONSTER_DEFS[LV_DEFS.LV1] = MONSTER_LV1
MONSTER_DEFS[LV_DEFS.LV2] = MONSTER_LV2
MONSTER_DEFS[LV_DEFS.LV3] = MONSTER_LV3
MONSTER_DEFS[LV_DEFS.LV4] = MONSTER_LV4
MONSTER_DEFS[LV_DEFS.LV5] = MONSTER_LV5
MONSTER_DEFS[LV_DEFS.LV6] = MONSTER_LV6


local MOSTER = {}


local function randomMonsterNum(monster_lv)
    local num = 1
    if monster_lv > LV_DEFS.LV3 then
        num = 1
    elseif monster_lv == LV_DEFS.LV3 then
        num = math.random(5)
    elseif monster_lv == LV_DEFS.LV3 then
        num = math.random(10)
    else
        num = math.random(30)
    end
    return num
end


--- 生成一个随机的目标等级的怪物
--- @param moster_lv 怪物等级，无就随机等级
--- @return 怪物代码 名称/等级/数量
local function randomMonster(task_lv)
    local lv = task_lv and task_lv or math.random(LV_DEFS.MAX)
    lv = math.max(LV_DEFS.LV1, lv)
    lv = math.min(LV_DEFS.MAX, lv)
    local monsters = MONSTER_DEFS[lv] 
    local index = math.random(#monsters)
    local name = monsters[index]
    local num = randomMonsterNum(lv)
    return name, lv, num
end



MOSTER.RandomMonster = randomMonster


return MOSTER

