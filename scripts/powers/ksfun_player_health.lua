
local NAME = KSFUN_TUNING.PLAYER_POWER_NAMES.HEALTH


-- 更新角色的血量数据
local function updateHealthState(inst)
    local lv = inst.components.ksfun_level.lv
    local target = inst.target
    local data = inst.components.ksfun_power:GetData()
    if target and data then
        local initHealth = data.health or 120
        local percent = target.components.health:GetPercent()
        target.components.health.maxhealth = initHealth + lv
        target.components.health:SetPercent(percent)
    end
end


--- 生命上限提升时
local function onLvChangeFunc(inst, lv, notice)
    updateHealthState(inst, false)
    KsFunSayPowerNotice(inst.target, inst.prefab)
end


--- 击杀怪物后，范围10以内的角色都可以获得血量升级的经验值
--- 范围内只有一个人时，经验值为100%获取
--- 人越多经验越低，最低50%
--- @param killer 击杀者 data 受害者数据集
local function onKillOther(killer, data)
    KsFunLog("onKillOther", data.victim.prefab)
    local victim = data.victim
    if victim == nil then return end
    if victim.components.health == nil then return end

    if victim.components.freezable or victim:HasTag("monster") then

        -- 所有经验都是10*lv 因此血量也需要计算为1/10
        local exp = victim.components.health.maxhealth / 10

        -- 击杀者能够得到满额的经验
        KsFunPowerGainExp(killer, NAME, exp)

        -- 非击杀者经验值计算，范围10以内其他玩家
        local x,y,z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x,y,z, 10, {"player"})
        if players == nil then return end
        local players_count = #players
        -- 单人模式经验100%，多人经验获取会减少，最低50%
        local exp_multi = math.max((6 - players_count) * 0.2, 0.5)
        for i, player in ipairs(players) do
            -- 击杀者已经给了经验了
            if player ~= killer then
                KsFunPowerGainExp(player, NAME, exp * exp_multi)
            end
        end
    end
end


local function reset(inst, target)
    --- 恢复原始数据
    local data = inst.components.ksfun_power:GetData()
    if data then
        local percent = target.components.health:GetPercent()
        target.components.health.maxhealth = data.health or 120
        target.components.health:SetPercent(percent)
    end
end


--- power 绑定
--- @param 属性  玩家  属性名称
local function onAttach(inst, target, name)
    inst.target = target

    -- 记录原始数据
    local h = target.components.health
    inst.components.ksfun_power:SetData({health = h.maxhealth, percent = h:GetPercent()})

    -- 初始化的时候修正一下血量百分比
    if inst.percent then
        local data = inst.components.ksfun_power:GetData()
        h.maxhealth = data.health
        h:SetPercent(inst.percent)
    end

    -- 玩家杀怪可以升级
    target:ListenForEvent("killed", onKillOther)

    updateHealthState(inst, true)
end


--- power解绑
--- 血量回复到初始值
--- @param 属性 角色 属性名称
local function onDetach(inst, target, name)
    target:RemoveEventCallback("killed", onKillOther)
end


local function getPercent(inst)
    if inst.target then
        return inst.target.components.health:GetPercent()
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
    onAttachFunc = onAttach,
    onDetachFunc = onDetach,
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

local health = {}


health.data = {
    power = power,
    level = level,
}

return health