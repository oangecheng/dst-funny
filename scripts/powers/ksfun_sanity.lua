local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES


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


-- [00:01:47]: 哈哈哈哈哈 calcItemExp  SCULPTING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  PERDOFFERING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  BOOKCRAFT  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  LUNARFORGING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  ROBOTMODULECRAFT  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  ORPHANAGE  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  FOODPROCESSING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  ANCIENT  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  WARGOFFERING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  SPIDERCRAFT  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  MOON_ALTAR  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  CARTOGRAPHY  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  SCIENCE  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  CATCOONOFFERING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  SEAFARING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  MADSCIENCE  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  CARNIVAL_PRIZESHOP  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  RABBITOFFERING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  FISHING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  HERMITCRABSHOP  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  CARRATOFFERING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  SHADOW  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  MAGIC  2	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  CARNIVAL_HOSTSHOP  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  TURFCRAFTING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  WINTERSFEASTCOOKING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  PIGOFFERING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  MASHTURFCRAFTING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  BEEFOFFERING  0	
-- [00:01:47]: 哈哈哈哈哈 calcItemExp  CELESTIAL  0	

--- 计算建造每个物品获得的经验值
local function calcItemExp(data)
    -- for k,v in pairs(data.recipe.level) do
    --     print("哈哈哈哈哈 calcItemExp  "..tostring(k).."  "..tostring(v))
    -- end
    return 25
end


--- 计算建造每个建筑获得的经验值
local function calcStructureExp(data)
    return 50
end


--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data 物品数据
local function onBuildItemFunc(player, data)
    local power = player.components.ksfun_powers:GetPower(NAMES.SANITY)
    if power and power.components.ksfun_level then
        local exp = calcItemExp(data)
        power.components.ksfun_level:GainExp(exp)
    end
end


--- 建造物品时获得升级经验
--- @param player 玩家
--- @param data 建筑数据
local function oBuildStructureFunc(player, data)
    local power = player.components.ksfun_powers:GetPower(NAMES.SANITY)
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