--- 不需要format的属性描述可以使用这个
local NAMES = KSFUN_TUNING.ITEM_POWER_NAMES

local function getPowerDesc(inst)
    local extra = KsFunGetPowerDescExtra(inst.prefab)
    return KsFunGetPowerDesc(inst, extra)
end


local function onForgSuccess(inst, data)
    local doername  = data.doer.name
    local item      = KsFunGetPrefabName(data.item.prefab)
    local powername = KsFunGetPrefabName(inst.prefab)
    local msg = string.format(STRINGS.KSFUN_FORG_SUCCESS_NOTICE, doername, item, powername)
    KsFunShowNotice(msg)
end



------ 吸血属性 ----------------------------------------------------------------------------------------
local lifestealmax = 5

local lifesteal = {
    onattach = function(inst)
        inst.components.ksfun_level:SetMax(lifestealmax)
    end,
    ondesc = getPowerDesc,
    forgable = {
        items     = {["mosquitosack"] = 2},
        onsuccess = onForgSuccess,
    },
}



------- 溅射伤害 ----------------------------------------------------------------------------------------
local aoemax = 10

local function onGetAoeDescFunc( inst, target, name )
    local multi,area = KsFunGetAoeProperty(inst)
    local desc = string.format(STRINGS.KSFUN_POWER_DESC[string.upper(inst.prefab)], tostring(area), (multi*100).."%")
    return KsFunGetPowerDesc(inst, desc)
end

local aoe = {
    onattach = function(inst)
        inst.components.ksfun_level:SetMax(aoemax)
    end,
    ondesc   = onGetAoeDescFunc,
    forgable = {
        onsuccess = onForgSuccess,
        items     = {["minotaurhorn"] = 5}, --犀牛角
    }
}



----- 挖矿 ----------------------------------------------------------------------------------------
local minemax = 10
local function updateMineStatus(inst)
    local lv = inst.components.ksfun_level:GetLevel()
    local m = math.max(minemax - lv, 1)
    inst.target.components.finiteuses:SetConsumption(ACTIONS.MINE, math.max(1, lv))
    inst.target.components.tool:SetAction(ACTIONS.MINE, minemax/m)
end

local mine = {
    onattach = function(inst, target)
        if target.components.tool == nil then target:AddComponent("tool") end
        inst.components.ksfun_level:SetMax(minemax)
        updateMineStatus(inst)  
    end,
    ondesc = getPowerDesc,
    onstatechange = updateMineStatus,
    -- 使用大理石或者硝石进行升级
    forgable = {
        items = { ["marble"] = 1, ["nitre"]  = 1,},
        onsuccess = onForgSuccess,
    }
}



----- 伐木 ----------------------------------------------------------------------------------------
local chopmax = 15
local function updateChopStatus(inst, l, n)
    local lv = inst.components.ksfun_level:GetLevel()
    local m = math.max(chopmax - lv, 1)
    inst.target.components.finiteuses:SetConsumption(ACTIONS.CHOP, math.max(1, lv))
    inst.target.components.tool:SetAction(ACTIONS.CHOP, chopmax/m)
end

local chop = {
    onattach = function(inst, target)
        if target.components.tool == nil then target:AddComponent("tool") end
        inst.components.ksfun_level:SetMax(chopmax)
        updateChopStatus(inst)  
    end,
    ondesc = getPowerDesc,
    onstatechange = updateChopStatus,
    -- 使用活木升级
    forgable = {
        items = { ["livinglog"] = 1,},
        onsuccess = onForgSuccess,
    }
}




----- 最大使用次数 ----------------------------------------------------------------------------------------
local function updateMaxusesStatus(inst)
    local data = inst.components.ksfun_power:GetData()
    local lv = inst.components.ksfun_level:GetLevel()

    -- 武器每次提升100的耐久
    local finiteuses = inst.target.components.finiteuses
    if finiteuses and data then
        local percent = finiteuses:GetPercent()
        finiteuses:SetMaxUses(data.maxuses + lv * 100)
        finiteuses:SetPercent(percent)
    end

    -- 护甲每次提升200的耐久
    local armor = inst.target.components.armor
    if armor and data then
        local percent = armor:GetPercent()
        armor.maxcondition = data.maxuses + lv * 200
        armor:SetPercent(percent)
    end
end

