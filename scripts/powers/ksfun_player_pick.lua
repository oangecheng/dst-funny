local NAME = KSFUN_TUNING.PLAYER_POWER_NAMES.PICK


-- 可多倍采集的物品定义
local PICKABLE_DEFS = {
    ["cutgrass"] = 10,         -- 草
    ["twigs"] = 10,            -- 树枝
    ["petals"] = 10,           -- 花瓣
    ["lightbulb"] = 10,        -- 荧光果

    ["wormlight_lesser"] = 20, -- 小型发光浆果
    ["cutreeds"] = 20,         -- 芦苇
    ["kelp"] = 20,             -- 海带
    ["carrot"] = 20,           -- 胡萝卜
    ["berries"] = 20,          -- 浆果
    ["berries_juicy"] = 20,    -- 多汁浆果
    ["red_cap"] = 20,          -- 红蘑菇
    ["green_cap"] = 20,
    ["blue_cap"] = 20,
    ["foliage"] = 20,         -- 蕨叶
    ["cactus_meat"] = 20,     -- 仙人掌肉
    ["cutlichen"] = 20,       -- 苔藓

    ["cactus_flower"] = 40,   -- 仙人掌花
    ["petals_evil"] = 40,     -- 恶魔花瓣
    ["wormlight"] = 40,       -- 发光浆果
}


local function canAddQuickPick(power)
    local lv =  power.components.ksfun_level:GetLevel()
    return lv >= (KSFUN_TUNING.DEBUG and 1 or 100) 
end



local function updatPowerStatus(inst)
    if canAddQuickPick(inst) and inst.target then
        if not inst.target:HasTag("fastpicker") then
            inst.target:AddTag("fastpicker")
        end
    end
end


local function onLvChangeFunc(inst, lv, notice)
    updatPowerStatus(inst)
end


--- 升级到下一级所需经验值
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (self.lv + 1) * 10
end


-- 设置最大等级
local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
    end
end


--- 计算倍率
--- 升级到30级大概需要采集400多个草
--- 0级的时候有 10% 概率双倍
local function calcPickMulti(power)
    local lv = math.floor(power.components.ksfun_level:GetLevel() / 30 )

    if lv < 1 then 
        return (math.random(100) < 10)  and 1 or 0
    end

    local r = math.random(1024) 

    --- lv=1时，50%双倍
    --- lv=2时，25%三倍采集，50%双倍
    --- 以此类推
    for i=lv, 1, -1 do
        local ratio = 1024 / (2^i)
        if r <= ratio then
            return i 
        end
    end
    return 0
end


local function onPickSomeThing(player, data)
    local power = player.components.ksfun_power_system:GetPower(NAME)

    -- 每次采摘尝试添加快速采集标签
    -- 这么做的原因是避免和勋章又冲突，勋章每次卸下的时候都会移除这个标签
    if canAddQuickPick(power) then
        if not player:HasTag("fastpicker") then
            player:AddTag("fastpicker")
        end
    end


    -- 处理特殊case，目前支持多汁浆果
    if data.object and data.prefab then
        local exp = PICKABLE_DEFS[data.prefab] or 0
        if exp > 0 then
            KsFunPowerGainExp(player, NAME, exp)
            local num = calcPickMulti(power)
            if num> 0 and data.object.components.lootdropper then
                local pt = data.object:GetPosition()
                pt.y = pt.y + (data.object.components.pickable.dropheight or 0)
                for i=1,num * data.num do
                    data.object.components.lootdropper:SpawnLootPrefab(data.prefab, pt)
                end
            end
        end
        return
    end

    -- 正常采集
    local loot = data and data.loot or nil
    if not (power and loot and data.object) then 
        return 
    end

    -- 农作物不支持多倍采集，由其他属性支持
    if data.object:HasTag("farm_plant") then
        return
    end

    --- 单个物品
    if loot.prefab ~= nil then
        local exp = PICKABLE_DEFS[loot.prefab] or 0

        if exp > 0 then
            KsFunPowerGainExp(player, NAME, exp)
            -- 根据等级计算可以多倍采集的倍率
            local num = calcPickMulti(power)
            if num > 0 then
                for i = 1, num do
                    local item = SpawnPrefab(loot.prefab)
                    player.components.inventory:GiveItem(item, nil, player:GetPosition())
                end       
            end
        end
    -- 多物品掉落
    elseif not IsTableEmpty(loot) then
        local items = {}
        for i, item in ipairs(loot) do
            local prefab = item.prefab
            local exp = PICKABLE_DEFS[prefab] or 0
            if exp > 0 then
                -- 命中白名单才有多倍
                table.insert(items, prefab)
                KsFunPowerGainExp(player, NAME, exp)
            end
        end

        -- 额外掉落物
        local extraloot = {}
        local lootdropper = data.object.components.lootdropper

        for _, prefab in ipairs(lootdropper:GenerateLoot()) do
            -- 白名单才能生成
            if table.contains(items, prefab) then
                -- 每种物品倍率单独计算
                local num = calcPickMulti(player)
                if  num > 0 then
                    for i = 1, num do
                        table.insert(extraloot, lootdropper:SpawnLootPrefab(prefab))
                    end
                end
            end
        end

        -- 给予玩家物品
        for _, item in ipairs(extraloot) do
            player.compowers.inventory:GiveItem(item, nil, player:GetPosition())
        end 
    end
end


local function onGetDescFunc(inst, target, name)
    local desc = "采集"
    if canAddQuickPick(inst) then
        desc = desc.."加速，"
    end
    desc = desc.."额外掉落"
    return KsFunGeneratePowerDesc(inst, desc)
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    target:ListenForEvent("picksomething", onPickSomeThing)
    target:ListenForEvent("ksfun_picksomething", onPickSomeThing)
    -- 最大等级10
    setUpMaxLv(inst, 300)
    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    target:RemoveEventCallback("picksomething", onPickSomeThing)
    target:RemoveEventCallback("ksfun_picksomething", onPickSomeThing)
    inst.target = nil
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
    onGetDescFunc= onGetDescFunc
}

local level = {
    nextLvExpFunc = nextLvExpFunc,
    onLvChangeFunc = onLvChangeFunc,
}


local pick = {}

pick.data = {
    power = power,
    level = level,
}


return pick