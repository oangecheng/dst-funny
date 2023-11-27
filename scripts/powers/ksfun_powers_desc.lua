local isch = KSFUN_TUNING.IS_CH
local NAMES = MergeMaps(KSFUN_TUNING.PLAYER_POWER_NAMES, KSFUN_TUNING.ITEM_POWER_NAMES)
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


local PowerDesc = {}


PowerDesc.ObtainBreackStr = function (data)
    local strs = {}
    local strlv = (isch and "等级: " or "lv: ") .. tostring(data.lv)
    local strxp = (isch and "经验: " or "xp: ") .. tostring(data.exp)
    local index = math.min(#breakstrs, data.breakcnt + 1)
    local name  = KsFunGetPowerNameStr(data.name)

    strs.name = { content = name  }
    strs.lv   = { content = strlv }
    strs.xp   = { content = strxp }

    if index > 0 then
        strs.br   = { 
            content = breakstrs[index], 
            color = breakcolors[index] 
        }
    end

    return strs
end



return PowerDesc