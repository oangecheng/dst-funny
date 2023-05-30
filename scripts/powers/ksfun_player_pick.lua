
local function updatPowerStatus(inst)

end


local function onLvChangeFunc(inst, lv, notice)
    updatPowerStatus(inst)
end


--- 升级到下一级所需经验值
--- 怪物的等级都是直接设定的，这里实际没啥用
local function nextLvExpFunc(inst, lv)
    return KSFUN_TUNING.DEBUG and 1 or (self.lv + 1) * 100
end


local function setUpMaxLv(inst, max)
    if inst.components.ksfun_level then
        inst.components.ksfun_level:SetMax(max)
    end
end




--- 绑定对象
local function onAttachFunc(inst, target, name)
    inst.target = target


    target:ListenForEvent("picksomething", function(self, data)
        if data and data.loot then
            local prefab = data.loot[1] and data.loot[1].prefab
            KsFunLog("picksomething 1", prefab)
        end

        if data and data.object then
            local t = data.object.prefab
            local p = data.loot and data.loot.prefab or nil

            local i = SpawnPrefab(p)
            target.components.inventory:GiveItem(i, nil, target:GetPosition())

            KsFunLog("picksomething 2", t, p)
        end

    end)




    -- 最大等级10
    setUpMaxLv(inst, 10)
    updatPowerStatus(inst)
end


--- 解绑对象
local function onDetachFunc(inst, target, name)
    inst.target = nil
end


local power = {
    onAttachFunc = onAttachFunc,
    onDetachFunc = onDetachFunc,
}

local level = {
    nextLvExpFunc = nextLvExpFunc,
    onLvChangeFunc = onLvChangeFunc,
}


local p = {}

p.data = {
    power = power,
    level = level,
}


return p