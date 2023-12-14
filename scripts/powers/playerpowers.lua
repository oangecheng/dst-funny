local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES
local BLUEPRINTS_KEY = "KSFUN_BLUEPRITS"
local GOD_STEP = 20 


local recipes = require "defs/ksfun_recipes_defs"


---comment 计算等阶
---@param lv integer 等级
---@return integer 当前等阶
local function getGodLv(lv)
    return math.min(math.floor(lv * 0.05) + 1, 6)
end



local function tryGiveBlueprint(target, name)
    if name and target then
        local r = KsFunGetPowerData(target, name, BLUEPRINTS_KEY)
        local hit = r and math.random() < r or false
        local drops = recipes[name]
        if hit and drops and target.components.builder and target.components.inventory then
            for k, v in pairs(drops) do
                if not target.components.builder:KnowsRecipe(k) then
                    local item = SpawnPrefab(k.."_blueprint")
                    if item then
                        target.components.inventory:GiveItem(item)
                    end
                end
            end
        end
    end
end







local sanity1 = function(inst, target, lv)
    local maxsanity = inst.maxsanity or 100
    local sanity = target.components.sanity
    if sanity then
        local percent = sanity:GetPercent()
        sanity.max = math.floor(maxsanity * (1 + lv * 0.01) + 0.5)
        sanity:SetPercent(percent)
    end
end



local sanity2 = function(inst, target, lv)
    KsFunAddTag(target, "handyperson")
    KsFunAddTag(target, "fastbuilder")
end


local sanity3 = function(inst, target, lv)
    KsFunAddTag(target, "bookbuilder")
    KsFunAddComponent(target, "reader")
    local reader = target.components.reader
    if inst.penaltymulti ~= nil and reader then
        inst.penaltymulti = reader:GetSanityPenaltyMultiplier()
    end
    if inst.penaltymulti then
        local m = math.max(1 - (lv - 20) * 0.01, 0.5)
        reader:SetSanityPenaltyMultiplier(inst.penaltymulti * m)
    end
end


local sanity4 = function(inst, target, lv)
    local ratio = math.min((lv - GOD_STEP * 3) * 0.01, 0.25)
    KsFunSetPowerData(target, NAMES.SANITY, BLUEPRINTS_KEY, ratio)
end


local sanity5 = function(inst, target, lv)
    local ratio = math.min((lv - GOD_STEP * 4) * 0.05, 1)
    KsFunSetPowerData(target, NAMES.SANITY, "INGREDIENT", ratio)
end


local sanity6 = function (inst, target, lv)
    KsFunAddTag(target, "ksfun_god"..NAMES.SANITY)
end


local sanitygods = { sanity1, sanity2, sanity3, sanity4, sanity5, sanity6 }

local function onbuilditemfn(player)
    local exp = math.random(3, 5)
    KsFunPowerGainExp(player, NAMES.SANITY, exp)
    tryGiveBlueprint(player, NAMES.SANITY)
end

local function onbuildstructurefn(player)
    local exp = math.random(6, 10)
    KsFunPowerGainExp(player, NAMES.SANITY, exp)
    tryGiveBlueprint(player, NAMES.SANITY)
end


local function updatefn(inst, target)
    local lv = inst.components.ksfun_level:GetLevel()
    local godlv = getGodLv(lv)
    KsFunLog("onLevelChange", NAMES.SANITY, lv, godlv)
    for i = 1, godlv do
        local fn = sanitygods[i]
        fn(inst, target, lv)
    end
end


local sanity = {
    onattach = function (inst, target, name)
        target:ListenForEvent("builditem", onbuilditemfn)
        target:ListenForEvent("buildstructure", onbuildstructurefn)
        local sanity = target.components.sanity
        inst.sanitymax = sanity and sanity.max or nil
        if inst.percent then
            sanity:SetPercent(inst.percent)
        end
    end,

    ondetach = function (inst, target, name)
        target:RemoveEventCallback("builditem", onbuilditemfn)
        target:RemoveEventCallback("buildstructure", onbuildstructurefn)
    end,

    onstatechange = function (inst, target, name)
        updatefn(inst, target)
    end,

    onsave = function (inst, data)
        data.percent = inst.target and inst.target.components.sanity:GetPercent()
    end,

    onload = function (inst, data)
        inst.percent = data.percent or nil
    end
}




return {
    [NAMES.SANITY] = sanity
}