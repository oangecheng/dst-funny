--- 移速


local function updatPowerStatus(inst)
    if inst.target and inst.target.components.locomotor then
        local lv = inst.components.ksfun_level:GetLevel()
        local mult = 1 + lv / 100
        inst.target.components.locomotor:SetExternalSpeedMultiplier(inst, "ksfun_com_locomotor", mult)
    end
end


local function onLvChangeFunc(inst, lv, notice)
    updatPowerStatus(inst)
    -- 人物会提示一下等级
    if inst.target and inst.target:HasTag("player") and notice then
        if inst.components.talker then
            inst.components.talker:Say("移速等级提升！")
        end
    end
end


local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
    end
end


local function reset(inst, target)
    if target.components.locomotor then
        target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "ksfun_com_locomotor")
    end
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    -- 没有移速组件的属性失效
    if target.components.locomotor == nil then
        return
    end

    -- 最大等级
    -- 人物还可以通过物品加移速，所以怪物的上限更高
    local max = target:HasTag("player") and 25 or 50
    setUpMaxLv(inst, max)
    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    reset(target)
    inst.target = nil
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
}

local level = {
    onLvChangeFunc = onLvChangeFunc,
}


local p = {}

p.data = {
    power = power,
    level = level,
}


return p