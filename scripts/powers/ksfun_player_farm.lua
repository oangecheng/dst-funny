local MAX_LV = 100
local NAME   = KSFUN_TUNING.PLAYER_POWER_NAMES.FARM



--- 计算倍率
local function calcPickMulti(power)
    local lv = math.floor(power.components.ksfun_level:GetLevel() / 20 )

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


--- 计算多倍采集
local function onPickSomeThing(player, data)
    if data and data.loot then
        --采摘的是农场作物
        if data.object and data.object:HasTag("farm_plant") then
            local prefab = data.loot[1] and data.loot[1].prefab--获取采摘的预置物名
            -- 采摘巨大作物即可获得经验
            if prefab and string.find(prefab, "oversized") then
                KsFunPowerGainExp(player, NAME, 10)
            end

            local lootdropper = data.object.components.lootdropper
            local power = player.components.ksfun_power_system:GetPower(NAME)

            -- 额外掉落物
            if power and lootdropper then
                local extraloot = {}
                for _, prefab in ipairs(lootdropper:GenerateLoot()) do
                    -- 每种物品倍率单独计算
                    local num = calcPickMulti(power)
                    if num > 0 then
                        for i = 1, num do
                            table.insert(extraloot, lootdropper:SpawnLootPrefab(prefab))
                        end
                    end
                end
         
                 -- 给予玩家物品
                for _, item in ipairs(extraloot) do
                    player.components.inventory:GiveItem(item, nil, player:GetPosition())
                end 
            end
        end
    end
end


--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(MAX_LV)
    end
    target:ListenForEvent("picksomething", onPickSomeThing)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    target:RemoveEventCallback("picksomething", onPickSomeThing)
    inst.target = nil
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
}

local level = {}


local p = {}

p.data = {
    power = power,
    level = level,
}


return p