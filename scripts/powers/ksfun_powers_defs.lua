local isch = KSFUN_TUNING.IS_CH
local ITEM_NAMES =  KSFUN_TUNING.ITEM_POWER_NAMES
local NAMES = MergeMaps(KSFUN_TUNING.PLAYER_POWER_NAMES, ITEM_NAMES)
local CONFIGS = KSFUN_POWER_CONFIGS

local breakstrs = {
    isch and "学徒" or "Apprentice",
    isch and "初阶" or "Elementary",
    isch and "中阶" or "Intermediate",
    isch and "高阶" or "Advanced",
    isch and "圣阶" or "Saint", 
    isch and "神阶" or "God",
}

local breakcolors = {
    UICOLOURS.GREY,
    UICOLOURS.WHITE,
    UICOLOURS.BLUE,
    UICOLOURS.PURPLE,
    UICOLOURS.GOLD,
    UICOLOURS.RED 
}


local FORGITEMS = {}
FORGITEMS[ITEM_NAMES.LIFESTEAL]  = { mosquitosack = 20, spidergland = 10 }
FORGITEMS[ITEM_NAMES.AOE]        = { minotaurhorn = 1000}
FORGITEMS[ITEM_NAMES.MINE]       = { marble = 50, nitre = 100,  flint = 10, rocks = 10}
FORGITEMS[ITEM_NAMES.CHOP]       = { livinglog = 50, log = 10,}
FORGITEMS[ITEM_NAMES.MAXUSES]    = { dragon_scales = 20, }
FORGITEMS[ITEM_NAMES.DAMAGE]     = { houndstooth = 5, stinger = 5 }
FORGITEMS[ITEM_NAMES.INSULATOR]  = { trunk_winter = 100, trunk_summer = 80, silk = 5, beefalowool = 5 }
FORGITEMS[ITEM_NAMES.DAPPERNESS] = { nightmarefuel = 5, spiderhat = 10,  walrushat = 30 }
FORGITEMS[ITEM_NAMES.WATER]      = { pigskin = 1, tentaclespots = 10 }
FORGITEMS[ITEM_NAMES.SPEED]      = { walrus_tusk = 300 }
FORGITEMS[ITEM_NAMES.ABSORB]     = { steelwool = 20 }




local Defs = {}


Defs.ObtainPowerInfo = function (data)
    local strs = {}
    local strlv = (isch and "等级: " or "lv: ") .. tostring(data.lv)
    local strxp = (isch and "经验: " or "xp: ") .. tostring(data.exp)
    local index = math.min(#breakstrs, data.breakcnt + 1)
    local name  = KsFunGetPowerNameStr(data.name)
    strs.name = { content = name  }
    strs.lv   = { content = strlv }
    strs.xp   = { content = strxp }
    if index > 0 then
        strs.br = { 
            content = breakstrs[index], 
            color   = breakcolors[index] 
        }
    end
    return strs
end


Defs.GetForgItems = function (name)
    return FORGITEMS[name]
end

Defs.IsForgItem = function(prefab)
    for k, v in pairs(FORGITEMS) do
        ---@diagnostic disable-next-line: undefined-field
        if table.contains(v, prefab) then
            return true
        end
    end
    return false
end


return Defs