local maxuses = {
    onattach = function(inst, target)
        if target.components.armor then
            inst.components.ksfun_power:SetData({ maxuses = target.components.armor.maxcondition })
        end
        if target.components.finiteuses then
            inst.components.ksfun_power:SetData({ maxuses = target.components.finiteuses.total })
        end
        updateMaxusesStatus(inst)
    end,
    onstatechange = updateMaxusesStatus,
    ondesc = getPowerDesc,
    forgable = {
        items = {["dragon_scales"] = 10,}, -- 龙鳞提升耐久
        onsuccess = onForgSuccess,
    }
}




----- 武器基础伤害 ----------------------------------------------------------------------------------------
local function updateDamageStatus(inst, l, n)
    local power = inst.components.ksfun_power
    local data  = power:GetData()
    if data then
        local damage = data.damage or 0
        if inst.target and inst.target.components.weapon then
            local level = inst.components.ksfun_level:GetLevel()
            inst.target.components.weapon:SetDamage(damage + level)
        end
    end
end

local damage = {
    onattach = function(inst, target)
        if target.components.weapon then
            local d = target.components.weapon.damage
            inst.components.ksfun_power:SetData({ damage = d})
            updateDamageStatus(inst)
        end
    end,
    onstatechange = updateDamageStatus,
    ondesc = getPowerDesc,
    forgable = {
        onsuccess = onForgSuccess,
        -- 铥矿棒/狗牙/蜂刺升级
        items = {
            ["ruins_bat"]   = 100,
            ["tentaclespike"] = 10,
            ["houndstooth"] = 1,
            ["stinger"]     = 1,
        }
    }
}





----- 保暖/隔热属性 ----------------------------------------------------------------------------------------
local function updateInsulatorStatus(inst, l, n)
    local insulator = inst.target and inst.target.components.insulator or nil
    local lv    = inst.components.ksfun_level:GetLevel()
    local data  = inst.components.ksfun_power:GetData()
    if insulator and data then
        insulator:SetInsulation(data.insulation + lv)
        local type = inst.type or data.type or insulator.type
        if type == SEASONS.SUMMER then
            insulator:SetSummer()
        elseif type  == SEASONS.WINTER then
            insulator:SetWinter()
        end
    end
end


local function changeInsulatorType(inst, target)
    -- 月圆之夜给予一个彩虹宝石可以获得切换模式的能力
    local function testfunc(t, item, giver)
        if not inst.switch then
            return TheWorld.state.isfullmoon and item.prefab == "opalpreciousgem"
        else
            if inst.type == SEASONS.SUMMER then
                return item.prefab == "redgem"
            elseif inst.type == SEASONS.WINTER then
                return item.prefab == "bluegem"
            end
        end
        return false
    end

    local function acceptfunc(t, item, giver)
        if item.prefab == "opalpreciousgem" then
            inst.switch = true
        elseif item.prefab == "redgem" then
            inst.type = SEASONS.WINTER
            updateInsulatorStatus(inst)
        elseif item.prefab == "bluegem" then
            inst.type = SEASONS.SUMMER
            updateInsulatorStatus(inst)
        end
    end

    KsFunAddTrader(target, testfunc, acceptfunc)
end


local insulator = {
    onattach = function(inst, target)
        if target.components.insulator == nil then
            target:AddComponent("insulator")
        end
        local ins, t = target.components.insulator:GetInsulation()
        inst.components.ksfun_power:SetData({insulation = ins, type = t})
        if not inst.type then inst.type = t end
        changeInsulatorType(inst, target)
        updateInsulatorStatus(inst)
    end,
    ondesc = getPowerDesc,
    onstatechange = updateInsulatorStatus,
    onsave = function(inst, data)
        data.type = inst.type or nil
        data.switch = inst.switch or false
    end,
    onload = function(inst, data)
        inst.type = data.type or nil
        inst.switch = data.switch or false
    end,
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["trunk_winter"] = 100, -- 冬日象鼻
            ["trunk_summer"] = 80, -- 夏日象鼻
            ["silk"] = 2, -- 蜘蛛网
            ["beardhair"] = 5, -- 胡须
            ["goose_feather"] = 10 -- 鹅毛
        }
    },
}




