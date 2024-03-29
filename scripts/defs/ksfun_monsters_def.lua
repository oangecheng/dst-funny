local NAMES  = KSFUN_TUNING.MONSTER_POWER_NAMES
local scount = 3
local mcount = 5
local hcount = 10
local maxlv  = 7

local monstersdef = {
    ["rabbit"]               = { lv = 1, punish = 0, pnum = scount, pwhites = {NAMES.HEALTH} }, -- 兔子
    ["butterfly"]            = { lv = 1, punish = 0, pnum = scount, pwhites = {NAMES.HEALTH} }, -- 蝴蝶
    ["bee"]                  = { lv = 1, punish = 0, pnum = scount },  -- 蜜蜂
    ["killerbee"]            = { lv = 1, punish = 1, pnum = scount },  -- 杀人峰
    ["mosquito"]             = { lv = 1, punish = 1, pnum = scount },  -- 蚊子
    ["frog"]                 = { lv = 1, punish = 1, pnum = scount, pblacks = {NAMES.STEAL} },  -- 青蛙
    ["hound"]                = { lv = 1, punish = 1, pnum = scount },  -- 猎犬
    ["firehound"]            = { lv = 1, punish = 1, pnum = scount },  -- 火猎犬
    ["icehound"]             = { lv = 1, punish = 1, pnum = scount },  -- 冰猎犬
    ["spider"]               = { lv = 1, punish = 1, pnum = scount },  -- 蜘蛛
    ["catcoon"]              = { lv = 1, punish = 0, pnum = scount },  -- 浣猫

    ["spider_warrior"]       = { lv = 2, punish = 1, pnum = mcount },  -- 蜘蛛战士
    ["spider_hider"]         = { lv = 2, punish = 1, pnum = mcount },  -- 洞穴蜘蛛
    ["spider_spitter"]       = { lv = 2, punish = 1, pnum = mcount },  -- 喷射蜘蛛
    ["crawlingnightmare"]    = { lv = 2, punish = 0, pnum = mcount },  -- 爬行梦魇
    ["nightmarebeak"]        = { lv = 2, punish = 0, pnum = mcount },  -- 巨喙梦魇
    ["krampus"]              = { lv = 2, punish = 1, pnum = mcount },  -- 坎普斯
    ["pigman"]               = { lv = 2, punish = 0, pnum = mcount, pblacks = {NAMES.SANITY} },  -- 猪人
    ["moonpig"]              = { lv = 2, punish = 0, pnum = mcount },  -- 疯猪
    ["merm"]                 = { lv = 2, punish = 0, pnum = mcount },  -- 鱼人
    ["bunnyman"]             = { lv = 2, punish = 0, pnum = mcount },  -- 兔人, 
    ["beeguard"]             = { lv = 2, punish = 0, pnum = mcount },  -- 嗡嗡蜜蜂，蜂后召唤的
    ["walrus"]               = { lv = 2, punish = 1, pnum = mcount },  -- 海象
    ["eyeofterror_mini"]     = { lv = 2, punish = 0, pnum = mcount },  -- 双子魔眼召唤物

    ["koalefant_summer"]     = { lv = 3, punish = 0, pnum = mcount },  -- 夏季大象
    ["koalefant_winter"]     = { lv = 3, punish = 0, pnum = mcount },  -- 冬季大象
    ["beefalo"]              = { lv = 3, punish = 0, pnum = mcount },  -- 牛
    ["lightninggoat"]        = { lv = 3, punish = 0, pnum = mcount },  -- 伏特羊
    ["tentacle"]             = { lv = 3, punish = 1, pnum = mcount, pblacks = {NAMES.LOCOMOTOR} },  -- 触手
    ["knight"]               = { lv = 3, punish = 1, pnum = mcount },  -- 发条骑士
    ["bishop"]               = { lv = 3, punish = 1, pnum = mcount },  -- 发条主教
    ["rook"]                 = { lv = 3, punish = 1, pnum = mcount },  -- 发条战车
    ["tallbird"]             = { lv = 3, punish = 1, pnum = mcount },  -- 高脚鸟
    ["slurtle"]              = { lv = 3, punish = 1, pnum = mcount },  -- 尖壳蜗牛
    ["snurtle"]              = { lv = 3, punish = 1, pnum = mcount },  -- 圆壳蜗牛

    ["spat"]                 = { lv = 4, punish = 1, pnum = hcount },  -- 钢羊
    ["warg"]                 = { lv = 4, punish = 1, pnum = hcount },  -- 座狼
    ["leif"]                 = { lv = 4, punish = 1, pnum = hcount },  -- 树精
    ["leif_sparse"]          = { lv = 4, punish = 1, pnum = hcount },  -- 常青树精
    ["spiderqueen"]          = { lv = 4, punish = 1, pnum = hcount },  -- 蜘蛛女王

    ["malbatross"]           = { lv = 5, punish = 0, pnum = hcount },  -- 邪天翁
    ["minotaur"]             = { lv = 5, punish = 1, pnum = hcount },  -- 远古守护者
    ["antlion"]              = { lv = 5, punish = 0, pnum = hcount, pblacks = {NAMES.LOCOMOTOR} }, -- 蚁狮
    ["bearger"]              = { lv = 5, punish = 1, pnum = hcount, pblacks = {NAMES.KNOCK_BACK, NAMES.STEAL} },  -- 熊大
    ["dragonfly"]            = { lv = 5, punish = 1, pnum = hcount },  -- 龙蝇
    ["deerclops"]            = { lv = 5, punish = 1, pnum = hcount },  -- 巨鹿
    ["moose"]                = { lv = 5, punish = 1, pnum = hcount },  -- 大鹅
    ["eyeofterror"]          = { lv = 5, punish = 1, pnum = hcount },  -- 恐怖之眼
    ["twinofterror1"]        = { lv = 5, punish = 1, pnum = hcount },  -- 双子魔眼1
    ["twinofterror2"]        = { lv = 5, punish = 1, pnum = hcount },  -- 双子魔眼2
    ["daywalker"]            = { lv = 5, punish = 1, pnum = hcount },  -- 噩梦猪人

    ["toadstool"]            = { lv = 6, punish = 1, pnum = hcount, pblacks = {NAMES.DAMAGE} },  -- 蛤蟆
    ["beequeen"]             = { lv = 6, punish = 1, pnum = hcount },  -- 蜂后
    ["klaus"]                = { lv = 6, punish = 1, pnum = hcount, pblacks = {NAMES.HEALTH} }, -- 克劳斯

    ["stalker_atrium"]       = { lv = 7, punish = 0, pnum = hcount },  -- 暗影编制者  
    ["toadstool_dark"]       = { lv = 7, punish = 0, pnum = hcount, pblacks = {NAMES.DAMAGE} },  -- 悲惨蛤蟆  
    ["crabking"]             = { lv = 7, punish = 0, pnum = hcount, pblacks = {NAMES.LOCOMOTOR} }, -- 帝王蟹
    ["alterguardian_phase3"] = { lv = 7, punish = 0, pnum = hcount}, -- 天体英雄3阶
}


