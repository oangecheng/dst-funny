local DEMAND = {}

local LV_DEFS = KSFUN_TUNING.TASK_DEMAND_LEVELS

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


local MONSTERS = {}
--- @param source 待插入的列表
local function addAll(source)
    for i = 1, #source do
        table.insert(MONSTERS, source[i])
    end
end
addAll(MONSTER_LV1)
addAll(MONSTER_LV2)
addAll(MONSTER_LV3)
addAll(MONSTER_LV4)
addAll(MONSTER_LV5)
addAll(MONSTER_LV6)





--- 获取怪物的难度等级
--- @param name 怪物代码
--- @return int 等级
local function getMonsterLv(name)
    if table.contains(MONSTER_LV1, name) then return LV_DEFS.LV1
    elseif table.contains(MONSTER_LV2, name) then return LV_DEFS.LV2
    elseif table.contains(MONSTER_LV3, name) then return LV_DEFS.LV3
    elseif table.contains(MONSTER_LV4, name) then return LV_DEFS.LV4
    elseif table.contains(MONSTER_LV5, name) then return LV_DEFS.LV5
    elseif table.contains(MONSTER_LV6, name) then return LV_DEFS.LV6
    else return LV_DEFS.UNKNOWN
    end
end


--- 随机获取一个怪物
--- @return string 怪物代码 
local function randomMonster()
    local index = math.random(#MONSTERS)
    return MONSTERS[index]
end



--- 生成一个击杀任务
--- @return 击杀任务
local function createDemandKill()
    local monster = randomMonster()
    local lv = getMonsterLv(monster)

    -- 怪物数量生成策略
    local count = 0
    if lv > LV_DEFS.LV3 then count = 1
    elseif lv == LV_DEFS.LV3 then count = math.random(5)
    elseif lv == LV_DEFS.LV2 then count = math.random(10)
    else count = math.random(30) end

    -- 任务时间绑定难度等级
    -- 1级难度任务为2天，每增加一级难度，时间+1天
    local time = KSFUN_TUNING.TASK_TIME_TOTAL_DAY * (1 + lv)

    return {
        type = KSFUN_TUNING.TASK_DEMAND_TYPES.KILL,
        level = lv,
        data = {
            victim = monster,
            num = count,
            duration = time,
        }
    }
end


--- 获取任务最大难度等级
--- @return 等级 number
DEMAND.maxLv = LV_DEFS.LV6


DEMAND.createDemandByType = function(demand_type)
    if demand_type == KSFUN_TUNING.TASK_DEMAND_TYPES.KILL then return createDemandKill()
    else return nil end
end


return DEMAND