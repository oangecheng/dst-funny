local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES


-- 物品基础经验值定义
local ITEM_EXP_DEF = 10
-- 建筑基础经验值定义
local STRUCTURE_EXP_DEF = 20
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


local KSFUN_SANITY = {}


local function updateSanityStatus(inst)
    local sanity = inst.target and inst.target.components.sanity or nil
    local level = inst.components.ksfun_level
    if sanity and level and inst.originSanity then
        local percent = sanity:GetPercent()
        sanity.max = inst.originSanity + level.lv
        sanity:SetPercent(percent)
    end
end


--- 监听等级提升
--- @param inst power实例
--- @param lv  等级
--- @param notice 是否需要说话
local function onLvChangeFunc(inst, lv, notice)
    updateSanityStatus(inst)
    if notice and inst.target then
        inst.target.components.talker:Say("脑残值提升！")
    end
end


--- 用户等级状态变更
--- 通知用户面板刷新状态
local function onStateChangeFunc(inst)
    if inst.target then
        inst.target:PushEvent(KSFUN_TUNING.EVENTS.PLAYER_STATE_CHANGE)
    end
end


--- 下一级饱食度所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 10 or 100 * (lv + 1)
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
    local power = player.components.ksfun_power_system:GetPower(NAMES.SANITY)
    if power and power.components.ksfun_level then
        local exp = calcItemExp(data)
        power.components.ksfun_level:GainExp(exp)
    end
end


--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data 建筑数据
local function oBuildStructureFunc(player, data)
    local power = player.components.ksfun_power_system:GetPower(NAMES.SANITY)
    if power and power.components.ksfun_level then
        local exp = calcStructureExp(data)
        power.components.ksfun_level:GainExp(exp)
    end
end


--- 绑定对象
local function onAttachFunc(inst, player, name)
    inst.target = player
    if not inst.originSanity then
        inst.originSanity = player.components.sanity.max
    end
    updateSanityStatus(inst)
    player:ListenForEvent("builditem", onBuildItemFunc)
    player:ListenForEvent("buildstructure", oBuildStructureFunc)
end


--- 解绑对象
local function onDetachFunc(inst, player, name)
    player:RemoveEventCallback("builditem", onBuildItemFunc)
    player:RemoveEventCallback("buildstructure", oBuildStructureFunc)

    if player.components.sanity and inst.originSanity then
        local percent = inst.components.sanity:GetPercent()
        player.components.sanity.max = inst.originSanity
        player.components.sanity:SetPercent(percent)
    end

    inst.target = nil
    inst.originSanity = nil
end



KSFUN_SANITY.power = {
    name = NAMES.SANITY,
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onExtendFunc = nil,
}

KSFUN_SANITY.level = {
    onLvChangeFunc = onLvChangeFunc,
    onStateChangeFunc = onStateChangeFunc,
    nextLvExpFunc = nextLvExpFunc,
}

return KSFUN_SANITY