local monsters = {}


--- 获取可以作为惩罚生成的怪物列表
monsters.punishMonsters = function()
    local list = { ["S"] = {}, ["M"] = {}, ["L"] = {},}
    for k,v in pairs(monstersdef) do
        if v.punish > 0 then
            if v.lv > 5 then
                table.insert(list["L"], k) 
            elseif v.lv > 4 then
                table.insert(list["M"], k)
            else
                table.insert(list["S"], k)
            end
        end
    end
    return list
end




local function getTaskMonsterNum(lv)
    if lv > 3 then return 1 end
    if lv > 2 then return math.random(2) end
    if lv > 1 then return math.random(4) end
    return math.random(8)
end

--- 获取可以作为任务对象的怪物
--- @return string 怪物prefab
--- @return number 数量
--- @return number 等级
monsters.randomTaskMonster = function(initlv)
    local seed = 5
    if KSFUN_TUNING.DIFFCULTY > 7 then
        seed = 7
    elseif KSFUN_TUNING.DIFFCULTY > 5 then
        seed = 6
    end
    local lv = initlv or math.random(seed)
    lv = math.min(maxlv, lv)
    local list = {}
    for k,v in pairs(monstersdef) do
        if lv == v.lv then
            table.insert(list, k)
        end
    end
    local name = GetRandomItem(list)
    local num  = getTaskMonsterNum(lv)
    return name, num, lv
end




monsters.reinforceMonster = function()
    return monstersdef
end


return monsters