----- 精神恢复 ----------------------------------------------------------------------------------------
local DAPPERNESS_RATIO = TUNING.DAPPERNESS_MED / 3
local function updateDappernessStatus(inst)
    local data = inst.components.ksfun_power:GetData()
    local equippable = inst.target and inst.target.components.equippable or nil
    local level = inst.components.ksfun_level
    if equippable and data then
        equippable.dapperness = data.dapperness + DAPPERNESS_RATIO * level:GetLevel()
    end
end

local dapperness = {
    onattach = function(inst, target)
        local equippable = target.components.equippable
        inst.components.ksfun_power:SetData({dapperness = equippable.dapperness})
        updateDappernessStatus(inst)
    end,
    onstatechange = updateDappernessStatus,
    ondesc = getPowerDesc,
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["spiderhat"] = 2, -- 蜘蛛帽
            ["walrushat"] = 20, -- 海象帽
            ["hivehat"]   = 50,
        }
    }
}





----- 防水 ----------------------------------------------------------------------------------------
local function updateWaterproofStatus(inst)
    local waterproofer = inst.target.components.waterproofer
    local data = inst.components.ksfun_power:GetData()
    local lv   = inst.components.ksfun_level:GetLevel()
    if waterproofer and data then
        waterproofer:SetEffectiveness(data.effectiveness + lv * 0.01)
    end
end

local waterproofer = {
    onattach = function(inst, target)
        -- 没有防水组件，添加
        if target.components.waterproofer == nil then
            target:AddComponent("waterproofer")
            target.components.waterproofer:SetEffectiveness(0)
        end
        local effect = target.components.waterproofer:GetEffectiveness()
        inst.components.ksfun_power:SetData({effectiveness = effect})
        -- 计算最大等级，眼球伞的最大等级就是0，也就是不需要升级的
        -- 眼球伞应该没办法添加防水属性，后面看下怎么加酸雨防护，暂时保留
        local max = math.floor((1 - effect) / 0.01)
        inst.components.ksfun_level:SetMax(max)
        updateWaterproofStatus(inst)
    end,
    onstatechange = updateWaterproofStatus,
    ondesc = getPowerDesc,
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["pigskin"] = 20,
            ["tentaclespots"] = 100
        }
    },
}




------ 移速 ----------------------------------------------------------------------------------------
local speedmax = 50
local function updateSpeedStatus(inst, l, n)
    local d = inst.components.ksfun_power:GetData()
    local speed = d and d.speed or 1
    local lv = inst.components.ksfun_level:GetLevel()
    if inst.target.components.equippable ~= nil then
        inst.target.components.equippable.walkspeedmult = speed + lv / 100
    end
end

local speed = {
    onattach = function(inst, target)
        local equippable = target.components.equippable
        inst.components.ksfun_power:SetData({speed = equippable:GetWalkSpeedMult()})
        inst.components.ksfun_level:SetMax(speedmax)
        updateSpeedStatus(inst)
    end,
    onstatechange = updateSpeedStatus,
    ondesc = getPowerDesc,
    -- 海象牙/步行手杖
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["walrus_tusk"] = 100,
            ["cane"] = 150,
        }
    }    
}





------ 护甲防护 ----------------------------------------------------------------------------------------
local function updateAbsorbStatus(inst)
    local armor = inst.target.components.armor
    local data  = inst.components.ksfun_power:GetData()
    local lv    = inst.components.ksfun_level:GetLevel()
    if armor and data then
        local p = data.absorb
        armor:SetAbsorption(p + lv * 0.01)
    end
end

local absorb = {
    onattach = function(inst, target)
        local absorb = target.components.armor.absorb_percent 
        inst.components.ksfun_power:SetData( {absorb = absorb} )
        local max = math.floor(math.max(0.9 - absorb, 0)/0.01 + 0.5)
        inst.components.ksfun_level:SetMax(max)
        updateAbsorbStatus(inst)
    end,
    onstatechange = updateAbsorbStatus,
    ondesc = getPowerDesc,
    forgable = {
        onsuccess = onForgSuccess,
        items = {
            ["steelwool"] = 10, -- 钢丝绒
        }
    }
}




local item = {
    
}


item.insulator    = { data = insulator }
item.waterproofer = { data = waterproofer }
item.dapperness   = { data = dapperness }

item.lifesteal    = { data = lifesteal }
item.aoe          = { data = aoe }
item.mine         = { data = mine }
item.chop         = { data = chop }
item.maxuses      = { data = maxuses }
item.damage       = { data = damage }

item.speed        = { data = speed }
item.absorb       = { data = absorb }


return item