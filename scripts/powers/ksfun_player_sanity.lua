local NAME = KSFUN_TUNING.PLAYER_POWER_NAMES.SANITY


-- 物品基础经验值定义
local ITEM_EXP_DEF = 1
-- 建筑基础经验值定义
local STRUCTURE_EXP_DEF = 2
-- 各科技等级经验值倍率
--- SCIENCE 1,2,3
--- MAGIC 6,7,  (SCIENCE最大倍率x2)
--- ANCIENT 14,15,16 (MAGIC最大倍率x2)
--- CELESTIAL 14,16, (同ANCIENT, 月岛科技等级只有1和3)
local EXP_MULTI_DEFS = {
    SCIENCE = 0,
    MAGIC = 4,
    ANCIENT = 12,
    CELESTIAL = 13,
    LUNARFORGING = 13,
}




local function updateSanityStatus(inst)
    local data = inst.components.ksfun_power:GetData()

    local sanity = inst.target and inst.target.components.sanity or nil
    local level = inst.components.ksfun_level
    if sanity and level and data then
        local percent = sanity:GetPercent()
        sanity.max = data.sanity + level.lv
        sanity:SetPercent(percent)
    end
end


--- 监听等级提升
--- @param inst power实例
--- @param lv  等级
--- @param notice 是否需要说话
local function onLvChangeFunc(inst, lv, notice)
    updateSanityStatus(inst)
    KsFunSayPowerNotice(inst.target, inst.prefab)
end


--- 根据物品等级计算经验倍率
--- 远古和魔法从等级2开始
local function getExpMultiByRecipeLevel(recipe_level)
    local multi = 2
    if recipe_level == nil then return multi end
    if recipe_level.SCIENCE ~= 0 then
        multi = tonumber(recipe_level.SCIENCE) + EXP_MULTI_DEFS.SCIENCE  
    elseif recipe_level.MAGIC ~= 0 then
        multi = tonumber(recipe_level.MAGIC) + EXP_MULTI_DEFS.MAGIC
    elseif recipe_level.ANCIENT ~= 0 then
        multi = tonumber(recipe_level.ANCIENT) + EXP_MULTI_DEFS.ANCIENT
    elseif recipe_level.CELESTIAL ~= 0 then
        multi = tonumber(recipe_level.CELESTIAL) + EXP_MULTI_DEFS.CELESTIAL
    elseif recipe_level.LUNARFORGING ~= 0 then
        multi = tonumber(recipe_level.LUNARFORGING) + EXP_MULTI_DEFS.LUNARFORGING
    end
    multi = math.max(1, multi)
    return multi
end

--- 计算建造每个物品获得的经验值
local function calcItemExp(data)
    local recipe_level = data.recipe.level
    local multi = getExpMultiByRecipeLevel(recipe_level)
    return multi * ITEM_EXP_DEF
end


--- 计算建造每个建筑获得的经验值
local function calcStructureExp(data)
    local recipe_level = data.recipe.level
    local multi = getExpMultiByRecipeLevel(recipe_level)
    return multi * STRUCTURE_EXP_DEF
end


--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data 物品数据
local function onBuildItemFunc(player, data)
    local exp = calcItemExp(data)
    KsFunPowerGainExp(player, NAME, exp)
end


--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data 建筑数据
local function oBuildStructureFunc(player, data)
    local exp = calcStructureExp(data)
    KsFunPowerGainExp(player, NAME, exp)
end


local function reset(inst, target)
    local data = inst.components.ksfun_power:GetData()
    if target.components.sanity and data then
        local percent = target.components.sanity:GetPercent()
        target.components.sanity.max = data.sanity
        target.components.sanity:SetPercent(percent)
    end
end


--- 绑定对象
local function onAttachFunc(inst, player, name)
    inst.target = player

    local sanity = player.components.sanity
    inst.components.ksfun_power:SetData({sanity = sanity.max})

    --- 修正精神值百分比
    if inst.percent then
        local data = inst.components.ksfun_power:GetData()
        sanity.max = data.sanity
        sanity:SetPercent(inst.percent)
    end

    updateSanityStatus(inst)
    player:ListenForEvent("builditem", onBuildItemFunc)
    player:ListenForEvent("buildstructure", oBuildStructureFunc)
end


--- 解绑对象
local function onDetachFunc(inst, player, name)
    player:RemoveEventCallback("builditem", onBuildItemFunc)
    player:RemoveEventCallback("buildstructure", oBuildStructureFunc)
    
    reset(inst, player)

end


local function getPercent(inst)
    if inst.target then
        return inst.target.components.sanity:GetPercent()
    end
    return nil
end


local function onSave(inst, data)
    data.percent = getPercent(inst)
end

local function onLoad(inst, data)
    inst.percent = data.percent or nil
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onLoadFunc   = onLoad,
    onSaveFunc   = onSave,

    onGetDescFunc = function(inst, t, n)
        local extra = KsFunGetPowerDescExtra(inst.prefab)
        return KsFunGetPowerDesc(inst, extra)
    end,
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
}


local KSFUN_SANITY = {}

KSFUN_SANITY.data = {
    power = power,
    level = level,
}


return KSFUN_SANITY