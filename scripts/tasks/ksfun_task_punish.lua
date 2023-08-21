local TYPES = KSFUN_PUNISHES


local function losePowerProperty(player, islv, data)
    local name  = data.name or ""
    local power = player.components.ksfun_power_system:GetPower(name)
    if power then
        local level   = power.components.ksfun_level
        local namestr = KsFunGetPowerNameStr(name)
        if islv then
            level:DoDelta(-data.num)
            local msg = string.format(STRINGS.KSFUN_TASK_PUNISH_POWER_LV, namestr, tostring(-data.num))
            KsFunShowTip(player, msg)
        else
            level:DoExpDelta(-data.num)
            local msg = string.format(STRINGS.KSFUN_TASK_PUNISH_POWER_EXP, namestr, tostring(-data.num))
            KsFunShowTip(player, msg)
        end
    end 
end




local function punishMonster(player, data)
    KsFunShowTip(player, STRINGS.KSFUN_TASK_PUNISH_MONSTER)
    for i,v in ipairs(data.monsters) do
        KsFunSpawnHostileMonster(player, v, 1)
    end
end



local function punishNegaPower(player, data)
    local system = player.components.ksfun_power_system
    if system and data.name then
        system:AddPower(data.name)
    end
end




local function onPunishFunc(inst, player, taskdata)
    local punish = taskdata.punish
    if punish and punish.data then
        if punish.type == TYPES.POWER_LV_LOSE then
            losePowerProperty(player, true, punish.data)
        elseif punish.type == TYPES.POWER_EXP_LOSE then
            losePowerProperty(player, false, punish.data)
        elseif punish.type == TYPES.MONSTER then
            punishMonster(player, punish.data)
        elseif punish.type == TYPES.NEGA_POWER then
            punishNegaPower(player, punish.data)
        end
    else
        KsFunShowTip(player, STRINGS.KSFUN_TASK_PUNISH_NONE)
    end
end


local PUNISH = {}

PUNISH.onLoseFunc = onPunishFunc


return PUNISH